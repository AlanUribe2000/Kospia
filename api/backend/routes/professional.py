import psycopg2
from flask import Blueprint, g, jsonify, request

from authentication import require_kospia_jwt, require_role
from database.connection import get_connection


professional = Blueprint("professional", __name__)

VALID_VALIDATION_STATUSES = {"pending", "validated", "rejected"}


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

    except psycopg2.Error:
        conn.rollback()

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

    except psycopg2.Error:
        conn.rollback()

        return jsonify({
            "error": "No se pudieron obtener las observaciones"
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
                id,
                photo_path,
                plant_part,
                latitude,
                longitude,
                altitude,
                accuracy,
                source,
                sync_status,
                captured_at,
                file_extension
            FROM public.observation_photos
            WHERE observation_id = %s
            ORDER BY captured_at ASC, id ASC;
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
            })

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
            }
        }), 200

    except psycopg2.Error:
        conn.rollback()

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
                      o.validated_species_id;
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

    except psycopg2.Error:
        conn.rollback()

        return jsonify({
            "error": "No se pudo actualizar la validación"
        }), 500

    finally:
        cursor.close()
        conn.close()