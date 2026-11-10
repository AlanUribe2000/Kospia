import os
import re
import sys
import unittest
import uuid
from datetime import datetime, timedelta, timezone
from unittest.mock import MagicMock, patch

import jwt
import psycopg2

BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, BACKEND_DIR)

from config import Config  # noqa: E402
import app as backend_app  # noqa: E402
from routes import admin_catalog as admin_module  # noqa: E402

TEST_SECRET = "test-secret-not-used-in-production-0123456789"
USER_ID = "11111111-1111-1111-1111-111111111111"
T0 = datetime(2026, 10, 1, 12, 0, tzinfo=timezone.utc)
T1 = datetime(2026, 10, 2, 12, 0, tzinfo=timezone.utc)


class FakeCursor:
    """Cursor guionado: cada execute() consume el siguiente resultado."""

    def __init__(self, results):
        self._results = list(results)
        self._current = []
        self.executed = []
        self.closed = False

    def execute(self, sql, params=None):
        self.executed.append((sql, params))
        result = self._results.pop(0) if self._results else []

        if isinstance(result, Exception):
            raise result

        self._current = list(result)

    def fetchone(self):
        return self._current[0] if self._current else None

    def fetchall(self):
        return list(self._current)

    def close(self):
        self.closed = True


def make_connection(results):
    cursor = FakeCursor(results)
    conn = MagicMock()
    conn.cursor.return_value = cursor
    return conn, cursor


def make_token(sub=USER_ID, exp_delta=timedelta(hours=1), secret=TEST_SECRET):
    payload = {"sub": sub, "exp": datetime.now(timezone.utc) + exp_delta}
    return jwt.encode(payload, secret, algorithm="HS256")


def species_row(sid="sp-001", common="Calafate", sci="Berberis microphylla",
                family="Berberidaceae", active=True):
    return (sid, common, sci, family, active, T0, T1)


DETAIL_VALUES = (
    "sp-001", "Calafate", "Berberis microphylla", "Arbusto espinoso", "",
    "Berberidaceae", "estepa", "amarillo", "arbusto", "alta", "pequeña",
    "elíptica", "espinoso", "coriácea", True, "foliares", "individual", "6",
    "mediana", True, "esférico", "azul oscuro", "pequeño", "comestible", True,
    T0, T1,
)


class AdminCatalogBase(unittest.TestCase):
    def setUp(self):
        patcher = patch.object(Config, "KOSPIA_JWT_SECRET", TEST_SECRET)
        patcher.start()
        self.addCleanup(patcher.stop)

        self.role = "admin"
        self.role_connections = []
        self.data_conn = None
        self.data_cursor = None

        auth_patch = patch(
            "authentication.get_connection", side_effect=self._role_connection
        )
        data_patch = patch(
            "routes.admin_catalog.get_connection", side_effect=self._data_connection
        )
        auth_patch.start()
        self.data_get_connection = data_patch.start()
        self.addCleanup(auth_patch.stop)
        self.addCleanup(data_patch.stop)

        self.client = backend_app.app.test_client()
        self.headers = {"Authorization": f"Bearer {make_token()}"}

    def _role_connection(self):
        rows = [(self.role,)] if self.role is not None else []
        conn, _ = make_connection([rows])
        self.role_connections.append(conn)
        return conn

    def _data_connection(self):
        if self.data_conn is None:
            raise AssertionError("La prueba no configuró la conexión de datos")

        return self.data_conn

    def set_role(self, role):
        self.role = role

    def set_data(self, results):
        self.data_conn, self.data_cursor = make_connection(results)


class SecurityTests(AdminCatalogBase):
    PATHS = [
        "/admin/questions",
        "/admin/species",
        "/admin/species/sp-001",
        "/admin/species/sp-001/images",
    ]

    def test_without_token_returns_401(self):
        for path in self.PATHS:
            with self.subTest(path=path):
                response = self.client.get(path)
                self.assertEqual(response.status_code, 401)
                self.assertIn("error", response.get_json())

        self.data_get_connection.assert_not_called()

    def test_invalid_token_returns_401(self):
        bad_tokens = [
            "no-es-un-jwt",
            make_token(secret="otro-secreto-distinto-0123456789abcdef"),
            make_token(exp_delta=timedelta(hours=-1)),
        ]

        for token in bad_tokens:
            for path in self.PATHS:
                with self.subTest(path=path, token=token[:10]):
                    response = self.client.get(
                        path, headers={"Authorization": f"Bearer {token}"}
                    )
                    self.assertEqual(response.status_code, 401)

        self.data_get_connection.assert_not_called()

    def test_non_admin_roles_return_403(self):
        for role in ("user", "professional"):
            self.set_role(role)

            for path in self.PATHS:
                with self.subTest(role=role, path=path):
                    response = self.client.get(path, headers=self.headers)
                    self.assertEqual(response.status_code, 403)

        self.data_get_connection.assert_not_called()

    def test_unknown_user_returns_401(self):
        self.set_role(None)
        response = self.client.get("/admin/species", headers=self.headers)
        self.assertEqual(response.status_code, 401)

    def test_admin_is_allowed(self):
        self.set_data([[(0,)], []])
        response = self.client.get("/admin/species", headers=self.headers)
        self.assertEqual(response.status_code, 200)

    def test_unimplemented_write_methods_return_405(self):
        implemented = {("post", "/admin/species"),
                       ("patch", "/admin/species/sp-001")}

        for method in ("post", "put", "patch", "delete"):
            for path in self.PATHS:
                if (method, path) in implemented:
                    continue

                with self.subTest(method=method, path=path):
                    response = getattr(self.client, method)(
                        path, headers=self.headers, json={}
                    )
                    self.assertEqual(response.status_code, 405)


class ListQuestionsTests(AdminCatalogBase):
    def test_questions_include_options_and_empty_inactive_questions(self):
        self.set_data([[('q1', 'Pregunta', True, 'o1', 'Una'),
                        ('q1', 'Pregunta', True, 'o2', 'Otra'),
                        ('q2', 'Inactiva', False, None, None)]])
        response = self.client.get('/admin/questions', headers=self.headers)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()['questions'], [
            {'id': 'q1', 'question_text': 'Pregunta', 'is_active': True,
             'options': [{'id': 'o1', 'option_text': 'Una'},
                         {'id': 'o2', 'option_text': 'Otra'}]},
            {'id': 'q2', 'question_text': 'Inactiva', 'is_active': False,
             'options': []},
        ])
        self.data_conn.set_session.assert_called_once_with(readonly=True)
        self.assertTrue(self.data_cursor.closed)
        self.data_conn.close.assert_called_once()

    def test_database_error_is_reported(self):
        self.set_data([psycopg2.OperationalError('database unavailable')])
        response = self.client.get('/admin/questions', headers=self.headers)
        self.assertEqual(response.status_code, 500)
        self.data_conn.rollback.assert_called_once()


class ListSpeciesTests(AdminCatalogBase):
    def test_list_returns_species_and_pagination(self):
        rows = [species_row("sp-001"), species_row("sp-002", "Neneo",
                "Azorella prolifera", "Apiaceae", False)]
        self.set_data([[(79,)], rows])

        response = self.client.get("/admin/species", headers=self.headers)
        body = response.get_json()

        self.assertEqual(response.status_code, 200)
        self.assertEqual(body["pagination"],
                         {"total": 79, "limit": 25, "offset": 0})
        self.assertEqual(len(body["species"]), 2)
        self.assertEqual(body["species"][0], {
            "id": "sp-001",
            "common_name": "Calafate",
            "scientific_name": "Berberis microphylla",
            "family": "Berberidaceae",
            "is_active": True,
            "created_at": T0.isoformat(),
            "updated_at": T1.isoformat(),
        })
        self.assertFalse(body["species"][1]["is_active"])

    def test_default_sql_has_stable_order_and_no_filters(self):
        self.set_data([[(0,)], []])
        self.client.get("/admin/species", headers=self.headers)

        count_sql, count_params = self.data_cursor.executed[0]
        list_sql, list_params = self.data_cursor.executed[1]

        self.assertNotIn("WHERE", count_sql)
        self.assertIn("ORDER BY LOWER(common_name) ASC, id ASC", list_sql)
        self.assertEqual(list_params, [25, 0])
        self.assertEqual(count_params, [])

    def test_search_uses_parameters_and_escapes_wildcards(self):
        self.set_data([[(1,)], [species_row()]])
        malicious = "x'; DROP TABLE species;-- 50%_!"
        self.client.get(
            "/admin/species", headers=self.headers, query_string={"q": malicious}
        )

        count_sql, count_params = self.data_cursor.executed[0]
        list_sql, list_params = self.data_cursor.executed[1]

        self.assertIn("ILIKE %s ESCAPE '!'", count_sql)
        self.assertNotIn("DROP TABLE", count_sql)
        self.assertNotIn("DROP TABLE", list_sql)
        expected = "%x'; DROP TABLE species;-- 50!%!_!!%"
        self.assertEqual(count_params, [expected, expected])
        self.assertEqual(list_params, [expected, expected, 25, 0])

    def test_status_filter(self):
        for status, fragment in (("active", "is_active = TRUE"),
                                 ("inactive", "is_active = FALSE")):
            with self.subTest(status=status):
                self.set_data([[(3,)], []])
                response = self.client.get(
                    "/admin/species", headers=self.headers,
                    query_string={"status": status},
                )
                self.assertEqual(response.status_code, 200)
                self.assertIn(fragment, self.data_cursor.executed[0][0])

        self.set_data([[(79,)], []])
        self.client.get("/admin/species", headers=self.headers,
                        query_string={"status": "all"})
        self.assertNotIn("is_active", self.data_cursor.executed[0][0])

    def test_sort_and_order_use_fixed_fragments(self):
        self.set_data([[(0,)], []])
        self.client.get("/admin/species", headers=self.headers,
                        query_string={"sort": "scientific_name", "order": "DESC"})

        list_sql = self.data_cursor.executed[1][0]
        self.assertIn("ORDER BY LOWER(scientific_name) DESC, id ASC", list_sql)

    def test_pagination_parameters(self):
        self.set_data([[(79,)], []])
        response = self.client.get(
            "/admin/species", headers=self.headers,
            query_string={"limit": "10", "offset": "30"},
        )

        self.assertEqual(response.get_json()["pagination"],
                         {"total": 79, "limit": 10, "offset": 30})
        self.assertEqual(self.data_cursor.executed[1][1], [10, 30])

    def test_invalid_parameters_return_400_without_touching_database(self):
        invalid = [
            {"limit": "0"}, {"limit": "101"}, {"limit": "abc"},
            {"offset": "-1"}, {"offset": "x"},
            {"sort": "password"}, {"sort": "common_name; DROP TABLE x"},
            {"order": "sideways"}, {"status": "borrada"},
            {"q": "a" * 101},
        ]

        for query in invalid:
            with self.subTest(query=query):
                response = self.client.get(
                    "/admin/species", headers=self.headers, query_string=query
                )
                self.assertEqual(response.status_code, 400)
                self.assertIn("error", response.get_json())

        self.data_get_connection.assert_not_called()

    def test_connection_is_readonly_and_closed(self):
        self.set_data([[(0,)], []])
        self.client.get("/admin/species", headers=self.headers)

        self.data_conn.set_session.assert_called_once_with(readonly=True)
        self.assertTrue(self.data_cursor.closed)
        self.data_conn.close.assert_called_once()
        self.data_conn.commit.assert_not_called()

    def test_database_error_returns_generic_500(self):
        error = psycopg2.OperationalError(
            "password authentication failed for user postgres at 127.0.0.1"
        )
        self.set_data([error])
        response = self.client.get("/admin/species", headers=self.headers)
        text = response.get_data(as_text=True)

        self.assertEqual(response.status_code, 500)
        self.assertEqual(response.get_json(),
                         {"error": "No se pudieron obtener las especies"})
        self.assertNotIn("password", text)
        self.assertNotIn("127.0.0.1", text)
        self.data_conn.rollback.assert_called()
        self.data_conn.close.assert_called_once()

    def test_unexpected_error_returns_generic_500(self):
        self.set_data([[(0,)], [(1,)]])  # fila inválida provoca un error interno
        response = self.client.get("/admin/species", headers=self.headers)

        self.assertEqual(response.status_code, 500)
        self.assertEqual(response.get_json(), {"error": "Error interno"})


class SpeciesDetailTests(AdminCatalogBase):
    def test_detail_with_traits(self):
        traits = [
            ("t-1", "q-001", "¿Qué tipo de planta es?", "opt-fb-01", "Arbusto"),
            ("t-2", "q-002", "¿De qué color es la flor?", "opt-cf-01", "Amarillo"),
        ]
        self.set_data([[DETAIL_VALUES], traits])

        response = self.client.get("/admin/species/sp-001", headers=self.headers)
        body = response.get_json()["species"]

        self.assertEqual(response.status_code, 200)
        self.assertEqual(body["id"], "sp-001")
        self.assertEqual(body["common_name"], "Calafate")
        self.assertEqual(body["description"], "Arbusto espinoso")
        self.assertTrue(body["has_spines"])
        self.assertTrue(body["is_active"])
        self.assertEqual(body["created_at"], T0.isoformat())
        self.assertEqual(body["updated_at"], T1.isoformat())
        self.assertEqual(body["traits"][0], {
            "id": "t-1",
            "question_id": "q-001",
            "question_text": "¿Qué tipo de planta es?",
            "option_id": "opt-fb-01",
            "option_text": "Arbusto",
        })
        self.assertEqual(len(body["traits"]), 2)

    def test_detail_queries_are_parameterized(self):
        self.set_data([[DETAIL_VALUES], []])
        self.client.get("/admin/species/sp-001", headers=self.headers)

        species_sql, species_params = self.data_cursor.executed[0]
        traits_sql, traits_params = self.data_cursor.executed[1]

        self.assertEqual(species_params, ("sp-001",))
        self.assertEqual(traits_params, ("sp-001",))
        self.assertIn("INNER JOIN public.questions", traits_sql)
        self.assertIn("INNER JOIN public.question_options", traits_sql)
        self.assertNotIn("sp-001", species_sql + traits_sql)

    def test_detail_without_traits_returns_empty_list(self):
        self.set_data([[DETAIL_VALUES], []])
        response = self.client.get("/admin/species/sp-001", headers=self.headers)
        self.assertEqual(response.get_json()["species"]["traits"], [])

    def test_unknown_species_returns_404(self):
        self.set_data([[]])
        response = self.client.get("/admin/species/no-existe", headers=self.headers)

        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.get_json(), {"error": "Especie no encontrada"})
        self.assertEqual(len(self.data_cursor.executed), 1)

    def test_oversized_id_returns_400(self):
        response = self.client.get(f"/admin/species/{'x' * 101}", headers=self.headers)
        self.assertEqual(response.status_code, 400)
        self.data_get_connection.assert_not_called()

    def test_database_error_returns_generic_500(self):
        self.set_data([psycopg2.DatabaseError("relation public.species broken")])
        response = self.client.get("/admin/species/sp-001", headers=self.headers)

        self.assertEqual(response.status_code, 500)
        self.assertEqual(response.get_json(),
                         {"error": "No se pudo obtener la especie"})
        self.assertNotIn("relation", response.get_data(as_text=True))


class SpeciesImagesTests(AdminCatalogBase):
    def test_existing_species_without_images_returns_empty_list(self):
        self.set_data([[(1,)], []])
        response = self.client.get(
            "/admin/species/sp-001/images", headers=self.headers
        )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json(), {"images": []})

    def test_unknown_species_returns_404(self):
        self.set_data([[]])
        response = self.client.get(
            "/admin/species/no-existe/images", headers=self.headers
        )

        self.assertEqual(response.status_code, 404)
        self.assertEqual(len(self.data_cursor.executed), 1)

    def test_images_are_serialized_and_ordered_in_sql(self):
        image = (
            "img-1", "sp-001", "a.jpg", "a" * 64, "image/jpeg", 100, 80,
            1000, 0, True, "active", "assets/images/Catalogs/x/a.jpg",
            T0, T1, "22222222-2222-2222-2222-222222222222",
        )
        self.set_data([[(1,)], [image]])
        response = self.client.get(
            "/admin/species/sp-001/images", headers=self.headers
        )
        payload = response.get_json()["images"][0]

        self.assertEqual(payload["id"], "img-1")
        self.assertTrue(payload["is_primary"])
        self.assertEqual(payload["created_at"], T0.isoformat())
        self.assertEqual(payload["created_by"],
                         "22222222-2222-2222-2222-222222222222")

        images_sql, images_params = self.data_cursor.executed[1]
        self.assertIn(
            "ORDER BY is_primary DESC, sort_order ASC, created_at ASC, id ASC",
            " ".join(images_sql.split()),
        )
        self.assertEqual(images_params, ("sp-001",))

    def test_connection_is_readonly_and_closed(self):
        self.set_data([[(1,)], []])
        self.client.get("/admin/species/sp-001/images", headers=self.headers)

        self.data_conn.set_session.assert_called_once_with(readonly=True)
        self.data_conn.close.assert_called_once()


class RegistrationTests(unittest.TestCase):
    def test_blueprint_registered_and_existing_routes_preserved(self):
        rules = {rule.rule for rule in backend_app.app.url_map.iter_rules()}

        self.assertIn("/admin/species", rules)
        self.assertIn("/admin/species/<string:species_id>", rules)
        self.assertIn("/admin/species/<string:species_id>/images", rules)
        self.assertIn("/professional/species", rules)
        self.assertIn("/auth/google", rules)
        self.assertIn("/attachments/<string:attachment_id>", rules)

    def test_admin_routes_expose_only_the_planned_methods(self):
        expected = {
            "/admin/questions": {"GET"},
            "/admin/species": {"GET", "POST"},
            "/admin/species/<string:species_id>": {"GET", "PATCH"},
            "/admin/species/<string:species_id>/images": {"GET"},
            "/admin/species/<string:species_id>/traits": {"PUT"},
        }
        found = {}

        for rule in backend_app.app.url_map.iter_rules():
            if rule.rule.startswith("/admin/"):
                found.setdefault(rule.rule, set()).update(
                    rule.methods - {"HEAD", "OPTIONS"}
                )

        self.assertEqual(found, expected)


FIXED_UUID = uuid.UUID("12345678-1234-5678-1234-567812345678")
NEW_ID = f"sp-{FIXED_UUID}"


def detail_row(**overrides):
    values = dict(zip(admin_module.SPECIES_DETAIL_FIELDS, DETAIL_VALUES))
    values.update(overrides)
    return tuple(values[f] for f in admin_module.SPECIES_DETAIL_FIELDS)


def set_columns(sql):
    clause = sql.split(" SET ", 1)[1].split(" WHERE ", 1)[0]
    return [part.split(" = ")[0].strip() for part in clause.split(", ")]


class CreateSpeciesTests(AdminCatalogBase):
    VALID = {
        "common_name": "  Especie nueva  ",
        "scientific_name": "Genus novum",
        "description": "Descripción de prueba",
        "has_fruit": True,
    }

    def post(self, body=None, **kwargs):
        return self.client.post(
            "/admin/species",
            headers=self.headers,
            json=self.VALID if body is None else body,
            **kwargs,
        )

    def created_row(self, **overrides):
        base = dict(id=NEW_ID, common_name="Especie nueva",
                    scientific_name="Genus novum", is_active=False,
                    has_fruit=True, has_spines=False)
        base.update(overrides)
        return detail_row(**base)

    def test_creates_species_inactive_with_server_side_id(self):
        self.set_data([[], [], [self.created_row()]])

        with patch("routes.admin_catalog.uuid.uuid4", return_value=FIXED_UUID):
            response = self.post()

        body = response.get_json()["species"]

        self.assertEqual(response.status_code, 201)
        self.assertEqual(body["id"], NEW_ID)
        self.assertFalse(body["is_active"])
        self.assertEqual(body["traits"], [])
        self.assertEqual(response.headers["Location"], f"/admin/species/{NEW_ID}")

        lock_sql, lock_params = self.data_cursor.executed[0]
        dup_sql, dup_params = self.data_cursor.executed[1]
        insert_sql, insert_params = self.data_cursor.executed[2]

        self.assertIn("pg_advisory_xact_lock", lock_sql)
        self.assertIn("LOWER(BTRIM(scientific_name)) = LOWER(BTRIM(%s))", dup_sql)
        self.assertEqual(dup_params, ["Genus novum"])
        self.assertTrue(insert_sql.startswith("INSERT INTO public.species"))
        self.assertIn("is_active", insert_sql.split("VALUES")[0])
        self.assertIn(", FALSE)", insert_sql)
        self.assertIn("RETURNING id,", insert_sql)
        self.assertEqual(insert_params[0], NEW_ID)
        self.assertIn("Especie nueva", insert_params)
        self.assertNotIn("  Especie nueva  ", insert_params)
        self.data_conn.commit.assert_called_once()
        self.data_conn.set_session.assert_not_called()
        self.data_conn.close.assert_called_once()
        self.assertTrue(self.data_cursor.closed)

    def test_generated_id_has_sp_uuid_format(self):
        self.set_data([[], [], [self.created_row()]])
        self.post()

        generated = self.data_cursor.executed[2][1][0]
        self.assertRegex(generated, r"^sp-[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$")

    def test_boolean_flags_default_to_false_and_empty_text_is_null(self):
        self.set_data([[], [], [self.created_row()]])
        self.post({"common_name": "A", "scientific_name": "B c",
                   "description": "   "})

        insert_sql, params = self.data_cursor.executed[2]
        columns = insert_sql.split("(", 1)[1].split(")", 1)[0].split(", ")

        self.assertEqual(columns[0], "id")
        self.assertEqual(columns[-1], "is_active")
        self.assertIn("has_spines", columns)
        self.assertIn("has_fruit", columns)
        self.assertEqual(params[columns.index("has_spines")], False)
        self.assertEqual(params[columns.index("has_fruit")], False)
        self.assertIsNone(params[columns.index("description")])

    def test_client_cannot_send_protected_fields(self):
        for field, value in (("id", "sp-999"), ("created_at", "2020-01-01"),
                             ("updated_at", "2020-01-01"),
                             ("is_active", True), ("is_active", False)):
            with self.subTest(field=field, value=value):
                response = self.post({**self.VALID, field: value})
                self.assertEqual(response.status_code, 400)
                self.assertEqual(response.get_json()["fields"], [field])

        self.data_get_connection.assert_not_called()

    def test_required_fields(self):
        cases = [
            {"scientific_name": "Genus novum"},
            {"common_name": "Especie"},
            {"common_name": "", "scientific_name": "Genus novum"},
            {"common_name": "   ", "scientific_name": "Genus novum"},
            {"common_name": None, "scientific_name": "Genus novum"},
            {"common_name": "Especie", "scientific_name": None},
        ]

        for body in cases:
            with self.subTest(body=body):
                response = self.post(body)
                self.assertEqual(response.status_code, 400)
                self.assertIn(response.get_json()["field"],
                              ("common_name", "scientific_name"))

        self.data_get_connection.assert_not_called()

    def test_invalid_types(self):
        cases = [
            {"description": 123}, {"description": ["x"]}, {"family": {"a": 1}},
            {"has_fruit": "true"}, {"has_spines": 1}, {"has_fruit": None},
            {"has_spines": "false"},
        ]

        for extra in cases:
            with self.subTest(extra=extra):
                response = self.post({**self.VALID, **extra})
                self.assertEqual(response.status_code, 400)
                self.assertIn("field", response.get_json())

        self.data_get_connection.assert_not_called()

    def test_unknown_fields_are_rejected(self):
        for field in ("foo", "species_traits", "image_url", "traits", "photos"):
            with self.subTest(field=field):
                response = self.post({**self.VALID, field: "x"})
                self.assertEqual(response.status_code, 400)
                self.assertEqual(response.get_json()["fields"], [field])

        self.data_get_connection.assert_not_called()

    def test_length_and_nul_limits(self):
        cases = [
            {"common_name": "a" * 201}, {"scientific_name": "a" * 201},
            {"description": "a" * 5001}, {"observations": "a" * 2001},
            {"flower_color": "a" * 101}, {"habitat": "bad\x00text"},
        ]

        for extra in cases:
            with self.subTest(field=list(extra)[0]):
                response = self.post({**self.VALID, **extra})
                self.assertEqual(response.status_code, 400)

        self.data_get_connection.assert_not_called()

    def test_boundary_lengths_are_accepted(self):
        self.set_data([[], [], [self.created_row()]])
        response = self.post({**self.VALID, "common_name": "a" * 200,
                              "description": "d" * 5000})
        self.assertEqual(response.status_code, 201)

    def test_invalid_bodies(self):
        for body in (None, [], "texto", 5):
            with self.subTest(body=body):
                response = self.client.post(
                    "/admin/species", headers=self.headers, json=body)
                self.assertEqual(response.status_code, 400)

        response = self.client.post("/admin/species", headers=self.headers,
                                    data="no es json",
                                    content_type="application/json")
        self.assertEqual(response.status_code, 400)
        response = self.client.post("/admin/species", headers=self.headers,
                                    data='{"common_name": "x"}',
                                    content_type="text/plain")
        self.assertEqual(response.status_code, 400)
        self.assertEqual(self.post({}).status_code, 400)
        self.data_get_connection.assert_not_called()

    def test_oversized_body_returns_413(self):
        response = self.client.post(
            "/admin/species", headers=self.headers,
            data='{"description": "' + "x" * 70000 + '"}',
            content_type="application/json")

        self.assertEqual(response.status_code, 413)
        self.assertIn("error", response.get_json())
        self.data_get_connection.assert_not_called()

    def test_duplicate_scientific_name_returns_409_without_insert(self):
        self.set_data([[], [("sp-009",)]])
        response = self.post()

        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.get_json()["field"], "scientific_name")
        self.assertEqual(len(self.data_cursor.executed), 2)
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()
        self.data_conn.close.assert_called_once()

    def test_database_error_rolls_back_with_generic_500(self):
        error = psycopg2.IntegrityError("duplicate key value violates secret_constraint")
        self.set_data([[], [], error])
        response = self.post()
        text = response.get_data(as_text=True)

        self.assertEqual(response.status_code, 500)
        self.assertEqual(response.get_json(), {"error": "No se pudo crear la especie"})
        self.assertNotIn("secret_constraint", text)
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()
        self.data_conn.close.assert_called_once()
        self.assertTrue(self.data_cursor.closed)

    def test_connection_error_returns_generic_500(self):
        self.data_get_connection.side_effect = psycopg2.OperationalError(
            "could not connect to server at 127.0.0.1")
        response = self.post()

        self.assertEqual(response.status_code, 500)
        self.assertNotIn("127.0.0.1", response.get_data(as_text=True))

    def test_unexpected_error_rolls_back(self):
        self.set_data([[], RuntimeError("boom con detalle interno")])
        response = self.post()

        self.assertEqual(response.status_code, 500)
        self.assertEqual(response.get_json(), {"error": "Error interno"})
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()
        self.data_conn.close.assert_called_once()

    def test_get_endpoints_unchanged_after_write_support(self):
        self.set_data([[(0,)], []])
        self.assertEqual(self.client.get("/admin/species", headers=self.headers).status_code, 200)
        self.data_conn.set_session.assert_called_once_with(readonly=True)


class UpdateSpeciesTests(AdminCatalogBase):
    PATH = "/admin/species/sp-001"

    def patch_request(self, body, path=None):
        return self.client.patch(path or self.PATH, headers=self.headers, json=body)

    def test_partial_update_changes_only_sent_fields(self):
        updated = detail_row(description="Nueva descripción")
        traits = [("t-1", "q-001", "¿Qué tipo?", "opt-1", "Arbusto")]
        self.set_data([[("sp-001",)], [updated], traits])

        response = self.patch_request({"description": "  Nueva descripción  "})
        body = response.get_json()["species"]

        self.assertEqual(response.status_code, 200)
        self.assertEqual(body["description"], "Nueva descripción")
        self.assertEqual(body["traits"][0]["option_text"], "Arbusto")
        self.assertEqual(len(self.data_cursor.executed), 3)

        select_sql, select_params = self.data_cursor.executed[0]
        update_sql, update_params = self.data_cursor.executed[1]

        self.assertIn("FOR UPDATE", select_sql)
        self.assertEqual(select_params, ("sp-001",))
        self.assertEqual(set_columns(update_sql), ["description"])
        self.assertEqual(update_params, ["Nueva descripción", "sp-001"])
        self.assertIn("WHERE id = %s", update_sql)
        self.assertNotIn("updated_at", update_sql.split(" RETURNING ")[0])
        self.assertNotIn("is_active", update_sql.split(" RETURNING ")[0])
        self.data_conn.commit.assert_called_once()
        self.data_conn.set_session.assert_not_called()
        self.data_conn.close.assert_called_once()

    def test_omitted_fields_are_not_part_of_the_update(self):
        self.set_data([[("sp-001",)], [detail_row()], []])
        self.patch_request({"flower_color": "blanco", "has_spines": False,
                            "habitat": None})

        sql, params = self.data_cursor.executed[1]
        self.assertEqual(set_columns(sql), ["flower_color", "habitat", "has_spines"])
        self.assertEqual(params, ["blanco", None, False, "sp-001"])

    def test_scientific_name_change_checks_duplicates_excluding_itself(self):
        self.set_data([[], [("sp-001",)], [], [detail_row(scientific_name="Genus nuevo")], []])
        response = self.patch_request({"scientific_name": " Genus nuevo "})

        self.assertEqual(response.status_code, 200)
        self.assertIn("pg_advisory_xact_lock", self.data_cursor.executed[0][0])
        dup_sql, dup_params = self.data_cursor.executed[2]
        self.assertIn("LOWER(BTRIM(scientific_name)) = LOWER(BTRIM(%s))", dup_sql)
        self.assertIn("AND id <> %s", dup_sql)
        self.assertEqual(dup_params, ["Genus nuevo", "sp-001"])

    def test_duplicate_scientific_name_returns_409_and_rolls_back(self):
        self.set_data([[], [("sp-001",)], [("sp-002",)]])
        response = self.patch_request({"scientific_name": "Berberis microphylla"})

        self.assertEqual(response.status_code, 409)
        self.assertEqual(response.get_json()["field"], "scientific_name")
        self.assertEqual(len(self.data_cursor.executed), 3)
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()

    def test_unknown_species_returns_404_without_writing(self):
        self.set_data([[]])
        response = self.patch_request({"description": "x"}, "/admin/species/no-existe")

        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.get_json(), {"error": "Especie no encontrada"})
        self.assertEqual(len(self.data_cursor.executed), 1)
        self.data_conn.commit.assert_not_called()

    def test_protected_fields_cannot_be_edited(self):
        for field, value in (("id", "sp-777"), ("created_at", "2020-01-01"),
                             ("updated_at", "2020-01-01"), ("is_active", False),
                             ("is_active", True)):
            with self.subTest(field=field, value=value):
                response = self.patch_request({field: value})
                self.assertEqual(response.status_code, 400)
                self.assertEqual(response.get_json()["fields"], [field])

        self.data_get_connection.assert_not_called()

    def test_traits_and_photos_cannot_be_edited_here(self):
        for field in ("species_traits", "traits", "images", "image_url", "photos"):
            with self.subTest(field=field):
                response = self.patch_request({field: []})
                self.assertEqual(response.status_code, 400)
                self.assertEqual(response.get_json()["fields"], [field])

        self.data_get_connection.assert_not_called()

    def test_empty_unknown_and_null_required_fields(self):
        cases = [{}, {"desconocido": 1}, {"common_name": None},
                 {"scientific_name": None}, {"common_name": "  "},
                 {"scientific_name": ""}]

        for body in cases:
            with self.subTest(body=body):
                self.assertEqual(self.patch_request(body).status_code, 400)

        self.data_get_connection.assert_not_called()

    def test_invalid_types_and_lengths(self):
        cases = [{"description": 5}, {"has_fruit": "yes"}, {"has_spines": 0},
                 {"has_fruit": None}, {"common_name": "a" * 201},
                 {"observations": "a" * 2001}, {"family": "x\x00y"}]

        for body in cases:
            with self.subTest(body=body):
                self.assertEqual(self.patch_request(body).status_code, 400)

        self.data_get_connection.assert_not_called()

    def test_invalid_body_and_id(self):
        self.assertEqual(self.client.patch(self.PATH, headers=self.headers, json=[1]).status_code, 400)
        self.assertEqual(self.client.patch(self.PATH, headers=self.headers, data="{", content_type="application/json").status_code, 400)
        self.assertEqual(self.patch_request({"description": "x"}, f"/admin/species/{'x' * 101}").status_code, 400)
        self.data_get_connection.assert_not_called()

    def test_oversized_body_returns_413(self):
        response = self.client.patch(
            self.PATH, headers=self.headers,
            data='{"description": "' + "x" * 70000 + '"}',
            content_type="application/json")
        self.assertEqual(response.status_code, 413)

    def test_database_error_rolls_back_with_generic_500(self):
        self.set_data([[("sp-001",)], psycopg2.IntegrityError("violates internal_check")])
        response = self.patch_request({"description": "x"})

        self.assertEqual(response.status_code, 500)
        self.assertEqual(response.get_json(), {"error": "No se pudo actualizar la especie"})
        self.assertNotIn("internal_check", response.get_data(as_text=True))
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()
        self.data_conn.close.assert_called_once()

    def test_failure_after_update_does_not_commit(self):
        self.set_data([[("sp-001",)], [detail_row()], psycopg2.OperationalError("lost")])
        response = self.patch_request({"description": "x"})

        self.assertEqual(response.status_code, 500)
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()


class WriteSecurityTests(AdminCatalogBase):
    CALLS = [
        ("post", "/admin/species", {"common_name": "A", "scientific_name": "B c"}),
        ("patch", "/admin/species/sp-001", {"description": "x"}),
    ]

    def call(self, method, path, body, headers):
        return getattr(self.client, method)(path, headers=headers, json=body)

    def test_without_token_returns_401(self):
        for method, path, body in self.CALLS:
            with self.subTest(method=method):
                self.assertEqual(self.call(method, path, body, {}).status_code, 401)

        self.data_get_connection.assert_not_called()

    def test_invalid_token_returns_401(self):
        for token in ("basura", make_token(secret="otro-secreto-distinto-0123456789abcdef"),
                      make_token(exp_delta=timedelta(hours=-1))):
            for method, path, body in self.CALLS:
                with self.subTest(method=method, token=token[:8]):
                    headers = {"Authorization": f"Bearer {token}"}
                    self.assertEqual(self.call(method, path, body, headers).status_code, 401)

        self.data_get_connection.assert_not_called()

    def test_non_admin_roles_return_403_before_any_write(self):
        for role in ("user", "professional"):
            self.set_role(role)

            for method, path, body in self.CALLS:
                with self.subTest(role=role, method=method):
                    self.assertEqual(self.call(method, path, body, self.headers).status_code, 403)

        self.data_get_connection.assert_not_called()

    def test_admin_is_allowed(self):
        self.set_data([[], [], [detail_row(id=NEW_ID, is_active=False)]])
        self.assertEqual(self.call(*self.CALLS[0], self.headers).status_code, 201)

        self.set_data([[("sp-001",)], [detail_row()], []])
        self.assertEqual(self.call(*self.CALLS[1], self.headers).status_code, 200)


class ReplaceTraitsTests(AdminCatalogBase):
    PATH = "/admin/species/sp-001/traits"
    UPDATED = datetime(2026, 11, 4, 9, 30, tzinfo=timezone.utc)

    def put(self, body, path=None):
        return self.client.put(path or self.PATH, headers=self.headers, json=body)

    def trait_rows(self, *pairs):
        return [(tid, q, o) for tid, q, o in pairs]

    def final_rows(self, *ids):
        return [(tid, "q-001", "¿Tipo?", "opt-1", "Arbusto") for tid in ids]

    def test_replaces_only_the_difference_and_keeps_existing_ids(self):
        # existentes: A(q1,o1) se conserva, B(q2,o2) se retira; pedido: A y C(q3,o3)
        self.set_data([
            [("sp-001", T0)],                                  # FOR UPDATE
            [("q-001", True), ("q-003", True)],                # preguntas
            [("opt-1", "q-001"), ("opt-3", "q-003")],          # opciones
            self.trait_rows(("t-A", "q-001", "opt-1"), ("t-B", "q-002", "opt-2")),
            [],                                                # DELETE
            [],                                                # INSERT
            [(self.UPDATED,)],                                 # UPDATE updated_at
            self.final_rows("t-A", "t-new"),
        ])

        with patch("routes.admin_catalog.uuid.uuid4", return_value=FIXED_UUID):
            response = self.put({"traits": [
                {"question_id": "q-001", "option_id": "opt-1"},
                {"question_id": "q-003", "option_id": "opt-3"},
            ]})

        body = response.get_json()
        executed = self.data_cursor.executed

        self.assertEqual(response.status_code, 200)
        self.assertEqual(body["changes"], {"added": 1, "removed": 1, "unchanged": 1})
        self.assertEqual(body["species"]["id"], "sp-001")
        self.assertEqual(body["species"]["updated_at"], self.UPDATED.isoformat())
        self.assertEqual(len(body["species"]["traits"]), 2)

        self.assertIn("FOR UPDATE", executed[0][0])
        delete_sql, delete_params = executed[4]
        insert_sql, insert_params = executed[5]
        touch_sql, touch_params = executed[6]

        self.assertIn("DELETE FROM public.species_traits", delete_sql)
        self.assertEqual(delete_params, ("sp-001", ["t-B"]))
        self.assertIn("INSERT INTO public.species_traits", insert_sql)
        self.assertEqual(insert_params, [str(FIXED_UUID), "sp-001", "q-003", "opt-3"])
        self.assertIn("UPDATE public.species SET updated_at = NOW()", touch_sql)
        self.assertEqual(touch_params, ("sp-001",))
        self.data_conn.commit.assert_called_once()
        self.data_conn.set_session.assert_not_called()
        self.data_conn.close.assert_called_once()

    def test_unchanged_request_does_not_write_nor_touch_species(self):
        self.set_data([
            [("sp-001", T0)],
            [("q-001", True)],
            [("opt-1", "q-001")],
            self.trait_rows(("t-A", "q-001", "opt-1")),
            self.final_rows("t-A"),
        ])
        response = self.put({"traits": [{"question_id": "q-001", "option_id": "opt-1"}]})
        body = response.get_json()
        sqls = " ".join(sql for sql, _ in self.data_cursor.executed)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(body["changes"], {"added": 0, "removed": 0, "unchanged": 1})
        self.assertEqual(body["species"]["updated_at"], T0.isoformat())
        self.assertNotIn("DELETE", sqls)
        self.assertNotIn("INSERT", sqls)
        self.assertNotIn("SET updated_at", sqls)
        self.assertEqual(body["species"]["traits"][0]["id"], "t-A")

    def test_empty_list_removes_all_relations_without_reference_queries(self):
        self.set_data([
            [("sp-001", T0)],
            self.trait_rows(("t-A", "q-001", "opt-1"), ("t-B", "q-002", "opt-2")),
            [],
            [(self.UPDATED,)],
            [],
        ])
        response = self.put({"traits": []})
        body = response.get_json()
        sqls = [sql for sql, _ in self.data_cursor.executed]

        self.assertEqual(response.status_code, 200)
        self.assertEqual(body["changes"], {"added": 0, "removed": 2, "unchanged": 0})
        self.assertEqual(body["species"]["traits"], [])
        self.assertFalse(any("public.questions WHERE" in s for s in sqls))
        self.assertEqual(self.data_cursor.executed[2][1], ("sp-001", ["t-A", "t-B"]))
        self.assertFalse(any(s.startswith("INSERT") for s in sqls))

    def test_assigns_to_species_without_relations(self):
        self.set_data([
            [("sp-001", T0)], [("q-001", True)], [("opt-1", "q-001")], [],
            [], [(self.UPDATED,)], self.final_rows("t-new"),
        ])
        response = self.put({"traits": [{"question_id": "q-001", "option_id": "opt-1"}]})

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()["changes"], {"added": 1, "removed": 0, "unchanged": 0})
        self.assertFalse(any(sql.startswith("DELETE") for sql, _ in self.data_cursor.executed))

    def test_multiple_options_for_the_same_question_are_allowed(self):
        self.set_data([
            [("sp-001", T0)], [("q-008", True)],
            [("opt-a", "q-008"), ("opt-b", "q-008")], [],
            [], [(self.UPDATED,)], self.final_rows("n1", "n2"),
        ])
        response = self.put({"traits": [
            {"question_id": "q-008", "option_id": "opt-a"},
            {"question_id": "q-008", "option_id": "opt-b"},
        ]})

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.get_json()["changes"]["added"], 2)

    def test_existing_duplicate_rows_for_a_requested_pair_are_collapsed(self):
        self.set_data([
            [("sp-001", T0)], [("q-001", True)], [("opt-1", "q-001")],
            self.trait_rows(("t-1", "q-001", "opt-1"), ("t-2", "q-001", "opt-1")),
            [], [(self.UPDATED,)], self.final_rows("t-1"),
        ])
        response = self.put({"traits": [{"question_id": "q-001", "option_id": "opt-1"}]})

        self.assertEqual(response.get_json()["changes"], {"added": 0, "removed": 1, "unchanged": 1})
        self.assertEqual(self.data_cursor.executed[4][1], ("sp-001", ["t-2"]))

    def test_whitespace_is_trimmed(self):
        self.set_data([
            [("sp-001", T0)], [("q-001", True)], [("opt-1", "q-001")],
            self.trait_rows(("t-A", "q-001", "opt-1")), self.final_rows("t-A"),
        ])
        response = self.put({"traits": [{"question_id": " q-001 ", "option_id": " opt-1 "}]})
        self.assertEqual(response.get_json()["changes"]["unchanged"], 1)

    def test_structure_errors_return_400_without_touching_database(self):
        valid = {"question_id": "q-001", "option_id": "opt-1"}
        cases = [
            {}, {"traits": None}, {"traits": "x"}, {"traits": {"a": 1}}, {"traits": 5},
            {"traitz": []}, {"traits": [], "extra": 1}, {"traits": [valid], "species_id": "sp-2"},
            {"traits": ["q-001"]}, {"traits": [None]}, {"traits": [[]]},
            {"traits": [{"question_id": "q-001"}]}, {"traits": [{"option_id": "opt-1"}]},
            {"traits": [{"question_id": None, "option_id": "opt-1"}]},
            {"traits": [{"question_id": 1, "option_id": "opt-1"}]},
            {"traits": [{"question_id": "", "option_id": "opt-1"}]},
            {"traits": [{"question_id": "   ", "option_id": "opt-1"}]},
            {"traits": [{"question_id": "q" * 101, "option_id": "opt-1"}]},
            {"traits": [{"question_id": "q\x00", "option_id": "opt-1"}]},
            {"traits": [{**valid, "extra": True}]},
            {"traits": [valid] * 2},
            {"traits": [valid, {"question_id": " q-001", "option_id": "opt-1 "}]},
            {"traits": [{"question_id": f"q-{i}", "option_id": f"o-{i}"} for i in range(201)]},
        ]

        for body in cases:
            with self.subTest(body=str(body)[:60]):
                response = self.put(body)
                self.assertEqual(response.status_code, 400)
                self.assertIn("error", response.get_json())

        for body in (None, [], "texto", 5):
            with self.subTest(body=body):
                self.assertEqual(self.put(body).status_code, 400)

        self.assertEqual(self.client.put(self.PATH, headers=self.headers, data="{",
                                         content_type="application/json").status_code, 400)
        self.assertEqual(self.put({"traits": []}, f"/admin/species/{'x' * 101}/traits").status_code, 400)
        self.data_get_connection.assert_not_called()

    def test_oversized_body_returns_413(self):
        response = self.client.put(
            self.PATH, headers=self.headers,
            data='{"traits": [], "pad": "' + "x" * 70000 + '"}',
            content_type="application/json")
        self.assertEqual(response.status_code, 413)
        self.data_get_connection.assert_not_called()

    def test_unknown_species_returns_404_without_writing(self):
        self.set_data([[]])
        response = self.put({"traits": [{"question_id": "q-001", "option_id": "opt-1"}]},
                            "/admin/species/no-existe/traits")

        self.assertEqual(response.status_code, 404)
        self.assertEqual(response.get_json(), {"error": "Especie no encontrada"})
        self.assertEqual(len(self.data_cursor.executed), 1)
        self.data_conn.commit.assert_not_called()

    def reference_case(self, questions, options, expected_error, expected_field="traits[0].question_id"):
        self.set_data([[("sp-001", T0)], questions, options])
        response = self.put({"traits": [{"question_id": "q-001", "option_id": "opt-1"}]})

        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.get_json()["error"], expected_error)
        self.assertEqual(response.get_json()["field"], expected_field)
        self.assertEqual(len(self.data_cursor.executed), 3)
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()

    def test_nonexistent_question_is_rejected(self):
        self.reference_case([], [("opt-1", "q-001")], "La pregunta no existe")

    def test_inactive_question_is_rejected(self):
        self.reference_case([("q-001", False)], [("opt-1", "q-001")], "La pregunta no está activa")

    def test_null_is_active_question_is_rejected_like_inactive(self):
        self.reference_case([("q-001", None)], [("opt-1", "q-001")], "La pregunta no está activa")

    def test_nonexistent_option_is_rejected(self):
        self.reference_case([("q-001", True)], [], "La opción no existe", "traits[0].option_id")

    def test_option_of_another_question_is_rejected(self):
        self.reference_case([("q-001", True)], [("opt-1", "q-002")],
                            "La opción no pertenece a la pregunta indicada", "traits[0].option_id")

    def test_reference_error_reports_the_failing_index(self):
        self.set_data([[("sp-001", T0)], [("q-001", True), ("q-002", True)],
                       [("opt-1", "q-001"), ("opt-2", "q-001")]])
        response = self.put({"traits": [
            {"question_id": "q-001", "option_id": "opt-1"},
            {"question_id": "q-002", "option_id": "opt-2"},
        ]})
        self.assertEqual(response.get_json()["field"], "traits[1].option_id")

    def test_reference_queries_use_parameter_arrays(self):
        self.set_data([[("sp-001", T0)], [], []])
        self.put({"traits": [{"question_id": "q-001'; DROP TABLE x;--", "option_id": "opt-1"}]})

        for sql, params in self.data_cursor.executed[1:3]:
            self.assertIn("= ANY(%s)", sql)
            self.assertNotIn("DROP TABLE", sql)
            self.assertIsInstance(params[0], list)

    def test_sql_error_rolls_back_with_generic_500(self):
        self.set_data([
            [("sp-001", T0)], [("q-001", True)], [("opt-1", "q-001")], [],
            psycopg2.IntegrityError("violates fk_species_traits_option secret"),
        ])
        response = self.put({"traits": [{"question_id": "q-001", "option_id": "opt-1"}]})

        self.assertEqual(response.status_code, 500)
        self.assertEqual(response.get_json(),
                         {"error": "No se pudieron actualizar los rasgos de la especie"})
        self.assertNotIn("secret", response.get_data(as_text=True))
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()
        self.data_conn.close.assert_called_once()
        self.assertTrue(self.data_cursor.closed)

    def test_failure_after_delete_does_not_commit(self):
        self.set_data([
            [("sp-001", T0)], self.trait_rows(("t-A", "q-001", "opt-1")), [],
            psycopg2.OperationalError("connection lost"),
        ])
        response = self.put({"traits": []})

        self.assertEqual(response.status_code, 500)
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()

    def test_unexpected_error_rolls_back(self):
        self.set_data([[("sp-001", T0)], RuntimeError("boom interno")])
        response = self.put({"traits": []})

        self.assertEqual(response.status_code, 500)
        self.assertEqual(response.get_json(), {"error": "Error interno"})
        self.data_conn.commit.assert_not_called()
        self.data_conn.rollback.assert_called()

    def test_never_touches_questions_options_or_other_tables_with_writes(self):
        self.set_data([
            [("sp-001", T0)], [("q-001", True)], [("opt-1", "q-001")],
            self.trait_rows(("t-B", "q-002", "opt-2")),
            [], [], [(self.UPDATED,)], self.final_rows("n"),
        ])
        self.put({"traits": [{"question_id": "q-001", "option_id": "opt-1"}]})

        for sql, _ in self.data_cursor.executed:
            head = sql.strip().split()[0].upper()

            if head in ("INSERT", "DELETE", "UPDATE"):
                self.assertTrue(
                    "public.species_traits" in sql
                    or sql.startswith("UPDATE public.species SET updated_at = NOW()"),
                    sql,
                )
                self.assertNotIn("questions", sql.replace("question_id", ""))
                self.assertNotIn("question_options", sql)

    def test_security_401_403_and_admin(self):
        body = {"traits": []}
        self.assertEqual(self.client.put(self.PATH, json=body).status_code, 401)
        self.assertEqual(self.client.put(self.PATH, json=body,
                                         headers={"Authorization": "Bearer basura"}).status_code, 401)
        self.assertEqual(self.client.put(self.PATH, json=body, headers={
            "Authorization": "Bearer " + make_token(exp_delta=timedelta(hours=-1))}).status_code, 401)
        self.assertEqual(self.client.put(self.PATH, json=body, headers={
            "Authorization": "Bearer " + make_token(secret="otro-secreto-distinto-0123456789abcdef")}).status_code, 401)

        for role in ("user", "professional"):
            self.set_role(role)
            self.assertEqual(self.put(body).status_code, 403)

        self.data_get_connection.assert_not_called()

        self.set_role("admin")
        self.set_data([[("sp-001", T0)], [], []])
        self.assertEqual(self.put(body).status_code, 200)

    def test_other_methods_on_traits_path_are_not_allowed(self):
        for method in ("get", "post", "patch", "delete"):
            with self.subTest(method=method):
                response = getattr(self.client, method)(self.PATH, headers=self.headers, json={})
                self.assertEqual(response.status_code, 405)

    def test_previous_endpoints_still_work(self):
        self.set_data([[(0,)], []])
        self.assertEqual(self.client.get("/admin/species", headers=self.headers).status_code, 200)
        self.set_data([[DETAIL_VALUES], []])
        self.assertEqual(self.client.get("/admin/species/sp-001", headers=self.headers).status_code, 200)
        self.set_data([[(1,)], []])
        self.assertEqual(self.client.get("/admin/species/sp-001/images", headers=self.headers).status_code, 200)
        self.set_data([[("sp-001",)], [detail_row()], []])
        self.assertEqual(self.client.patch("/admin/species/sp-001", headers=self.headers,
                                           json={"description": "x"}).status_code, 200)


if __name__ == "__main__":
    unittest.main()
