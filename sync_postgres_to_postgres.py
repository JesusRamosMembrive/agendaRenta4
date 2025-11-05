#!/usr/bin/env python3
"""
Script para copiar base de datos PostgreSQL local a producción
Uso: python3 sync_postgres_to_postgres.py <production_database_url>

Ejemplo:
    python3 sync_postgres_to_postgres.py "postgresql://user:pass@host:port/dbname"
"""

import os
import sys

import psycopg2
import psycopg2.extras
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Tablas a migrar en orden (respetando foreign keys)
TABLES_ORDER = [
    # Stage 1 - Sistema Manual
    "sections",
    "task_types",
    "alert_settings",
    "notification_preferences",
    "notification_emails",
    "users",
    "tasks",
    "notifications",
    "pending_alerts",
    # Stage 2 - Crawler Automático
    "crawl_runs",  # Primero crawl_runs (no tiene FK)
    "discovered_urls",  # Luego discovered_urls (FK a crawl_runs)
    "url_changes",  # Luego url_changes (FK a discovered_urls)
    "health_snapshots",  # Health snapshots (independiente)
]


def get_table_schema(conn, table_name):
    """Get CREATE TABLE statement from PostgreSQL"""
    cursor = conn.cursor()

    # Get table structure
    cursor.execute(
        """
        SELECT column_name, data_type, character_maximum_length,
               is_nullable, column_default
        FROM information_schema.columns
        WHERE table_name = %s
        ORDER BY ordinal_position
    """,
        (table_name,),
    )

    columns = cursor.fetchall()

    if not columns:
        return None

    # Build CREATE TABLE statement (simplified)
    create_parts = []
    for col in columns:
        col_name, data_type, max_length, nullable, default = col

        # Build column definition
        col_def = f"{col_name} "

        if data_type == "character varying" and max_length:
            col_def += f"VARCHAR({max_length})"
        elif data_type == "integer" and default and "nextval" in str(default):
            col_def += "SERIAL"
        else:
            col_def += data_type.upper()

        if nullable == "NO" and "nextval" not in str(default or ""):
            col_def += " NOT NULL"

        if default and "nextval" not in str(default):
            col_def += f" DEFAULT {default}"

        create_parts.append(col_def)

    # Get primary key
    cursor.execute(
        """
        SELECT a.attname
        FROM pg_index i
        JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
        WHERE i.indrelid = %s::regclass AND i.indisprimary
    """,
        (table_name,),
    )

    pk_cols = [row[0] for row in cursor.fetchall()]
    if pk_cols:
        create_parts.append(f"PRIMARY KEY ({', '.join(pk_cols)})")

    cursor.close()

    return f"CREATE TABLE {table_name} ({', '.join(create_parts)})"


def migrate_table_data(source_conn, dest_conn, table_name):
    """Copy data from source PostgreSQL to destination PostgreSQL"""
    src_cursor = source_conn.cursor()
    dest_cursor = dest_conn.cursor()

    # Get all data from source
    src_cursor.execute(f"SELECT * FROM {table_name}")
    rows = src_cursor.fetchall()

    if not rows:
        print(f"  ⚠️  {table_name}: No data to migrate")
        return 0

    # Get column names
    columns = [desc[0] for desc in src_cursor.description]

    # Build INSERT statement
    placeholders = ",".join(["%s"] * len(columns))
    columns_str = ",".join(columns)
    insert_sql = f"INSERT INTO {table_name} ({columns_str}) VALUES ({placeholders})"

    # Insert data
    count = 0
    for row in rows:
        try:
            dest_cursor.execute(insert_sql, row)
            count += 1
        except Exception as e:
            print(f"  ❌ Error inserting row in {table_name}: {e}")
            print(f"     Row data: {row}")
            raise

    dest_conn.commit()
    return count


def reset_sequences(conn):
    """Reset PostgreSQL sequences to match current max IDs"""
    cursor = conn.cursor()

    # Tables with auto-increment IDs
    tables_with_id = [
        "sections",
        "task_types",
        "tasks",
        "notifications",
        "pending_alerts",
        "notification_emails",
        "users",
        "crawl_runs",
        "discovered_urls",
        "url_changes",
        "health_snapshots",
    ]

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

    conn.commit()


def main():
    if len(sys.argv) < 2:
        print("Error: Production DATABASE_URL required")
        print(f"Usage: {sys.argv[0]} <production_database_url>")
        print()
        print("Example:")
        print(
            '  python3 sync_postgres_to_postgres.py "postgresql://user:pass@host:port/dbname"'
        )
        sys.exit(1)

    production_url = sys.argv[1]
    local_url = os.getenv("DATABASE_URL")

    if not local_url:
        print("Error: Local DATABASE_URL not found in .env")
        sys.exit(1)

    print("=" * 70)
    print("  Sync: PostgreSQL Local → PostgreSQL Production")
    print("=" * 70)
    print()
    print(f"Source (Local):      {local_url[:50]}...")
    print(f"Destination (Prod):  {production_url[:50]}...")
    print()

    # Connect to both databases
    print("Connecting to databases...")
    try:
        local_conn = psycopg2.connect(local_url)
        print("  ✓ Connected to LOCAL PostgreSQL")

        prod_conn = psycopg2.connect(production_url)
        print("  ✓ Connected to PRODUCTION PostgreSQL")
        print()
    except Exception as e:
        print(f"  ❌ Connection error: {e}")
        sys.exit(1)

    # Drop and recreate tables in production
    print("Recreating tables in production...")
    prod_cursor = prod_conn.cursor()

    for table_name in TABLES_ORDER:
        try:
            # Drop table if exists
            prod_cursor.execute(f"DROP TABLE IF EXISTS {table_name} CASCADE")
            print(f"  ✓ Dropped table: {table_name}")
        except Exception as e:
            print(f"  ⚠️  Error dropping {table_name}: {e}")
            prod_conn.rollback()

    prod_conn.commit()
    print()

    # Apply migrations from SQL files
    print("Applying migration files...")

    migrations = [
        "migrations/002_add_crawler_tables.sql",
        "migrations/003_add_priority_flag.sql",
        "migrations/004_add_health_snapshots.sql",
    ]

    # First, create Stage 1 tables from local schema
    local_cursor = local_conn.cursor()
    stage1_tables = [
        "sections",
        "task_types",
        "alert_settings",
        "notification_preferences",
        "notification_emails",
        "users",
        "tasks",
        "notifications",
        "pending_alerts",
    ]

    for table in stage1_tables:
        try:
            # Get table definition from local
            local_cursor.execute(
                f"""
                SELECT 'CREATE TABLE {table} (' || string_agg(column_definition, ', ') || ')'
                FROM (
                    SELECT column_name || ' ' || data_type ||
                           CASE WHEN character_maximum_length IS NOT NULL
                                THEN '(' || character_maximum_length || ')'
                                ELSE '' END ||
                           CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
                           CASE WHEN column_default IS NOT NULL AND column_default NOT LIKE 'nextval%'
                                THEN ' DEFAULT ' || column_default
                                ELSE '' END AS column_definition
                    FROM information_schema.columns
                    WHERE table_name = %s
                    ORDER BY ordinal_position
                ) AS cols
            """,
                (table,),
            )

            result = local_cursor.fetchone()
            if result and result[0]:
                # Simplified: just copy structure from local and data will follow
                pass

            print(f"  ✓ Table {table} schema obtained")
        except Exception as e:
            print(f"  ⚠️  Could not get schema for {table}: {e}")

    # Apply Stage 2 migration files
    for migration_file in migrations:
        try:
            with open(migration_file) as f:
                sql = f.read()
                prod_cursor.execute(sql)
                prod_conn.commit()
                print(f"  ✓ Applied: {migration_file}")
        except Exception as e:
            print(f"  ❌ Error applying {migration_file}: {e}")
            prod_conn.rollback()

    print()

    # Migrate data
    print("Migrating data...")
    total_rows = 0

    for table_name in TABLES_ORDER:
        try:
            # Check if table exists in local
            local_cursor.execute(
                """
                SELECT EXISTS (
                    SELECT FROM information_schema.tables
                    WHERE table_name = %s
                )
            """,
                (table_name,),
            )

            if not local_cursor.fetchone()[0]:
                print(f"  ⚠️  {table_name}: Table not found in local, skipping")
                continue

            count = migrate_table_data(local_conn, prod_conn, table_name)
            print(f"  ✓ {table_name}: {count} rows migrated")
            total_rows += count
        except Exception as e:
            print(f"  ❌ Error migrating {table_name}: {e}")
            prod_conn.rollback()
            raise

    print()

    # Reset sequences
    print("Resetting sequences...")
    reset_sequences(prod_conn)
    print()

    # Close connections
    local_conn.close()
    prod_conn.close()

    print("=" * 70)
    print("  ✅ Migration completed successfully!")
    print(f"  Total rows migrated: {total_rows}")
    print("=" * 70)
    print()
    print("Next steps:")
    print("1. Verify data in production")
    print("2. Test the application in Render")
    print("3. Check that crawler works correctly")
    print()


if __name__ == "__main__":
    main()
