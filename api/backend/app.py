from flask import Flask
from flask_cors import CORS

from routes.tasks import tasks
from routes.observaciones import observaciones
from routes.attachments import attachments
from routes.fotografias import fotografias
from routes.auth import auth

from config import Config

app = Flask(__name__)

CORS(app)

app.register_blueprint(tasks)
app.register_blueprint(observaciones)
app.register_blueprint(attachments)
app.register_blueprint(fotografias)
app.register_blueprint(auth)

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )