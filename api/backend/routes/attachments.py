import os

from flask import Blueprint, request, jsonify, send_file

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


@attachments.route(
    "/attachments/<string:attachment_id>",
    methods=["PUT"],
)
def upload_attachment(attachment_id):
    """
    Recibe un archivo enviado por Flutter / PowerSync.

    Ejemplo:
    PUT /attachments/abc-123?extension=jpg
    """

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
def download_attachment(attachment_id):
    """
    Devuelve un attachment almacenado en el servidor.
    """

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
def delete_attachment(attachment_id):
    """
    Elimina físicamente un attachment.
    """

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