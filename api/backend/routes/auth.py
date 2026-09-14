import base64
from datetime import datetime, timedelta, timezone

import jwt
from flask import Blueprint, jsonify

from config import Config


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
def powersync_token():

    if not Config.POWERSYNC_JWT_SECRET:
        return jsonify({
            "error": "POWERSYNC_JWT_SECRET no está configurado"
        }), 500

    now = datetime.now(timezone.utc)

    expires_at = now + timedelta(minutes=15)

    # Por ahora usamos un usuario fijo de desarrollo.
    # Más adelante será el ID del usuario autenticado.
    user_id = "test-user"

    payload = {
        "sub": user_id,
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