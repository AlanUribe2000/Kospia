from flask import g, jsonify, request
from flask_smorest import Blueprint

from authentication import require_kospia_jwt
from database.connection import get_connection


fotografias = Blueprint("fotografias", __name__)


@fotografias.route("/fotografias-observacion", methods=["GET"])
@fotografias.doc(
    summary="Listar fotografías de observaciones",
    description=(
        "Lista los metadatos de fotografías del esquema legado cuyo "
        "`deleted_at` es nulo, ordenados por fecha de creación descendente. "
        "No requiere parámetros, cuerpo ni autenticación.\n\n"
        "**Respuesta:** lista con `id`, `observacion_id`, `tipo_foto`, "
        "`file_extension`, `mime_type`, fechas de creación/actualización, "
        "`deleted_at` y `version`. Las fechas se devuelven como texto ISO 8601; "
        "ante un error de consulta, responde con `500` y un mensaje de error."
    ),
)
def get_fotografias():

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT
                id,
                observacion_id,
                tipo_foto,
                file_extension,
                mime_type,
                created_at,
                updated_at,
                deleted_at,
                version
            FROM public.fotografias_observacion
            WHERE deleted_at IS NULL
            ORDER BY created_at DESC;
        """)

        rows = cursor.fetchall()

        result = []

        for row in rows:
            result.append({
                "id": str(row[0]),
                "observacion_id": str(row[1]),
                "tipo_foto": row[2],
                "file_extension": row[3],
                "mime_type": row[4],
                "created_at":
                    row[5].isoformat() if row[5] else None,
                "updated_at":
                    row[6].isoformat() if row[6] else None,
                "deleted_at":
                    row[7].isoformat() if row[7] else None,
                "version": row[8],
            })

        return jsonify(result), 200

    except Exception as error:
        conn.rollback()

        return jsonify({
            "error": "No se pudieron obtener las fotografías",
            "details": str(error),
        }), 500

    finally:
        cursor.close()
        conn.close()


@fotografias.route("/fotografias-observacion", methods=["POST"])
@fotografias.doc(
    summary="Registrar una fotografía de observación",
    description=(
        "Registra los metadatos de una fotografía en el esquema legado; no "
        "sube el archivo de imagen. El JSON requiere `id`, `observacion_id` y "
        "`tipo_foto`; `file_extension` y `mime_type` son opcionales.\n\n"
        "**Respuesta:** mensaje e identificador. Una nueva fila responde con "
        "`201`; si el `id` ya estaba registrado, evita duplicarla y responde "
        "con `200`. Si falta un campo obligatorio, responde con `400`; ante un "
        "error de persistencia, responde con `500`."
    ),
    requestBody={
        "required": True,
        "content": {
            "application/json": {
                "schema": {
                    "type": "object",
                    "properties": {
                        "id": {"type": "string", "description": "Identificador del registro fotográfico."},
                        "observacion_id": {"type": "string", "description": "Identificador de la observación asociada."},
                        "tipo_foto": {"type": "string", "description": "Tipo o categoría de fotografía."},
                        "file_extension": {"type": "string", "description": "Extensión del archivo, si está disponible."},
                        "mime_type": {"type": "string", "description": "Tipo MIME del archivo, si está disponible."},
                    },
                    "required": ["id", "observacion_id", "tipo_foto"],
                },
            },
        },
    },
)
def create_fotografia():

    data = request.get_json(silent=True) or {}

    fotografia_id = data.get("id")
    observacion_id = data.get("observacion_id")
    tipo_foto = data.get("tipo_foto")
    file_extension = data.get("file_extension")
    mime_type = data.get("mime_type")

    if not fotografia_id:
        return jsonify({
            "error": "El campo id es obligatorio"
        }), 400

    if not observacion_id:
        return jsonify({
            "error": "El campo observacion_id es obligatorio"
        }), 400

    if not tipo_foto:
        return jsonify({
            "error": "El campo tipo_foto es obligatorio"
        }), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO public.fotografias_observacion (
                id,
                observacion_id,
                tipo_foto,
                file_extension,
                mime_type,
                version
            )
            VALUES (%s, %s, %s, %s, %s, 1)
            ON CONFLICT (id) DO NOTHING
            RETURNING id;
        """, (
            fotografia_id,
            observacion_id,
            tipo_foto,
            file_extension,
            mime_type,
        ))

        inserted = cursor.fetchone()

        conn.commit()

        if inserted is None:
            return jsonify({
                "message": "La fotografía ya estaba registrada",
                "id": fotografia_id,
            }), 200

        return jsonify({
            "message": "Fotografía registrada correctamente",
            "id": str(inserted[0]),
        }), 201

    except Exception as error:
        conn.rollback()

        return jsonify({
            "error": "No se pudo registrar la fotografía",
            "details": str(error),
        }), 500

    finally:
        cursor.close()
        conn.close()


@fotografias.route("/observation-photos", methods=["POST"])
@fotografias.doc(
    summary="Sincronizar una fotografía Kospia",
    description=(
        "Crea o sincroniza los metadatos de una fotografía; no carga los bytes "
        "del archivo. Requiere token Kospia y un JSON con `id`, `observation_id`, "
        "`photo_path`, `latitude` y `longitude`. Son opcionales `plant_part` "
        "(por defecto `general`), `altitude` y `accuracy` (por defecto `0.0`), "
        "`source` (por defecto `camera`), `captured_at` y `file_extension` "
        "(por defecto `jpg`).\n\n"
        "La observación debe existir y pertenecer al usuario autenticado. Si ya "
        "hay una fotografía con ese `id`, solo puede actualizarse si pertenece "
        "al mismo usuario y a la misma observación.\n\n"
        "**Respuesta:** `200` con mensaje e identificador. Responde con `400` "
        "si faltan campos obligatorios, `404` si la observación no existe, "
        "`403` si la observación/fotografía pertenece a otro usuario o está "
        "asociada a otra observación, y `500` ante un error de persistencia."
    ),
    requestBody={
        "required": True,
        "content": {
            "application/json": {
                "schema": {
                    "type": "object",
                    "properties": {
                        "id": {"type": "string", "description": "Identificador único de la fotografía."},
                        "observation_id": {"type": "string", "description": "Identificador de la observación asociada."},
                        "photo_path": {"type": "string", "description": "Ruta o referencia del archivo fotográfico."},
                        "plant_part": {"type": "string", "default": "general", "description": "Parte de la planta fotografiada."},
                        "latitude": {"type": "number", "description": "Latitud de captura."},
                        "longitude": {"type": "number", "description": "Longitud de captura."},
                        "altitude": {"type": "number", "default": 0.0, "description": "Altitud de captura."},
                        "accuracy": {"type": "number", "default": 0.0, "description": "Precisión estimada de la ubicación."},
                        "source": {"type": "string", "default": "camera", "description": "Origen de la fotografía."},
                        "captured_at": {"type": "string", "format": "date-time", "description": "Fecha y hora de captura."},
                        "file_extension": {"type": "string", "default": "jpg", "description": "Extensión del archivo."},
                    },
                    "required": ["id", "observation_id", "photo_path", "latitude", "longitude"],
                },
            },
        },
    },
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
def create_kospia_observation_photo():

    data = request.get_json(silent=True) or {}

    photo_id = data.get("id")
    observation_id = data.get("observation_id")
    photo_path = data.get("photo_path")
    plant_part = data.get("plant_part", "general")

    latitude = data.get("latitude")
    longitude = data.get("longitude")
    altitude = data.get("altitude", 0.0)
    accuracy = data.get("accuracy", 0.0)

    source = data.get("source", "camera")
    captured_at = data.get("captured_at")

    file_extension = data.get(
    "file_extension",
    "jpg",
)

    if not photo_id:
        return jsonify({
            "error": "El campo id es obligatorio"
        }), 400

    if not observation_id:
        return jsonify({
            "error": "El campo observation_id es obligatorio"
        }), 400

    if photo_path is None:
        return jsonify({
            "error": "El campo photo_path es obligatorio"
        }), 400

    if latitude is None:
        return jsonify({
            "error": "El campo latitude es obligatorio"
        }), 400

    if longitude is None:
        return jsonify({
            "error": "El campo longitude es obligatorio"
        }), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT user_id
            FROM public.observations
            WHERE id = %s
            LIMIT 1;
        """, (observation_id,))
        observation = cursor.fetchone()

        if observation is None:
            conn.rollback()
            return jsonify({
                "error": "La observación no existe"
            }), 404

        if str(observation[0]) != g.kospia_user_id:
            conn.rollback()
            return jsonify({
                "error": "La observación pertenece a otro usuario"
            }), 403

        cursor.execute("""
            SELECT p.observation_id, o.user_id
            FROM public.observation_photos p
            JOIN public.observations o ON o.id = p.observation_id
            WHERE p.id = %s
            LIMIT 1;
        """, (photo_id,))
        existing_photo = cursor.fetchone()

        if existing_photo is not None:
            if str(existing_photo[1]) != g.kospia_user_id:
                conn.rollback()
                return jsonify({
                    "error": "La fotografía pertenece a otro usuario"
                }), 403
            if str(existing_photo[0]) != observation_id:
                conn.rollback()
                return jsonify({
                    "error": "La fotografía ya pertenece a otra observación"
                }), 403

        cursor.execute("""
    INSERT INTO public.observation_photos (
        id,
        observation_id,
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
    )
    VALUES (
        %s,
        %s,
        %s,
        %s,
        %s,
        %s,
        %s,
        %s,
        %s,
        'synced',
        COALESCE(%s::timestamptz, NOW()),
        %s
    )
    ON CONFLICT (id)
    DO UPDATE SET
        observation_id = EXCLUDED.observation_id,
        photo_path = EXCLUDED.photo_path,
        plant_part = EXCLUDED.plant_part,
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude,
        altitude = EXCLUDED.altitude,
        accuracy = EXCLUDED.accuracy,
        source = EXCLUDED.source,
        sync_status = 'synced',
        captured_at = EXCLUDED.captured_at,
        file_extension = EXCLUDED.file_extension
    RETURNING id;
""", (
    photo_id,
    observation_id,
    photo_path,
    plant_part,
    latitude,
    longitude,
    altitude,
    accuracy,
    source,
    captured_at,
    file_extension,
))

        saved = cursor.fetchone()

        conn.commit()

        return jsonify({
            "message": "Metadatos de fotografía guardados correctamente",
            "id": str(saved[0])
        }), 200

    except Exception as error:
        conn.rollback()

        return jsonify({
            "error": "No se pudieron guardar los metadatos de la fotografía",
            "details": str(error)
        }), 500

    finally:
        cursor.close()
        conn.close()