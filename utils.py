#!/usr/bin/env python3
"""
Agenda Renta4 - Utility Functions
Shared functions for database, dates, and common operations
"""

import os
import sqlite3
from contextlib import contextmanager
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database configuration
DATABASE_PATH = os.getenv('DATABASE_PATH', 'agendaRenta4.db')


# ==============================================================================
# DATABASE UTILITIES
# ==============================================================================

def get_db_connection():
    """
    Create and return a database connection.

    Returns:
        sqlite3.Connection: Database connection with Row factory
    """
    conn = sqlite3.connect(DATABASE_PATH)
    conn.row_factory = sqlite3.Row  # Return rows as dict-like objects
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
        sqlite3.Cursor: Database cursor for queries
    """
    conn = get_db_connection()
    cursor = conn.cursor()
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
        return ''
    try:
        date_obj = datetime.strptime(str(date_str), '%Y-%m-%d')
        return date_obj.strftime('%d/%m/%Y')
    except:
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
        return ''
    try:
        year, month = period_str.split('-')
        months_es = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                     'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
        return f"{months_es[int(month)]} {year}"
    except:
        return period_str


def generate_available_periods():
    """
    Generate list of available periods (last 6 months + current + next 6 months).

    Returns:
        list: List of period strings in format 'YYYY-MM'
    """
    from dateutil.relativedelta import relativedelta

    current_date = datetime.now()
    periods = []

    # Last 6 months
    for i in range(6, 0, -1):
        past_date = current_date - relativedelta(months=i)
        periods.append(past_date.strftime('%Y-%m'))

    # Current month
    periods.append(current_date.strftime('%Y-%m'))

    # Next 6 months
    for i in range(1, 7):
        future_date = current_date + relativedelta(months=i)
        periods.append(future_date.strftime('%Y-%m'))

    return periods
