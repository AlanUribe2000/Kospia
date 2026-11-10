import logging
import os
import re
import uuid

import psycopg2
from flask import g, jsonify, request, send_file
from flask_smorest import Blueprint

from authentication import require_kospia_jwt, require_role
from database.connection import get_connection


logger = logging.getLogger(__name__)

help_cards = Blueprint("help_cards", __name__)


ALLOWED_EXTENSIONS = {
    "jpg",
    "jpeg",
    "png",
    "webp",
}
MAX_IMAGE_BYTES = 10 * 1024 * 1024


def _valid_image_id(image_id):
    return re.fullmatch(r"[A-Za-z0-9_-]{1,128}", image_id) is not None


def _matches_image_extension(data, extension):
    if extension in {"jpg", "jpeg"}:
        return data.startswith(b"\xff\xd8\xff")
    if extension == "png":
        return data.startswith(b"\x89PNG\r\n\x1a\n")
    return len(data) >= 12 and data[:4] == b"RIFF" and data[8:12] == b"WEBP"


# Carpeta donde se almacenan físicamente los iconos y fotos de galería de las
# opciones. Mismo mecanismo que routes/attachments.py pero en uploads/opciones/.
BASE_DIR = os.path.dirname(
    os.path.dirname(os.path.abspath(__file__))
)

UPLOAD_FOLDER = os.path.join(
    BASE_DIR,
    "uploads",
    "opciones",
)


def _ensure_upload_folder():
    """Crea la carpeta de uploads si todavía no existe."""
    os.makedirs(
        UPLOAD_FOLDER,
        exist_ok=True,
    )


def _get_path(image_id, extension):
    """Construye la ruta física del archivo uploads/opciones/<id>.<ext>."""
    extension = (extension or "").lstrip(".").lower()
    return os.path.join(
        UPLOAD_FOLDER,
        f"{image_id}.{extension}",
    )


def _log_psycopg_error(exc, message, *args):
    # Mismo patrón de logging detallado que professional.py.
    diag = getattr(exc, "diag", None)
    logger.exception(message, *args)
    logger.error(
        "Detalle psycopg2: pgcode=%s message_primary=%s constraint=%s "
        "pgerror=%s",
        getattr(exc, "pgcode", None),
        getattr(diag, "message_primary", None),
        getattr(diag, "constraint_name", None),
        getattr(exc, "pgerror", None),
    )


def _resolve_image_extension(image_id):
    """
    Resuelve la extensión guardada de una imagen de opción.

    Un `image_id` puede ser el icono de una opción
    (question_options.icon_attachment_id -> icon_extension) o una foto de
    galería (question_option_photos.id -> file_extension). Se consulta en ese
    orden. Devuelve la extensión o None si no existe fila para ese id.
    """
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT icon_extension
            FROM public.question_options
            WHERE icon_attachment_id = %s
            LIMIT 1;
            """,
            (image_id,),
        )
        row = cursor.fetchone()
        if row is not None:
            return row[0]

        cursor.execute(
            """
            SELECT file_extension
            FROM public.question_option_photos
            WHERE id = %s
            LIMIT 1;
            """,
            (image_id,),
        )
        row = cursor.fetchone()
        if row is not None:
            return row[0]

        return None
    finally:
        cursor.close()
        conn.close()


# ---------------------------------------------------------------------------
# Imágenes (icono + galería). Reutiliza el mecanismo de attachments.py.
# ---------------------------------------------------------------------------


@help_cards.route(
    "/option-images/<string:image_id>",
    methods=["PUT"],
)
@help_cards.doc(
    summary="Subir la imagen de una opción (icono o foto de galería)",
    description=(
        "Carga los bytes de la imagen para el `image_id` indicado en la ruta. "
        "Requiere rol professional o admin. Envíe el contenido binario "
        "directamente en el "
        "cuerpo. El parámetro `extension` es opcional (por defecto `jpg`) y "
        "solo admite `jpg`, `jpeg`, `png` o `webp`. Máximo 10 MiB; la firma "
        "debe corresponder a la extensión. Si el archivo ya existe, responde "
        "con 409 y no lo sobrescribe."
    ),
    parameters=[
        {
            "name": "image_id",
            "in": "path",
            "required": True,
            "schema": {"type": "string"},
        },
        {
            "name": "extension",
            "in": "query",
            "required": False,
            "schema": {
                "type": "string",
                "enum": ["jpg", "jpeg", "png", "webp"],
                "default": "jpg",
            },
        },
    ],
    requestBody={
        "required": True,
        "content": {
            "application/octet-stream": {
                "schema": {"type": "string", "format": "binary"},
            },
        },
    },
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("professional", "admin")
def upload_option_image(image_id):
    if not _valid_image_id(image_id):
        return jsonify({"error": "Id de imagen no válido"}), 400
    extension = request.args.get("extension", "jpg")
    extension = extension.lower().lstrip(".")

    if extension not in ALLOWED_EXTENSIONS:
        return jsonify({
            "error": "Extensión de archivo no permitida"
        }), 400

    if request.content_length is not None and request.content_length > MAX_IMAGE_BYTES:
        return jsonify({"error": "La imagen excede el tamaño permitido"}), 413
    data = request.stream.read(MAX_IMAGE_BYTES + 1)
    if len(data) > MAX_IMAGE_BYTES:
        return jsonify({"error": "La imagen excede el tamaño permitido"}), 413
    if not _matches_image_extension(data, extension):
        return jsonify({"error": "El contenido no coincide con la extensión"}), 400

    _ensure_upload_folder()

    file_path = _get_path(image_id, extension)

    try:
        with open(file_path, "xb") as file:
            file.write(data)

        return jsonify({
            "message": "Archivo guardado correctamente",
            "id": image_id,
            "extension": extension,
        }), 200

    except FileExistsError:
        return jsonify({"error": "El archivo de imagen ya existe"}), 409
    except Exception as error:
        return jsonify({
            "error": "No se pudo guardar el archivo",
            "details": str(error),
        }), 500


@help_cards.route(
    "/option-images/<string:image_id>",
    methods=["GET"],
)
@help_cards.doc(
    summary="Descargar la imagen de una opción",
    description=(
        "Devuelve el archivo binario asociado al `image_id`. Requiere un token "
        "Kospia (cualquier usuario autenticado). La extensión se resuelve desde "
        "la fila correspondiente (icono o foto de galería)."
    ),
    parameters=[
        {
            "name": "image_id",
            "in": "path",
            "required": True,
            "schema": {"type": "string"},
        },
    ],
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
def download_option_image(image_id):
    if not _valid_image_id(image_id):
        return jsonify({"error": "Id de imagen no válido"}), 400
    extension = _resolve_image_extension(image_id)

    if extension is None:
        return jsonify({
            "error": "La imagen no existe"
        }), 404

    extension = (extension or "").lower().lstrip(".")

    if extension not in ALLOWED_EXTENSIONS:
        return jsonify({
            "error": "Extensión de archivo no permitida"
        }), 400

    file_path = _get_path(image_id, extension)

    if not os.path.exists(file_path):
        return jsonify({
            "error": "Archivo no encontrado"
        }), 404

    return send_file(file_path)


@help_cards.route(
    "/option-images/<string:image_id>",
    methods=["DELETE"],
)
@help_cards.doc(
    summary="Eliminar el archivo físico de una imagen de opción",
    description=(
        "Elimina del almacenamiento el archivo asociado al `image_id`. "
        "Requiere rol professional o admin. Operación idempotente: si el "
        "archivo ya no existe "
        "responde igualmente con `200`. El parámetro `extension` es opcional "
        "(por defecto `jpg`)."
    ),
    parameters=[
        {
            "name": "image_id",
            "in": "path",
            "required": True,
            "schema": {"type": "string"},
        },
        {
            "name": "extension",
            "in": "query",
            "required": False,
            "schema": {"type": "string", "default": "jpg"},
        },
    ],
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("professional", "admin")
def delete_option_image(image_id):
    if not _valid_image_id(image_id):
        return jsonify({"error": "Id de imagen no válido"}), 400
    extension = request.args.get("extension")

    # Si no nos pasan extensión, intentamos resolverla desde la base.
    if not extension:
        extension = _resolve_image_extension(image_id)

    extension = (extension or "jpg").lower().lstrip(".")
    if extension not in ALLOWED_EXTENSIONS:
        return jsonify({"error": "Extensión de archivo no permitida"}), 400

    file_path = _get_path(image_id, extension)

    if not os.path.exists(file_path):
        return jsonify({
            "message": "El archivo ya no existe"
        }), 200

    try:
        os.remove(file_path)
        return jsonify({
            "message": "Archivo eliminado correctamente"
        }), 200
    except Exception as error:
        return jsonify({
            "error": "No se pudo eliminar el archivo",
            "details": str(error),
        }), 500


# ---------------------------------------------------------------------------
# Catálogo: preguntas + opciones + galería (lectura autenticada, escritura admin)
# ---------------------------------------------------------------------------


def _option_photos(cursor, option_id):
    cursor.execute(
        """
        SELECT id, order_index, file_extension, created_at
        FROM public.question_option_photos
        WHERE option_id = %s
        ORDER BY order_index ASC, id ASC;
        """,
        (option_id,),
    )
    return [
        {
            "id": row[0],
            "order_index": row[1],
            "file_extension": row[2],
            "created_at": row[3].isoformat() if row[3] else None,
        }
        for row in cursor.fetchall()
    ]


@help_cards.route("/questions", methods=["GET"])
@help_cards.doc(
    summary="Listar las preguntas del cuestionario",
    description="Lista las preguntas activas ordenadas. Requiere token Kospia.",
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
def list_questions():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT id, question_text, field_name, required_part,
                   order_index, is_active
            FROM public.questions
            ORDER BY order_index ASC, id ASC;
            """
        )
        rows = cursor.fetchall()

        return jsonify({
            "questions": [
                {
                    "id": row[0],
                    "question_text": row[1],
                    "field_name": row[2],
                    "required_part": row[3],
                    "order_index": row[4],
                    "is_active": row[5],
                }
                for row in rows
            ]
        }), 200

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(exc, "Error al listar preguntas")
        return jsonify({
            "error": "No se pudieron obtener las preguntas"
        }), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/questions/<string:question_id>/options",
    methods=["GET"],
)
@help_cards.doc(
    summary="Listar opciones de una pregunta",
    description=(
        "Devuelve las opciones de la pregunta ordenadas, con su descripción, "
        "icono y sus fotos de galería ordenadas. Requiere token Kospia."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
def list_options(question_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT id, question_id, option_text, value_key, order_index,
                   description, icon_attachment_id, icon_extension
            FROM public.question_options
            WHERE question_id = %s
            ORDER BY order_index ASC, id ASC;
            """,
            (question_id,),
        )
        rows = cursor.fetchall()

        options = []
        for row in rows:
            options.append({
                "id": row[0],
                "question_id": row[1],
                "option_text": row[2],
                "value_key": row[3],
                "order_index": row[4],
                "description": row[5],
                "icon_attachment_id": row[6],
                "icon_extension": row[7],
                "photos": _option_photos(cursor, row[0]),
            })

        return jsonify({"options": options}), 200

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(
            exc, "Error al listar opciones (question=%s)", question_id
        )
        return jsonify({
            "error": "No se pudieron obtener las opciones"
        }), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/questions/<string:question_id>/options",
    methods=["POST"],
)
@help_cards.doc(
    summary="Crear una opción",
    description=(
        "Crea una opción para la pregunta. Body JSON: option_text (obligatorio),"
        " value_key, description, order_index. Requiere rol admin."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("admin")
def create_option(question_id):
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify({"error": "El cuerpo debe ser un JSON válido"}), 400

    option_text = data.get("option_text")
    if not isinstance(option_text, str) or not option_text.strip():
        return jsonify({"error": "option_text es obligatorio"}), 400

    value_key = data.get("value_key")
    value_key = value_key.strip() if isinstance(value_key, str) else ""

    description = data.get("description")
    if description is not None and not isinstance(description, str):
        return jsonify({"error": "description debe ser texto"}), 400

    order_index = data.get("order_index")
    if order_index is None:
        order_index = 0
    if not isinstance(order_index, int):
        return jsonify({"error": "order_index debe ser un entero"}), 400

    option_id = str(uuid.uuid4())

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT 1 FROM public.questions WHERE id = %s LIMIT 1;
            """,
            (question_id,),
        )
        if cursor.fetchone() is None:
            return jsonify({"error": "La pregunta no existe"}), 404

        cursor.execute(
            """
            INSERT INTO public.question_options
                (id, question_id, option_text, value_key, order_index,
                 description)
            VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING id;
            """,
            (
                option_id,
                question_id,
                option_text.strip(),
                value_key,
                order_index,
                description,
            ),
        )
        conn.commit()

        return jsonify({
            "message": "Opción creada correctamente",
            "id": option_id,
        }), 201

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(
            exc, "Error al crear opción (question=%s)", question_id
        )
        return jsonify({"error": "No se pudo crear la opción"}), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/options/<string:option_id>",
    methods=["PUT"],
)
@help_cards.doc(
    summary="Editar una opción",
    description=(
        "Edita option_text / value_key / description de una opción. Requiere "
        "rol admin."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("admin")
def update_option(option_id):
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify({"error": "El cuerpo debe ser un JSON válido"}), 400

    option_text = data.get("option_text")
    if not isinstance(option_text, str) or not option_text.strip():
        return jsonify({"error": "option_text es obligatorio"}), 400

    value_key = data.get("value_key")
    value_key = value_key.strip() if isinstance(value_key, str) else ""

    description = data.get("description")
    if description is not None and not isinstance(description, str):
        return jsonify({"error": "description debe ser texto"}), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            UPDATE public.question_options
            SET option_text = %s,
                value_key = %s,
                description = %s
            WHERE id = %s
            RETURNING id;
            """,
            (option_text.strip(), value_key, description, option_id),
        )
        row = cursor.fetchone()

        if row is None:
            conn.rollback()
            return jsonify({"error": "La opción no existe"}), 404

        conn.commit()

        return jsonify({"message": "Opción actualizada correctamente"}), 200

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(exc, "Error al editar opción (option=%s)", option_id)
        return jsonify({"error": "No se pudo actualizar la opción"}), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route("/options/<string:option_id>/help", methods=["PATCH"])
@help_cards.doc(
    summary="Actualizar la descripción de ayuda de una opción",
    description="Recibe exactamente description (texto o null). Requiere rol professional o admin.",
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("professional", "admin")
def update_option_help(option_id):
    data = request.get_json(silent=True)
    if not isinstance(data, dict) or set(data) != {"description"}:
        return jsonify({"error": "El cuerpo debe contener solo description"}), 400
    description = data["description"]
    if description is not None and not isinstance(description, str):
        return jsonify({"error": "description debe ser texto o null"}), 400

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute(
            """
            UPDATE public.question_options SET description = %s
            WHERE id = %s RETURNING id;
            """,
            (description, option_id),
        )
        if cursor.fetchone() is None:
            conn.rollback()
            return jsonify({"error": "La opción no existe"}), 404
        conn.commit()
        return jsonify({"message": "Descripción actualizada correctamente"}), 200
    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(exc, "Error al editar ayuda (option=%s)", option_id)
        return jsonify({"error": "No se pudo actualizar la descripción"}), 500
    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/options/<string:option_id>",
    methods=["DELETE"],
)
@help_cards.doc(
    summary="Eliminar una opción",
    description=(
        "Elimina una opción (y en cascada sus fotos de galería). Requiere rol "
        "admin. Devuelve los ids/extensiones de las fotos "
        "borradas "
        "para que el cliente pueda limpiar los archivos físicos."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("admin")
def delete_option(option_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        # Recopilamos las fotos e icono para que el llamador borre los archivos.
        cursor.execute(
            """
            SELECT id, file_extension
            FROM public.question_option_photos
            WHERE option_id = %s;
            """,
            (option_id,),
        )
        photos = [
            {"id": row[0], "file_extension": row[1]}
            for row in cursor.fetchall()
        ]

        cursor.execute(
            """
            SELECT icon_attachment_id, icon_extension
            FROM public.question_options
            WHERE id = %s
            FOR UPDATE;
            """,
            (option_id,),
        )
        icon_row = cursor.fetchone()

        if icon_row is None:
            conn.rollback()
            return jsonify({"error": "La opción no existe"}), 404

        cursor.execute(
            "SELECT 1 FROM public.species_traits WHERE option_id = %s LIMIT 1;",
            (option_id,),
        )
        if cursor.fetchone() is not None:
            conn.rollback()
            return jsonify({"error": "La opción está referenciada por especies"}), 409

        cursor.execute(
            """
            DELETE FROM public.question_options WHERE id = %s;
            """,
            (option_id,),
        )
        conn.commit()

        return jsonify({
            "message": "Opción eliminada correctamente",
            "deleted_photos": photos,
            "icon_attachment_id": icon_row[0],
            "icon_extension": icon_row[1],
        }), 200

    except psycopg2.Error as exc:
        conn.rollback()
        if getattr(exc, "pgcode", None) == "23503":
            return jsonify({"error": "La opción está referenciada"}), 409
        _log_psycopg_error(
            exc, "Error al eliminar opción (option=%s)", option_id
        )
        return jsonify({"error": "No se pudo eliminar la opción"}), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/questions/<string:question_id>/options/reorder",
    methods=["PUT"],
)
@help_cards.doc(
    summary="Reordenar las opciones de una pregunta",
    description=(
        "Recibe {\"option_ids\": [...]} con los ids en el orden deseado y "
        "asigna order_index por posición. Requiere rol admin."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("admin")
def reorder_options(question_id):
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify({"error": "El cuerpo debe ser un JSON válido"}), 400

    option_ids = data.get("option_ids")
    if not isinstance(option_ids, list) or not all(
        isinstance(x, str) for x in option_ids
    ):
        return jsonify({
            "error": "option_ids debe ser una lista de ids (texto)"
        }), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        for index, option_id in enumerate(option_ids):
            cursor.execute(
                """
                UPDATE public.question_options
                SET order_index = %s
                WHERE id = %s AND question_id = %s;
                """,
                (index, option_id, question_id),
            )
        conn.commit()

        return jsonify({"message": "Opciones reordenadas correctamente"}), 200

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(
            exc, "Error al reordenar opciones (question=%s)", question_id
        )
        return jsonify({"error": "No se pudieron reordenar las opciones"}), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/options/<string:option_id>/icon",
    methods=["PUT"],
)
@help_cards.doc(
    summary="Asignar el icono de una opción",
    description=(
        "Asocia a la opción un icono ya subido vía PUT /option-images/<id>. "
        "Body JSON: icon_attachment_id (obligatorio), icon_extension "
        "(obligatorio). Requiere rol professional o admin."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("professional", "admin")
def set_option_icon(option_id):
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify({"error": "El cuerpo debe ser un JSON válido"}), 400

    icon_attachment_id = data.get("icon_attachment_id")
    if not isinstance(icon_attachment_id, str) or not icon_attachment_id.strip():
        return jsonify({"error": "icon_attachment_id es obligatorio"}), 400
    if not _valid_image_id(icon_attachment_id.strip()):
        return jsonify({"error": "Id de imagen no válido"}), 400

    icon_extension = data.get("icon_extension")
    if not isinstance(icon_extension, str) or not icon_extension.strip():
        return jsonify({"error": "icon_extension es obligatorio"}), 400

    icon_extension = icon_extension.lower().lstrip(".")
    if icon_extension not in ALLOWED_EXTENSIONS:
        return jsonify({"error": "Extensión de archivo no permitida"}), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            UPDATE public.question_options
            SET icon_attachment_id = %s,
                icon_extension = %s
            WHERE id = %s
            RETURNING id;
            """,
            (icon_attachment_id.strip(), icon_extension, option_id),
        )
        row = cursor.fetchone()

        if row is None:
            conn.rollback()
            return jsonify({"error": "La opción no existe"}), 404

        conn.commit()

        return jsonify({"message": "Icono asignado correctamente"}), 200

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(
            exc, "Error al asignar icono (option=%s)", option_id
        )
        return jsonify({"error": "No se pudo asignar el icono"}), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/options/<string:option_id>/icon",
    methods=["DELETE"],
)
@help_cards.doc(
    summary="Quitar el icono de una opción",
    description=(
        "Limpia icon_attachment_id / icon_extension de la opción y devuelve los "
        "valores previos para que el cliente borre el archivo físico. "
        "Requiere rol professional o admin."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("professional", "admin")
def delete_option_icon(option_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            UPDATE public.question_options
            SET icon_attachment_id = NULL,
                icon_extension = NULL
            WHERE id = %s
            RETURNING id;
            """,
            (option_id,),
        )
        row = cursor.fetchone()

        if row is None:
            conn.rollback()
            return jsonify({"error": "La opción no existe"}), 404

        conn.commit()

        return jsonify({"message": "Icono eliminado correctamente"}), 200

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(
            exc, "Error al eliminar icono (option=%s)", option_id
        )
        return jsonify({"error": "No se pudo eliminar el icono"}), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/options/<string:option_id>/photos",
    methods=["POST"],
)
@help_cards.doc(
    summary="Crear una foto de galería para una opción",
    description=(
        "Crea la fila de la foto en question_option_photos y devuelve su id para"
        " que el cliente suba el binario con PUT /option-images/<id>. Body JSON:"
        " file_extension (obligatorio), order_index (opcional). Requiere rol "
        "professional o admin."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("professional", "admin")
def create_option_photo(option_id):
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify({"error": "El cuerpo debe ser un JSON válido"}), 400

    file_extension = data.get("file_extension")
    if not isinstance(file_extension, str) or not file_extension.strip():
        return jsonify({"error": "file_extension es obligatorio"}), 400

    file_extension = file_extension.lower().lstrip(".")
    if file_extension not in ALLOWED_EXTENSIONS:
        return jsonify({"error": "Extensión de archivo no permitida"}), 400

    order_index = data.get("order_index")
    if order_index is None:
        order_index = 0
    if not isinstance(order_index, int):
        return jsonify({"error": "order_index debe ser un entero"}), 400

    photo_id = str(uuid.uuid4())

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT 1 FROM public.question_options WHERE id = %s LIMIT 1;
            """,
            (option_id,),
        )
        if cursor.fetchone() is None:
            return jsonify({"error": "La opción no existe"}), 404

        cursor.execute(
            """
            INSERT INTO public.question_option_photos
                (id, option_id, order_index, file_extension)
            VALUES (%s, %s, %s, %s)
            RETURNING id;
            """,
            (photo_id, option_id, order_index, file_extension),
        )
        conn.commit()

        return jsonify({
            "message": "Foto creada correctamente",
            "id": photo_id,
            "file_extension": file_extension,
        }), 201

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(
            exc, "Error al crear foto (option=%s)", option_id
        )
        return jsonify({"error": "No se pudo crear la foto"}), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/photos/<string:photo_id>",
    methods=["DELETE"],
)
@help_cards.doc(
    summary="Eliminar una foto de galería",
    description=(
        "Borra la fila de la foto y devuelve su extensión para que el cliente "
        "elimine el archivo físico. Requiere rol professional o admin."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("professional", "admin")
def delete_option_photo(photo_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            DELETE FROM public.question_option_photos
            WHERE id = %s
            RETURNING file_extension;
            """,
            (photo_id,),
        )
        row = cursor.fetchone()

        if row is None:
            conn.rollback()
            return jsonify({"error": "La foto no existe"}), 404

        conn.commit()

        return jsonify({
            "message": "Foto eliminada correctamente",
            "file_extension": row[0],
        }), 200

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(exc, "Error al eliminar foto (photo=%s)", photo_id)
        return jsonify({"error": "No se pudo eliminar la foto"}), 500

    finally:
        cursor.close()
        conn.close()


@help_cards.route(
    "/options/<string:option_id>/photos/reorder",
    methods=["PUT"],
)
@help_cards.doc(
    summary="Reordenar las fotos de galería de una opción",
    description=(
        "Recibe {\"photo_ids\": [...]} con los ids en el orden deseado y asigna "
        "order_index por posición. Requiere rol professional o admin."
    ),
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
@require_role("professional", "admin")
def reorder_option_photos(option_id):
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify({"error": "El cuerpo debe ser un JSON válido"}), 400

    photo_ids = data.get("photo_ids")
    if not isinstance(photo_ids, list) or not all(
        isinstance(x, str) for x in photo_ids
    ):
        return jsonify({
            "error": "photo_ids debe ser una lista de ids (texto)"
        }), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        for index, photo_id in enumerate(photo_ids):
            cursor.execute(
                """
                UPDATE public.question_option_photos
                SET order_index = %s
                WHERE id = %s AND option_id = %s;
                """,
                (index, photo_id, option_id),
            )
        conn.commit()

        return jsonify({"message": "Fotos reordenadas correctamente"}), 200

    except psycopg2.Error as exc:
        conn.rollback()
        _log_psycopg_error(
            exc, "Error al reordenar fotos (option=%s)", option_id
        )
        return jsonify({"error": "No se pudieron reordenar las fotos"}), 500

    finally:
        cursor.close()
        conn.close()
