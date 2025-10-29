#!/usr/bin/env python3
"""
Script para migrar datos de SQLite a PostgreSQL
Uso: python3 migrate_to_postgres.py <database_url>

Ejemplo:
    python3 migrate_to_postgres.py "postgresql://user:pass@host:port/dbname"
"""

import sys
import sqlite3
import psycopg2
import psycopg2.extras
from datetime import datetime

# Tablas a migrar en orden (respetando foreign keys)
TABLES_ORDER = [
    'sections',
    'task_types',
    'alert_settings',
    'notification_preferences',
    'notification_emails',
    'users',
    'tasks',
    'notifications',
    'pending_alerts',
]


def get_sqlite_schema(table_name):
    """Get CREATE TABLE statement from SQLite"""
    conn = sqlite3.connect('agendaRenta4.db')
    cursor = conn.cursor()
    cursor.execute(f"SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table_name,))
    result = cursor.fetchone()
    conn.close()
    return result[0] if result else None


def convert_sqlite_to_postgres_schema(sqlite_schema):
    """Convert SQLite CREATE TABLE to PostgreSQL syntax"""
    # SQLite to PostgreSQL type mappings
    replacements = {
        'INTEGER PRIMARY KEY AUTOINCREMENT': 'SERIAL PRIMARY KEY',
        'INTEGER PRIMARY KEY': 'SERIAL PRIMARY KEY',
        'DATETIME DEFAULT CURRENT_TIMESTAMP': 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
        'DATETIME': 'TIMESTAMP',
        'BOOLEAN DEFAULT 1': 'BOOLEAN DEFAULT TRUE',
        'BOOLEAN DEFAULT 0': 'BOOLEAN DEFAULT FALSE',
        'INTEGER DEFAULT 1': 'INTEGER DEFAULT 1',  # Keep INTEGER defaults as-is
        'INTEGER DEFAULT 0': 'INTEGER DEFAULT 0',
        'TEXT': 'TEXT',
        'INTEGER': 'INTEGER',
        'REAL': 'REAL',
        'BOOLEAN': 'BOOLEAN',
    }

    pg_schema = sqlite_schema
    for old, new in replacements.items():
        pg_schema = pg_schema.replace(old, new)

    return pg_schema


def migrate_table_data(sqlite_conn, pg_conn, table_name):
    """Migrate data from SQLite table to PostgreSQL"""
    sqlite_cursor = sqlite_conn.cursor()
    pg_cursor = pg_conn.cursor()

    # Get all data from SQLite
    sqlite_cursor.execute(f"SELECT * FROM {table_name}")
    rows = sqlite_cursor.fetchall()

    if not rows:
        print(f"  ⚠️  {table_name}: No data to migrate")
        return 0

    # Get column names and types
    columns = [description[0] for description in sqlite_cursor.description]

    # Get PostgreSQL column types to know which need conversion
    pg_cursor.execute(f"""
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_name = %s
    """, (table_name,))
    pg_columns = {row[0]: row[1] for row in pg_cursor.fetchall()}

    # Build INSERT statement
    placeholders = ','.join(['%s'] * len(columns))
    columns_str = ','.join(columns)
    insert_sql = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"

    # Insert data
    count = 0
    for row in rows:
        try:
            # Convert SQLite row to list and fix boolean types
            row_data = []
            for i, value in enumerate(row):
                col_name = columns[i]
                col_type = pg_columns.get(col_name, '')

                # Convert SQLite integers (0/1) to PostgreSQL booleans (False/True)
                if col_type == 'boolean' and isinstance(value, int):
                    row_data.append(bool(value))
                else:
                    row_data.append(value)

            pg_cursor.execute(insert_sql, row_data)
            count += 1
        except Exception as e:
            print(f"  ❌ Error inserting row in {table_name}: {e}")
            print(f"     Row data: {row}")
            raise

    pg_conn.commit()
    return count


def reset_sequences(pg_conn):
    """Reset PostgreSQL sequences to match current max IDs"""
    cursor = pg_conn.cursor()

    # Tables with auto-increment IDs
    tables_with_id = ['sections', 'task_types', 'tasks', 'notifications',
                      'pending_alerts', 'notification_emails', 'users']

    for table in tables_with_id:
        try:
            cursor.execute(f"""
                SELECT setval(pg_get_serial_sequence('{table}', 'id'),
                              COALESCE((SELECT MAX(id) FROM {table}), 0) + 1,
                              false)
            """)
            print(f"  ✓ Reset sequence for {table}")
        except Exception as e:
            print(f"  ⚠️  Could not reset sequence for {table}: {e}")

    pg_conn.commit()


def main():
    if len(sys.argv) < 2:
        print("Error: DATABASE_URL required")
        print(f"Usage: {sys.argv[0]} <database_url>")
        print()
        print("Example:")
        print('  python3 migrate_to_postgres.py "postgresql://user:pass@host:port/dbname"')
        sys.exit(1)

    database_url = sys.argv[1]

    print("=" * 70)
    print("  Migration: SQLite → PostgreSQL")
    print("=" * 70)
    print()
    print(f"Source:      agendaRenta4.db (SQLite)")
    print(f"Destination: {database_url[:50]}..." if len(database_url) > 50 else database_url)
    print()

    # Connect to both databases
    print("Connecting to databases...")
    try:
        sqlite_conn = sqlite3.connect('agendaRenta4.db')
        sqlite_conn.row_factory = sqlite3.Row
        print("  ✓ Connected to SQLite")

        pg_conn = psycopg2.connect(database_url)
        print("  ✓ Connected to PostgreSQL")
        print()
    except Exception as e:
        print(f"  ❌ Connection error: {e}")
        sys.exit(1)

    # Create tables in PostgreSQL
    print("Creating tables in PostgreSQL...")
    pg_cursor = pg_conn.cursor()

    for table_name in TABLES_ORDER:
        try:
            # Get SQLite schema
            sqlite_schema = get_sqlite_schema(table_name)
            if not sqlite_schema:
                print(f"  ⚠️  {table_name}: Table not found in SQLite, skipping")
                continue

            # Convert to PostgreSQL
            pg_schema = convert_sqlite_to_postgres_schema(sqlite_schema)

            # Drop if exists and create
            pg_cursor.execute(f"DROP TABLE IF EXISTS {table_name} CASCADE")
            pg_cursor.execute(pg_schema)
            pg_conn.commit()

            print(f"  ✓ Created table: {table_name}")
        except Exception as e:
            print(f"  ❌ Error creating {table_name}: {e}")
            print(f"     Schema: {pg_schema}")
            pg_conn.rollback()
            raise

    print()

    # Migrate data
    print("Migrating data...")
    total_rows = 0

    for table_name in TABLES_ORDER:
        try:
            count = migrate_table_data(sqlite_conn, pg_conn, table_name)
            print(f"  ✓ {table_name}: {count} rows migrated")
            total_rows += count
        except Exception as e:
            print(f"  ❌ Error migrating {table_name}: {e}")
            pg_conn.rollback()
            raise

    print()

    # Reset sequences
    print("Resetting sequences...")
    reset_sequences(pg_conn)
    print()

    # Close connections
    sqlite_conn.close()
    pg_conn.close()

    print("=" * 70)
    print(f"  ✅ Migration completed successfully!")
    print(f"  Total rows migrated: {total_rows}")
    print("=" * 70)
    print()
    print("Next steps:")
    print("1. Set DATABASE_URL environment variable in Render")
    print("2. Deploy your application")
    print("3. Verify data in production")
    print()


if __name__ == '__main__':
    main()
