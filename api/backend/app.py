from flask import Flask
from flask_cors import CORS
from flask_smorest import Api

from routes.tasks import tasks
from routes.observaciones import observaciones
from routes.attachments import attachments
from routes.fotografias import fotografias
from routes.auth import auth
from routes.professional import professional

from config import Config

app = Flask(__name__)
app.config.from_object(Config)

api = Api(app)

CORS(app)

api.register_blueprint(tasks)
api.register_blueprint(observaciones)
api.register_blueprint(attachments)
api.register_blueprint(fotografias)
api.register_blueprint(auth)

# professional es un Blueprint común de Flask, no de flask-smorest.
app.register_blueprint(professional)

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )