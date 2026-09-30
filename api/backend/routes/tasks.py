from flask import jsonify, request
from flask_smorest import Blueprint


from database.connection import get_connection

tasks = Blueprint("tasks", __name__)


@tasks.route("/tasks", methods=["GET"])
@tasks.doc(
    summary="Listar tareas",
    description=(
        "Consulta las tareas almacenadas y las ordena alfabéticamente por título. "
        "No requiere parámetros ni cuerpo de solicitud.\n\n"
        "**Respuesta:** lista de objetos con `id`, `title` y `completed`; "
        "si no hay tareas, devuelve una lista vacía. Si falla la consulta, "
        "responde con un mensaje de error y el detalle disponible."
    ),
)
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
@tasks.doc(
    summary="Eliminar una tarea",
    description=(
        "Elimina la tarea cuyo identificador se envía en el parámetro de ruta "
        "`task_id`. No requiere cuerpo de solicitud.\n\n"
        "**Respuesta:** mensaje de confirmación y el identificador recibido. "
        "La implementación responde correctamente aunque ese identificador "
        "no encuentre una fila para eliminar; ante un error de base de datos, "
        "devuelve un mensaje de error y su detalle."
    ),
    parameters=[
        {
            "name": "task_id",
            "in": "path",
            "required": True,
            "description": "Identificador de la tarea que se eliminará.",
            "schema": {"type": "string"},
        },
    ],
)
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
@tasks.doc(
    summary="Crear una tarea",
    description=(
        "Crea una tarea a partir de un objeto JSON. `id` y `title` son "
        "obligatorios; `title` no puede quedar vacío después de quitar "
        "espacios. `completed` es opcional y, si se omite, toma el valor "
        "`false`.\n\n"
        "**Respuesta:** devuelve un mensaje y el identificador. Una tarea nueva "
        "responde con `201`; si ya existe una tarea con ese `id`, no la duplica "
        "y responde con `200`. Si falta `id` o `title`, responde con `400`; "
        "los errores de persistencia responden con `500`."
    ),
    requestBody={
        "required": True,
        "content": {
            "application/json": {
                "schema": {
                    "type": "object",
                    "properties": {
                        "id": {"type": "string", "description": "Identificador único de la tarea."},
                        "title": {"type": "string", "description": "Título de la tarea; no puede estar vacío."},
                        "completed": {"type": "boolean", "default": False, "description": "Indica si la tarea está completada."},
                    },
                    "required": ["id", "title"],
                },
            },
        },
    },
)
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
@tasks.doc(
    summary="Actualizar una tarea",
    description=(
        "Actualiza la tarea indicada por `task_id` usando un objeto JSON. "
        "Se requieren `title` y `completed`; ambos deben estar presentes y no "
        "ser `null`. El título se guarda sin espacios al inicio o al final.\n\n"
        "**Respuesta:** mensaje de confirmación e identificador actualizado. "
        "Responde con `400` si falta uno de los campos, `404` si la tarea no "
        "existe y `500` si ocurre un error durante la actualización."
    ),
    parameters=[
        {
            "name": "task_id",
            "in": "path",
            "required": True,
            "description": "Identificador de la tarea que se actualizará.",
            "schema": {"type": "string"},
        },
    ],
    requestBody={
        "required": True,
        "content": {
            "application/json": {
                "schema": {
                    "type": "object",
                    "properties": {
                        "title": {"type": "string", "description": "Nuevo título de la tarea."},
                        "completed": {"type": "boolean", "description": "Nuevo estado de completado."},
                    },
                    "required": ["title", "completed"],
                },
            },
        },
    },
)
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