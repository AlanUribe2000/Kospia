import importlib
import os
import sys
import tempfile
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path
from unittest.mock import patch

import jwt
import psycopg2


BACKEND_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_DIR))
TEST_SECRET = "isolated-test-only-jwt-secret-0123456789"
USERS = {
    "admin": "11111111-1111-1111-1111-111111111111",
    "professional": "22222222-2222-2222-2222-222222222222",
    "user": "33333333-3333-3333-3333-333333333333",
}


class IsolatedPostgresIntegrationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        port_text = os.environ.get("TEST_ISOLATED_PORT", "")
        marker = os.environ.get("TEST_ISOLATED_MARKER", "")
        if not port_text.isascii() or not port_text.isdecimal():
            raise RuntimeError("TEST_ISOLATED_PORT debe ser un puerto explicito")
        port = int(port_text)
        if not 1 <= port <= 65535 or not marker.startswith("kospia-isolated-"):
            raise RuntimeError("Puerto o marca aislada invalida")

        clean_environment = {
            key: value for key, value in os.environ.items()
            if not key.upper().startswith("PG")
        }
        cls.enterClassContext(patch.dict(os.environ, clean_environment, clear=True))
        cls.enterClassContext(patch("dotenv.load_dotenv", return_value=False))
        original_connect = psycopg2.connect
        allowed = {
            "host": "127.0.0.1",
            "hostaddr": "127.0.0.1",
            "port": port,
            "dbname": "kospia_isolated",
            "user": "postgres",
            "sslmode": "disable",
            "connect_timeout": 5,
        }

        def guarded_connect(*args, **kwargs):
            if args or kwargs != allowed:
                raise RuntimeError("Conexion fuera de la base aislada prohibida")
            return original_connect(**allowed)

        cls.enterClassContext(patch("psycopg2.connect", side_effect=guarded_connect))

        def isolated_connection():
            return psycopg2.connect(**allowed)

        cls.isolated_connection = staticmethod(isolated_connection)
        with isolated_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT marker FROM public.isolated_test_marker")
                if cursor.fetchall() != [(marker,)]:
                    raise RuntimeError("La base no tiene la marca aislada esperada")

        backend_app = importlib.import_module("app")
        authentication = importlib.import_module("authentication")
        admin_catalog = importlib.import_module("routes.admin_catalog")
        cls.help_cards = importlib.import_module("routes.help_cards")
        config = importlib.import_module("config")
        cls.enterClassContext(patch.object(config.Config, "KOSPIA_JWT_SECRET", TEST_SECRET))
        for module in (authentication, admin_catalog, cls.help_cards):
            cls.enterClassContext(patch.object(module, "get_connection", isolated_connection))
        cls.client = backend_app.app.test_client()

    def setUp(self):
        with self.isolated_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("DELETE FROM public.species_traits WHERE species_id = %s", ("sp-001",))
                cursor.execute(
                    "INSERT INTO public.species_traits VALUES (%s, %s, %s, %s), (%s, %s, %s, %s)",
                    ("t-keep", "sp-001", "q-001", "opt-1", "t-remove", "sp-001", "q-002", "opt-3"),
                )
                cursor.execute("UPDATE public.question_options SET description = NULL WHERE id = %s", ("opt-1",))

    def headers(self, role):
        token = jwt.encode(
            {"sub": USERS[role], "exp": datetime.now(timezone.utc) + timedelta(hours=1)},
            TEST_SECRET,
            algorithm="HS256",
        )
        return {"Authorization": f"Bearer {token}"}

    def test_connection_guard_rejects_nonisolated_targets(self):
        for arguments in (
            {},
            {"host": "localhost", "port": os.environ["TEST_ISOLATED_PORT"]},
            {"host": "127.0.0.1"},
        ):
            with self.subTest(arguments=arguments), self.assertRaises(RuntimeError):
                psycopg2.connect(**arguments)
        with self.assertRaises(RuntimeError):
            psycopg2.connect("host=127.0.0.1 dbname=postgres")

    def test_jwt_and_roles(self):
        self.assertEqual(self.client.get("/admin/questions").status_code, 401)
        self.assertEqual(self.client.get("/admin/questions", headers={"Authorization": "Bearer invalid"}).status_code, 401)
        for role in ("user", "professional"):
            with self.subTest(role=role):
                self.assertEqual(self.client.get("/admin/questions", headers=self.headers(role)).status_code, 403)
        for role in ("admin", "professional"):
            with self.subTest(role=role):
                response = self.client.patch("/options/opt-1/help", headers=self.headers(role), json={"description": role})
                self.assertEqual(response.status_code, 200, response.get_data(as_text=True))
        self.assertEqual(self.client.patch("/options/opt-1/help", headers=self.headers("user"), json={"description": "forbidden"}).status_code, 403)

    def test_catalog_questions_species_and_help_cards(self):
        admin = self.headers("admin")
        questions = self.client.get("/admin/questions", headers=admin)
        self.assertEqual(questions.status_code, 200, questions.get_data(as_text=True))
        self.assertEqual([item["id"] for item in questions.json["questions"][0]["options"]], ["opt-1", "opt-2"])
        species = self.client.get("/admin/species", headers=admin)
        self.assertEqual(species.status_code, 200, species.get_data(as_text=True))
        self.assertEqual(species.json["species"][0]["id"], "sp-001")
        detail = self.client.get("/admin/species/sp-001", headers=admin)
        self.assertEqual(detail.status_code, 200, detail.get_data(as_text=True))
        self.assertEqual({trait["id"] for trait in detail.json["species"]["traits"]}, {"t-keep", "t-remove"})
        questions = self.client.get("/questions", headers=self.headers("professional"))
        self.assertEqual(questions.status_code, 200, questions.get_data(as_text=True))
        self.assertEqual(len(questions.json["questions"]), 2)
        options = self.client.get("/questions/q-001/options", headers=self.headers("professional"))
        self.assertEqual(options.status_code, 200, options.get_data(as_text=True))
        self.assertEqual(options.json["options"][0]["photos"], [])

    def test_traits_delta_preserves_ids_and_unchanged_timestamp(self):
        payload = {"traits": [
            {"question_id": "q-001", "option_id": "opt-1"},
            {"question_id": "q-001", "option_id": "opt-2"},
        ]}
        response = self.client.put("/admin/species/sp-001/traits", headers=self.headers("admin"), json=payload)
        self.assertEqual(response.status_code, 200, response.get_data(as_text=True))
        self.assertEqual(response.json["changes"], {"added": 1, "removed": 1, "unchanged": 1})
        self.assertIn("t-keep", {trait["id"] for trait in response.json["species"]["traits"]})
        timestamp = response.json["species"]["updated_at"]
        repeated = self.client.put("/admin/species/sp-001/traits", headers=self.headers("admin"), json=payload)
        self.assertEqual(repeated.status_code, 200, repeated.get_data(as_text=True))
        self.assertEqual(repeated.json["changes"], {"added": 0, "removed": 0, "unchanged": 2})
        self.assertEqual(repeated.json["species"]["updated_at"], timestamp)
        with self.isolated_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT id, option_id FROM public.species_traits WHERE species_id = %s ORDER BY option_id", ("sp-001",))
                rows = cursor.fetchall()
        self.assertEqual(rows[0], ("t-keep", "opt-1"))
        self.assertEqual(rows[1][1], "opt-2")

    def test_help_description_persists_and_rejects_invalid_input(self):
        headers = self.headers("professional")
        response = self.client.patch("/options/opt-1/help", headers=headers, json={"description": "Descripcion ficticia"})
        self.assertEqual(response.status_code, 200, response.get_data(as_text=True))
        self.assertEqual(self.client.patch("/options/opt-1/help", headers=headers, json={"description": 42}).status_code, 400)
        self.assertEqual(self.client.patch("/options/missing/help", headers=headers, json={"description": "x"}).status_code, 404)
        options = self.client.get("/questions/q-001/options", headers=headers)
        self.assertEqual(options.status_code, 200, options.get_data(as_text=True))
        self.assertEqual(options.json["options"][0]["description"], "Descripcion ficticia")

    def test_upload_boundaries_and_signature(self):
        headers = self.headers("professional")
        png = b"\x89PNG\r\n\x1a\n"
        with tempfile.TemporaryDirectory(prefix="isolated_upload_", dir=BACKEND_DIR / "tests") as directory:
            with patch.object(self.help_cards, "UPLOAD_FOLDER", directory):
                url = "/option-images/fixture?extension=png"
                self.assertEqual(self.client.put(url, headers=headers, data=b"invalid").status_code, 400)
                too_large = self.client.put(url, headers=headers, data=png + b"x" * (self.help_cards.MAX_IMAGE_BYTES - len(png) + 1))
                self.assertEqual(too_large.status_code, 413)
                exact = self.client.put(url, headers=headers, data=png + b"x" * (self.help_cards.MAX_IMAGE_BYTES - len(png)))
                self.assertEqual(exact.status_code, 200, exact.get_data(as_text=True))
                self.assertEqual((Path(directory) / "fixture.png").stat().st_size, self.help_cards.MAX_IMAGE_BYTES)
                self.assertEqual(self.client.put(url, headers=headers, data=png).status_code, 409)


if __name__ == "__main__":
    unittest.main()