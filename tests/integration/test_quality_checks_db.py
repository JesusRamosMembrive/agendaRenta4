"""
Integration tests for quality_checks table operations

Tests database interactions for storing and retrieving quality check results.
"""

from datetime import datetime

import pytest


@pytest.mark.integration
@pytest.mark.requires_db
class TestQualityChecksTable:
    """Integration tests for quality_checks table"""

    def test_insert_quality_check_result(self, db_cursor_fixture, sample_section):
        """Test inserting a quality check result into database"""
        cursor = db_cursor_fixture
        section_id = sample_section["id"]

        # Insert quality check result
        cursor.execute(
            """
            INSERT INTO quality_checks
            (section_id, check_type, status, score, message, details, issues_found, execution_time_ms, checked_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """,
            (
                section_id,
                "test_check",
                "ok",
                90,
                "Test passed",
                '{"test": "data"}',
                0,
                100,
                datetime.now(),
            ),
        )

        check_id = cursor.fetchone()["id"]
        assert check_id is not None

        # Verify insertion
        cursor.execute("SELECT * FROM quality_checks WHERE id = %s", (check_id,))
        result = cursor.fetchone()

        assert result is not None
        assert result["section_id"] == section_id
        assert result["check_type"] == "test_check"
        assert result["status"] == "ok"
        assert result["score"] == 90
        assert result["message"] == "Test passed"
        assert result["issues_found"] == 0
        assert result["execution_time_ms"] == 100

    def test_query_checks_by_section(self, db_cursor_fixture, sample_section):
        """Test querying quality checks by section_id"""
        cursor = db_cursor_fixture
        section_id = sample_section["id"]

        # Insert multiple checks for the section
        check_types = ["broken_links", "image_quality", "typo"]

        for check_type in check_types:
            cursor.execute(
                """
                INSERT INTO quality_checks
                (section_id, check_type, status, score, message, details, issues_found, execution_time_ms)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
                (section_id, check_type, "ok", 100, "All good", "{}", 0, 50),
            )

        # Query all checks for this section
        cursor.execute(
            """
            SELECT check_type, status, score
            FROM quality_checks
            WHERE section_id = %s
            ORDER BY check_type
        """,
            (section_id,),
        )

        results = cursor.fetchall()
        assert len(results) == 3
        assert [r["check_type"] for r in results] == [
            "broken_links",
            "image_quality",
            "typo",
        ]

    def test_query_checks_by_type(self, db_cursor_fixture, sample_sections):
        """Test querying all checks of a specific type across sections"""
        cursor = db_cursor_fixture

        # Insert same check type for multiple sections
        for section in sample_sections:
            cursor.execute(
                """
                INSERT INTO quality_checks
                (section_id, check_type, status, score, message, details, issues_found, execution_time_ms)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
                (section["id"], "broken_links", "ok", 95, "OK", "{}", 0, 100),
            )

        # Query all broken_links checks
        cursor.execute(
            """
            SELECT s.name, qc.status, qc.score
            FROM quality_checks qc
            JOIN sections s ON qc.section_id = s.id
            WHERE qc.check_type = %s
            ORDER BY s.name
        """,
            ("broken_links",),
        )

        results = cursor.fetchall()
        assert len(results) == 3
        assert all(r["status"] == "ok" for r in results)

    def test_query_checks_by_status(self, db_cursor_fixture, sample_section):
        """Test querying checks by status (ok, warning, error)"""
        cursor = db_cursor_fixture
        section_id = sample_section["id"]

        # Insert checks with different statuses
        statuses = [
            ("broken_links", "ok", 100),
            ("image_quality", "warning", 60),
            ("typo", "error", 30),
        ]

        for check_type, status, score in statuses:
            cursor.execute(
                """
                INSERT INTO quality_checks
                (section_id, check_type, status, score, message, details, issues_found, execution_time_ms)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
                (section_id, check_type, status, score, "Message", "{}", 0, 100),
            )

        # Query only errors
        cursor.execute(
            """
            SELECT check_type, score
            FROM quality_checks
            WHERE section_id = %s AND status = %s
        """,
            (section_id, "error"),
        )

        results = cursor.fetchall()
        assert len(results) == 1
        assert results[0]["check_type"] == "typo"
        assert results[0]["score"] == 30

    def test_update_quality_check(self, db_cursor_fixture, sample_section):
        """Test updating an existing quality check"""
        cursor = db_cursor_fixture
        section_id = sample_section["id"]

        # Insert initial check
        cursor.execute(
            """
            INSERT INTO quality_checks
            (section_id, check_type, status, score, message, details, issues_found, execution_time_ms)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """,
            (section_id, "test_check", "ok", 90, "Initial", "{}", 0, 100),
        )

        check_id = cursor.fetchone()["id"]

        # Update the check
        cursor.execute(
            """
            UPDATE quality_checks
            SET status = %s, score = %s, message = %s, issues_found = %s
            WHERE id = %s
        """,
            ("error", 40, "Updated", 5, check_id),
        )

        # Verify update
        cursor.execute("SELECT * FROM quality_checks WHERE id = %s", (check_id,))
        result = cursor.fetchone()

        assert result["status"] == "error"
        assert result["score"] == 40
        assert result["message"] == "Updated"
        assert result["issues_found"] == 5

    def test_delete_quality_check(self, db_cursor_fixture, sample_section):
        """Test deleting a quality check"""
        cursor = db_cursor_fixture
        section_id = sample_section["id"]

        # Insert check
        cursor.execute(
            """
            INSERT INTO quality_checks
            (section_id, check_type, status, score, message, details, issues_found, execution_time_ms)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """,
            (section_id, "test_check", "ok", 90, "Test", "{}", 0, 100),
        )

        check_id = cursor.fetchone()["id"]

        # Delete check
        cursor.execute("DELETE FROM quality_checks WHERE id = %s", (check_id,))

        # Verify deletion
        cursor.execute("SELECT * FROM quality_checks WHERE id = %s", (check_id,))
        result = cursor.fetchone()

        assert result is None

    def test_cascade_delete_on_section_removal(self, db_cursor_fixture, sample_section):
        """Test that quality checks are deleted when section is deleted (CASCADE)"""
        cursor = db_cursor_fixture
        section_id = sample_section["id"]

        # Insert quality check
        cursor.execute(
            """
            INSERT INTO quality_checks
            (section_id, check_type, status, score, message, details, issues_found, execution_time_ms)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """,
            (section_id, "test_check", "ok", 90, "Test", "{}", 0, 100),
        )

        check_id = cursor.fetchone()["id"]

        # Delete the section (should cascade to quality_checks)
        cursor.execute("DELETE FROM sections WHERE id = %s", (section_id,))

        # Verify quality check was also deleted
        cursor.execute("SELECT * FROM quality_checks WHERE id = %s", (check_id,))
        result = cursor.fetchone()

        assert result is None

    def test_score_constraint(self, db_cursor_fixture, sample_section):
        """Test that score constraint (0-100) is enforced"""
        cursor = db_cursor_fixture
        section_id = sample_section["id"]

        # Try to insert score > 100
        with pytest.raises(Exception):  # Should raise IntegrityError
            cursor.execute(
                """
                INSERT INTO quality_checks
                (section_id, check_type, status, score, message, details, issues_found, execution_time_ms)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
                (section_id, "test_check", "ok", 150, "Invalid", "{}", 0, 100),
            )

        # Try to insert score < 0
        with pytest.raises(Exception):  # Should raise IntegrityError
            cursor.execute(
                """
                INSERT INTO quality_checks
                (section_id, check_type, status, score, message, details, issues_found, execution_time_ms)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
                (section_id, "test_check", "error", -10, "Invalid", "{}", 0, 100),
            )

    def test_jsonb_details_field(self, db_cursor_fixture, sample_section):
        """Test storing and retrieving complex JSON data in details field"""
        import json

        cursor = db_cursor_fixture
        section_id = sample_section["id"]

        complex_details = {
            "broken_links": [
                {"url": "https://example.com/404", "status_code": 404},
                {"url": "https://example.com/500", "status_code": 500},
            ],
            "total_links": 50,
            "metadata": {"checked_at": "2025-10-31", "checker_version": "1.0"},
        }

        # Insert with complex JSON (convert dict to JSON string)
        cursor.execute(
            """
            INSERT INTO quality_checks
            (section_id, check_type, status, score, message, details, issues_found, execution_time_ms)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """,
            (
                section_id,
                "broken_links",
                "error",
                60,
                "Found broken links",
                json.dumps(complex_details),
                2,
                250,
            ),
        )

        check_id = cursor.fetchone()["id"]

        # Retrieve and verify JSON structure
        cursor.execute("SELECT details FROM quality_checks WHERE id = %s", (check_id,))
        result = cursor.fetchone()

        assert result["details"]["total_links"] == 50
        assert len(result["details"]["broken_links"]) == 2
        assert result["details"]["metadata"]["checker_version"] == "1.0"

    def test_get_latest_checks_per_section(self, db_cursor_fixture, sample_section):
        """Test querying latest quality check for each type per section"""
        from datetime import datetime, timedelta

        cursor = db_cursor_fixture
        section_id = sample_section["id"]

        # Insert multiple checks of same type at different times with explicit timestamps
        base_time = datetime.now()
        for i in range(3):
            cursor.execute(
                """
                INSERT INTO quality_checks
                (section_id, check_type, status, score, message, details, issues_found, execution_time_ms, checked_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
                (
                    section_id,
                    "broken_links",
                    "ok",
                    90 + i,
                    f"Check {i}",
                    "{}",
                    0,
                    100,
                    base_time + timedelta(seconds=i),
                ),
            )

        # Query latest check of each type
        cursor.execute(
            """
            SELECT DISTINCT ON (check_type)
                check_type, score, message, checked_at
            FROM quality_checks
            WHERE section_id = %s
            ORDER BY check_type, checked_at DESC
        """,
            (section_id,),
        )

        result = cursor.fetchone()
        assert result is not None
        assert result["score"] == 92  # Latest check (90+2)
        assert result["message"] == "Check 2"
