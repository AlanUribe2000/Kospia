import os

from flask import Blueprint, g, request, jsonify, send_file

from authentication import require_kospia_jwt
from database.connection import get_connection

attachments = Blueprint("attachments", __name__)


# Carpeta donde se almacenarán físicamente las fotografías.
BASE_DIR = os.path.dirname(
    os.path.dirname(os.path.abspath(__file__))
)

UPLOAD_FOLDER = os.path.join(
    BASE_DIR,
    "uploads",
    "observaciones"
)


def _ensure_upload_folder():
    """
    Crea la carpeta de uploads si todavía no existe.
    """
    os.makedirs(
        UPLOAD_FOLDER,
        exist_ok=True,
    )


def _get_attachment_path(
    attachment_id,
    extension,
):
    """
    Construye la ruta física del archivo.
    """

    # Evitamos que nos pasen extensiones con puntos.
    extension = extension.lstrip(".").lower()

    return os.path.join(
        UPLOAD_FOLDER,
        f"{attachment_id}.{extension}",
    )


def _get_attachment_owner(attachment_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT o.user_id
            FROM public.observation_photos p
            JOIN public.observations o ON o.id = p.observation_id
            WHERE p.id = %s
            LIMIT 1;
        """, (attachment_id,))
        row = cursor.fetchone()
        return str(row[0]) if row is not None else None
    finally:
        cursor.close()
        conn.close()


def _require_attachment_owner(attachment_id):
    owner_id = _get_attachment_owner(attachment_id)
    if owner_id is None:
        return jsonify({
            "error": "El attachment no existe"
        }), 404
    if owner_id != g.kospia_user_id:
        return jsonify({
            "error": "El attachment pertenece a otro usuario"
        }), 403
    return None


@attachments.route(
    "/attachments/<string:attachment_id>",
    methods=["PUT"],
)
@require_kospia_jwt
def upload_attachment(attachment_id):
    """
    Recibe un archivo enviado por Flutter / PowerSync.

    Ejemplo:
    PUT /attachments/abc-123?extension=jpg
    """

    ownership_error = _require_attachment_owner(attachment_id)
    if ownership_error is not None:
        return ownership_error

    extension = request.args.get(
        "extension",
        "jpg",
    )

    allowed_extensions = {
        "jpg",
        "jpeg",
        "png",
        "webp",
    }

    extension = extension.lower().lstrip(".")

    if extension not in allowed_extensions:
        return jsonify({
            "error": "Extensión de archivo no permitida"
        }), 400

    _ensure_upload_folder()

    file_path = _get_attachment_path(
        attachment_id,
        extension,
    )

    try:
        with open(file_path, "wb") as file:
            file.write(request.get_data())

        return jsonify({
            "message": "Archivo guardado correctamente",
            "id": attachment_id,
            "extension": extension,
        }), 200

    except Exception as error:
        return jsonify({
            "error": "No se pudo guardar el archivo",
            "details": str(error),
        }), 500


@attachments.route(
    "/attachments/<string:attachment_id>",
    methods=["GET"],
)
@require_kospia_jwt
def download_attachment(attachment_id):
    """
    Devuelve un attachment almacenado en el servidor.
    """

    ownership_error = _require_attachment_owner(attachment_id)
    if ownership_error is not None:
        return ownership_error

    extension = request.args.get(
        "extension",
        "jpg",
    )

    extension = extension.lower().lstrip(".")

    file_path = _get_attachment_path(
        attachment_id,
        extension,
    )

    if not os.path.exists(file_path):
        return jsonify({
            "error": "Archivo no encontrado"
        }), 404

    return send_file(file_path)


@attachments.route(
    "/attachments/<string:attachment_id>",
    methods=["DELETE"],
)
@require_kospia_jwt
def delete_attachment(attachment_id):
    """
    Elimina físicamente un attachment.
    """

    ownership_error = _require_attachment_owner(attachment_id)
    if ownership_error is not None:
        return ownership_error

    extension = request.args.get(
        "extension",
        "jpg",
    )

    extension = extension.lower().lstrip(".")

    file_path = _get_attachment_path(
        attachment_id,
        extension,
    )

    if not os.path.exists(file_path):
        # Lo tratamos como operación idempotente.
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