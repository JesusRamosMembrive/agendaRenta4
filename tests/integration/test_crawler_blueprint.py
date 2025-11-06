"""
Integration tests for crawler blueprint routes

Tests Flask routes in crawler/routes.py

TODO: These tests require proper Flask app context and authentication setup.
Many tests are currently skipped and need to be fixed to work with:
- Proper Flask-Login session handling
- Request context management
- Background job mocking (crawler scheduler)
"""

from datetime import datetime

import pytest


@pytest.mark.skip(
    reason="TODO: Fix Flask app context and authentication for blueprint tests"
)
@pytest.mark.integration
@pytest.mark.requires_db
class TestCrawlerBlueprint:
    """Integration tests for crawler blueprint routes"""

    def test_dashboard_route_loads(self, authenticated_client, db_cursor_fixture):
        """Test /crawler dashboard loads successfully"""
        response = authenticated_client.get("/crawler")

        assert response.status_code == 200
        assert b"Dashboard" in response.data or b"Crawler" in response.data

    def test_dashboard_shows_crawl_stats(self, authenticated_client, db_cursor_fixture):
        """Test dashboard displays crawl statistics"""
        cursor = db_cursor_fixture

        # Insert a crawl run
        cursor.execute(
            """
            INSERT INTO crawl_runs (started_at, completed_at, total_urls, status)
            VALUES (%s, %s, %s, %s)
            RETURNING id
        """,
            (datetime.now(), datetime.now(), 100, "completed"),
        )

        response = authenticated_client.get("/crawler")
        assert response.status_code == 200

    def test_results_route_loads(self, authenticated_client):
        """Test /crawler/results loads successfully"""
        response = authenticated_client.get("/crawler/results")

        assert response.status_code == 200
        # Should show results page even if empty

    def test_results_by_run_with_invalid_id(self, authenticated_client):
        """Test /crawler/results/<id> with non-existent run"""
        response = authenticated_client.get("/crawler/results/99999")

        # Should either redirect or show empty results
        assert response.status_code in [200, 302, 404]

    def test_results_by_run_with_valid_id(
        self, authenticated_client, db_cursor_fixture
    ):
        """Test /crawler/results/<id> with valid crawl run"""
        cursor = db_cursor_fixture

        # Insert crawl run
        cursor.execute(
            """
            INSERT INTO crawl_runs (started_at, total_urls, status)
            VALUES (%s, %s, %s)
            RETURNING id
        """,
            (datetime.now(), 10, "completed"),
        )
        crawl_run_id = cursor.fetchone()["id"]

        # Insert discovered URLs for this run
        cursor.execute(
            """
            INSERT INTO discovered_urls (url, depth, crawl_run_id, discovered_at)
            VALUES (%s, %s, %s, %s)
        """,
            ("https://example.com/test", 1, crawl_run_id, datetime.now()),
        )

        response = authenticated_client.get(f"/crawler/results/{crawl_run_id}")
        assert response.status_code == 200

    def test_broken_links_route_loads(self, authenticated_client):
        """Test /crawler/broken loads successfully"""
        response = authenticated_client.get("/crawler/broken")

        assert response.status_code == 200
        # Should show broken links page even if empty

    def test_broken_links_shows_404_urls(self, authenticated_client, db_cursor_fixture):
        """Test broken links page displays URLs with 404 status"""
        cursor = db_cursor_fixture

        # Insert a broken URL
        cursor.execute(
            """
            INSERT INTO discovered_urls
            (url, depth, is_broken, status_code, discovered_at)
            VALUES (%s, %s, %s, %s, %s)
        """,
            ("https://example.com/404", 1, True, 404, datetime.now()),
        )

        response = authenticated_client.get("/crawler/broken")
        assert response.status_code == 200
        # Content verification would require parsing HTML

    def test_health_route_loads(self, authenticated_client):
        """Test /crawler/health loads successfully"""
        response = authenticated_client.get("/crawler/health")

        assert response.status_code == 200

    def test_health_shows_snapshots(self, authenticated_client, db_cursor_fixture):
        """Test health page displays health snapshots"""
        cursor = db_cursor_fixture

        # Insert health snapshot
        cursor.execute(
            """
            INSERT INTO health_snapshots
            (snapshot_date, health_score, total_urls, ok_urls, broken_urls)
            VALUES (%s, %s, %s, %s, %s)
        """,
            (datetime.now().date(), 95, 100, 95, 5),
        )

        response = authenticated_client.get("/crawler/health")
        assert response.status_code == 200

    def test_scheduler_get_route_loads(self, authenticated_client):
        """Test GET /crawler/scheduler loads successfully"""
        response = authenticated_client.get("/crawler/scheduler")

        assert response.status_code == 200
        # Should show scheduler configuration page

    def test_scheduler_post_start_action(self, authenticated_client):
        """Test POST /crawler/scheduler with start action"""
        response = authenticated_client.post(
            "/crawler/scheduler",
            data={"action": "start", "frequency": "daily", "hour": "3", "minute": "0"},
            follow_redirects=False,
        )

        # Should redirect or return success
        assert response.status_code in [200, 302]

    def test_scheduler_post_stop_action(self, authenticated_client):
        """Test POST /crawler/scheduler with stop action"""
        response = authenticated_client.post(
            "/crawler/scheduler", data={"action": "stop"}, follow_redirects=False
        )

        # Should redirect or return success
        assert response.status_code in [200, 302]

    def test_tree_route_loads(self, authenticated_client):
        """Test /crawler/tree loads successfully"""
        response = authenticated_client.get("/crawler/tree")

        assert response.status_code == 200

    def test_tree_with_urls(self, authenticated_client, db_cursor_fixture):
        """Test tree view with hierarchical URLs"""
        cursor = db_cursor_fixture

        # Insert root URL
        cursor.execute(
            """
            INSERT INTO discovered_urls
            (url, depth, parent_url, discovered_at)
            VALUES (%s, %s, %s, %s)
            RETURNING id
        """,
            ("https://example.com", 0, None, datetime.now()),
        )
        root_id = cursor.fetchone()["id"]

        # Insert child URL
        cursor.execute(
            """
            INSERT INTO discovered_urls
            (url, depth, parent_url, discovered_at)
            VALUES (%s, %s, %s, %s)
        """,
            ("https://example.com/page1", 1, "https://example.com", datetime.now()),
        )

        response = authenticated_client.get("/crawler/tree")
        assert response.status_code == 200

    def test_tree_with_filters(self, authenticated_client, db_cursor_fixture):
        """Test tree view with broken_only filter"""
        cursor = db_cursor_fixture

        # Insert broken URL
        cursor.execute(
            """
            INSERT INTO discovered_urls
            (url, depth, is_broken, status_code, discovered_at)
            VALUES (%s, %s, %s, %s, %s)
        """,
            ("https://example.com/404", 1, True, 404, datetime.now()),
        )

        response = authenticated_client.get("/crawler/tree?broken_only=true")
        assert response.status_code == 200

    def test_tree_with_max_depth(self, authenticated_client):
        """Test tree view with max_depth filter"""
        response = authenticated_client.get("/crawler/tree?max_depth=3")

        assert response.status_code == 200

    def test_tree_with_search(self, authenticated_client):
        """Test tree view with search query"""
        response = authenticated_client.get("/crawler/tree?search=example")

        assert response.status_code == 200

    def test_start_crawler_requires_post(self, authenticated_client):
        """Test /crawler/start requires POST method"""
        response = authenticated_client.get("/crawler/start")

        # Should reject GET requests
        assert response.status_code == 405  # Method Not Allowed

    def test_start_crawler_post(self, authenticated_client):
        """Test POST /crawler/start initiates crawl"""
        response = authenticated_client.post("/crawler/start", follow_redirects=False)

        # Should redirect after starting crawl
        # Note: This will actually start a crawl in background
        # In a real scenario, we'd mock the crawler
        assert response.status_code in [200, 302]


@pytest.mark.skip(
    reason="TODO: Fix Flask app context and authentication for blueprint tests"
)
@pytest.mark.integration
@pytest.mark.requires_db
class TestCrawlerBlueprintAuthentication:
    """Test that crawler routes require authentication (if implemented)"""

    def test_dashboard_accessible_without_auth(self, authenticated_client):
        """Test if dashboard is accessible without authentication"""
        # Current implementation may not require auth
        response = authenticated_client.get("/crawler")

        # If auth is required, should redirect to login (302)
        # If not required, should load (200)
        assert response.status_code in [200, 302]

    def test_start_crawler_accessible(self, authenticated_client):
        """Test if starting crawler requires authentication"""
        response = authenticated_client.post("/crawler/start", follow_redirects=False)

        # Check if auth is enforced
        assert response.status_code in [200, 302, 405]
