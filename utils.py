#!/usr/bin/env python3
"""
Agenda Renta4 - Utility Functions
Shared functions for database, dates, and common operations
"""

import logging
import os
from contextlib import contextmanager
from datetime import datetime
from functools import wraps

import psycopg2
import psycopg2.extras
from dotenv import load_dotenv
from flask import jsonify

logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

# Database configuration - PostgreSQL only
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is required")


# ==============================================================================
# DATABASE UTILITIES
# ==============================================================================


def get_db_connection():
    """
    Create and return a PostgreSQL database connection.

    Returns:
        psycopg2.Connection: Database connection
    """
    conn = psycopg2.connect(DATABASE_URL)
    return conn


@contextmanager
def db_cursor(commit=True):
    """
    Context manager for database operations.
    Automatically handles connection lifecycle, commit/rollback, and cleanup.

    Args:
        commit: Whether to commit changes on success (default: True)

    Usage:
        with db_cursor() as cursor:
            cursor.execute("SELECT * FROM users")
            results = cursor.fetchall()
        # Connection automatically committed and closed

    Yields:
        psycopg2.Cursor: Database cursor for queries (returns dict-like rows)
    """
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    try:
        yield cursor
        if commit:
            conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


# ==============================================================================
# DATE & PERIOD UTILITIES
# ==============================================================================


def format_date(date_str):
    """
    Format date string to Spanish format: dd/mm/yyyy

    Args:
        date_str: Date string in format YYYY-MM-DD

    Returns:
        str: Date in format dd/mm/yyyy, or original string if parsing fails
    """
    if not date_str:
        return ""
    try:
        date_obj = datetime.strptime(str(date_str), "%Y-%m-%d")
        return date_obj.strftime("%d/%m/%Y")
    except (ValueError, TypeError):
        return date_str


def format_period(period_str):
    """
    Format period string from '2025-11' to 'Noviembre 2025'

    Args:
        period_str: Period string in format YYYY-MM

    Returns:
        str: Period in Spanish format, or original string if parsing fails
    """
    if not period_str:
        return ""
    try:
        year, month = period_str.split("-")
        months_es = [
            "",
            "Enero",
            "Febrero",
            "Marzo",
            "Abril",
            "Mayo",
            "Junio",
            "Julio",
            "Agosto",
            "Septiembre",
            "Octubre",
            "Noviembre",
            "Diciembre",
        ]
        return f"{months_es[int(month)]} {year}"
    except (ValueError, IndexError, TypeError):
        return period_str


def generate_available_periods():
    """
    Generate list of available periods (configurable range via constants.PERIOD_RANGE_MONTHS).

    Returns:
        list: List of period strings in format 'YYYY-MM'
    """
    from dateutil.relativedelta import relativedelta

    from constants import PERIOD_RANGE_MONTHS

    current_date = datetime.now()
    periods = []

    # Last N months
    for i in range(PERIOD_RANGE_MONTHS, 0, -1):
        past_date = current_date - relativedelta(months=i)
        periods.append(past_date.strftime("%Y-%m"))

    # Current month
    periods.append(current_date.strftime("%Y-%m"))

    # Next N months
    for i in range(1, PERIOD_RANGE_MONTHS + 1):
        future_date = current_date + relativedelta(months=i)
        periods.append(future_date.strftime("%Y-%m"))

    return periods


# ==============================================================================
# CRAWLER UTILITIES
# ==============================================================================


def get_latest_crawl_run(cursor, status="completed"):
    """
    Get the most recent crawl run with the specified status.

    Args:
        cursor: DB cursor
        status: Status of the crawl ('completed', 'running', 'failed', 'cancelled')

    Returns:
        dict: Crawl run data or None if no matching crawl found
    """
    cursor.execute(
        """
        SELECT id, started_at, finished_at, urls_discovered, status
        FROM crawl_runs
        WHERE status = %s
        ORDER BY id DESC
        LIMIT 1
    """,
        (status,),
    )
    return cursor.fetchone()


# ==============================================================================
# PAGINATION UTILITIES
# ==============================================================================


class Paginator:
    """
    Helper for calculating pagination of results.

    Usage:
        paginator = Paginator(page=1, per_page=20)
        query = f"SELECT * FROM items LIMIT {paginator.per_page} OFFSET {paginator.offset}"
        pagination_info = paginator.page_info(total_items)
    """

    def __init__(self, page=1, per_page=20):
        """
        Initialize paginator.

        Args:
            page: Current page number (1-indexed)
            per_page: Items per page
        """
        self.page = max(1, page)  # Ensure page >= 1
        self.per_page = per_page

    @property
    def offset(self):
        """
        Calculate offset for LIMIT/OFFSET in SQL.

        Returns:
            int: Offset value
        """
        return (self.page - 1) * self.per_page

    def total_pages(self, total_items):
        """
        Calculate total number of pages given total items.

        Args:
            total_items: Total number of items

        Returns:
            int: Total pages
        """
        return (total_items + self.per_page - 1) // self.per_page

    def page_info(self, total_items):
        """
        Return dict with pagination info for templates.

        Args:
            total_items: Total number of items

        Returns:
            dict: Pagination info with keys: page, per_page, total_pages,
                  total_items, has_prev, has_next
        """
        return {
            "page": self.page,
            "per_page": self.per_page,
            "total_pages": self.total_pages(total_items),
            "total_items": total_items,
            "has_prev": self.page > 1,
            "has_next": self.page < self.total_pages(total_items),
        }


# ==============================================================================
# API ERROR HANDLING
# ==============================================================================


def handle_api_errors(f):
    """
    Decorator for consistent error handling in API endpoints.

    Captures exceptions, logs them, and returns appropriate JSON error responses.

    Usage:
        @app.route('/api/endpoint')
        @login_required
        @handle_api_errors
        def my_endpoint():
            # Your logic here
            return jsonify({'success': True})

    Error Handling:
        - ValueError: 400 Bad Request (validation errors)
        - Other Exception: 500 Internal Server Error
    """

    @wraps(f)
    def decorated_function(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except ValueError as e:
            # Validation errors (400 Bad Request)
            logger.warning(f"Validation error in {f.__name__}: {str(e)}")
            return jsonify({"success": False, "error": str(e)}), 400
        except Exception as e:
            # Unexpected errors (500 Internal Server Error)
            logger.error(f"Unexpected error in {f.__name__}: {str(e)}", exc_info=True)
            return jsonify({"success": False, "error": "Internal server error"}), 500

    return decorated_function
