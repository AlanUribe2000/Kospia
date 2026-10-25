import logging
import uuid

import psycopg2
from flask import Blueprint, g, jsonify, request

from authentication import require_kospia_jwt, require_role
from database.connection import get_connection


logger = logging.getLogger(__name__)

professional = Blueprint("professional", __name__)


def _log_psycopg_error(exc, message, *args):
    # Registra con lujo de detalle una excepción de psycopg2: traceback
    # completo + el detalle de Postgres (pgcode, mensaje primario, constraint y
    # pgerror) para poder identificar de un vistazo qué falló (p. ej. un CHECK
    # violado). exc.diag puede no estar poblado en todos los errores, de ahí el
    # getattr defensivo.
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

VALID_VALIDATION_STATUSES = {"pending", "reviewed"}
VALID_PHOTO_ACTIONS = {"validate", "reject", "reassign"}
MAX_COMMENT_LENGTH = 2000


def build_notification(notification_type, old_name, new_name, reason):
    # Función pura (sin BD) que arma los textos en español de la notificación.
    # Permite testear la selección de caso y los mensajes sin tocar Postgres.
    if notification_type == "validated":
        return (
            "Identificación aprobada",
            f"Tu registro de {new_name} fue validado."
            if new_name
            else "Tu registro fue validado.",
        )

    if notification_type == "species_changed":
        return (
            "Especie corregida",
            f"Tu registro se validó como {new_name} "
            f"(habías propuesto {old_name}).",
        )

    if notification_type == "rejected":
        return (
            "Identificación rechazada",
            reason if reason else "Tu registro fue rechazado.",
        )

    raise ValueError(f"Tipo de notificación desconocido: {notification_type}")


def build_photo_notification(
    action, part_label, comment, old_name, new_name, species_name=None
):
    # Función pura (sin BD) para la decisión por-foto individual (§3.3).
    # Devuelve (notification_type, title, body); el type respeta el CHECK de
    # notifications (validated|rejected|species_changed).
    # species_name (opcional) identifica la especie de la foto para que la
    # notificación diga qué foto cambió (ej: varias observaciones distintas).
    part = part_label or "una parte"

    if action == "validate":
        body = (
            f"Tu foto de {part} ({species_name}) fue validada."
            if species_name
            else f"Tu foto de {part} fue validada."
        )
        if comment:
            body = f"{body} Comentario: {comment}"
        return ("validated", "Fotografía validada", body)

    if action == "reject":
        if comment:
            body = comment
        elif species_name:
            body = f"Tu foto de {part} ({species_name}) fue rechazada."
        else:
            body = f"Tu foto de {part} fue rechazada."
        return ("rejected", "Fotografía rechazada", body)

    if action == "reassign":
        body = (
            f"Tu foto de {part} ahora pertenece a {new_name}"
            if new_name
            else f"Tu foto de {part} fue reasignada a otra especie"
        )
        if old_name:
            body = f"{body} (habías propuesto {old_name})."
        else:
            body = f"{body}."
        if comment:
            body = f"{body} Comentario: {comment}"
        return ("species_changed", "Especie corregida", body)

    raise ValueError(f"Acción de foto desconocida: {action}")


def build_bulk_notification(
    action, counts, comment, old_name, new_name, species_name=None
):
    # Función pura (sin BD) para el resumen "aplicar a todas" (§3.3).
    # counts = {'validated': int, 'rejected': int, 'pending': int}.
    # Prioridad de tipo: species_changed > validated > rejected.
    # species_name (opcional) identifica la especie de la observación.
    validated_n = counts.get("validated", 0)
    rejected_n = counts.get("rejected", 0)
    total = validated_n + rejected_n + counts.get("pending", 0)

    if action == "reassign":
        body = (
            f"Se movieron {total} foto(s) a {new_name}"
            if new_name
            else f"Se movieron {total} foto(s) a otra especie"
        )
        if old_name:
            body = f"{body} (habías propuesto {old_name})."
        else:
            body = f"{body}."
        if comment:
            body = f"{body} Comentario: {comment}"
        return ("species_changed", "Especie corregida", body)

    if action == "validate":
        body = (
            f"Se validaron {validated_n} foto(s) de {species_name}."
            if species_name
            else f"Se validaron {validated_n} foto(s)."
        )
        if comment:
            body = f"{body} Comentario: {comment}"
        return ("validated", "Fotografías validadas", body)

    if action == "reject":
        if comment:
            body = comment
        elif species_name:
            body = f"Se rechazaron {rejected_n} foto(s) de {species_name}."
        else:
            body = f"Se rechazaron {rejected_n} foto(s)."
        return ("rejected", "Fotografías rechazadas", body)

    raise ValueError(f"Acción masiva desconocida: {action}")


def recompute_observation_status(cursor, observation_id):
    # Recalcula el estado agregado de la observación a partir de sus fotos (§2.2).
    # Dos estados funcionales a nivel observación: 'pending' (queda >=1 foto
    # pendiente o sin fotos) y 'reviewed' (todas las fotos decididas). El estado
    # por foto (validated/rejected) es el que la app consume y el detalle muestra.
    # Se llama SIEMPRE dentro de la transacción del endpoint llamador.
    cursor.execute(
        """
        WITH agg AS (
            SELECT
                COUNT(*) FILTER (
                    WHERE validation_status = 'validated'
                ) AS validated_n,
                COUNT(*) FILTER (
                    WHERE validation_status = 'rejected'
                ) AS rejected_n,
                COUNT(*) AS total_n,
                MAX(validated_at) AS last_validated_at
            FROM public.observation_photos
            WHERE observation_id = %s
        )
        UPDATE public.observations o
        SET validation_status = CASE
                WHEN agg.total_n = 0 THEN 'pending'
                WHEN (agg.validated_n + agg.rejected_n) = agg.total_n
                    THEN 'reviewed'
                ELSE 'pending'
            END,
            validated_at = CASE
                WHEN agg.total_n > 0
                     AND (agg.validated_n + agg.rejected_n) = agg.total_n
                    THEN agg.last_validated_at
                ELSE NULL
            END,
            updated_at = NOW()
        FROM agg
        WHERE o.id = %s
        RETURNING o.validation_status;
        """,
        (observation_id, observation_id),
    )

    status_row = cursor.fetchone()
    aggregated_status = status_row[0] if status_row else None

    # validated_by de la observación: el de la foto validada más reciente.
    cursor.execute(
        """
        UPDATE public.observations o
        SET validated_by = (
            SELECT op.validated_by
            FROM public.observation_photos op
            WHERE op.observation_id = %s
              AND op.validated_at IS NOT NULL
            ORDER BY op.validated_at DESC, op.id DESC
            LIMIT 1
        )
        WHERE o.id = %s;
        """,
        (observation_id, observation_id),
    )

    # rejection_reason a nivel observación: compuesto cuando la observación está
    # 'reviewed'; el STRING_AGG agrega solo las fotos rechazadas (NULL si no hay
    # ninguna). El detalle real vive por-foto en validation_comment.
    if aggregated_status == "reviewed":
        cursor.execute(
            """
            UPDATE public.observations o
            SET rejection_reason = (
                SELECT STRING_AGG(
                    COALESCE(op.validation_comment, 'Sin comentario'),
                    ' | '
                    ORDER BY op.id
                )
                FROM public.observation_photos op
                WHERE op.observation_id = %s
                  AND op.validation_status = 'rejected'
            )
            WHERE o.id = %s;
            """,
            (observation_id, observation_id),
        )
    else:
        cursor.execute(
            """
            UPDATE public.observations
            SET rejection_reason = NULL
            WHERE id = %s;
            """,
            (observation_id,),
        )

    # NOTA: la especie de la observación es INMUTABLE y no se toca aquí.
    # recompute solo recalcula el estado agregado (pending/reviewed). La especie
    # editable vive por-foto en observation_photos.validated_species_id, y la
    # agrupación por especie se resuelve con COALESCE(op.validated_species_id,
    # o.species_id). No se escribe observations.validated_species_id: copiar
    # species_id (p.ej. el marcador 'unidentified') a esa columna con FK a
    # species provocaba ForeignKeyViolation (23503) al quedar 'reviewed'.

    return aggregated_status


def resolve_target_observation(
    cursor, user_id, target_species_id, exclude_obs_id
):
    # Regla determinista de reasignación (§2.3): reutiliza la observación
    # pending/validated más reciente del usuario cuya especie efectiva
    # COALESCE(validated_species_id, species_id) sea target_species_id,
    # excluyendo rejected y exclude_obs_id; si no existe, crea una nueva.
    # Devuelve el id de la observación destino.
    cursor.execute(
        """
        SELECT id
        FROM public.observations
        WHERE user_id = %s
          AND id <> %s
          AND validation_status <> 'rejected'
          AND COALESCE(validated_species_id, species_id) = %s
        ORDER BY created_at DESC, id DESC
        LIMIT 1;
        """,
        (user_id, exclude_obs_id, target_species_id),
    )

    row = cursor.fetchone()

    if row is not None:
        return row[0]

    new_obs_id = str(uuid.uuid4())

    cursor.execute(
        """
        INSERT INTO public.observations
            (id, user_id, species_id, notes, sync_status,
             validation_status, validated_species_id,
             created_at, updated_at, synced_at)
        VALUES
            (%s, %s, %s, '', 'synced',
             'pending', NULL,
             NOW(), NOW(), NOW());
        """,
        (new_obs_id, user_id, target_species_id),
    )

    return new_obs_id


def _species_or_none(species_id, common_name, scientific_name):
    # species_id viene del JOIN: es None si no resolvió una fila de species.
    if species_id is None:
        return None

    return {
        "id": species_id,
        "common_name": common_name,
        "scientific_name": scientific_name,
    }


@professional.route("/professional/me", methods=["GET"])
@require_kospia_jwt
@require_role("professional", "admin")
def professional_me():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT
                id,
                email,
                display_name,
                photo_url,
                role
            FROM public.users
            WHERE id = %s
            LIMIT 1;
            """,
            (g.kospia_user_id,),
        )

        row = cursor.fetchone()

        if row is None:
            return jsonify({
                "error": "Usuario Kospia no encontrado"
            }), 404

        return jsonify({
            "user": {
                "id": str(row[0]),
                "email": row[1],
                "display_name": row[2],
                "photo_url": row[3],
                "role": row[4],
            }
        }), 200

    finally:
        cursor.close()
        conn.close()


@professional.route("/professional/species", methods=["GET"])
@require_kospia_jwt
@require_role("professional", "admin")
def list_professional_species():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT
                id,
                common_name,
                scientific_name,
                family
            FROM public.species
            WHERE is_active = TRUE
            ORDER BY common_name ASC, scientific_name ASC, id ASC;
            """
        )

        rows = cursor.fetchall()

        return jsonify({
            "species": [
                {
                    "id": row[0],
                    "common_name": row[1],
                    "scientific_name": row[2],
                    "family": row[3],
                }
                for row in rows
            ]
        }), 200

    except psycopg2.Error as exc:
        conn.rollback()

        _log_psycopg_error(exc, "Error al obtener las especies")

        return jsonify({
            "error": "No se pudieron obtener las especies"
        }), 500

    finally:
        cursor.close()
        conn.close()


@professional.route("/professional/observations", methods=["GET"])
@require_kospia_jwt
@require_role("professional", "admin")
def list_professional_observations():
    status = request.args.get("status")

    if status is not None and status not in VALID_VALIDATION_STATUSES:
        return jsonify({
            "error": "El parámetro status no es válido",
            "allowed": sorted(VALID_VALIDATION_STATUSES),
        }), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT
                o.id,
                o.validation_status,
                o.created_at,
                o.user_id,
                u.display_name,
                u.email,
                proposed.id,
                proposed.common_name,
                proposed.scientific_name,
                COUNT(p.id) AS photo_count,
                confirmed.id,
                confirmed.common_name,
                confirmed.scientific_name
            FROM public.observations o
            LEFT JOIN public.users u
                ON u.id::text = o.user_id
            LEFT JOIN public.species proposed
                ON proposed.id = o.species_id
            LEFT JOIN public.species confirmed
                ON confirmed.id = o.validated_species_id
            LEFT JOIN public.observation_photos p
                ON p.observation_id = o.id
            WHERE %s::text IS NULL OR o.validation_status = %s
            GROUP BY
                o.id,
                o.validation_status,
                o.created_at,
                o.user_id,
                u.display_name,
                u.email,
                proposed.id,
                proposed.common_name,
                proposed.scientific_name,
                confirmed.id,
                confirmed.common_name,
                confirmed.scientific_name
            ORDER BY o.created_at DESC;
            """,
            (status, status),
        )

        rows = cursor.fetchall()

        observations = []

        for row in rows:
            observations.append({
                "id": row[0],
                "validation_status": row[1],
                "created_at": row[2].isoformat() if row[2] else None,
                "user": {
                    "id": row[3],
                    "display_name": row[4],
                    "email": row[5],
                },
                "proposed_species": _species_or_none(
                    row[6], row[7], row[8]
                ),
                "confirmed_species": _species_or_none(
                    row[10], row[11], row[12]
                ),
                "photo_count": row[9],
            })

        return jsonify({
            "observations": observations
        }), 200

    except psycopg2.Error as exc:
        conn.rollback()

        _log_psycopg_error(exc, "Error al obtener las observaciones")

        return jsonify({
            "error": "No se pudieron obtener las observaciones"
        }), 500

    finally:
        cursor.close()
        conn.close()


@professional.route("/professional/observations/counts", methods=["GET"])
@require_kospia_jwt
@require_role("professional", "admin")
def count_professional_observations():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT validation_status, COUNT(*)
            FROM public.observations
            GROUP BY validation_status;
            """
        )

        rows = cursor.fetchall()

        # Dos buckets a nivel observación: pending y reviewed. Los históricos
        # 'validated'/'rejected' (previos a este modelo, no migrados) se suman a
        # reviewed para que los contadores cuadren con el total.
        counts = {"pending": 0, "reviewed": 0}

        for status_value, n in rows:
            if status_value == "pending":
                counts["pending"] += n
            elif status_value in ("reviewed", "validated", "rejected"):
                counts["reviewed"] += n

        return jsonify({
            "counts": counts
        }), 200

    except psycopg2.Error as exc:
        conn.rollback()

        _log_psycopg_error(exc, "Error al obtener los conteos")

        return jsonify({
            "error": "No se pudieron obtener los conteos"
        }), 500

    finally:
        cursor.close()
        conn.close()


@professional.route(
    "/professional/observations/<string:observation_id>",
    methods=["GET"],
)
@require_kospia_jwt
@require_role("professional", "admin")
def get_professional_observation(observation_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT
                o.id,
                o.notes,
                o.sync_status,
                o.validation_status,
                o.created_at,
                o.updated_at,
                o.synced_at,
                o.validated_at,
                o.validated_by,
                o.rejection_reason,
                o.user_id,
                u.display_name,
                u.email,
                proposed.id,
                proposed.common_name,
                proposed.scientific_name,
                confirmed.id,
                confirmed.common_name,
                confirmed.scientific_name
            FROM public.observations o
            LEFT JOIN public.users u
                ON u.id::text = o.user_id
            LEFT JOIN public.species proposed
                ON proposed.id = o.species_id
            LEFT JOIN public.species confirmed
                ON confirmed.id = o.validated_species_id
            WHERE o.id = %s
            LIMIT 1;
            """,
            (observation_id,),
        )

        observation_row = cursor.fetchone()

        if observation_row is None:
            return jsonify({
                "error": "Observación no encontrada"
            }), 404

        cursor.execute(
            """
            SELECT
                op.id,
                op.photo_path,
                op.plant_part,
                op.latitude,
                op.longitude,
                op.altitude,
                op.accuracy,
                op.source,
                op.sync_status,
                op.captured_at,
                op.file_extension,
                op.validation_status,
                op.validation_comment,
                op.validated_species_id,
                op.validated_at,
                op.validated_by,
                vs.common_name,
                vs.scientific_name
            FROM public.observation_photos op
            LEFT JOIN public.species vs
                ON vs.id = op.validated_species_id
            WHERE op.observation_id = %s
            ORDER BY op.captured_at ASC, op.id ASC;
            """,
            (observation_id,),
        )

        photo_rows = cursor.fetchall()

        photos = []

        for photo_row in photo_rows:
            photos.append({
                "id": photo_row[0],
                "photo_path": photo_row[1],
                "plant_part": photo_row[2],
                "latitude": photo_row[3],
                "longitude": photo_row[4],
                "altitude": photo_row[5],
                "accuracy": photo_row[6],
                "source": photo_row[7],
                "sync_status": photo_row[8],
                "captured_at":
                    photo_row[9].isoformat() if photo_row[9] else None,
                "file_extension": photo_row[10],
                "validation_status": photo_row[11],
                "validation_comment": photo_row[12],
                "validated_species_id": photo_row[13],
                "validated_at":
                    photo_row[14].isoformat() if photo_row[14] else None,
                "validated_by":
                    str(photo_row[15]) if photo_row[15] else None,
                "validated_species": _species_or_none(
                    photo_row[13], photo_row[16], photo_row[17]
                ),
            })

        cursor.execute(
            """
            SELECT
                COUNT(*) FILTER (WHERE validation_status = 'validated'),
                COUNT(*) FILTER (WHERE validation_status = 'rejected'),
                COUNT(*) FILTER (WHERE validation_status = 'pending')
            FROM public.observation_photos
            WHERE observation_id = %s;
            """,
            (observation_id,),
        )

        summary_row = cursor.fetchone()
        summary = {
            "validated": summary_row[0] if summary_row else 0,
            "rejected": summary_row[1] if summary_row else 0,
            "pending": summary_row[2] if summary_row else 0,
        }

        return jsonify({
            "observation": {
                "id": observation_row[0],
                "notes": observation_row[1],
                "sync_status": observation_row[2],
                "validation_status": observation_row[3],
                "created_at":
                    observation_row[4].isoformat()
                    if observation_row[4] else None,
                "updated_at":
                    observation_row[5].isoformat()
                    if observation_row[5] else None,
                "synced_at":
                    observation_row[6].isoformat()
                    if observation_row[6] else None,
                "validated_at":
                    observation_row[7].isoformat()
                    if observation_row[7] else None,
                "validated_by":
                    str(observation_row[8])
                    if observation_row[8] else None,
                "rejection_reason": observation_row[9],
                "user": {
                    "id": observation_row[10],
                    "display_name": observation_row[11],
                    "email": observation_row[12],
                },
                "proposed_species": _species_or_none(
                    observation_row[13],
                    observation_row[14],
                    observation_row[15],
                ),
                "confirmed_species": _species_or_none(
                    observation_row[16],
                    observation_row[17],
                    observation_row[18],
                ),
                "photos": photos,
                "summary": summary,
            }
        }), 200

    except psycopg2.Error as exc:
        conn.rollback()

        _log_psycopg_error(
            exc, "Error al obtener la observación (obs=%s)", observation_id
        )

        return jsonify({
            "error": "No se pudo obtener la observación"
        }), 500

    finally:
        cursor.close()
        conn.close()


@professional.route(
    "/professional/observations/<string:observation_id>/validation",
    methods=["PATCH"],
)
@require_kospia_jwt
@require_role("professional", "admin")
def update_observation_validation(observation_id):
    # DEPRECATED: usar los endpoints por-foto
    # (PATCH .../photos/<photo_id>/validation y PATCH .../photos/validation).
    # Se conserva por compatibilidad; la web migró 100% a decisión por-foto.
    data = request.get_json(silent=True)

    if not isinstance(data, dict):
        return jsonify({
            "error": "El cuerpo debe ser un JSON válido"
        }), 400

    validation_status = data.get("validation_status")

    if validation_status not in ("validated", "rejected"):
        return jsonify({
            "error": "validation_status debe ser 'validated' o 'rejected'"
        }), 400

    rejection_reason = None

    if validation_status == "rejected":
        raw_reason = data.get("rejection_reason")

        if not isinstance(raw_reason, str) or not raw_reason.strip():
            return jsonify({
                "error": "rejection_reason es obligatorio al rechazar"
            }), 400

        rejection_reason = raw_reason.strip()

    explicit_species_id = None
    raw_species_id = data.get("validated_species_id")

    if raw_species_id is not None:
        # Un rechazo no tiene especie confirmada: se rechaza el payload ambiguo.
        if validation_status == "rejected":
            return jsonify({
                "error": "Un rechazo no puede incluir validated_species_id"
            }), 400

        if not isinstance(raw_species_id, str) or not raw_species_id.strip():
            return jsonify({
                "error": "validated_species_id debe ser un texto no vacío"
            }), 400

        explicit_species_id = raw_species_id.strip()

    conn = get_connection()
    cursor = conn.cursor()

    proposes_existing = (
        validation_status == "validated" and explicit_species_id is None
    )

    try:
        if explicit_species_id is not None:
            cursor.execute(
                """
                SELECT 1
                FROM public.species
                WHERE id = %s
                  AND is_active = TRUE
                LIMIT 1;
                """,
                (explicit_species_id,),
            )

            if cursor.fetchone() is None:
                return jsonify({
                    "error": "La especie seleccionada no existe o no está activa"
                }), 400

        # Fragmentos fijos (sin datos del cliente); los valores van parametrizados.
        if validation_status == "rejected":
            species_expr = "NULL"
            species_params = ()
            extra_where = ""
        elif explicit_species_id is not None:
            species_expr = "%s"
            species_params = (explicit_species_id,)
            extra_where = ""
        else:
            # Confirma la propuesta resolviéndola en el mismo UPDATE atómico.
            species_expr = (
                "(SELECT sp.id FROM public.species sp "
                "WHERE sp.id = o.species_id AND sp.is_active = TRUE)"
            )
            species_params = ()
            extra_where = (
                "AND EXISTS (SELECT 1 FROM public.species sp "
                "WHERE sp.id = o.species_id AND sp.is_active = TRUE)"
            )

        cursor.execute(
            f"""
            UPDATE public.observations o
            SET validation_status = %s,
                validated_at = NOW(),
                validated_by = %s,
                rejection_reason = %s,
                validated_species_id = {species_expr}
            WHERE o.id = %s
              AND o.validation_status = 'pending'
              {extra_where}
            RETURNING o.id,
                      o.validation_status,
                      o.validated_at,
                      o.validated_by,
                      o.rejection_reason,
                      o.validated_species_id,
                      o.species_id,
                      o.user_id;
            """,
            (
                validation_status,
                g.kospia_user_id,
                rejection_reason,
                *species_params,
                observation_id,
            ),
        )

        row = cursor.fetchone()

        if row is None:
            conn.rollback()

            # Distingue inexistente, ya decidida y propuesta no confirmable.
            cursor.execute(
                """
                SELECT validation_status
                FROM public.observations
                WHERE id = %s
                LIMIT 1;
                """,
                (observation_id,),
            )

            current = cursor.fetchone()

            if current is None:
                return jsonify({
                    "error": "Observación no encontrada"
                }), 404

            if current[0] == "pending" and proposes_existing:
                return jsonify({
                    "error": (
                        "No se puede validar sin seleccionar "
                        "una especie confirmada"
                    )
                }), 400

            return jsonify({
                "error": "La observación ya fue decidida"
            }), 409

        resulting_status = row[1]
        resulting_rejection_reason = row[4]
        resulting_validated_species_id = row[5]
        original_species_id = row[6]
        observation_user_id = row[7]

        # Resuelve los nombres de especie propuesta y confirmada en una sola
        # consulta parametrizada, dentro de la misma transacción.
        species_ids = [
            species_id
            for species_id in (
                original_species_id,
                resulting_validated_species_id,
            )
            if species_id is not None
        ]

        names_by_id = {}

        if species_ids:
            cursor.execute(
                """
                SELECT id, common_name
                FROM public.species
                WHERE id = ANY(%s);
                """,
                (species_ids,),
            )

            for species_row in cursor.fetchall():
                names_by_id[species_row[0]] = species_row[1]

        # Decide el caso a partir de datos que el endpoint ya tiene.
        if resulting_status == "rejected":
            notification_type = "rejected"
            old_species_id = None
            new_species_id = None
        elif resulting_validated_species_id == original_species_id:
            notification_type = "validated"
            old_species_id = None
            new_species_id = resulting_validated_species_id
        else:
            notification_type = "species_changed"
            old_species_id = original_species_id
            new_species_id = resulting_validated_species_id

        old_species_name = (
            names_by_id.get(old_species_id)
            if old_species_id is not None
            else None
        )
        new_species_name = (
            names_by_id.get(new_species_id)
            if new_species_id is not None
            else None
        )

        title, body = build_notification(
            notification_type,
            old_species_name,
            new_species_name,
            resulting_rejection_reason,
        )

        cursor.execute(
            """
            INSERT INTO public.notifications
                (id, user_id, observation_id, type, title, body,
                 old_species_id, old_species_name,
                 new_species_id, new_species_name)
            VALUES (%s, %s::uuid, %s, %s, %s, %s, %s, %s, %s, %s);
            """,
            (
                str(uuid.uuid4()),
                observation_user_id,
                observation_id,
                notification_type,
                title,
                body,
                old_species_id,
                old_species_name,
                new_species_id,
                new_species_name,
            ),
        )

        conn.commit()

        return jsonify({
            "observation": {
                "id": row[0],
                "validation_status": row[1],
                "validated_at": row[2].isoformat() if row[2] else None,
                "validated_by": str(row[3]) if row[3] else None,
                "rejection_reason": row[4],
                "validated_species_id": row[5],
            }
        }), 200

    except psycopg2.Error as exc:
        conn.rollback()

        _log_psycopg_error(
            exc,
            "Error al actualizar la validación (obs=%s)",
            observation_id,
        )

        return jsonify({
            "error": "No se pudo actualizar la validación"
        }), 500

    finally:
        cursor.close()
        conn.close()


def _parse_photo_decision_payload(data):
    # Valida el body compartido por los endpoints por-foto y bulk (§3.1).
    # Devuelve (payload, None) si es válido, o (None, (error_json, status)).
    if not isinstance(data, dict):
        return None, ({"error": "El cuerpo debe ser un JSON válido"}, 400)

    action = data.get("action")

    if action not in VALID_PHOTO_ACTIONS:
        return None, ({
            "error": "La acción no es válida",
            "allowed": sorted(VALID_PHOTO_ACTIONS),
        }, 400)

    raw_comment = data.get("comment")
    comment = None

    if raw_comment is not None:
        if not isinstance(raw_comment, str):
            return None, ({
                "error": "El comentario debe ser un texto"
            }, 400)

        comment = raw_comment.strip()

        if len(comment) > MAX_COMMENT_LENGTH:
            return None, ({
                "error": (
                    "El comentario supera el máximo de "
                    f"{MAX_COMMENT_LENGTH} caracteres"
                )
            }, 400)

        if comment == "":
            comment = None

    if action == "reject" and not comment:
        return None, ({
            "error": "El comentario es obligatorio al rechazar"
        }, 400)

    target_species_id = None
    raw_target = data.get("target_species_id")

    if action == "reassign":
        if not isinstance(raw_target, str) or not raw_target.strip():
            return None, ({
                "error": "target_species_id es obligatorio al reasignar"
            }, 400)

        target_species_id = raw_target.strip()
    elif raw_target is not None:
        return None, ({
            "error": "target_species_id solo se permite al reasignar"
        }, 400)

    return {
        "action": action,
        "comment": comment,
        "target_species_id": target_species_id,
    }, None


def _fetch_species_names(cursor, species_ids):
    ids = [sid for sid in species_ids if sid is not None]
    names = {}

    if not ids:
        return names

    cursor.execute(
        """
        SELECT id, common_name
        FROM public.species
        WHERE id = ANY(%s);
        """,
        (ids,),
    )

    for sid, common_name in cursor.fetchall():
        names[sid] = common_name

    return names


def _insert_notification(
    cursor, user_id, observation_id, notification_type, title, body,
    old_species_id=None, old_species_name=None,
    new_species_id=None, new_species_name=None,
):
    cursor.execute(
        """
        INSERT INTO public.notifications
            (id, user_id, observation_id, type, title, body,
             old_species_id, old_species_name,
             new_species_id, new_species_name)
        VALUES (%s, %s::uuid, %s, %s, %s, %s, %s, %s, %s, %s);
        """,
        (
            str(uuid.uuid4()),
            user_id,
            observation_id,
            notification_type,
            title,
            body,
            old_species_id,
            old_species_name,
            new_species_id,
            new_species_name,
        ),
    )


@professional.route(
    "/professional/observations/<string:observation_id>"
    "/photos/<string:photo_id>/validation",
    methods=["PATCH"],
)
@require_kospia_jwt
@require_role("professional", "admin")
def decide_photo_validation(observation_id, photo_id):
    payload, error = _parse_photo_decision_payload(request.get_json(silent=True))

    if error is not None:
        body, status = error
        return jsonify(body), status

    action = payload["action"]
    comment = payload["comment"]
    target_species_id = payload["target_species_id"]

    conn = get_connection()
    cursor = conn.cursor()

    try:
        # La foto debe pertenecer a la observación indicada.
        cursor.execute(
            """
            SELECT op.id, op.plant_part, o.user_id, o.species_id,
                   op.validation_status
            FROM public.observation_photos op
            INNER JOIN public.observations o
                ON o.id = op.observation_id
            WHERE op.id = %s
              AND op.observation_id = %s
            LIMIT 1;
            """,
            (photo_id, observation_id),
        )

        photo_row = cursor.fetchone()

        if photo_row is None:
            return jsonify({
                "error": "Fotografía u observación no encontrada"
            }), 404

        plant_part = photo_row[1]
        observation_user_id = photo_row[2]
        source_species_id = photo_row[3]
        current_photo_status = photo_row[4]

        # Decisión única e irreversible: una foto ya decidida no se re-decide.
        # Evita notificaciones duplicadas sobre la misma foto (§A).
        if current_photo_status != "pending":
            conn.rollback()
            return jsonify({
                "error": "La fotografía ya fue decidida"
            }), 409

        if action == "reassign":
            # Validar especie destino activa.
            cursor.execute(
                """
                SELECT 1
                FROM public.species
                WHERE id = %s AND is_active = TRUE
                LIMIT 1;
                """,
                (target_species_id,),
            )

            if cursor.fetchone() is None:
                return jsonify({
                    "error": "La especie seleccionada no existe o no está activa"
                }), 400

            # Especie efectiva actual de la observación origen.
            cursor.execute(
                """
                SELECT COALESCE(validated_species_id, species_id)
                FROM public.observations
                WHERE id = %s
                LIMIT 1;
                """,
                (observation_id,),
            )

            effective = cursor.fetchone()

            if effective is not None and effective[0] == target_species_id:
                return jsonify({
                    "error": (
                        "La especie corregida coincide con la especie actual"
                    )
                }), 400

            target_obs_id = resolve_target_observation(
                cursor,
                observation_user_id,
                target_species_id,
                observation_id,
            )

            cursor.execute(
                """
                UPDATE public.observation_photos
                SET observation_id = %s,
                    validation_status = 'validated',
                    validation_comment = %s,
                    validated_species_id = %s,
                    validated_at = NOW(),
                    validated_by = %s::uuid
                WHERE id = %s;
                """,
                (
                    target_obs_id,
                    comment,
                    target_species_id,
                    g.kospia_user_id,
                    photo_id,
                ),
            )

            recompute_observation_status(cursor, observation_id)
            recompute_observation_status(cursor, target_obs_id)

            names = _fetch_species_names(
                cursor, [source_species_id, target_species_id]
            )
            notification_type, title, body = build_photo_notification(
                "reassign",
                plant_part,
                comment,
                names.get(source_species_id),
                names.get(target_species_id),
            )

            _insert_notification(
                cursor,
                observation_user_id,
                observation_id,
                notification_type,
                title,
                body,
                old_species_id=source_species_id,
                old_species_name=names.get(source_species_id),
                new_species_id=target_species_id,
                new_species_name=names.get(target_species_id),
            )

        else:
            new_status = "validated" if action == "validate" else "rejected"

            cursor.execute(
                """
                UPDATE public.observation_photos
                SET validation_status = %s,
                    validation_comment = %s,
                    validated_species_id = NULL,
                    validated_at = NOW(),
                    validated_by = %s::uuid
                WHERE id = %s;
                """,
                (new_status, comment, g.kospia_user_id, photo_id),
            )

            recompute_observation_status(cursor, observation_id)

            names = _fetch_species_names(cursor, [source_species_id])
            notification_type, title, body = build_photo_notification(
                action,
                plant_part,
                comment,
                None,
                None,
                species_name=names.get(source_species_id),
            )

            _insert_notification(
                cursor,
                observation_user_id,
                observation_id,
                notification_type,
                title,
                body,
            )

        # Estado por-foto y agregado resultante.
        cursor.execute(
            """
            SELECT validation_status, validation_comment,
                   validated_species_id, validated_at, validated_by,
                   observation_id
            FROM public.observation_photos
            WHERE id = %s
            LIMIT 1;
            """,
            (photo_id,),
        )

        updated = cursor.fetchone()
        result_obs_id = updated[5]

        cursor.execute(
            """
            SELECT validation_status
            FROM public.observations
            WHERE id = %s
            LIMIT 1;
            """,
            (result_obs_id,),
        )

        obs_status_row = cursor.fetchone()

        conn.commit()

        return jsonify({
            "photo": {
                "id": photo_id,
                "validation_status": updated[0],
                "validation_comment": updated[1],
                "validated_species_id": updated[2],
                "validated_at": updated[3].isoformat() if updated[3] else None,
                "validated_by": str(updated[4]) if updated[4] else None,
                "observation_id": result_obs_id,
            },
            "observation": {
                "id": observation_id,
                "validation_status":
                    obs_status_row[0] if obs_status_row else None,
            },
        }), 200

    except psycopg2.errors.InvalidTextRepresentation:
        conn.rollback()

        return jsonify({"error": "id inválido"}), 400

    except psycopg2.Error as exc:
        conn.rollback()

        _log_psycopg_error(
            exc,
            "Error al actualizar la validación (obs=%s)",
            observation_id,
        )

        return jsonify({
            "error": "No se pudo actualizar la validación"
        }), 500

    finally:
        cursor.close()
        conn.close()


@professional.route(
    "/professional/observations/<string:observation_id>/photos/validation",
    methods=["PATCH"],
)
@require_kospia_jwt
@require_role("professional", "admin")
def decide_all_photos_validation(observation_id):
    payload, error = _parse_photo_decision_payload(request.get_json(silent=True))

    if error is not None:
        body, status = error
        return jsonify(body), status

    action = payload["action"]
    comment = payload["comment"]
    target_species_id = payload["target_species_id"]

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT user_id, species_id,
                   COALESCE(validated_species_id, species_id)
            FROM public.observations
            WHERE id = %s
            LIMIT 1;
            """,
            (observation_id,),
        )

        obs_row = cursor.fetchone()

        if obs_row is None:
            return jsonify({
                "error": "Observación no encontrada"
            }), 404

        observation_user_id = obs_row[0]
        source_species_id = obs_row[1]
        effective_species_id = obs_row[2]

        # La observación debe tener al menos una foto para decidir.
        cursor.execute(
            """
            SELECT COUNT(*)
            FROM public.observation_photos
            WHERE observation_id = %s;
            """,
            (observation_id,),
        )

        photo_count = cursor.fetchone()[0]

        if photo_count == 0:
            return jsonify({
                "error": "La observación no tiene fotografías"
            }), 400

        # Las acciones "a todas" aplican SOLO sobre las fotos pendientes (§C).
        # Se cuenta antes de los UPDATE para dimensionar la notificación y para
        # rechazar la acción si no quedan pendientes.
        cursor.execute(
            """
            SELECT COUNT(*)
            FROM public.observation_photos
            WHERE observation_id = %s
              AND validation_status = 'pending';
            """,
            (observation_id,),
        )

        pending_count = cursor.fetchone()[0]

        if action == "reassign":
            cursor.execute(
                """
                SELECT 1
                FROM public.species
                WHERE id = %s AND is_active = TRUE
                LIMIT 1;
                """,
                (target_species_id,),
            )

            if cursor.fetchone() is None:
                return jsonify({
                    "error": "La especie seleccionada no existe o no está activa"
                }), 400

            if effective_species_id == target_species_id:
                return jsonify({
                    "error": (
                        "La especie corregida coincide con la especie actual"
                    )
                }), 400

            if pending_count == 0:
                conn.rollback()
                return jsonify({
                    "error": (
                        "No hay fotografías pendientes para aplicar la acción"
                    )
                }), 409

            target_obs_id = resolve_target_observation(
                cursor,
                observation_user_id,
                target_species_id,
                observation_id,
            )

            # Solo se trasladan las fotos pendientes; las ya decididas se quedan
            # en la observación origen con su estado final (§C).
            cursor.execute(
                """
                UPDATE public.observation_photos
                SET observation_id = %s,
                    validation_status = 'validated',
                    validation_comment = %s,
                    validated_species_id = %s,
                    validated_at = NOW(),
                    validated_by = %s::uuid
                WHERE observation_id = %s
                  AND validation_status = 'pending';
                """,
                (
                    target_obs_id,
                    comment,
                    target_species_id,
                    g.kospia_user_id,
                    observation_id,
                ),
            )

            recompute_observation_status(cursor, observation_id)
            recompute_observation_status(cursor, target_obs_id)

            names = _fetch_species_names(
                cursor, [source_species_id, target_species_id]
            )
            counts = {"validated": pending_count, "rejected": 0, "pending": 0}
            notification_type, title, body = build_bulk_notification(
                "reassign",
                counts,
                comment,
                names.get(source_species_id),
                names.get(target_species_id),
            )

            _insert_notification(
                cursor,
                observation_user_id,
                observation_id,
                notification_type,
                title,
                body,
                old_species_id=source_species_id,
                old_species_name=names.get(source_species_id),
                new_species_id=target_species_id,
                new_species_name=names.get(target_species_id),
            )

        else:
            if pending_count == 0:
                conn.rollback()
                return jsonify({
                    "error": (
                        "No hay fotografías pendientes para aplicar la acción"
                    )
                }), 409

            new_status = "validated" if action == "validate" else "rejected"

            # Solo se deciden las fotos pendientes; las ya decididas conservan
            # su estado final (§C).
            cursor.execute(
                """
                UPDATE public.observation_photos
                SET validation_status = %s,
                    validation_comment = %s,
                    validated_species_id = NULL,
                    validated_at = NOW(),
                    validated_by = %s::uuid
                WHERE observation_id = %s
                  AND validation_status = 'pending';
                """,
                (new_status, comment, g.kospia_user_id, observation_id),
            )

            recompute_observation_status(cursor, observation_id)

            counts = {
                "validated": pending_count if action == "validate" else 0,
                "rejected": pending_count if action == "reject" else 0,
                "pending": 0,
            }
            names = _fetch_species_names(cursor, [source_species_id])
            notification_type, title, body = build_bulk_notification(
                action,
                counts,
                comment,
                None,
                None,
                species_name=names.get(source_species_id),
            )

            _insert_notification(
                cursor,
                observation_user_id,
                observation_id,
                notification_type,
                title,
                body,
            )

        cursor.execute(
            """
            SELECT
                COUNT(*) FILTER (WHERE validation_status = 'validated'),
                COUNT(*) FILTER (WHERE validation_status = 'rejected'),
                COUNT(*) FILTER (WHERE validation_status = 'pending')
            FROM public.observation_photos
            WHERE observation_id = %s;
            """,
            (observation_id,),
        )

        counts_row = cursor.fetchone()

        cursor.execute(
            """
            SELECT validation_status
            FROM public.observations
            WHERE id = %s
            LIMIT 1;
            """,
            (observation_id,),
        )

        obs_status_row = cursor.fetchone()

        conn.commit()

        return jsonify({
            "observation": {
                "id": observation_id,
                "validation_status":
                    obs_status_row[0] if obs_status_row else None,
                "counts": {
                    "validated": counts_row[0],
                    "rejected": counts_row[1],
                    "pending": counts_row[2],
                },
            },
        }), 200

    except psycopg2.errors.InvalidTextRepresentation:
        conn.rollback()

        return jsonify({"error": "id inválido"}), 400

    except psycopg2.Error as exc:
        conn.rollback()

        _log_psycopg_error(
            exc,
            "Error al actualizar la validación (obs=%s)",
            observation_id,
        )

        return jsonify({
            "error": "No se pudo actualizar la validación"
        }), 500

    finally:
        cursor.close()
        conn.close()