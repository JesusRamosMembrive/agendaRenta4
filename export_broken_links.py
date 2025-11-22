#!/usr/bin/env python3
"""
Export Broken Links Report
Generates detailed reports of broken URLs, redirects, and errors
"""

from datetime import datetime

from dotenv import load_dotenv

from utils import db_cursor

load_dotenv()


def export_broken_links_txt():
    """Export broken links to text file"""

    with db_cursor(commit=False) as cursor:
        # Get latest crawl run
        cursor.execute("""
            SELECT id, started_at, finished_at, urls_discovered
            FROM crawl_runs
            ORDER BY id DESC
            LIMIT 1
        """)
        crawl_run = cursor.fetchone()

        if not crawl_run:
            print("❌ No crawl runs found")
            return

        # Get broken URLs (4xx, 5xx)
        cursor.execute(
            """
            SELECT
                url,
                status_code,
                response_time,
                error_message,
                last_checked,
                is_priority,
                depth
            FROM discovered_urls
            WHERE crawl_run_id = %s
              AND status_code >= 400
            ORDER BY status_code, is_priority DESC, url
        """,
            (crawl_run["id"],),
        )

        broken_urls = cursor.fetchall()

        # Get redirects that end in 404
        cursor.execute(
            """
            SELECT
                url,
                status_code,
                response_time,
                last_checked,
                is_priority,
                depth
            FROM discovered_urls
            WHERE crawl_run_id = %s
              AND status_code >= 300
              AND status_code < 400
              AND url LIKE %s
            ORDER BY url
        """,
            (crawl_run["id"], "%error-404%"),
        )

        bad_redirects = cursor.fetchall()

        # Get timeouts/errors
        cursor.execute(
            """
            SELECT
                url,
                error_message,
                last_checked,
                is_priority,
                depth
            FROM discovered_urls
            WHERE crawl_run_id = %s
              AND status_code IS NULL
              AND last_checked IS NOT NULL
            ORDER BY url
        """,
            (crawl_run["id"],),
        )

        errors = cursor.fetchall()

        # Get all redirects for analysis
        cursor.execute(
            """
            SELECT
                url,
                status_code,
                response_time,
                is_priority
            FROM discovered_urls
            WHERE crawl_run_id = %s
              AND status_code >= 300
              AND status_code < 400
            ORDER BY url
        """,
            (crawl_run["id"],),
        )

        all_redirects = cursor.fetchall()

    # Generate report
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"broken_links_report_{timestamp}.txt"

    with open(filename, "w", encoding="utf-8") as f:
        # Header
        f.write("=" * 80 + "\n")
        f.write("BROKEN LINKS REPORT\n")
        f.write("=" * 80 + "\n")
        f.write(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Crawl Run ID: {crawl_run['id']}\n")
        f.write(
            f"Crawl Started: {crawl_run['started_at'].strftime('%Y-%m-%d %H:%M:%S')}\n"
        )
        if crawl_run["finished_at"]:
            f.write(
                f"Crawl Finished: {crawl_run['finished_at'].strftime('%Y-%m-%d %H:%M:%S')}\n"
            )
        f.write(f"Total URLs Discovered: {crawl_run['urls_discovered']}\n")

        # Summary
        f.write("\n" + "=" * 80 + "\n")
        f.write("SUMMARY\n")
        f.write("=" * 80 + "\n")
        f.write(f"Broken URLs (4xx, 5xx): {len(broken_urls)}\n")
        f.write(f"Bad Redirects (→ 404):  {len(bad_redirects)}\n")
        f.write(f"Errors/Timeouts:        {len(errors)}\n")
        f.write(f"Total Redirects:        {len(all_redirects)}\n")
        f.write(
            f"TOTAL ISSUES:           {len(broken_urls) + len(bad_redirects) + len(errors)}\n"
        )

        # Broken URLs (4xx, 5xx)
        if broken_urls:
            f.write("\n" + "=" * 80 + "\n")
            f.write(f"BROKEN URLS ({len(broken_urls)})\n")
            f.write("=" * 80 + "\n")

            # Group by status code
            status_groups = {}
            for url_data in broken_urls:
                code = url_data["status_code"]
                if code not in status_groups:
                    status_groups[code] = []
                status_groups[code].append(url_data)

            for status_code in sorted(status_groups.keys()):
                urls = status_groups[status_code]
                f.write(f"\n--- HTTP {status_code} ({len(urls)} URLs) ---\n\n")

                for url_data in urls:
                    priority_marker = "⭐ " if url_data["is_priority"] else ""
                    f.write(f"{priority_marker}{url_data['url']}\n")
                    if url_data["error_message"]:
                        f.write(f"   Error: {url_data['error_message']}\n")
                    if url_data["response_time"]:
                        f.write(f"   Response time: {url_data['response_time']:.2f}s\n")
                    f.write(f"   Depth: {url_data['depth']}\n")
                    f.write(
                        f"   Last checked: {url_data['last_checked'].strftime('%Y-%m-%d %H:%M:%S')}\n"
                    )
                    f.write("\n")

        # Bad Redirects
        if bad_redirects:
            f.write("\n" + "=" * 80 + "\n")
            f.write(f"BAD REDIRECTS (→ 404) ({len(bad_redirects)})\n")
            f.write("=" * 80 + "\n")
            f.write("\nThese URLs redirect to error pages:\n\n")

            for url_data in bad_redirects:
                priority_marker = "⭐ " if url_data["is_priority"] else ""
                f.write(f"{priority_marker}{url_data['url']}\n")
                f.write(f"   Status: {url_data['status_code']} (redirect)\n")
                f.write(f"   Response time: {url_data['response_time']:.2f}s\n")
                f.write(f"   Depth: {url_data['depth']}\n")
                f.write("\n")

        # Errors/Timeouts
        if errors:
            f.write("\n" + "=" * 80 + "\n")
            f.write(f"ERRORS & TIMEOUTS ({len(errors)})\n")
            f.write("=" * 80 + "\n")
            f.write("\nURLs that failed to respond:\n\n")

            for url_data in errors:
                priority_marker = "⭐ " if url_data["is_priority"] else ""
                f.write(f"{priority_marker}{url_data['url']}\n")
                f.write(f"   Error: {url_data['error_message']}\n")
                f.write(f"   Depth: {url_data['depth']}\n")
                f.write("\n")

        # All Redirects (for reference)
        if all_redirects:
            f.write("\n" + "=" * 80 + "\n")
            f.write(f"ALL REDIRECTS ({len(all_redirects)})\n")
            f.write("=" * 80 + "\n")
            f.write("\nFor reference - all redirect responses (3xx):\n\n")

            for url_data in all_redirects:
                priority_marker = "⭐ " if url_data["is_priority"] else ""
                f.write(
                    f"{priority_marker}[{url_data['status_code']}] {url_data['url']}\n"
                )

        # Recommendations
        f.write("\n" + "=" * 80 + "\n")
        f.write("RECOMMENDATIONS\n")
        f.write("=" * 80 + "\n")
        f.write("\n")

        if len(broken_urls) > 0:
            f.write("1. Fix or remove broken links (4xx, 5xx errors)\n")

        if len(bad_redirects) > 0:
            f.write("2. Update URLs that redirect to error pages\n")

        if len(errors) > 0:
            f.write("3. Investigate timeout/connection errors\n")

        if len(all_redirects) > 50:
            f.write(
                "4. Consider updating permanent redirects (301) to point directly\n"
            )

        f.write("\n")
        f.write("View detailed results:\n")
        f.write("- Web UI: http://localhost:5000/crawler/broken\n")
        f.write("- Excel Report: python generate_excel_report.py\n")
        f.write("\n")

    print("=" * 80)
    print("BROKEN LINKS REPORT GENERATED")
    print("=" * 80)
    print(f"\n📄 File: {filename}")
    print("\n📊 Summary:")
    print(f"   - Broken URLs (4xx, 5xx): {len(broken_urls)}")
    print(f"   - Bad Redirects (→ 404):  {len(bad_redirects)}")
    print(f"   - Errors/Timeouts:        {len(errors)}")
    print(f"   - Total Redirects:        {len(all_redirects)}")
    print(
        f"   - TOTAL ISSUES:           {len(broken_urls) + len(bad_redirects) + len(errors)}"
    )
    print(f"\n✅ Report saved to: {filename}")

    return filename


if __name__ == "__main__":
    export_broken_links_txt()
