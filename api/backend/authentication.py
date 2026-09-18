from functools import wraps

import jwt
from flask import g, jsonify, request

from config import Config


def require_kospia_jwt(route):
    @wraps(route)
    def wrapped(*args, **kwargs):
        authorization = request.headers.get("Authorization", "")
        if not authorization.startswith("Bearer "):
            return jsonify({
                "error": "Autorización Kospia requerida"
            }), 401

        token = authorization.removeprefix("Bearer ").strip()
        if not token:
            return jsonify({
                "error": "Token Kospia requerido"
            }), 401

        if not Config.KOSPIA_JWT_SECRET:
            return jsonify({
                "error": "KOSPIA_JWT_SECRET no está configurado"
            }), 500

        try:
            payload = jwt.decode(
                token,
                Config.KOSPIA_JWT_SECRET,
                algorithms=["HS256"],
                options={"require": ["sub", "exp"]},
            )
        except jwt.ExpiredSignatureError:
            return jsonify({
                "error": "Sesión Kospia expirada"
            }), 401
        except jwt.InvalidTokenError:
            return jsonify({
                "error": "JWT Kospia inválido"
            }), 401

        user_id = payload.get("sub")
        if not isinstance(user_id, str) or not user_id.strip():
            return jsonify({
                "error": "JWT Kospia sin sub válido"
            }), 401

        g.kospia_user_id = user_id
        return route(*args, **kwargs)

    return wrapped
