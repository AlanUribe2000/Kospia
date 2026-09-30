from flask import g, jsonify, request
from flask_smorest import Blueprint

from authentication import require_kospia_jwt
from database.connection import get_connection


observaciones = Blueprint("observaciones", __name__)


@observaciones.route("/observaciones", methods=["GET"])
@observaciones.doc(
    summary="Listar observaciones",
    description=(
        "Lista las observaciones del esquema legado que no tienen `deleted_at`. "
        "Se ordenan por `fecha_registro`, de la más reciente a la más antigua, "
        "y se incluyen los nombres común y científico de la especie propuesta "
        "cuando hay una coincidencia en el catálogo. No requiere autenticación, "
        "parámetros ni cuerpo.\n\n"
        "**Respuesta:** lista de observaciones con identificador, especie "
        "propuesta y validada, descripción, coordenadas, fechas, estado de "
        "validación, comentario profesional y versión. Las fechas se devuelven "
        "como texto ISO 8601; ante un error de consulta, responde con `500` y "
        "un mensaje de error."
    ),
)
def get_observaciones():

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT
                o.id,
                o.especie_propuesta_id,
                f.nombre_comun,
                f.nombre_cientifico,
                o.descripcion,
                o.latitud,
                o.longitud,
                o.fecha_registro,
                o.estado_validacion,
                o.especie_validada_id,
                o.comentario_profesional,
                o.created_at,
                o.updated_at,
                o.deleted_at,
                o.version
            FROM public.observaciones o
            LEFT JOIN public.flores f
                ON f.id = o.especie_propuesta_id
            WHERE o.deleted_at IS NULL
            ORDER BY o.fecha_registro DESC;
        """)

        rows = cursor.fetchall()

        result = []

        for row in rows:
            result.append({
                "id": str(row[0]),
                "especie_propuesta_id":
                    str(row[1]) if row[1] else None,
                "nombre_comun": row[2],
                "nombre_cientifico": row[3],
                "descripcion": row[4],
                "latitud": row[5],
                "longitud": row[6],
                "fecha_registro":
                    row[7].isoformat() if row[7] else None,
                "estado_validacion": row[8],
                "especie_validada_id":
                    str(row[9]) if row[9] else None,
                "comentario_profesional": row[10],
                "created_at":
                    row[11].isoformat() if row[11] else None,
                "updated_at":
                    row[12].isoformat() if row[12] else None,
                "deleted_at":
                    row[13].isoformat() if row[13] else None,
                "version": row[14],
            })

        return jsonify(result), 200

    except Exception as error:
        conn.rollback()

        return jsonify({
            "error": "No se pudieron obtener las observaciones",
            "details": str(error)
        }), 500

    finally:
        cursor.close()
        conn.close()


@observaciones.route("/observaciones", methods=["POST"])
@observaciones.doc(
    summary="Crear una observación",
    description=(
        "Registra una observación en el esquema legado mediante un objeto JSON. "
        "`id` es obligatorio. También se pueden enviar `especie_propuesta_id`, "
        "`descripcion`, `latitud`, `longitud` y `fecha_registro`; si no se "
        "indica la fecha, el servidor usa la fecha y hora actuales. El estado "
        "inicial queda como `pendiente`.\n\n"
        "**Respuesta:** mensaje e identificador de la observación. Una nueva "
        "fila responde con `201`; si el `id` ya estaba guardado, no se duplica "
        "y responde con `200`. Si falta `id`, responde con `400`; ante un error "
        "de persistencia, responde con `500`."
    ),
    requestBody={
        "required": True,
        "content": {
            "application/json": {
                "schema": {
                    "type": "object",
                    "properties": {
                        "id": {"type": "string", "description": "Identificador único de la observación."},
                        "especie_propuesta_id": {"type": "string", "nullable": True, "description": "Identificador de la especie propuesta."},
                        "descripcion": {"type": "string", "nullable": True, "description": "Descripción de la observación."},
                        "latitud": {"type": "number", "nullable": True, "description": "Latitud de la observación."},
                        "longitud": {"type": "number", "nullable": True, "description": "Longitud de la observación."},
                        "fecha_registro": {"type": "string", "format": "date-time", "nullable": True, "description": "Fecha de registro; si se omite o es nula, se usa la hora actual."},
                    },
                    "required": ["id"],
                },
            },
        },
    },
)
def create_observacion():

    data = request.get_json(silent=True) or {}

    observacion_id = data.get("id")
    especie_propuesta_id = data.get("especie_propuesta_id")
    descripcion = data.get("descripcion")
    latitud = data.get("latitud")
    longitud = data.get("longitud")
    fecha_registro = data.get("fecha_registro")

    if not observacion_id:
        return jsonify({
            "error": "El campo id es obligatorio"
        }), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO public.observaciones (
                id,
                especie_propuesta_id,
                descripcion,
                latitud,
                longitud,
                fecha_registro,
                estado_validacion,
                version
            )
            VALUES (
                %s,
                %s,
                %s,
                %s,
                %s,
                COALESCE(%s::timestamptz, NOW()),
                'pendiente',
                1
            )
            ON CONFLICT (id) DO NOTHING
            RETURNING id;
        """, (
            observacion_id,
            especie_propuesta_id,
            descripcion,
            latitud,
            longitud,
            fecha_registro,
        ))

        inserted = cursor.fetchone()

        conn.commit()

        if inserted is None:
            return jsonify({
                "message": "La observación ya estaba guardada",
                "id": observacion_id
            }), 200

        return jsonify({
            "message": "Observación creada correctamente",
            "id": str(inserted[0])
        }), 201

    except Exception as error:

        conn.rollback()

        return jsonify({
            "error": "No se pudo crear la observación",
            "details": str(error)
        }), 500

    finally:
        cursor.close()
        conn.close()


@observaciones.route("/observations", methods=["POST"])
@observaciones.doc(
    summary="Sincronizar una observación Kospia",
    description=(
        "Crea o sincroniza una observación en el esquema de Kospia. Requiere "
        "autenticación con token Kospia y un JSON con `id` y `species_id`. "
        "Acepta `notes` (por defecto, texto vacío), `created_at` y `updated_at` "
        "(por defecto, la hora actual). `user_id` es opcional; si se envía, "
        "debe coincidir con el usuario autenticado.\n\n"
        "Si el `id` ya existe y pertenece al mismo usuario, actualiza especie, "
        "notas y fecha de actualización, y marca el registro como sincronizado. "
        "No permite modificar una observación de otro usuario.\n\n"
        "**Respuesta:** `200` con mensaje e identificador. Responde con `400` "
        "si falta `id` o `species_id`, `403` si el usuario no coincide o el "
        "registro pertenece a otra cuenta, y `500` ante un error de persistencia."
    ),
    requestBody={
        "required": True,
        "content": {
            "application/json": {
                "schema": {
                    "type": "object",
                    "properties": {
                        "id": {"type": "string", "description": "Identificador único de la observación."},
                        "user_id": {"type": "string", "description": "Si se envía, debe coincidir con el usuario del token."},
                        "species_id": {"type": "string", "description": "Identificador de la especie observada."},
                        "notes": {"type": "string", "default": "", "description": "Notas de la observación."},
                        "created_at": {"type": "string", "format": "date-time", "description": "Fecha de creación; por defecto, la hora actual."},
                        "updated_at": {"type": "string", "format": "date-time", "description": "Fecha de actualización; por defecto, la hora actual."},
                    },
                    "required": ["id", "species_id"],
                },
            },
        },
    },
    security=[{"KospiaBearerAuth": []}],
)
@require_kospia_jwt
def create_kospia_observation():

    data = request.get_json(silent=True) or {}

    observation_id = data.get("id")
    requested_user_id = data.get("user_id")
    species_id = data.get("species_id")
    notes = data.get("notes", "")
    created_at = data.get("created_at")
    updated_at = data.get("updated_at")

    if not observation_id:
        return jsonify({
            "error": "El campo id es obligatorio"
        }), 400

    if requested_user_id is not None and requested_user_id != g.kospia_user_id:
        return jsonify({
            "error": "El user_id no coincide con la sesión Kospia"
        }), 403

    if not species_id:
        return jsonify({
            "error": "El campo species_id es obligatorio"
        }), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            INSERT INTO public.observations (
                id,
                user_id,
                species_id,
                notes,
                sync_status,
                created_at,
                updated_at,
                synced_at
            )
            VALUES (
                %s,
                %s,
                %s,
                %s,
                'synced',
                COALESCE(%s::timestamptz, NOW()),
                COALESCE(%s::timestamptz, NOW()),
                NOW()
            )
            ON CONFLICT (id)
            DO UPDATE SET
                species_id = EXCLUDED.species_id,
                notes = EXCLUDED.notes,
                sync_status = 'synced',
                updated_at = EXCLUDED.updated_at,
                synced_at = NOW()
            WHERE public.observations.user_id = EXCLUDED.user_id
            RETURNING id;
        """, (
            observation_id,
            g.kospia_user_id,
            species_id,
            notes,
            created_at,
            updated_at,
        ))

        saved = cursor.fetchone()

        if saved is None:
            conn.rollback()
            return jsonify({
                "error": "La observación pertenece a otro usuario"
            }), 403

        conn.commit()

        return jsonify({
            "message": "Observación Kospia guardada correctamente",
            "id": str(saved[0])
        }), 200

    except Exception as error:
        conn.rollback()

        return jsonify({
            "error": "No se pudo guardar la observación de Kospia",
            "details": str(error)
        }), 500

    finally:
        cursor.close()
        conn.close()