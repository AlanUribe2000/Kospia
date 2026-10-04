import os

from flask import g, request, jsonify, send_file
from flask_smorest import Blueprint

from authentication import require_kospia_jwt
from database.connection import get_connection

attachments = Blueprint("attachments", __name__)

ALLOWED_EXTENSIONS = {
    "jpg",
    "jpeg",
    "png",
    "webp",
}

PROFESSIONAL_ROLES = {"professional", "admin"}


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


def _get_attachment_owner_and_extension(attachment_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT o.user_id, p.file_extension
            FROM public.observation_photos p
            JOIN public.observations o ON o.id = p.observation_id
            WHERE p.id = %s
            LIMIT 1;
        """, (attachment_id,))
        row = cursor.fetchone()
        if row is None:
            return None, None
        return str(row[0]), row[1]
    finally:
        cursor.close()
        conn.close()


def _get_user_role(user_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT role
            FROM public.users
            WHERE id = %s
            LIMIT 1;
        """, (user_id,))
        row = cursor.fetchone()
        return row[0] if row is not None else None
    finally:
        cursor.close()
        conn.close()


@attachments.route(
    "/attachments/<string:attachment_id>",
    methods=["PUT"],
)
@attachments.doc(
    summary="Subir un archivo adjunto",
    description=(
        "Carga los bytes del archivo para el `attachment_id` indicado en la "
        "ruta. Requiere un token Kospia y que el registro de fotografía esté "
        "vinculado a una observación del usuario autenticado. Envíe el contenido "
        "binario directamente en el cuerpo, no como JSON ni como formulario.\n\n"
        "El parámetro de consulta `extension` es opcional, por defecto `jpg`, "
        "y solo admite `jpg`, `jpeg`, `png` o `webp`. El archivo queda guardado "
        "en el almacenamiento del servidor.\n\n"
        "**Respuesta:** `200` con mensaje, id y extensión. Responde con `400` "
        "si la extensión no está permitida, `404` si no existe el registro del "
        "adjunto, `403` si pertenece a otro usuario y `500` si falla la escritura."
    ),
    parameters=[
        {
            "name": "attachment_id",
            "in": "path",
            "required": True,
            "description": "Identificador de la fotografía/adjunto asociado a la observación.",
            "schema": {"type": "string"},
        },
        {
            "name": "extension",
            "in": "query",
            "required": False,
            "description": "Extensión del archivo. Acepta jpg, jpeg, png o webp; por defecto es jpg.",
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
                "schema": {
                    "type": "string",
                    "format": "binary",
                    "description": "Bytes del archivo de imagen.",
                },
            },
        },
    },
    security=[{"KospiaBearerAuth": []}],
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

    extension = extension.lower().lstrip(".")

    if extension not in ALLOWED_EXTENSIONS:
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
@attachments.doc(
    summary="Descargar un archivo adjunto",
    description=(
        "Devuelve el archivo binario asociado al `attachment_id` de la ruta. "
        "Requiere un token Kospia. Pueden descargarlo el propietario de la "
        "observación y los usuarios con rol `professional` o `admin` (el rol se "
        "consulta en la base de datos). La extensión se toma de la "
        "`file_extension` guardada para la fotografía; el parámetro de consulta "
        "`extension` se ignora y se conserva solo por compatibilidad.\n\n"
        "**Respuesta:** contenido del archivo con su tipo MIME detectado por "
        "Flask. Responde con `404` si no existe el registro del adjunto o el "
        "archivo físico, `403` si pertenece a otro usuario y quien consulta no "
        "es profesional ni admin, y `400` si la extensión guardada no está permitida."
    ),
    parameters=[
        {
            "name": "attachment_id",
            "in": "path",
            "required": True,
            "description": "Identificador de la fotografía/adjunto que se descargará.",
            "schema": {"type": "string"},
        },
        {
            "name": "extension",
            "in": "query",
            "required": False,
            "description": "Se ignora al descargar: la extensión sale de file_extension en la base. Se conserva por compatibilidad.",
            "schema": {"type": "string", "default": "jpg"},
        },
    ],
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
def download_attachment(attachment_id):
    """
    Devuelve un attachment almacenado en el servidor.

    Permite acceso al propietario o a usuarios con role professional/admin.
    La extensión se resuelve desde observation_photos.file_extension,
    ignorando el query param ?extension= (se mantiene por compatibilidad).
    """

    owner_id, file_extension = _get_attachment_owner_and_extension(
        attachment_id
    )

    if owner_id is None:
        return jsonify({
            "error": "El attachment no existe"
        }), 404

    if owner_id != g.kospia_user_id:
        role = _get_user_role(g.kospia_user_id)
        if role not in PROFESSIONAL_ROLES:
            return jsonify({
                "error": "El attachment pertenece a otro usuario"
            }), 403

    extension = (file_extension or "").lower().lstrip(".")

    if extension not in ALLOWED_EXTENSIONS:
        return jsonify({
            "error": "Extensión de archivo no permitida"
        }), 400

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
@attachments.doc(
    summary="Eliminar un archivo adjunto",
    description=(
        "Elimina del almacenamiento del servidor el archivo asociado al "
        "`attachment_id` indicado. Requiere un token Kospia y que el registro "
        "pertenezca a una observación del usuario autenticado. El parámetro de "
        "consulta `extension` es opcional y por defecto es `jpg`; debe coincidir "
        "con la extensión del archivo.\n\n"
        "**Respuesta:** `200` con un mensaje de confirmación. Si el registro del "
        "adjunto no existe, responde con `404`; si pertenece a otro usuario, "
        "responde con `403`. Si el registro existe pero el archivo físico ya fue "
        "eliminado, responde igualmente con `200`. Los errores al borrar "
        "responden con `500`."
    ),
    parameters=[
        {
            "name": "attachment_id",
            "in": "path",
            "required": True,
            "description": "Identificador de la fotografía/adjunto cuyo archivo se eliminará.",
            "schema": {"type": "string"},
        },
        {
            "name": "extension",
            "in": "query",
            "required": False,
            "description": "Extensión del archivo que se eliminará; por defecto es jpg.",
            "schema": {"type": "string", "default": "jpg"},
        },
    ],
    security=[{"KospiaBearerAuth": []}],
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