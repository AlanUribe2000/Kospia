import logging
import uuid
from contextlib import contextmanager

import psycopg2
from flask import Blueprint, jsonify, request
from werkzeug.exceptions import RequestEntityTooLarge

from authentication import require_kospia_jwt, require_role
from database.connection import get_connection


logger = logging.getLogger(__name__)

admin_catalog = Blueprint("admin_catalog", __name__)

DEFAULT_LIMIT = 25
MAX_LIMIT = 100
MAX_SEARCH_LENGTH = 100
MAX_ID_LENGTH = 100

# Solo estas claves del cliente llegan al ORDER BY; el SQL sale de estos mapas.
SORT_COLUMNS = {
    "common_name": "LOWER(common_name)",
    "scientific_name": "LOWER(scientific_name)",
}
SORT_DIRECTIONS = {"asc": "ASC", "desc": "DESC"}
VALID_STATUSES = {"all", "active", "inactive"}

SPECIES_DETAIL_FIELDS = (
    "id",
    "common_name",
    "scientific_name",
    "description",
    "image_url",
    "family",
    "habitat",
    "flower_color",
    "biological_form",
    "approximate_height",
    "leaf_length",
    "leaf_shape",
    "leaf_edge",
    "leaf_texture",
    "has_spines",
    "spine_type",
    "flower_grouping",
    "petal_count",
    "flower_size",
    "has_fruit",
    "fruit_shape",
    "fruit_color",
    "fruit_size",
    "observations",
    "is_active",
    "created_at",
    "updated_at",
)

IMAGE_FIELDS = (
    "id",
    "species_id",
    "file_name",
    "content_hash",
    "mime_type",
    "width",
    "height",
    "size_bytes",
    "sort_order",
    "is_primary",
    "status",
    "source_path",
    "created_at",
    "updated_at",
    "created_by",
)

MAX_BODY_BYTES = 64 * 1024

# Serializa las altas/ediciones de nombre científico hechas por esta API.
# No impide que otro escritor duplique el nombre: no hay UNIQUE en PostgreSQL.
SCIENTIFIC_NAME_LOCK_KEY = 861220008

REQUIRED_SPECIES_FIELDS = ("common_name", "scientific_name")
BOOLEAN_SPECIES_FIELDS = ("has_spines", "has_fruit")

# Columnas editables de texto y su longitud máxima. No incluye image_url:
# las fotografías se administrarán por separado.
TEXT_SPECIES_FIELDS = {
    "common_name": 200,
    "scientific_name": 200,
    "description": 5000,
    "family": 200,
    "habitat": 200,
    "flower_color": 100,
    "biological_form": 100,
    "approximate_height": 100,
    "leaf_length": 100,
    "leaf_shape": 100,
    "leaf_edge": 100,
    "leaf_texture": 100,
    "spine_type": 100,
    "flower_grouping": 100,
    "petal_count": 100,
    "flower_size": 100,
    "fruit_shape": 100,
    "fruit_color": 100,
    "fruit_size": 100,
    "observations": 2000,
}
EDITABLE_SPECIES_FIELDS = frozenset(TEXT_SPECIES_FIELDS) | frozenset(
    BOOLEAN_SPECIES_FIELDS
)
PROTECTED_SPECIES_FIELDS = frozenset(
    {"id", "created_at", "updated_at", "is_active"}
)


@contextmanager
def _read_cursor():
    # Conexión de solo lectura: cualquier escritura accidental falla en Postgres.
    conn = get_connection()

    try:
        conn.set_session(readonly=True)
        cursor = conn.cursor()

        try:
            yield cursor
        finally:
            cursor.close()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def _error(message, status):
    return jsonify({"error": message}), status


def _database_error(exc, message):
    logger.exception(message)
    logger.error(
        "Detalle psycopg2: pgcode=%s",
        getattr(exc, "pgcode", None),
    )

    return _error(message, 500)


def _iso(value):
    return value.isoformat() if value is not None else None


def _text_or_none(value):
    return str(value) if value is not None else None


def _parse_int_param(name, default, minimum, maximum=None):
    raw = request.args.get(name)

    if raw is None or raw == "":
        return default, None

    try:
        value = int(raw)
    except ValueError:
        return None, f"El parámetro {name} debe ser un número entero"

    if value < minimum or (maximum is not None and value > maximum):
        if maximum is None:
            return None, f"El parámetro {name} debe ser mayor o igual a {minimum}"

        return None, (
            f"El parámetro {name} debe estar entre {minimum} y {maximum}"
        )

    return value, None


def _escape_like(term):
    # '!' es el carácter de escape declarado en el SQL (ESCAPE '!').
    return (
        term.replace("!", "!!")
        .replace("%", "!%")
        .replace("_", "!_")
    )


def _valid_species_id(species_id):
    return (
        isinstance(species_id, str)
        and species_id.strip() != ""
        and len(species_id) <= MAX_ID_LENGTH
    )


def _species_summary(row):
    return {
        "id": row[0],
        "common_name": row[1],
        "scientific_name": row[2],
        "family": row[3],
        "is_active": row[4],
        "created_at": _iso(row[5]),
        "updated_at": _iso(row[6]),
    }


def _species_detail(row):
    species = {}

    for field, value in zip(SPECIES_DETAIL_FIELDS, row):
        if field in ("created_at", "updated_at"):
            species[field] = _iso(value)
        else:
            species[field] = value

    return species


def _image_payload(row):
    image = {}

    for field, value in zip(IMAGE_FIELDS, row):
        if field in ("created_at", "updated_at"):
            image[field] = _iso(value)
        elif field == "created_by":
            image[field] = _text_or_none(value)
        else:
            image[field] = value

    return image


@admin_catalog.route("/admin/questions", methods=["GET"])
@require_kospia_jwt
@require_role("admin")
def list_admin_questions():
    try:
        with _read_cursor() as cursor:
            cursor.execute(
                """
                SELECT q.id, q.question_text, q.is_active,
                       o.id, o.option_text
                FROM public.questions q
                LEFT JOIN public.question_options o ON o.question_id = q.id
                ORDER BY q.order_index ASC, q.id ASC,
                         o.order_index ASC, o.id ASC;
                """
            )
            rows = cursor.fetchall()

        questions = []
        for question_id, question_text, active, option_id, option_text in rows:
            if not questions or questions[-1]["id"] != question_id:
                questions.append({
                    "id": question_id,
                    "question_text": question_text,
                    "is_active": active,
                    "options": [],
                })
            if option_id is not None:
                questions[-1]["options"].append({
                    "id": option_id,
                    "option_text": option_text,
                })
        return jsonify({"questions": questions}), 200
    except psycopg2.Error as exc:
        return _database_error(exc, "No se pudieron obtener las preguntas")


@admin_catalog.route("/admin/species", methods=["GET"])
@require_kospia_jwt
@require_role("admin")
def list_admin_species():
    status = request.args.get("status", "all")

    if status not in VALID_STATUSES:
        return jsonify({
            "error": "El parámetro status no es válido",
            "allowed": sorted(VALID_STATUSES),
        }), 400

    sort = request.args.get("sort", "common_name")

    if sort not in SORT_COLUMNS:
        return jsonify({
            "error": "El parámetro sort no es válido",
            "allowed": sorted(SORT_COLUMNS),
        }), 400

    order = request.args.get("order", "asc").lower()

    if order not in SORT_DIRECTIONS:
        return jsonify({
            "error": "El parámetro order no es válido",
            "allowed": sorted(SORT_DIRECTIONS),
        }), 400

    search = request.args.get("q", "").strip()

    if len(search) > MAX_SEARCH_LENGTH:
        return _error(
            f"El parámetro q supera el máximo de {MAX_SEARCH_LENGTH} caracteres",
            400,
        )

    limit, limit_error = _parse_int_param("limit", DEFAULT_LIMIT, 1, MAX_LIMIT)

    if limit_error is not None:
        return _error(limit_error, 400)

    offset, offset_error = _parse_int_param("offset", 0, 0)

    if offset_error is not None:
        return _error(offset_error, 400)

    conditions = []
    params = []

    if search:
        pattern = f"%{_escape_like(search)}%"
        conditions.append(
            "(common_name ILIKE %s ESCAPE '!' "
            "OR scientific_name ILIKE %s ESCAPE '!')"
        )
        params.extend([pattern, pattern])

    if status == "active":
        conditions.append("is_active = TRUE")
    elif status == "inactive":
        conditions.append("is_active = FALSE")

    where_sql = f"WHERE {' AND '.join(conditions)}" if conditions else ""
    order_sql = (
        f"ORDER BY {SORT_COLUMNS[sort]} {SORT_DIRECTIONS[order]}, id ASC"
    )

    try:
        with _read_cursor() as cursor:
            cursor.execute(
                f"SELECT COUNT(*) FROM public.species {where_sql};",
                params,
            )
            total = cursor.fetchone()[0]

            cursor.execute(
                f"""
                SELECT
                    id,
                    common_name,
                    scientific_name,
                    family,
                    is_active,
                    created_at,
                    updated_at
                FROM public.species
                {where_sql}
                {order_sql}
                LIMIT %s OFFSET %s;
                """,
                [*params, limit, offset],
            )
            rows = cursor.fetchall()

        return jsonify({
            "species": [_species_summary(row) for row in rows],
            "pagination": {
                "total": total,
                "limit": limit,
                "offset": offset,
            },
        }), 200

    except psycopg2.Error as exc:
        return _database_error(exc, "No se pudieron obtener las especies")


@admin_catalog.route("/admin/species/<string:species_id>", methods=["GET"])
@require_kospia_jwt
@require_role("admin")
def get_admin_species(species_id):
    if not _valid_species_id(species_id):
        return _error("El id de la especie no es válido", 400)

    try:
        with _read_cursor() as cursor:
            cursor.execute(
                f"""
                SELECT {", ".join(SPECIES_DETAIL_FIELDS)}
                FROM public.species
                WHERE id = %s
                LIMIT 1;
                """,
                (species_id,),
            )
            species_row = cursor.fetchone()

            if species_row is None:
                return _error("Especie no encontrada", 404)

            cursor.execute(
                """
                SELECT
                    st.id,
                    st.question_id,
                    q.question_text,
                    st.option_id,
                    o.option_text
                FROM public.species_traits st
                INNER JOIN public.questions q
                    ON q.id = st.question_id
                INNER JOIN public.question_options o
                    ON o.id = st.option_id
                WHERE st.species_id = %s
                ORDER BY q.order_index ASC, q.id ASC,
                         o.order_index ASC, o.id ASC, st.id ASC;
                """,
                (species_id,),
            )
            trait_rows = cursor.fetchall()

        species = _species_detail(species_row)
        species["traits"] = [
            {
                "id": row[0],
                "question_id": row[1],
                "question_text": row[2],
                "option_id": row[3],
                "option_text": row[4],
            }
            for row in trait_rows
        ]

        return jsonify({"species": species}), 200

    except psycopg2.Error as exc:
        return _database_error(exc, "No se pudo obtener la especie")


@admin_catalog.route(
    "/admin/species/<string:species_id>/images",
    methods=["GET"],
)
@require_kospia_jwt
@require_role("admin")
def list_admin_species_images(species_id):
    if not _valid_species_id(species_id):
        return _error("El id de la especie no es válido", 400)

    try:
        with _read_cursor() as cursor:
            cursor.execute(
                """
                SELECT 1
                FROM public.species
                WHERE id = %s
                LIMIT 1;
                """,
                (species_id,),
            )

            if cursor.fetchone() is None:
                return _error("Especie no encontrada", 404)

            cursor.execute(
                f"""
                SELECT {", ".join(IMAGE_FIELDS)}
                FROM public.species_images
                WHERE species_id = %s
                ORDER BY is_primary DESC, sort_order ASC,
                         created_at ASC, id ASC;
                """,
                (species_id,),
            )
            rows = cursor.fetchall()

        return jsonify({
            "images": [_image_payload(row) for row in rows],
        }), 200

    except psycopg2.Error as exc:
        return _database_error(
            exc, "No se pudieron obtener las fotografías de la especie"
        )


@contextmanager
def _write_transaction():
    # Transacción de escritura: el handler hace commit; todo lo demás se revierte.
    conn = get_connection()

    try:
        cursor = conn.cursor()

        try:
            yield conn, cursor
        finally:
            cursor.close()
    except Exception:
        conn.rollback()
        raise
    finally:
        try:
            # No-op tras un commit; libera bloqueos en retornos tempranos.
            conn.rollback()
        except psycopg2.Error:
            pass

        conn.close()


def _field_error(message, field=None, status=400):
    body = {"error": message}

    if field is not None:
        body["field"] = field

    return jsonify(body), status


def _read_json_body():
    request.max_content_length = MAX_BODY_BYTES

    try:
        data = request.get_json(silent=True)
    except RequestEntityTooLarge:
        return None, _error(
            "El cuerpo supera el tamaño máximo permitido", 413
        )

    if not isinstance(data, dict):
        return None, _error("El cuerpo debe ser un JSON válido", 400)

    return data, None


def _validate_species_payload(data, creating):
    # Devuelve (campos_limpios, None) o (None, respuesta_de_error).
    if not data:
        return None, _error("El cuerpo no puede estar vacío", 400)

    protected = sorted(key for key in data if key in PROTECTED_SPECIES_FIELDS)

    if protected:
        return None, (jsonify({
            "error": "Estos campos no se pueden enviar",
            "fields": protected,
        }), 400)

    unknown = sorted(
        key for key in data if key not in EDITABLE_SPECIES_FIELDS
    )

    if unknown:
        return None, (jsonify({
            "error": "Hay campos desconocidos",
            "fields": [key[:50] for key in unknown[:20]],
        }), 400)

    clean = {}

    for key in sorted(data):
        value = data[key]

        if key in BOOLEAN_SPECIES_FIELDS:
            if not isinstance(value, bool):
                return None, _field_error(
                    f"{key} debe ser true o false", key
                )

            clean[key] = value
            continue

        if value is None:
            if key in REQUIRED_SPECIES_FIELDS:
                return None, _field_error(f"{key} no puede ser nulo", key)

            clean[key] = None
            continue

        if not isinstance(value, str):
            return None, _field_error(f"{key} debe ser un texto", key)

        text = value.strip()

        if "\x00" in text:
            return None, _field_error(
                f"{key} contiene caracteres no permitidos", key
            )

        if key in REQUIRED_SPECIES_FIELDS and not text:
            return None, _field_error(f"{key} no puede estar vacío", key)

        if len(text) > TEXT_SPECIES_FIELDS[key]:
            return None, _field_error(
                f"{key} supera el máximo de {TEXT_SPECIES_FIELDS[key]} caracteres",
                key,
            )

        clean[key] = text or None

    if creating:
        for key in REQUIRED_SPECIES_FIELDS:
            if key not in clean:
                return None, _field_error(f"{key} es obligatorio", key)

    return clean, None


def _scientific_name_exists(cursor, scientific_name, exclude_id=None):
    sql = (
        "SELECT id FROM public.species "
        "WHERE LOWER(BTRIM(scientific_name)) = LOWER(BTRIM(%s))"
    )
    params = [scientific_name]

    if exclude_id is not None:
        sql += " AND id <> %s"
        params.append(exclude_id)

    cursor.execute(sql + " LIMIT 1;", params)

    return cursor.fetchone() is not None


def _duplicate_name_response():
    return _field_error(
        "Ya existe una especie con ese nombre científico",
        "scientific_name",
        409,
    )


def _fetch_species_traits(cursor, species_id):
    cursor.execute(
        """
        SELECT
            st.id,
            st.question_id,
            q.question_text,
            st.option_id,
            o.option_text
        FROM public.species_traits st
        INNER JOIN public.questions q
            ON q.id = st.question_id
        INNER JOIN public.question_options o
            ON o.id = st.option_id
        WHERE st.species_id = %s
        ORDER BY q.order_index ASC, q.id ASC,
                 o.order_index ASC, o.id ASC, st.id ASC;
        """,
        (species_id,),
    )

    return [
        {
            "id": row[0],
            "question_id": row[1],
            "question_text": row[2],
            "option_id": row[3],
            "option_text": row[4],
        }
        for row in cursor.fetchall()
    ]


@admin_catalog.route("/admin/species", methods=["POST"])
@require_kospia_jwt
@require_role("admin")
def create_admin_species():
    data, error = _read_json_body()

    if error is not None:
        return error

    clean, error = _validate_species_payload(data, creating=True)

    if error is not None:
        return error

    for key in BOOLEAN_SPECIES_FIELDS:
        clean.setdefault(key, False)

    species_id = f"sp-{uuid.uuid4()}"
    columns = ["id", *clean, "is_active"]
    placeholders = ["%s"] * (len(columns) - 1) + ["FALSE"]
    insert_sql = (
        f"INSERT INTO public.species ({', '.join(columns)}) "
        f"VALUES ({', '.join(placeholders)}) "
        f"RETURNING {', '.join(SPECIES_DETAIL_FIELDS)};"
    )

    try:
        with _write_transaction() as (conn, cursor):
            cursor.execute(
                "SELECT pg_advisory_xact_lock(%s);",
                (SCIENTIFIC_NAME_LOCK_KEY,),
            )

            if _scientific_name_exists(cursor, clean["scientific_name"]):
                return _duplicate_name_response()

            cursor.execute(insert_sql, [species_id, *clean.values()])
            row = cursor.fetchone()
            conn.commit()

        species = _species_detail(row)
        species["traits"] = []
        response = jsonify({"species": species})
        response.status_code = 201
        response.headers["Location"] = f"/admin/species/{species_id}"

        return response

    except psycopg2.Error as exc:
        return _database_error(exc, "No se pudo crear la especie")


@admin_catalog.route("/admin/species/<string:species_id>", methods=["PATCH"])
@require_kospia_jwt
@require_role("admin")
def update_admin_species(species_id):
    if not _valid_species_id(species_id):
        return _error("El id de la especie no es válido", 400)

    data, error = _read_json_body()

    if error is not None:
        return error

    clean, error = _validate_species_payload(data, creating=False)

    if error is not None:
        return error

    set_sql = ", ".join(f"{column} = %s" for column in clean)
    update_sql = (
        f"UPDATE public.species SET {set_sql} WHERE id = %s "
        f"RETURNING {', '.join(SPECIES_DETAIL_FIELDS)};"
    )

    try:
        with _write_transaction() as (conn, cursor):
            if "scientific_name" in clean:
                cursor.execute(
                    "SELECT pg_advisory_xact_lock(%s);",
                    (SCIENTIFIC_NAME_LOCK_KEY,),
                )

            cursor.execute(
                "SELECT id FROM public.species WHERE id = %s FOR UPDATE;",
                (species_id,),
            )

            if cursor.fetchone() is None:
                return _error("Especie no encontrada", 404)

            if "scientific_name" in clean and _scientific_name_exists(
                cursor, clean["scientific_name"], exclude_id=species_id
            ):
                return _duplicate_name_response()

            cursor.execute(update_sql, [*clean.values(), species_id])
            row = cursor.fetchone()
            species = _species_detail(row)
            species["traits"] = _fetch_species_traits(cursor, species_id)
            conn.commit()

        return jsonify({"species": species}), 200

    except psycopg2.Error as exc:
        return _database_error(exc, "No se pudo actualizar la especie")


MAX_TRAITS_PER_REQUEST = 200
MAX_TRAIT_ID_LENGTH = 100


def _validate_traits_payload(data):
    # Devuelve (pares [(question_id, option_id)] en orden de llegada, None)
    # o (None, respuesta_de_error).
    extra = sorted(key for key in data if key != "traits")

    if extra:
        return None, (jsonify({
            "error": "Hay campos desconocidos",
            "fields": [key[:50] for key in extra[:20]],
        }), 400)

    if "traits" not in data:
        return None, _field_error("traits es obligatorio", "traits")

    traits = data["traits"]

    if not isinstance(traits, list):
        return None, _field_error("traits debe ser un arreglo", "traits")

    if len(traits) > MAX_TRAITS_PER_REQUEST:
        return None, _field_error(
            f"traits supera el máximo de {MAX_TRAITS_PER_REQUEST} elementos",
            "traits",
        )

    pairs = []
    seen = set()

    for index, item in enumerate(traits):
        label = f"traits[{index}]"

        if not isinstance(item, dict):
            return None, _field_error(f"{label} debe ser un objeto", label)

        unknown = sorted(
            key for key in item if key not in ("question_id", "option_id")
        )

        if unknown:
            return None, _field_error(
                f"{label} tiene campos desconocidos", label
            )

        values = []

        for key in ("question_id", "option_id"):
            value = item.get(key)
            field = f"{label}.{key}"

            if not isinstance(value, str):
                return None, _field_error(f"{field} debe ser un texto", field)

            value = value.strip()

            if not value or len(value) > MAX_TRAIT_ID_LENGTH or "\x00" in value:
                return None, _field_error(f"{field} no es válido", field)

            values.append(value)

        pair = (values[0], values[1])

        if pair in seen:
            return None, _field_error(f"{label} está duplicado", label)

        seen.add(pair)
        pairs.append(pair)

    return pairs, None


def _check_trait_references(cursor, pairs):
    # Devuelve una respuesta de error si alguna referencia es inválida.
    question_ids = sorted({question_id for question_id, _ in pairs})
    option_ids = sorted({option_id for _, option_id in pairs})

    cursor.execute(
        "SELECT id, is_active FROM public.questions WHERE id = ANY(%s);",
        (question_ids,),
    )
    questions = {row[0]: row[1] for row in cursor.fetchall()}

    cursor.execute(
        "SELECT id, question_id FROM public.question_options "
        "WHERE id = ANY(%s) ORDER BY id FOR KEY SHARE;",
        (option_ids,),
    )
    options = {row[0]: row[1] for row in cursor.fetchall()}

    for index, (question_id, option_id) in enumerate(pairs):
        label = f"traits[{index}]"

        if question_id not in questions:
            return _field_error(
                "La pregunta no existe", f"{label}.question_id"
            )

        if questions[question_id] is not True:
            return _field_error(
                "La pregunta no está activa", f"{label}.question_id"
            )

        if option_id not in options:
            return _field_error("La opción no existe", f"{label}.option_id")

        if options[option_id] != question_id:
            return _field_error(
                "La opción no pertenece a la pregunta indicada",
                f"{label}.option_id",
            )

    return None


@admin_catalog.route(
    "/admin/species/<string:species_id>/traits",
    methods=["PUT"],
)
@require_kospia_jwt
@require_role("admin")
def replace_admin_species_traits(species_id):
    # Reemplaza el conjunto de rasgos aplicando solo la diferencia: conserva
    # las filas (y sus ids) que no cambian. Una pregunta puede tener varias
    # opciones por especie (q-008, q-014 y q-015 ya lo hacen en los datos).
    # Si el conjunto cambia, se toca species.updated_at para que los clientes
    # detecten la modificación; si no cambia, la fecha no se altera.
    if not _valid_species_id(species_id):
        return _error("El id de la especie no es válido", 400)

    data, error = _read_json_body()

    if error is not None:
        return error

    pairs, error = _validate_traits_payload(data)

    if error is not None:
        return error

    try:
        with _write_transaction() as (conn, cursor):
            cursor.execute(
                "SELECT id, updated_at FROM public.species "
                "WHERE id = %s FOR UPDATE;",
                (species_id,),
            )
            species_row = cursor.fetchone()

            if species_row is None:
                return _error("Especie no encontrada", 404)

            updated_at = species_row[1]

            if pairs:
                reference_error = _check_trait_references(cursor, pairs)

                if reference_error is not None:
                    return reference_error

            cursor.execute(
                "SELECT id, question_id, option_id "
                "FROM public.species_traits WHERE species_id = %s "
                "ORDER BY id ASC;",
                (species_id,),
            )

            requested = set(pairs)
            kept_pairs = set()
            delete_ids = []

            for trait_id, question_id, option_id in cursor.fetchall():
                pair = (question_id, option_id)

                if pair in requested and pair not in kept_pairs:
                    kept_pairs.add(pair)
                else:
                    delete_ids.append(trait_id)

            new_pairs = [pair for pair in pairs if pair not in kept_pairs]

            if delete_ids:
                cursor.execute(
                    "DELETE FROM public.species_traits "
                    "WHERE species_id = %s AND id = ANY(%s);",
                    (species_id, delete_ids),
                )

            if new_pairs:
                values_sql = ", ".join(["(%s, %s, %s, %s)"] * len(new_pairs))
                params = []

                for question_id, option_id in new_pairs:
                    params.extend(
                        [str(uuid.uuid4()), species_id, question_id, option_id]
                    )

                cursor.execute(
                    "INSERT INTO public.species_traits "
                    "(id, species_id, question_id, option_id) "
                    f"VALUES {values_sql};",
                    params,
                )

            if delete_ids or new_pairs:
                cursor.execute(
                    "UPDATE public.species SET updated_at = NOW() "
                    "WHERE id = %s RETURNING updated_at;",
                    (species_id,),
                )
                updated_at = cursor.fetchone()[0]

            traits = _fetch_species_traits(cursor, species_id)
            conn.commit()

        return jsonify({
            "species": {
                "id": species_id,
                "updated_at": _iso(updated_at),
                "traits": traits,
            },
            "changes": {
                "added": len(new_pairs),
                "removed": len(delete_ids),
                "unchanged": len(kept_pairs),
            },
        }), 200

    except psycopg2.Error as exc:
        return _database_error(
            exc, "No se pudieron actualizar los rasgos de la especie"
        )