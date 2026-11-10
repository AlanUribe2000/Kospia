import os
import sys
import tempfile
import unittest
from datetime import datetime, timedelta, timezone
from unittest.mock import MagicMock, mock_open, patch

import jwt

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import app as backend_app
from config import Config


TEST_SECRET = "test-secret-not-used-in-production-0123456789"


class HelpCardsTests(unittest.TestCase):
    def setUp(self):
        secret_patch = patch.object(Config, "KOSPIA_JWT_SECRET", TEST_SECRET)
        auth_patch = patch("authentication.get_connection", side_effect=self.role_connection)
        data_patch = patch("routes.help_cards.get_connection", side_effect=self.data_connection)
        secret_patch.start()
        auth_patch.start()
        self.data_get_connection = data_patch.start()
        self.addCleanup(secret_patch.stop)
        self.addCleanup(auth_patch.stop)
        self.addCleanup(data_patch.stop)
        self.role = "professional"
        self.conn = MagicMock()
        self.cursor = self.conn.cursor.return_value
        self.cursor.fetchone.return_value = ("option-1",)
        self.client = backend_app.app.test_client()
        token = jwt.encode(
            {"sub": "user-1", "exp": datetime.now(timezone.utc) + timedelta(hours=1)},
            TEST_SECRET,
            algorithm="HS256",
        )
        self.headers = {"Authorization": f"Bearer {token}"}

    def role_connection(self):
        conn = MagicMock()
        conn.cursor.return_value.fetchone.return_value = (self.role,)
        return conn

    def data_connection(self):
        return self.conn

    def test_reads_require_valid_jwt(self):
        for path in ("/questions", "/questions/q-1/options", "/option-images/image-1"):
            with self.subTest(path=path):
                self.assertEqual(self.client.get(path).status_code, 401)
                self.assertEqual(
                    self.client.get(path, headers={"Authorization": "Bearer invalid"}).status_code,
                    401,
                )
        self.data_get_connection.assert_not_called()

    def test_identity_operations_are_admin_only(self):
        cases = (
            ("post", "/questions/q-1/options", {"option_text": "Example"}),
            ("put", "/options/option-1", {"option_text": "Example"}),
            ("delete", "/options/option-1", None),
            ("put", "/questions/q-1/options/reorder", {"option_ids": []}),
        )
        for role in ("professional", "user"):
            self.role = role
            for method, path, body in cases:
                with self.subTest(role=role, path=path, method=method):
                    response = getattr(self.client, method)(path, json=body, headers=self.headers)
                    self.assertEqual(response.status_code, 403)
        self.data_get_connection.assert_not_called()

    def test_admin_can_use_identity_operations(self):
        self.role = "admin"
        self.assertEqual(self.client.post(
            "/questions/q-1/options", json={"option_text": "Example"}, headers=self.headers
        ).status_code, 201)
        self.assertEqual(self.client.put(
            "/options/option-1", json={"option_text": "Example"}, headers=self.headers
        ).status_code, 200)
        self.assertEqual(self.client.put(
            "/questions/q-1/options/reorder", json={"option_ids": []}, headers=self.headers
        ).status_code, 200)
        self.cursor.fetchone.side_effect = [(None, None), None]
        self.cursor.fetchall.return_value = []
        self.assertEqual(self.client.delete(
            "/options/option-1", headers=self.headers
        ).status_code, 200)

    def test_help_updates_only_description_for_both_roles(self):
        for role in ("professional", "admin"):
            for description in ("Text", None):
                with self.subTest(role=role, description=description):
                    self.role = role
                    self.cursor.reset_mock()
                    response = self.client.patch(
                        "/options/option-1/help", json={"description": description},
                        headers=self.headers,
                    )
                    self.assertEqual(response.status_code, 200)
                    sql, params = self.cursor.execute.call_args.args
                    self.assertIn("SET description = %s", sql)
                    self.assertNotIn("option_text", sql)
                    self.assertNotIn("value_key", sql)
                    self.assertEqual(params, (description, "option-1"))

    def test_help_rejects_bad_body_and_unauthorized_role(self):
        self.assertEqual(self.client.patch(
            "/options/option-1/help", json={"description": "x"}
        ).status_code, 401)
        for body in ({}, {"description": 3}, {"description": None, "value_key": "x"}, []):
            with self.subTest(body=body):
                self.assertEqual(self.client.patch(
                    "/options/option-1/help", json=body, headers=self.headers
                ).status_code, 400)
        self.role = "user"
        self.assertEqual(self.client.patch(
            "/options/option-1/help", json={"description": "x"}, headers=self.headers
        ).status_code, 403)
        self.data_get_connection.assert_not_called()

    def test_help_missing_option_rolls_back(self):
        self.cursor.fetchone.return_value = None
        response = self.client.patch(
            "/options/missing/help", json={"description": None}, headers=self.headers
        )
        self.assertEqual(response.status_code, 404)
        self.conn.rollback.assert_called_once()
        self.conn.commit.assert_not_called()

    def test_delete_referenced_option_is_conflict(self):
        self.role = "admin"
        self.cursor.fetchall.return_value = []
        self.cursor.fetchone.side_effect = [(None, None), (1,)]
        response = self.client.delete("/options/option-1", headers=self.headers)
        self.assertEqual(response.status_code, 409)
        self.conn.rollback.assert_called_once()
        self.conn.commit.assert_not_called()
        self.assertFalse(any(
            "DELETE FROM public.question_options" in call.args[0]
            for call in self.cursor.execute.call_args_list
        ))

    def test_professional_can_manage_icon_and_photos(self):
        cases = (
            ("put", "/options/option-1/icon", {"icon_attachment_id": "image-1", "icon_extension": "png"}, 200),
            ("delete", "/options/option-1/icon", None, 200),
            ("post", "/options/option-1/photos", {"file_extension": "png"}, 201),
            ("put", "/options/option-1/photos/reorder", {"photo_ids": []}, 200),
            ("delete", "/photos/photo-1", None, 200),
        )
        for method, path, body, expected in cases:
            with self.subTest(path=path, method=method):
                response = getattr(self.client, method)(path, json=body, headers=self.headers)
                self.assertEqual(response.status_code, expected)

    def test_user_cannot_manage_help_images(self):
        self.role = "user"
        cases = (
            ("put", "/option-images/image-1", b"image"),
            ("delete", "/option-images/image-1", None),
            ("put", "/options/option-1/icon", None),
            ("delete", "/options/option-1/icon", None),
            ("post", "/options/option-1/photos", None),
            ("put", "/options/option-1/photos/reorder", None),
            ("delete", "/photos/photo-1", None),
        )
        for method, path, body in cases:
            with self.subTest(path=path, method=method):
                response = getattr(self.client, method)(path, data=body, headers=self.headers)
                self.assertEqual(response.status_code, 403)
        self.data_get_connection.assert_not_called()

    def test_image_validation_and_upload(self):
        path = "/option-images/image-1?extension=png"
        with patch("routes.help_cards._ensure_upload_folder") as ensure, patch(
            "builtins.open", mock_open()
        ) as file_open:
            self.assertEqual(self.client.put(path, data=b"not an image", headers=self.headers).status_code, 400)
            self.assertEqual(self.client.put(path, data=b"x" * (10 * 1024 * 1024 + 1), headers=self.headers).status_code, 413)
            ensure.assert_not_called()
            self.assertEqual(self.client.put(
                path, data=b"\x89PNG\r\n\x1a\ncontent", headers=self.headers
            ).status_code, 200)
            file_open.assert_called_once()
            self.assertEqual(file_open.call_args.args[1], "xb")
        self.assertEqual(self.client.delete(
            "/option-images/image-1?extension=txt", headers=self.headers
        ).status_code, 400)
        self.assertEqual(self.client.put(
            "/option-images/bad%5Cid?extension=png", data=b"", headers=self.headers
        ).status_code, 400)

    def test_image_upload_collision_does_not_replace_existing_file(self):
        original = b"\x89PNG\r\n\x1a\noriginal"
        replacement = b"\x89PNG\r\n\x1a\nreplacement"
        with tempfile.TemporaryDirectory() as folder, patch(
            "routes.help_cards.UPLOAD_FOLDER", folder
        ):
            path = "/option-images/image-1?extension=png"
            self.assertEqual(self.client.put(path, data=original, headers=self.headers).status_code, 200)
            self.assertEqual(self.client.put(path, data=replacement, headers=self.headers).status_code, 409)
            with open(os.path.join(folder, "image-1.png"), "rb") as image:
                self.assertEqual(image.read(), original)

    def test_admin_catalog_stays_admin_only(self):
        self.assertEqual(self.client.get("/admin/species", headers=self.headers).status_code, 403)


if __name__ == "__main__":
    unittest.main()