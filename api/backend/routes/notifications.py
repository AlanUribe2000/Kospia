import psycopg2
from flask import Blueprint, g, jsonify

from authentication import require_kospia_jwt
from database.connection import get_connection


notifications = Blueprint("notifications", __name__)


@notifications.route("/notifications", methods=["GET"])
@require_kospia_jwt
def list_notifications():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT
                id,
                observation_id,
                type,
                title,
                body,
                old_species_id,
                old_species_name,
                new_species_id,
                new_species_name,
                read_at,
                created_at
            FROM public.notifications
            WHERE user_id = %s::uuid
            ORDER BY created_at DESC;
            """,
            (g.kospia_user_id,),
        )

        rows = cursor.fetchall()

        return jsonify({
            "notifications": [
                {
                    "id": str(row[0]),
                    "observation_id": row[1],
                    "type": row[2],
                    "title": row[3],
                    "body": row[4],
                    "old_species_id": row[5],
                    "old_species_name": row[6],
                    "new_species_id": row[7],
                    "new_species_name": row[8],
                    "read_at": row[9].isoformat() if row[9] else None,
                    "created_at": row[10].isoformat() if row[10] else None,
                }
                for row in rows
            ]
        }), 200

    except psycopg2.Error:
        conn.rollback()

        return jsonify({
            "error": "No se pudieron obtener las notificaciones"
        }), 500

    finally:
        cursor.close()
        conn.close()


@notifications.route(
    "/notifications/<string:notification_id>/read",
    methods=["PATCH"],
)
@require_kospia_jwt
def mark_notification_read(notification_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            UPDATE public.notifications
            SET read_at = NOW()
            WHERE id = %s::uuid
              AND user_id = %s::uuid
              AND read_at IS NULL
            RETURNING id, read_at;
            """,
            (notification_id, g.kospia_user_id),
        )

        row = cursor.fetchone()

        if row is not None:
            conn.commit()

            return jsonify({
                "notification": {
                    "id": str(row[0]),
                    "read_at": row[1].isoformat() if row[1] else None,
                }
            }), 200

        # Sin fila actualizada: distingue inexistente/ajena de ya leída.
        cursor.execute(
            """
            SELECT id, read_at
            FROM public.notifications
            WHERE id = %s::uuid
              AND user_id = %s::uuid
            LIMIT 1;
            """,
            (notification_id, g.kospia_user_id),
        )

        existing = cursor.fetchone()

        conn.commit()

        if existing is None:
            return jsonify({
                "error": "Notificación no encontrada"
            }), 404

        # Ya estaba leída: idempotente, 200.
        return jsonify({
            "notification": {
                "id": str(existing[0]),
                "read_at": existing[1].isoformat() if existing[1] else None,
            }
        }), 200

    except psycopg2.errors.InvalidTextRepresentation:
        # UUID inválido en la ruta: 400 en vez de 500.
        conn.rollback()

        return jsonify({
            "error": "id inválido"
        }), 400

    except psycopg2.Error:
        conn.rollback()

        return jsonify({
            "error": "No se pudo actualizar la notificación"
        }), 500

    finally:
        cursor.close()
        conn.close()
