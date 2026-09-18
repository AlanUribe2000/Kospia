import base64
import uuid
from datetime import datetime, timedelta, timezone

import jwt
import psycopg2
from flask import Blueprint, g, jsonify, request
from google.auth.transport import requests
from google.oauth2 import id_token

from authentication import require_kospia_jwt
from config import Config
from database.connection import get_connection


auth = Blueprint("auth", __name__)


def decode_base64url(value):
    padding = "=" * (-len(value) % 4)

    return base64.urlsafe_b64decode(
        value + padding
    )


@auth.route(
    "/auth/powersync-token",
    methods=["GET"],
)
@require_kospia_jwt
def powersync_token():

    if not Config.POWERSYNC_JWT_SECRET:
        return jsonify({
            "error": "POWERSYNC_JWT_SECRET no está configurado"
        }), 500

    now = datetime.now(timezone.utc)

    expires_at = now + timedelta(minutes=15)

    payload = {
        "sub": g.kospia_user_id,
        "aud": Config.POWERSYNC_JWT_AUDIENCE,
        "iss": "flora-backend",
        "iat": int(now.timestamp()),
        "exp": int(expires_at.timestamp()),
    }

    secret_bytes = decode_base64url(
        Config.POWERSYNC_JWT_SECRET
    )

    token = jwt.encode(
        payload,
        secret_bytes,
        algorithm="HS256",
        headers={
            "kid": Config.POWERSYNC_JWT_KID,
        },
    )

    return jsonify({
        "token": token,
        "expires_at": expires_at.isoformat(),
    }), 200


@auth.route("/auth/google", methods=["POST"])
def google_login():
    data = request.get_json(silent=True) or {}
    google_id_token = data.get("id_token")

    if not google_id_token:
        return jsonify({
            "error": "El campo id_token es obligatorio"
        }), 400

    if not Config.GOOGLE_CLIENT_ID:
        return jsonify({
            "error": "GOOGLE_CLIENT_ID no está configurado"
        }), 500

    if not Config.KOSPIA_JWT_SECRET:
        return jsonify({
            "error": "KOSPIA_JWT_SECRET no está configurado"
        }), 500

    try:
        verified = id_token.verify_oauth2_token(
            google_id_token,
            requests.Request(),
            audience=Config.GOOGLE_CLIENT_ID,
        )
    except ValueError:
        return jsonify({
            "error": "Token de Google inválido o expirado"
        }), 401
    except Exception:
        return jsonify({
            "error": "Error al verificar el token de Google"
        }), 401

    google_sub = verified.get("sub")
    email = verified.get("email")
    display_name = verified.get("name")
    photo_url = verified.get("picture")

    if not google_sub:
        return jsonify({
            "error": "Token de Google sin sub válido"
        }), 401

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT id, email, display_name, photo_url
            FROM public.users
            WHERE google_sub = %s
            LIMIT 1;
            """,
            (google_sub,),
        )
        row = cursor.fetchone()

        if row is None:
            user_id = str(uuid.uuid4())
            cursor.execute(
                """
                INSERT INTO public.users (
                    id,
                    google_sub,
                    email,
                    display_name,
                    photo_url,
                    created_at,
                    updated_at
                )
                VALUES (%s, %s, %s, %s, %s, NOW(), NOW());
                """,
                (
                    user_id,
                    google_sub,
                    email,
                    display_name,
                    photo_url,
                ),
            )
        else:
            user_id = str(row[0])
            cursor.execute(
                """
                UPDATE public.users
                SET
                    email = %s,
                    display_name = %s,
                    photo_url = %s,
                    updated_at = NOW()
                WHERE id = %s;
                """,
                (
                    email,
                    display_name,
                    photo_url,
                    user_id,
                ),
            )

        conn.commit()

        now = datetime.now(timezone.utc)
        expires_at = now + timedelta(days=7)
        kospia_token = jwt.encode(
            {
                "sub": user_id,
                "iat": int(now.timestamp()),
                "exp": int(expires_at.timestamp()),
            },
            Config.KOSPIA_JWT_SECRET,
            algorithm="HS256",
        )

        return jsonify({
            "access_token": kospia_token,
            "user": {
                "id": user_id,
                "email": email,
                "display_name": display_name,
                "photo_url": photo_url,
            }
        }), 200

    except psycopg2.Error:
        conn.rollback()
        return jsonify({
            "error": "Error al crear o actualizar el usuario"
        }), 500
    except Exception:
        conn.rollback()
        return jsonify({
            "error": "Error interno"
        }), 500
    finally:
        cursor.close()
        conn.close()