import os

from dotenv import load_dotenv


load_dotenv()


class Config:
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