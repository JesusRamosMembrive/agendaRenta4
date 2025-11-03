"""
Integration tests for config blueprint routes

Tests Flask routes in config/routes.py

TODO: These tests require proper Flask app context and authentication setup.
Many tests are currently skipped and need to be fixed to work with:
- Proper Flask-Login session handling
- Request context management
- JSON response parsing with proper content types
"""

import pytest
import json
from datetime import datetime


@pytest.mark.skip(reason="TODO: Fix Flask app context and authentication for blueprint tests")
@pytest.mark.integration
@pytest.mark.requires_db
class TestConfigBlueprint:
    """Integration tests for config blueprint routes"""

    def test_config_index_route_loads(self, authenticated_client):
        """Test GET /configuracion loads successfully"""
        response = authenticated_client.get("/configuracion")

        assert response.status_code in [200, 302]  # 302 if auth required

    def test_config_index_shows_task_types(self, authenticated_client, db_cursor_fixture):
        """Test configuration page shows task types"""
        cursor = db_cursor_fixture

        # Verify task_types exist
        cursor.execute("SELECT COUNT(*) as count FROM task_types")
        count = cursor.fetchone()["count"]

        if count > 0:
            response = authenticated_client.get("/configuracion")
            # If accessible, should show task types
            if response.status_code == 200:
                assert b"task" in response.data.lower() or b"tarea" in response.data.lower()

    def test_config_index_shows_sections(self, authenticated_client, db_cursor_fixture, sample_section):
        """Test configuration page shows sections (URLs)"""
        response = authenticated_client.get("/configuracion")

        if response.status_code == 200:
            # Should display the sample section
            assert sample_section["name"].encode() in response.data or b"section" in response.data.lower()

    def test_save_alert_settings_requires_post(self, authenticated_client):
        """Test /configuracion/alertas requires POST method"""
        response = authenticated_client.get("/configuracion/alertas")

        assert response.status_code == 405  # Method Not Allowed

    def test_save_alert_settings_with_valid_data(self, authenticated_client, db_cursor_fixture):
        """Test POST /configuracion/alertas with valid alert settings"""
        cursor = db_cursor_fixture

        # Get a task type ID
        cursor.execute("SELECT id FROM task_types LIMIT 1")
        row = cursor.fetchone()

        if row:
            task_type_id = row["id"]

            alert_data = [
                {
                    "task_type_id": task_type_id,
                    "alert_frequency": "weekly",
                    "alert_day": "monday",
                    "enabled": True,
                }
            ]

            response = authenticated_client.post(
                "/configuracion/alertas",
                data=json.dumps(alert_data),
                content_type="application/json",
            )

            assert response.status_code == 200
            data = json.loads(response.data)
            assert data.get("success") is True

            # Verify in database
            cursor.execute(
                "SELECT * FROM alert_settings WHERE task_type_id = %s", (task_type_id,)
            )
            result = cursor.fetchone()
            assert result is not None
            assert result["alert_frequency"] == "weekly"

    def test_save_alert_settings_with_invalid_json(self, authenticated_client):
        """Test POST /configuracion/alertas with invalid JSON"""
        response = authenticated_client.post(
            "/configuracion/alertas",
            data="invalid json",
            content_type="application/json",
        )

        # Should return error
        assert response.status_code in [400, 500]

    def test_save_notification_preferences_requires_post(self, authenticated_client):
        """Test /configuracion/notificaciones requires POST method"""
        response = authenticated_client.get("/configuracion/notificaciones")

        assert response.status_code == 405  # Method Not Allowed

    def test_save_notification_preferences_with_valid_data(self, authenticated_client, db_cursor_fixture):
        """Test POST /configuracion/notificaciones with valid data"""
        response = authenticated_client.post(
            "/configuracion/notificaciones",
            data={
                "email": "test@example.com",
                "enable_email": "true",
                "enable_desktop": "false",
                "enable_in_app": "true",
            },
        )

        # Should succeed or redirect
        assert response.status_code in [200, 302]

        if response.status_code == 200:
            data = json.loads(response.data)
            assert data.get("success") is True

    def test_add_url_requires_post(self, authenticated_client):
        """Test /configuracion/url/add requires POST method"""
        response = authenticated_client.get("/configuracion/url/add")

        assert response.status_code == 405  # Method Not Allowed

    def test_add_url_with_valid_data(self, authenticated_client, db_cursor_fixture):
        """Test POST /configuracion/url/add with valid URL"""
        cursor = db_cursor_fixture

        response = authenticated_client.post(
            "/configuracion/url/add",
            data={"name": "Test URL", "url": "https://test.example.com"},
        )

        assert response.status_code == 200
        data = json.loads(response.data)
        assert data.get("success") is True
        assert "id" in data

        new_id = data["id"]

        # Verify in database
        cursor.execute("SELECT * FROM sections WHERE id = %s", (new_id,))
        result = cursor.fetchone()
        assert result is not None
        assert result["name"] == "Test URL"
        assert result["url"] == "https://test.example.com"

    def test_add_url_with_missing_name(self, authenticated_client):
        """Test POST /configuracion/url/add with missing name"""
        response = authenticated_client.post(
            "/configuracion/url/add", data={"url": "https://test.example.com"}
        )

        assert response.status_code == 400
        data = json.loads(response.data)
        assert data.get("success") is False

    def test_add_url_with_missing_url(self, authenticated_client):
        """Test POST /configuracion/url/add with missing URL"""
        response = authenticated_client.post("/configuracion/url/add", data={"name": "Test URL"})

        assert response.status_code == 400
        data = json.loads(response.data)
        assert data.get("success") is False

    def test_edit_url_requires_post(self, authenticated_client):
        """Test /configuracion/url/edit/<id> requires POST method"""
        response = authenticated_client.get("/configuracion/url/edit/1")

        assert response.status_code == 405  # Method Not Allowed

    def test_edit_url_with_valid_data(self, authenticated_client, db_cursor_fixture, sample_section):
        """Test POST /configuracion/url/edit/<id> with valid data"""
        cursor = db_cursor_fixture
        url_id = sample_section["id"]

        response = authenticated_client.post(
            f"/configuracion/url/edit/{url_id}",
            data={"name": "Updated Name", "url": "https://updated.example.com"},
        )

        assert response.status_code == 200
        data = json.loads(response.data)
        assert data.get("success") is True

        # Verify update in database
        cursor.execute("SELECT * FROM sections WHERE id = %s", (url_id,))
        result = cursor.fetchone()
        assert result["name"] == "Updated Name"
        assert result["url"] == "https://updated.example.com"

    def test_edit_url_with_invalid_id(self, authenticated_client):
        """Test POST /configuracion/url/edit/<id> with non-existent ID"""
        response = authenticated_client.post(
            "/configuracion/url/edit/99999",
            data={"name": "Test", "url": "https://test.com"},
        )

        # Should succeed but not update anything
        assert response.status_code == 200

    def test_toggle_url_requires_post(self, authenticated_client):
        """Test /configuracion/url/toggle/<id> requires POST method"""
        response = authenticated_client.get("/configuracion/url/toggle/1")

        assert response.status_code == 405  # Method Not Allowed

    def test_toggle_url_activates_inactive(self, authenticated_client, db_cursor_fixture):
        """Test POST /configuracion/url/toggle/<id> activates inactive URL"""
        cursor = db_cursor_fixture

        # Insert inactive URL
        cursor.execute(
            """
            INSERT INTO sections (name, url, active, created_at)
            VALUES (%s, %s, %s, CURRENT_TIMESTAMP)
            RETURNING id
        """,
            ("Inactive URL", "https://inactive.example.com", False),
        )
        url_id = cursor.fetchone()["id"]

        response = authenticated_client.post(f"/configuracion/url/toggle/{url_id}")

        assert response.status_code == 200
        data = json.loads(response.data)
        assert data.get("success") is True
        assert data.get("active") == 1  # Should be activated

        # Verify in database
        cursor.execute("SELECT active FROM sections WHERE id = %s", (url_id,))
        result = cursor.fetchone()
        assert result["active"] is True

    def test_toggle_url_deactivates_active(self, authenticated_client, db_cursor_fixture, sample_section):
        """Test POST /configuracion/url/toggle/<id> deactivates active URL"""
        cursor = db_cursor_fixture
        url_id = sample_section["id"]

        response = authenticated_client.post(f"/configuracion/url/toggle/{url_id}")

        assert response.status_code == 200
        data = json.loads(response.data)
        assert data.get("success") is True
        assert data.get("active") == 0  # Should be deactivated

        # Verify in database
        cursor.execute("SELECT active FROM sections WHERE id = %s", (url_id,))
        result = cursor.fetchone()
        assert result["active"] is False

    def test_toggle_url_with_invalid_id(self, authenticated_client):
        """Test POST /configuracion/url/toggle/<id> with non-existent ID"""
        response = authenticated_client.post("/configuracion/url/toggle/99999")

        assert response.status_code == 404
        data = json.loads(response.data)
        assert data.get("success") is False

    def test_delete_url_requires_post(self, authenticated_client):
        """Test /configuracion/url/delete/<id> requires POST method"""
        response = authenticated_client.get("/configuracion/url/delete/1")

        assert response.status_code == 405  # Method Not Allowed

    def test_delete_url_without_tasks(self, authenticated_client, db_cursor_fixture):
        """Test POST /configuracion/url/delete/<id> deletes URL without tasks"""
        cursor = db_cursor_fixture

        # Insert URL without tasks
        cursor.execute(
            """
            INSERT INTO sections (name, url, active, created_at)
            VALUES (%s, %s, %s, CURRENT_TIMESTAMP)
            RETURNING id
        """,
            ("Deletable URL", "https://delete.example.com", True),
        )
        url_id = cursor.fetchone()["id"]

        response = authenticated_client.post(f"/configuracion/url/delete/{url_id}")

        assert response.status_code == 200
        data = json.loads(response.data)
        assert data.get("success") is True

        # Verify deletion in database
        cursor.execute("SELECT * FROM sections WHERE id = %s", (url_id,))
        result = cursor.fetchone()
        assert result is None

    def test_delete_url_with_tasks(self, authenticated_client, db_cursor_fixture, sample_section):
        """Test POST /configuracion/url/delete/<id> fails if URL has tasks"""
        cursor = db_cursor_fixture
        url_id = sample_section["id"]

        # Insert a task for this section
        cursor.execute(
            """
            INSERT INTO tasks (section_id, task_type_id, period, status)
            VALUES (%s, %s, %s, %s)
        """,
            (url_id, 1, "2025-10", "pending"),
        )

        response = authenticated_client.post(f"/configuracion/url/delete/{url_id}")

        assert response.status_code == 400
        data = json.loads(response.data)
        assert data.get("success") is False
        assert "tareas asociadas" in data.get("error", "").lower()

        # Verify URL still exists
        cursor.execute("SELECT * FROM sections WHERE id = %s", (url_id,))
        result = cursor.fetchone()
        assert result is not None

    def test_delete_url_with_invalid_id(self, authenticated_client):
        """Test POST /configuracion/url/delete/<id> with non-existent ID"""
        response = authenticated_client.post("/configuracion/url/delete/99999")

        # Should succeed but not delete anything
        assert response.status_code == 200


@pytest.mark.skip(reason="TODO: Fix Flask app context and authentication for blueprint tests")
@pytest.mark.integration
@pytest.mark.requires_db
class TestConfigBlueprintEdgeCases:
    """Test edge cases and error handling"""

    def test_save_alert_settings_with_empty_array(self, authenticated_client):
        """Test saving empty alert settings array"""
        response = authenticated_client.post(
            "/configuracion/alertas",
            data=json.dumps([]),
            content_type="application/json",
        )

        # Should succeed (no updates)
        assert response.status_code == 200

    def test_add_url_with_very_long_name(self, authenticated_client, db_cursor_fixture):
        """Test adding URL with very long name"""
        long_name = "A" * 500  # Very long name

        response = authenticated_client.post(
            "/configuracion/url/add",
            data={"name": long_name, "url": "https://test.com"},
        )

        # Should succeed or fail gracefully
        assert response.status_code in [200, 400, 500]

    def test_add_url_with_invalid_url_format(self, authenticated_client):
        """Test adding URL with invalid format"""
        response = authenticated_client.post(
            "/configuracion/url/add",
            data={"name": "Invalid URL", "url": "not-a-valid-url"},
        )

        # Should succeed (validation is minimal) or fail gracefully
        assert response.status_code in [200, 400]
