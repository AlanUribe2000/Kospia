from flask import Blueprint, jsonify, request


from database.connection import get_connection

tasks = Blueprint("tasks", __name__)


@tasks.route("/tasks", methods=["GET"])
def get_tasks():

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT id, title, completed
            FROM public.tasks
            ORDER BY title;
        """)

        rows = cursor.fetchall()

        result = []

        for row in rows:
            result.append({
                "id": str(row[0]),
                "title": row[1],
                "completed": row[2]
            })

        return jsonify(result), 200

    except Exception as e:
        conn.rollback()
        return jsonify({
            "error": "No se pudieron obtener las tareas",
            "details": str(e)
        }), 500

    finally:
        cursor.close()
        conn.close()

@tasks.route("/tasks/<string:task_id>", methods=["DELETE"])
def delete_task(task_id):

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            DELETE FROM public.tasks
            WHERE id = %s;
        """, (
            task_id,
        ))

        conn.commit()

        return jsonify({
            "message": "Tarea eliminada correctamente",
            "id": task_id
        }), 200

    except Exception as e:

        conn.rollback()

        return jsonify({
            "error": "No se pudo eliminar la tarea",
            "details": str(e)
        }), 500

    finally:

        cursor.close()
        conn.close()

@tasks.route("/tasks", methods=["POST"])
def create_task():
    data = request.get_json(silent=True) or {}

    task_id = data.get("id")
    title = data.get("title")
    completed = data.get("completed", False)

    if not task_id:
        return jsonify({
            "error": "El campo id es obligatorio"
        }), 400

    if not title or not str(title).strip():
        return jsonify({
            "error": "El campo title es obligatorio"
        }), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            INSERT INTO public.tasks (
                id,
                title,
                completed
            )
            VALUES (%s, %s, %s)
            ON CONFLICT (id) DO NOTHING
            RETURNING id;
            """,
            (
                task_id,
                str(title).strip(),
                bool(completed),
            ),
        )

        inserted_task = cursor.fetchone()

        conn.commit()

        if inserted_task is None:
            # El registro ya existía, posiblemente porque PowerSync
            # reintentó una operación que ya había llegado al servidor.
            return jsonify({
                "message": "La tarea ya estaba guardada",
                "id": task_id
            }), 200

        return jsonify({
            "message": "Tarea creada correctamente",
            "id": str(inserted_task[0])
        }), 201

    except Exception as error:
        conn.rollback()

        return jsonify({
            "error": "No se pudo crear la tarea",
            "details": str(error)
        }), 500

    finally:
        cursor.close()
        conn.close()

@tasks.route("/tasks/<string:task_id>", methods=["PATCH"])
def update_task(task_id):
    data = request.get_json(silent=True) or {}

    title = data.get("title")
    completed = data.get("completed")

    if title is None:
        return jsonify({
            "error": "El campo title es obligatorio"
        }), 400

    if completed is None:
        return jsonify({
            "error": "El campo completed es obligatorio"
        }), 400

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            UPDATE public.tasks
            SET
                title = %s,
                completed = %s
            WHERE id = %s
            RETURNING id;
            """,
            (
                str(title).strip(),
                bool(completed),
                task_id,
            ),
        )

        updated_task = cursor.fetchone()

        if updated_task is None:
            conn.rollback()

            return jsonify({
                "error": "La tarea ya no existe",
                "id": task_id
            }), 404

        conn.commit()

        return jsonify({
            "message": "Tarea actualizada correctamente",
            "id": str(updated_task[0])
        }), 200

    except Exception as error:
        conn.rollback()

        return jsonify({
            "error": "No se pudo actualizar la tarea",
            "details": str(error)
        }), 500

    finally:
        cursor.close()
        conn.close()