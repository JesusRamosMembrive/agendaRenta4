#!/usr/bin/env python3
"""
Script to seed CTA validation rules with initial data.
Based on analysis from inspect_ctas.py
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils import get_db_connection

def seed_page_types(conn, cursor):
    """Create initial page types."""
    print("🌱 Seeding page types...")

    page_types = [
        ('global', 'CTAs that appear on all pages', None),
        ('homepage', 'Main homepage (www.r4.com/)', r'^https://www\.r4\.com/?$'),
        ('planes_pensiones', 'Pension plans pages', r'^https://www\.r4\.com/planes-de-pensiones/'),
        ('clientes', 'Client area and services', r'^https://www\.r4\.com/clientes'),
        ('fondos', 'Investment funds pages', r'^https://www\.r4\.com/fondos-de-inversion/'),
        ('broker', 'Broker platform pages', r'^https://www\.r4\.com/broker-online/'),
        ('academia', 'Training and courses', r'^https://www\.r4\.com/academiar4/'),
        ('contacto', 'Contact and support pages', r'^https://www\.r4\.com/contacto'),
    ]

    for name, description, url_pattern in page_types:
        cursor.execute("""
            INSERT INTO cta_page_types (name, description, url_pattern)
            VALUES (%s, %s, %s)
            ON CONFLICT (name) DO NOTHING
            RETURNING id
        """, (name, description, url_pattern))

        result = cursor.fetchone()
        if result:
            print(f"  ✅ Created page type: {name} (ID: {result[0]})")
        else:
            print(f"  ⏭️  Page type already exists: {name}")

    conn.commit()

def seed_global_rules(conn, cursor):
    """Create global CTA rules (appear on all pages)."""
    print("\n🌍 Seeding global CTA rules...")

    # Get global page type ID
    cursor.execute("SELECT id FROM cta_page_types WHERE name = 'global'")
    global_type_id = cursor.fetchone()[0]

    global_rules = [
        # (expected_text, expected_url_pattern, url_match_type, is_optional, priority)
        ('Contratar', 'https://www.r4.com/portal?TX=goto&FWD=CONT_LND&PAG=0', 'exact', False, 2),
        ('Abre una cuenta', 'https://www.r4.com/abrir-cuenta', 'exact', False, 2),
        ('abrir cuenta', 'https://www.r4.com/new?TX=goto&FWD=APERTURA-CUENTA', 'contains', True, 1),
        ('Área cliente', 'https://www.r4.com/portal', 'contains', True, 0),
    ]

    for expected_text, expected_url, url_match_type, is_optional, priority in global_rules:
        cursor.execute("""
            INSERT INTO cta_validation_rules
            (page_type_id, is_global, expected_text, expected_url_pattern,
             url_match_type, is_optional, priority)
            VALUES (%s, TRUE, %s, %s, %s, %s, %s)
            ON CONFLICT (page_type_id, expected_text, is_global) DO NOTHING
            RETURNING id
        """, (global_type_id, expected_text, expected_url, url_match_type, is_optional, priority))

        result = cursor.fetchone()
        if result:
            print(f"  ✅ Created global rule: '{expected_text}' (ID: {result[0]})")
        else:
            print(f"  ⏭️  Global rule already exists: '{expected_text}'")

    conn.commit()

def seed_specific_rules(conn, cursor):
    """Create page-type-specific CTA rules."""
    print("\n📄 Seeding page-specific CTA rules...")

    # Get page type IDs
    cursor.execute("SELECT id, name FROM cta_page_types WHERE name != 'global'")
    page_types = {name: id for id, name in cursor.fetchall()}

    specific_rules = [
        # Homepage specific CTAs
        (page_types['homepage'], 'Descubrir carteras Easy',
         'https://www.r4.com/soluciones-easy/carteras-easy', 'exact', False, 1),
        (page_types['homepage'], 'Ver promoción',
         'https://www.r4.com/serviciosr4/', 'contains', True, 0),
        (page_types['homepage'], 'Contactar con nosotros',
         'https://www.r4.com/contacto', 'exact', True, 0),

        # Fondos specific CTAs
        (page_types['fondos'], 'Ver fondo',
         'https://www.r4.com/fondos-de-inversion/fondos/', 'contains', False, 1),

        # Contacto specific CTAs
        (page_types['contacto'], 'contacta con un asesor',
         '/contacto', 'contains', False, 1),
    ]

    for page_type_id, expected_text, expected_url, url_match_type, is_optional, priority in specific_rules:
        cursor.execute("""
            INSERT INTO cta_validation_rules
            (page_type_id, is_global, expected_text, expected_url_pattern,
             url_match_type, is_optional, priority)
            VALUES (%s, FALSE, %s, %s, %s, %s, %s)
            ON CONFLICT (page_type_id, expected_text, is_global) DO NOTHING
            RETURNING id
        """, (page_type_id, expected_text, expected_url, url_match_type, is_optional, priority))

        result = cursor.fetchone()
        if result:
            print(f"  ✅ Created specific rule: '{expected_text}' for page type ID {page_type_id}")
        else:
            print(f"  ⏭️  Specific rule already exists: '{expected_text}'")

    conn.commit()

def seed_example_assignments(conn, cursor):
    """Create example URL assignments for testing."""
    print("\n🔗 Seeding example URL assignments...")

    # Get page type IDs
    cursor.execute("SELECT id, name FROM cta_page_types")
    page_types = {name: id for id, name in cursor.fetchall()}

    # Assign some URLs from sections table to page types
    example_assignments = [
        ('https://www.r4.com/', page_types['homepage']),
        ('https://www.r4.com/clientes', page_types['clientes']),
        ('https://www.r4.com/planes-de-pensiones/categorias', page_types['planes_pensiones']),
    ]

    for url_str, page_type_id in example_assignments:
        # Get URL ID from discovered_urls
        cursor.execute("SELECT id FROM discovered_urls WHERE url = %s", (url_str,))
        result = cursor.fetchone()

        if result:
            url_id = result[0]
            cursor.execute("""
                INSERT INTO cta_url_assignments (url_id, page_type_id, assigned_by, confidence)
                VALUES (%s, %s, 'seed_script', 1.0)
                ON CONFLICT (url_id, page_type_id) DO NOTHING
                RETURNING id
            """, (url_id, page_type_id))

            assignment_result = cursor.fetchone()
            if assignment_result:
                print(f"  ✅ Assigned URL '{url_str}' to page type ID {page_type_id}")
            else:
                print(f"  ⏭️  Assignment already exists for '{url_str}'")
        else:
            print(f"  ⚠️  URL not found in discovered_urls: '{url_str}'")

    conn.commit()

def print_summary(cursor):
    """Print summary of seeded data."""
    print("\n" + "="*80)
    print("📊 SEEDING SUMMARY")
    print("="*80)

    cursor.execute("SELECT COUNT(*) FROM cta_page_types")
    page_types_count = cursor.fetchone()[0]
    print(f"Page types: {page_types_count}")

    cursor.execute("SELECT COUNT(*) FROM cta_validation_rules WHERE is_global = TRUE")
    global_rules_count = cursor.fetchone()[0]
    print(f"Global rules: {global_rules_count}")

    cursor.execute("SELECT COUNT(*) FROM cta_validation_rules WHERE is_global = FALSE")
    specific_rules_count = cursor.fetchone()[0]
    print(f"Specific rules: {specific_rules_count}")

    cursor.execute("SELECT COUNT(*) FROM cta_url_assignments")
    assignments_count = cursor.fetchone()[0]
    print(f"URL assignments: {assignments_count}")

    print("\n✅ Seeding completed successfully!")

def main():
    """Main seeding function."""
    print("🌱 Starting CTA rules seeding...\n")

    conn = None
    cursor = None

    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        seed_page_types(conn, cursor)
        seed_global_rules(conn, cursor)
        seed_specific_rules(conn, cursor)
        seed_example_assignments(conn, cursor)
        print_summary(cursor)

    except Exception as e:
        print(f"\n❌ Error during seeding: {e}")
        if conn:
            conn.rollback()
        raise
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

if __name__ == '__main__':
    main()
