"""
Crawler Routes Blueprint
All crawler-related routes extracted from app.py
"""

from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from flask_login import login_required, current_user
from utils import db_cursor

# Create blueprint
crawler_bp = Blueprint('crawler', __name__, url_prefix='/crawler')


@crawler_bp.route('')
@login_required
def dashboard():
    """
    Crawler dashboard - shows crawler runs and discovered URLs.
    """
    with db_cursor(commit=False) as cursor:
        # Get recent crawl runs
        cursor.execute("""
            SELECT id, started_at, finished_at, status, root_url,
                   urls_discovered, urls_broken, created_by
            FROM crawl_runs
            ORDER BY started_at DESC
            LIMIT 10
        """)
        crawl_runs = cursor.fetchall()

        # Get total discovered URLs
        cursor.execute("SELECT COUNT(*) as count FROM discovered_urls WHERE active = TRUE")
        total_urls = cursor.fetchone()['count']

        # Get broken URLs count
        cursor.execute("SELECT COUNT(*) as count FROM discovered_urls WHERE is_broken = TRUE")
        broken_urls = cursor.fetchone()['count']

    return render_template('crawler/dashboard.html',
                         crawl_runs=crawl_runs,
                         total_urls=total_urls,
                         broken_urls=broken_urls,
                         current_user=current_user)


@crawler_bp.route('/start', methods=['POST'])
@login_required
def start():
    """
    Start a new crawl run manually.
    """
    from crawler import Crawler, CRAWLER_CONFIG
    import logging

    logger = logging.getLogger(__name__)

    try:
        # Create crawler instance
        crawler = Crawler(CRAWLER_CONFIG)

        # Start crawl
        stats = crawler.crawl(created_by=current_user.full_name)

        flash(f"Crawl completado: {stats['urls_discovered']} URLs descubiertas", 'success')
        return jsonify({'success': True, 'stats': stats})

    except Exception as e:
        logger.error(f"Error starting crawler: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@crawler_bp.route('/results')
@login_required
def results():
    """
    Show list of discovered URLs (simple table).
    """
    # Get page number
    page = request.args.get('page', 1, type=int)
    per_page = 50

    with db_cursor(commit=False) as cursor:
        # Get total count
        cursor.execute("SELECT COUNT(*) as count FROM discovered_urls WHERE active = TRUE")
        total = cursor.fetchone()['count']

        # Get paginated URLs
        offset = (page - 1) * per_page
        cursor.execute("""
            SELECT id, url, depth, discovered_at, last_checked,
                   status_code, is_broken, parent_url_id
            FROM discovered_urls
            WHERE active = TRUE
            ORDER BY discovered_at DESC
            LIMIT %s OFFSET %s
        """, (per_page, offset))
        urls = cursor.fetchall()

    # Calculate pagination
    total_pages = (total + per_page - 1) // per_page

    return render_template('crawler/results.html',
                         urls=urls,
                         page=page,
                         total_pages=total_pages,
                         total=total,
                         current_user=current_user)


@crawler_bp.route('/results/<int:crawl_run_id>')
@login_required
def results_by_run(crawl_run_id):
    """
    Show URLs discovered in a specific crawl run.
    """
    with db_cursor(commit=False) as cursor:
        # Get crawl run info
        cursor.execute("""
            SELECT id, started_at, finished_at, status, root_url,
                   urls_discovered, urls_broken, created_by
            FROM crawl_runs
            WHERE id = %s
        """, (crawl_run_id,))
        crawl_run = cursor.fetchone()

        if not crawl_run:
            flash('Crawl run no encontrado', 'error')
            return redirect(url_for('crawler.dashboard'))

        # Get URLs from this run
        cursor.execute("""
            SELECT id, url, depth, discovered_at, status_code, is_broken
            FROM discovered_urls
            WHERE crawl_run_id = %s
            ORDER BY depth ASC, url ASC
        """, (crawl_run_id,))
        urls = cursor.fetchall()

    return render_template('crawler/results.html',
                         crawl_run=crawl_run,
                         urls=urls,
                         current_user=current_user)


@crawler_bp.route('/broken')
@login_required
def broken():
    """Show broken links from latest crawl"""

    # Get latest crawl run
    with db_cursor() as cursor:
        cursor.execute("""
            SELECT id, started_at, finished_at, urls_discovered
            FROM crawl_runs
            ORDER BY id DESC
            LIMIT 1
        """)
        crawl_run = cursor.fetchone()

    if not crawl_run:
        return render_template('crawler/broken.html',
                             crawl_run=None,
                             broken_urls=[],
                             current_user=current_user)

    # Get validation statistics
    with db_cursor() as cursor:
        cursor.execute("""
            SELECT
                COUNT(*) as total_validated,
                COUNT(*) FILTER (WHERE is_priority = TRUE) as priority_validated,
                COUNT(*) FILTER (WHERE is_broken = TRUE) as total_broken,
                COUNT(*) FILTER (WHERE is_priority = TRUE AND is_broken = TRUE) as priority_broken,
                COUNT(*) FILTER (WHERE is_priority = FALSE AND is_broken = TRUE) as non_priority_broken
            FROM discovered_urls
            WHERE crawl_run_id = %s AND last_checked IS NOT NULL
        """, (crawl_run['id'],))
        stats = cursor.fetchone()

    # Get broken URLs
    with db_cursor() as cursor:
        cursor.execute("""
            SELECT
                id,
                url,
                is_priority,
                depth,
                status_code,
                response_time,
                error_message,
                last_checked
            FROM discovered_urls
            WHERE crawl_run_id = %s AND is_broken = TRUE
            ORDER BY is_priority DESC, status_code ASC, url ASC
        """, (crawl_run['id'],))
        broken_urls = cursor.fetchall()

    return render_template('crawler/broken.html',
                         crawl_run=crawl_run,
                         broken_urls=broken_urls,
                         stats=stats,
                         current_user=current_user)


@crawler_bp.route('/health')
@login_required
def health():
    """
    Health dashboard with historical tracking.
    Shows health score evolution over time.
    """
    with db_cursor() as cursor:
        # Get health snapshots (last 30 days)
        cursor.execute("""
            SELECT
                id,
                snapshot_date,
                health_score,
                total_urls,
                ok_urls,
                broken_urls,
                redirect_urls,
                error_urls
            FROM health_snapshots
            ORDER BY snapshot_date DESC
            LIMIT 30
        """)
        snapshots = cursor.fetchall()

        # Get current health (latest snapshot)
        current_health = snapshots[0] if snapshots else None

        # Get trend (compare with 7 days ago)
        if len(snapshots) >= 7:
            week_ago_health = snapshots[6]['health_score']
            trend = current_health['health_score'] - week_ago_health
        else:
            trend = 0

        # Get recent changes (last 7 days)
        cursor.execute("""
            SELECT
                c.change_type,
                COUNT(*) as count
            FROM url_changes c
            WHERE c.detected_at >= NOW() - INTERVAL '7 days'
            GROUP BY c.change_type
            ORDER BY count DESC
        """)
        recent_changes = cursor.fetchall()

    return render_template(
        'crawler/health.html',
        snapshots=snapshots,
        current_health=current_health,
        trend=trend,
        recent_changes=recent_changes
    )


@crawler_bp.route('/scheduler', methods=['GET', 'POST'])
@login_required
def scheduler():
    """
    Configure automatic revalidation scheduler.
    """
    from crawler.scheduler import get_scheduler, start_scheduler, stop_scheduler

    scheduler_instance = get_scheduler()

    if request.method == 'POST':
        action = request.form.get('action')

        if action == 'start':
            frequency = request.form.get('frequency', 'daily')
            hour = int(request.form.get('hour', 3))
            minute = int(request.form.get('minute', 0))

            try:
                start_scheduler(frequency, hour, minute)
                flash(f'✓ Scheduler iniciado: {frequency} a las {hour:02d}:{minute:02d}', 'success')
            except Exception as e:
                flash(f'✗ Error al iniciar scheduler: {e}', 'error')

        elif action == 'stop':
            try:
                stop_scheduler()
                flash('✓ Scheduler detenido', 'success')
            except Exception as e:
                flash(f'✗ Error al detener scheduler: {e}', 'error')

        elif action == 'run_now':
            try:
                scheduler_instance.run_revalidation()
                flash('✓ Revalidación manual ejecutada', 'success')
            except Exception as e:
                flash(f'✗ Error al ejecutar revalidación: {e}', 'error')

        return redirect(url_for('crawler.scheduler'))

    # Get scheduler info
    schedule_info = scheduler_instance.get_schedule_info()

    return render_template(
        'crawler/scheduler.html',
        schedule_info=schedule_info
    )


@crawler_bp.route('/tree')
@login_required
def tree():
    """
    Tree view of discovered URLs with hierarchical structure.
    Shows parent-child relationships with expand/collapse functionality.
    """
    # Get filter parameters
    show_broken_only = request.args.get('broken_only', '0') == '1'
    max_depth = request.args.get('max_depth', type=int)
    search_query = request.args.get('search', '').strip()

    with db_cursor(commit=False) as cursor:
        # Build WHERE clause based on filters
        where_clauses = ["active = TRUE"]
        params = []

        if show_broken_only:
            where_clauses.append("is_broken = TRUE")

        if max_depth is not None:
            where_clauses.append("depth <= %s")
            params.append(max_depth)

        if search_query:
            where_clauses.append("url ILIKE %s")
            params.append(f'%{search_query}%')

        where_sql = " AND ".join(where_clauses)

        # Get all URLs with parent information
        cursor.execute(f"""
            SELECT id, url, parent_url_id, depth, status_code,
                   is_broken, last_checked, response_time
            FROM discovered_urls
            WHERE {where_sql}
            ORDER BY url
        """, params)
        all_urls = cursor.fetchall()

        # Get statistics
        cursor.execute("""
            SELECT
                COUNT(*) as total,
                COUNT(CASE WHEN is_broken THEN 1 END) as broken,
                COUNT(CASE WHEN status_code >= 200 AND status_code < 300 THEN 1 END) as ok,
                MAX(depth) as max_depth_value
            FROM discovered_urls
            WHERE active = TRUE
        """)
        stats = cursor.fetchone()

    # Build tree structure
    url_dict = {url['id']: dict(url) for url in all_urls}

    # Add children list to each URL
    for url in url_dict.values():
        url['children'] = []

    # Build parent-child relationships
    root_urls = []
    for url in url_dict.values():
        if url['parent_url_id'] and url['parent_url_id'] in url_dict:
            url_dict[url['parent_url_id']]['children'].append(url)
        else:
            # Root URL (no parent or parent not in filtered results)
            root_urls.append(url)

    return render_template(
        'crawler/tree.html',
        root_urls=root_urls,
        stats=stats,
        show_broken_only=show_broken_only,
        max_depth_filter=max_depth,
        search_query=search_query,
        current_user=current_user
    )
