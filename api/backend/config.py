import os

from dotenv import load_dotenv


load_dotenv()


class Config:
    API_TITLE = "Kospia API"
    API_VERSION = "v1"
    OPENAPI_VERSION = "3.0.3"
    OPENAPI_URL_PREFIX = "/"
    OPENAPI_SWAGGER_UI_PATH = "/swagger-ui"
    OPENAPI_SWAGGER_UI_URL = "https://cdn.jsdelivr.net/npm/swagger-ui-dist/"
    API_SPEC_OPTIONS = {
        "components": {
            "securitySchemes": {
                "KospiaBearerAuth": {
                    "type": "http",
                    "scheme": "bearer",
                    "bearerFormat": "JWT",
                    "description": "Token de acceso JWT emitido por la API de Kospia.",
                },
            },
        },
    }

    DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
    DB_PORT = int(os.getenv("DB_PORT", "5432"))
    DB_NAME = os.getenv("DB_NAME", "postgres")
    DB_USER = os.getenv("DB_USER", "postgres")
    DB_PASSWORD = os.getenv("DB_PASSWORD")

    # PowerSync JWT
    POWERSYNC_JWT_SECRET = os.getenv(
        "POWERSYNC_JWT_SECRET"
    )

    POWERSYNC_JWT_KID = os.getenv(
        "POWERSYNC_JWT_KID",
        "app-key-1"
    )

    POWERSYNC_JWT_AUDIENCE = os.getenv(
        "POWERSYNC_JWT_AUDIENCE",
        "powersync-dev"
    )

    GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")

    KOSPIA_JWT_SECRET = os.getenv("KOSPIA_JWT_SECRET")