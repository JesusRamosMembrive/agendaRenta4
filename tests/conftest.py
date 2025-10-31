"""
Pytest configuration and shared fixtures
"""

import os
import pytest
from datetime import datetime
from unittest.mock import MagicMock
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import database utilities
from utils import db_cursor


@pytest.fixture(scope="session")
def database_url():
    """Provide database URL for tests."""
    return os.getenv("DATABASE_URL")


@pytest.fixture(scope="function")
def db_connection():
    """
    Provide a database connection for tests.
    Automatically rolls back after each test.
    """
    import psycopg2
    import psycopg2.extras

    conn = psycopg2.connect(os.getenv("DATABASE_URL"))
    conn.autocommit = False  # Enable transaction mode

    yield conn

    # Rollback any changes made during test
    conn.rollback()
    conn.close()


@pytest.fixture(scope="function")
def db_cursor_fixture(db_connection):
    """
    Provide a database cursor for tests.
    Uses RealDictCursor for dict-like row access.
    """
    import psycopg2.extras

    cursor = db_connection.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    yield cursor
    cursor.close()


@pytest.fixture
def sample_section(db_cursor_fixture):
    """
    Create a sample section (URL) for testing.
    Automatically cleaned up after test.
    """
    cursor = db_cursor_fixture

    cursor.execute(
        """
        INSERT INTO sections (name, url, active, created_at)
        VALUES (%s, %s, %s, CURRENT_TIMESTAMP)
        RETURNING id, name, url, active
    """,
        ("Test Section", "https://example.com/test", True),
    )

    section = dict(cursor.fetchone())
    yield section

    # Cleanup is automatic via transaction rollback


@pytest.fixture
def sample_sections(db_cursor_fixture):
    """
    Create multiple sample sections for testing.
    """
    cursor = db_cursor_fixture
    sections = []

    test_data = [
        ("Section 1", "https://example.com/page1", True),
        ("Section 2", "https://example.com/page2", True),
        ("Section 3", "https://example.com/page3", False),
    ]

    for name, url, active in test_data:
        cursor.execute(
            """
            INSERT INTO sections (name, url, active, created_at)
            VALUES (%s, %s, %s, CURRENT_TIMESTAMP)
            RETURNING id, name, url, active
        """,
            (name, url, active),
        )
        sections.append(dict(cursor.fetchone()))

    yield sections


@pytest.fixture
def mock_html_content():
    """Provide sample HTML content for testing."""
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Test Page</title>
    </head>
    <body>
        <h1>Test Content</h1>
        <img src="https://example.com/image1.jpg" alt="Test Image 1">
        <img src="https://example.com/image2.png" alt="Test Image 2">
        <img src="https://example.com/image3.gif">
        <a href="https://example.com/link1">Link 1</a>
        <a href="https://example.com/link2">Link 2</a>
        <a href="https://broken.com/404">Broken Link</a>
    </body>
    </html>
    """


@pytest.fixture
def mock_requests_get(monkeypatch):
    """
    Mock requests.get() to avoid real network calls.
    Returns a mock response object.
    """
    import requests

    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.text = "<html><body>Test</body></html>"
    mock_response.headers = {"content-type": "text/html"}

    def mock_get(*args, **kwargs):
        return mock_response

    monkeypatch.setattr(requests, "get", mock_get)
    yield mock_response


@pytest.fixture
def quality_check_config():
    """Provide sample configuration for quality checkers."""
    return {
        "timeout": 10,
        "max_links": 50,
        "follow_redirects": True,
        "ignore_patterns": ["/static/", "/media/", ".pdf"],
    }


@pytest.fixture
def app():
    """
    Provide Flask app instance for testing.
    Configured for testing mode.
    """
    from app import app as flask_app

    flask_app.config["TESTING"] = True
    flask_app.config["WTF_CSRF_ENABLED"] = False

    yield flask_app


@pytest.fixture
def client(app):
    """
    Provide Flask test client.
    """
    return app.test_client()


@pytest.fixture
def authenticated_client(client):
    """
    Provide authenticated Flask test client.
    """
    # Mock login
    with client.session_transaction() as sess:
        sess["user_id"] = 1

    yield client
