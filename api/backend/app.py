import logging

from flask import Flask
from flask_cors import CORS
from flask_smorest import Api
from werkzeug.exceptions import HTTPException

from routes.tasks import tasks
from routes.observaciones import observaciones
from routes.attachments import attachments
from routes.fotografias import fotografias
from routes.auth import auth
from routes.professional import professional
from routes.notifications import notifications

from config import Config

logging.basicConfig(
    level=getattr(logging, str(Config.LOG_LEVEL).upper(), logging.INFO),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

app = Flask(__name__)
app.config.from_object(Config)

api = Api(app)

CORS(app)


@app.errorhandler(Exception)
def handle_unexpected(exc):
    # Deja las respuestas HTTP normales (404/401/409, etc.) intactas: en
    # Flask 3 el errorhandler(Exception) también recibe las HTTPException, así
    # que las re-devolvemos con su propio código en lugar de convertirlas en
    # 500. Sólo las excepciones realmente no controladas quedan como 500.
    if isinstance(exc, HTTPException):
        return exc

    app.logger.exception("Excepción no controlada")

    return {"error": "Error interno"}, 500

api.register_blueprint(tasks)
api.register_blueprint(observaciones)
api.register_blueprint(attachments)
api.register_blueprint(fotografias)
api.register_blueprint(auth)

# professional es un Blueprint común de Flask, no de flask-smorest.
app.register_blueprint(professional)
app.register_blueprint(notifications)

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )