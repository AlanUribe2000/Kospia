from flask import Blueprint, jsonify, request

from database.connection import get_connection


observaciones = Blueprint("observaciones", __name__)


@observaciones.route("/observaciones", methods=["GET"])
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
def create_kospia_observation():

    data = request.get_json(silent=True) or {}

    observation_id = data.get("id")
    user_id = data.get("user_id")
    species_id = data.get("species_id")
    notes = data.get("notes", "")
    created_at = data.get("created_at")
    updated_at = data.get("updated_at")

    if not observation_id:
        return jsonify({
            "error": "El campo id es obligatorio"
        }), 400

    if not user_id:
        return jsonify({
            "error": "El campo user_id es obligatorio"
        }), 400

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
                user_id = EXCLUDED.user_id,
                species_id = EXCLUDED.species_id,
                notes = EXCLUDED.notes,
                sync_status = 'synced',
                updated_at = EXCLUDED.updated_at,
                synced_at = NOW()
            RETURNING id;
        """, (
            observation_id,
            user_id,
            species_id,
            notes,
            created_at,
            updated_at,
        ))

        saved = cursor.fetchone()

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