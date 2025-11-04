#!/usr/bin/env python3
"""
Restore database from Render production to local PostgreSQL.
"""

import psycopg2
from psycopg2.extras import RealDictCursor

# Connection strings
RENDER_URL = "postgresql://taskmanagerwebrenta4db_ozfy_user:cp6ZcGTJWL1FDUCkaXijmSzFhnUlo4Nm@dpg-d416bl98ocjs73ch4lrg-a.frankfurt-postgres.render.com/taskmanagerwebrenta4db_ozfy"
LOCAL_URL = "postgresql://jesusramos:dev-password@localhost/agendaRenta4"

# Tables to copy (in dependency order)
TABLES = [
    'users',
    'sections',
    'task_types',
    'alert_settings',
    'notification_preferences',
    'tasks',
    'pending_alerts',
    'discovered_urls',
    'crawl_runs',
    'url_changes',
    'health_snapshots',
    'quality_checks',
    'quality_check_batches',
    'quality_check_config'
]

def copy_table(source_conn, dest_conn, table_name):
    """Copy all data from source table to destination table."""
    print(f"Copying table: {table_name}")

    src_cur = source_conn.cursor(cursor_factory=RealDictCursor)
    dest_cur = dest_conn.cursor()

    try:
        # Get all data from source
        src_cur.execute(f"SELECT * FROM {table_name}")
        rows = src_cur.fetchall()

        if not rows:
            print(f"  ⚠️  Table {table_name} is empty, skipping")
            return

        # Get column names
        columns = list(rows[0].keys())

        # Truncate destination table
        dest_cur.execute(f"TRUNCATE TABLE {table_name} CASCADE")

        # Insert all rows
        for row in rows:
            values = [row[col] for col in columns]
            placeholders = ', '.join(['%s'] * len(columns))
            cols = ', '.join(columns)

            dest_cur.execute(
                f"INSERT INTO {table_name} ({cols}) VALUES ({placeholders})",
                values
            )

        dest_conn.commit()
        print(f"  ✅ Copied {len(rows)} rows")

    except psycopg2.Error as e:
        print(f"  ❌ Error copying {table_name}: {e}")
        dest_conn.rollback()
    finally:
        src_cur.close()
        dest_cur.close()

def reset_sequences(conn):
    """Reset all sequences to max(id) + 1."""
    print("\nResetting sequences...")
    cur = conn.cursor()

    for table in TABLES:
        try:
            # Get the sequence name
            cur.execute(f"""
                SELECT pg_get_serial_sequence('{table}', 'id')
            """)
            result = cur.fetchone()

            if result and result[0]:
                sequence = result[0]
                # Reset sequence
                cur.execute(f"""
                    SELECT setval('{sequence}', COALESCE((SELECT MAX(id) FROM {table}), 1))
                """)
                print(f"  ✅ Reset sequence for {table}")
        except psycopg2.Error as e:
            print(f"  ⚠️  Could not reset sequence for {table}: {e}")

    conn.commit()
    cur.close()

def main():
    print("="*80)
    print("RESTORING DATABASE FROM RENDER TO LOCAL")
    print("="*80)

    # Connect to both databases
    print("\nConnecting to Render (production)...")
    src_conn = psycopg2.connect(RENDER_URL)
    print("✅ Connected to Render")

    print("\nConnecting to local PostgreSQL...")
    dest_conn = psycopg2.connect(LOCAL_URL)
    print("✅ Connected to local")

    # Copy all tables
    print("\n" + "="*80)
    print("COPYING TABLES")
    print("="*80 + "\n")

    for table in TABLES:
        copy_table(src_conn, dest_conn, table)

    # Reset sequences
    reset_sequences(dest_conn)

    # Close connections
    src_conn.close()
    dest_conn.close()

    print("\n" + "="*80)
    print("✅ DATABASE RESTORE COMPLETED")
    print("="*80)
    print("\nYou can now access the application at http://localhost:5000")
    print("All data has been restored from production.")

if __name__ == "__main__":
    main()
