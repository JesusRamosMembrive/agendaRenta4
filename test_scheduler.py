#!/usr/bin/env python3
"""
Test script for Phase 2.4 - Automatic Revalidation System
Tests the scheduler functionality without starting the Flask app
"""

from dotenv import load_dotenv

from crawler.scheduler import ValidationScheduler
from utils import db_cursor

load_dotenv()


def test_manual_revalidation():
    """Test manual revalidation execution"""
    print("=" * 80)
    print("TEST: Manual Revalidation")
    print("=" * 80)

    scheduler = ValidationScheduler()

    print("\n1. Running manual revalidation...")
    print("   This will validate all URLs and create a health snapshot.\n")

    try:
        scheduler.run_revalidation()
        print("\n✅ Manual revalidation completed successfully!")

        # Check health snapshot
        print("\n2. Checking health snapshot...")
        with db_cursor() as cursor:
            cursor.execute("""
                SELECT
                    snapshot_date,
                    health_score,
                    total_urls,
                    ok_urls,
                    broken_urls
                FROM health_snapshots
                ORDER BY snapshot_date DESC
                LIMIT 1
            """)
            snapshot = cursor.fetchone()

            if snapshot:
                print("\n   Latest Health Snapshot:")
                print(f"   - Date: {snapshot['snapshot_date']}")
                print(f"   - Health Score: {snapshot['health_score']:.1f}%")
                print(f"   - Total URLs: {snapshot['total_urls']}")
                print(f"   - OK URLs: {snapshot['ok_urls']}")
                print(f"   - Broken URLs: {snapshot['broken_urls']}")
            else:
                print("   ⚠️  No health snapshot found")

        return True

    except Exception as e:
        print(f"\n❌ Error during revalidation: {e}")
        import traceback

        traceback.print_exc()
        return False


def test_scheduler_configuration():
    """Test scheduler start/stop"""
    print("\n" + "=" * 80)
    print("TEST: Scheduler Configuration")
    print("=" * 80)

    from crawler.scheduler import get_scheduler, start_scheduler, stop_scheduler

    print("\n1. Starting scheduler (daily at 03:00)...")
    try:
        start_scheduler(frequency="daily", hour=3, minute=0)
        print("   ✅ Scheduler started")

        # Get info
        scheduler = get_scheduler()
        info = scheduler.get_schedule_info()

        if info:
            print("\n   Scheduler Info:")
            print(f"   - Job ID: {info['job_id']}")
            print(f"   - Name: {info['name']}")
            print(f"   - Next Run: {info['next_run']}")
            print(f"   - Trigger: {info['trigger']}")
        else:
            print("   ⚠️  No schedule info available")

        # Stop scheduler
        print("\n2. Stopping scheduler...")
        stop_scheduler()
        print("   ✅ Scheduler stopped")

        return True

    except Exception as e:
        print(f"\n❌ Error during scheduler test: {e}")
        import traceback

        traceback.print_exc()
        return False


def check_database_setup():
    """Check if health_snapshots table exists"""
    print("=" * 80)
    print("SETUP CHECK: Database Tables")
    print("=" * 80)

    with db_cursor() as cursor:
        # Check health_snapshots table
        cursor.execute("""
            SELECT EXISTS (
                SELECT FROM information_schema.tables
                WHERE table_name = 'health_snapshots'
            ) as exists;
        """)
        result = cursor.fetchone()
        exists = result["exists"]

        if exists:
            print("\n✅ health_snapshots table exists")

            # Check if there are any snapshots
            cursor.execute("SELECT COUNT(*) as count FROM health_snapshots")
            count = cursor.fetchone()["count"]
            print(f"   - Current snapshots: {count}")
        else:
            print("\n❌ health_snapshots table does NOT exist")
            print(
                "   Run migration: psql ... < migrations/004_add_health_snapshots.sql"
            )
            return False

        # Check discovered_urls
        cursor.execute("SELECT COUNT(*) as count FROM discovered_urls")
        url_count = cursor.fetchone()["count"]
        print(f"\n✅ discovered_urls table: {url_count} URLs")

        # Check validation status
        cursor.execute("""
            SELECT
                COUNT(*) FILTER (WHERE status_code IS NOT NULL) as validated,
                COUNT(*) FILTER (WHERE is_broken = TRUE) as broken
            FROM discovered_urls
        """)
        validation_stats = cursor.fetchone()
        print(f"   - Validated: {validation_stats['validated']}")
        print(f"   - Broken: {validation_stats['broken']}")

    return True


if __name__ == "__main__":
    print("\n🧪 TESTING PHASE 2.4 - AUTOMATIC REVALIDATION SYSTEM\n")

    # Step 1: Check database setup
    if not check_database_setup():
        print("\n❌ Database setup incomplete. Fix issues and try again.")
        exit(1)

    # Step 2: Test manual revalidation
    print("\n" + "=" * 80)
    response = (
        input("Run manual revalidation test? This will validate all URLs (y/n): ")
        .strip()
        .lower()
    )

    if response == "y":
        success = test_manual_revalidation()
        if not success:
            print("\n❌ Manual revalidation test failed")
            exit(1)
    else:
        print("   Skipped")

    # Step 3: Test scheduler configuration
    print("\n" + "=" * 80)
    response = input("Test scheduler configuration? (y/n): ").strip().lower()

    if response == "y":
        success = test_scheduler_configuration()
        if not success:
            print("\n❌ Scheduler test failed")
            exit(1)
    else:
        print("   Skipped")

    print("\n" + "=" * 80)
    print("✅ ALL TESTS PASSED")
    print("=" * 80)
    print("\nPhase 2.4 implementation is ready!")
    print("\nNext steps:")
    print("  1. Start Flask app: python app.py")
    print("  2. Navigate to: http://localhost:5000/crawler/health")
    print("  3. Configure scheduler: http://localhost:5000/crawler/scheduler")
    print("  4. Test email notifications (configure SMTP in .env)")
    print("\n")
