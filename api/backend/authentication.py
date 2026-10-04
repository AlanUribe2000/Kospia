from functools import wraps

from database.connection import get_connection

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


def require_role(*allowed_roles):
    def decorator(route):
        @wraps(route)
        def wrapped(*args, **kwargs):
            user_id = getattr(g, "kospia_user_id", None)

            if not user_id:
                return jsonify({
                    "error": "Usuario Kospia no autenticado"
                }), 401

            conn = get_connection()
            cursor = conn.cursor()

            try:
                cursor.execute(
                    """
                    SELECT role
                    FROM public.users
                    WHERE id = %s
                    LIMIT 1;
                    """,
                    (user_id,),
                )

                row = cursor.fetchone()

                if row is None:
                    return jsonify({
                        "error": "Usuario Kospia no encontrado"
                    }), 401

                role = row[0]

                if role not in allowed_roles:
                    return jsonify({
                        "error": "No tenés permisos para acceder a este recurso"
                    }), 403

                g.kospia_user_role = role

                return route(*args, **kwargs)

            finally:
                cursor.close()
                conn.close()

        return wrapped

    return decorator
