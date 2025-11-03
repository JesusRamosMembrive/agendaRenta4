"""
Crawler Routes Blueprint
All crawler-related routes extracted from app.py
"""

from flask import Blueprint, render_template, request, redirect, url_for, flash, jsonify
from flask_login import login_required, current_user
from utils import db_cursor, get_latest_crawl_run, Paginator
from constants import URLS_PER_PAGE, QUALITY_CHECKS_PER_PAGE

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
    Runs crawler in background thread to avoid blocking.
    """
    from crawler import Crawler, CRAWLER_CONFIG
    from crawler.progress_tracker import progress_tracker
    import logging
    import threading

    logger = logging.getLogger(__name__)

    # Check if crawl is already running
    if progress_tracker.get_progress()['is_running']:
        return jsonify({'success': False, 'error': 'Ya hay un crawl en ejecución'}), 400

    # Capture current user name (can't access current_user in thread context)
    created_by = current_user.full_name

    def _crawl_worker():
        """Background worker task to run crawler."""
        try:
            logger.info("Starting background crawler task...")
            crawler = Crawler(CRAWLER_CONFIG)
            stats = crawler.crawl(created_by=created_by)
            logger.info(f"Crawl completed: {stats}")
        except Exception as e:
            logger.error(f"Error in background crawler: {e}")
            progress_tracker.stop_crawl()

    try:
        # Start crawler in background thread
        thread = threading.Thread(target=_crawl_worker, daemon=True)
        thread.start()

        logger.info("Crawler thread started successfully")

        # Return immediately (don't wait for completion)
        return jsonify({
            'success': True,
            'message': 'Crawl iniciado en segundo plano. Actualización automática cada 2 segundos.',
            'polling': True
        })

    except Exception as e:
        logger.error(f"Error starting crawler thread: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@crawler_bp.route('/progress', methods=['GET'])
@login_required
def progress():
    """
    Get current crawl progress (real-time status).
    Returns JSON with progress metrics.
    """
    from crawler.progress_tracker import progress_tracker

    return jsonify(progress_tracker.get_progress())


@crawler_bp.route('/cancel', methods=['POST'])
@login_required
def cancel():
    """
    Request cancellation of current crawl.
    """
    from crawler.progress_tracker import progress_tracker
    import logging

    logger = logging.getLogger(__name__)

    if progress_tracker.request_cancel():
        logger.info("Crawl cancellation requested by user")
        return jsonify({'success': True, 'message': 'Cancelación solicitada. El crawl se detendrá en breve.'})
    else:
        return jsonify({'success': False, 'error': 'No hay crawl en ejecución'}), 400


@crawler_bp.route('/results')
@login_required
def results():
    """
    Show list of discovered URLs (simple table).
    """
    # Get page number
    page = request.args.get('page', 1, type=int)
    per_page = URLS_PER_PAGE

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

    # Get latest crawl run (any status)
    with db_cursor() as cursor:
        # Get latest crawl run regardless of status
        cursor.execute("""
            SELECT id, started_at, finished_at, urls_discovered, status
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
                COALESCE(MAX(depth), 0) as max_depth_value
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


@crawler_bp.route('/quality')
@login_required
def quality():
    """
    Quality checks dashboard - shows image quality results for discovered URLs.
    """
    # Get filter parameters
    status_filter = request.args.get('status', '')  # 'ok', 'warning', 'error'
    page = request.args.get('page', 1, type=int)
    per_page = QUALITY_CHECKS_PER_PAGE

    with db_cursor(commit=False) as cursor:
        # Build WHERE clause
        where_clauses = []
        params = []

        if status_filter:
            where_clauses.append("qc.status = %s")
            params.append(status_filter)

        where_sql = " AND " + " AND ".join(where_clauses) if where_clauses else ""

        # Get quality check results with discovered URL info
        # Support both section_id (old) and discovered_url_id (new)
        cursor.execute(f"""
            SELECT
                qc.id,
                qc.section_id,
                qc.discovered_url_id,
                COALESCE(s.url, du.url) as url,
                COALESCE(s.name, du.url) as url_name,
                qc.check_type,
                qc.status,
                qc.score,
                qc.message,
                qc.details,
                qc.issues_found,
                qc.checked_at,
                qc.execution_time_ms
            FROM quality_checks qc
            LEFT JOIN sections s ON qc.section_id = s.id
            LEFT JOIN discovered_urls du ON qc.discovered_url_id = du.id
            WHERE qc.check_type = 'image_quality'{where_sql}
            ORDER BY qc.checked_at DESC
            LIMIT %s OFFSET %s
        """, params + [per_page, (page - 1) * per_page])
        quality_checks = cursor.fetchall()

        # Get total count
        cursor.execute(f"""
            SELECT COUNT(*) as count
            FROM quality_checks qc
            WHERE qc.check_type = 'image_quality'{where_sql}
        """, params)
        total = cursor.fetchone()['count']

        # Get statistics
        cursor.execute("""
            SELECT
                COUNT(*) as total_checks,
                COUNT(CASE WHEN status = 'ok' THEN 1 END) as ok_count,
                COUNT(CASE WHEN status = 'warning' THEN 1 END) as warning_count,
                COUNT(CASE WHEN status = 'error' THEN 1 END) as error_count,
                AVG(score) as avg_score,
                SUM(issues_found) as total_issues
            FROM quality_checks
            WHERE check_type = 'image_quality'
        """)
        stats = cursor.fetchone()

    # Calculate pagination
    total_pages = (total + per_page - 1) // per_page

    return render_template(
        'crawler/quality.html',
        quality_checks=quality_checks,
        stats=stats,
        status_filter=status_filter,
        page=page,
        total_pages=total_pages,
        current_user=current_user
    )


@crawler_bp.route('/test-runner')
@login_required
def test_runner():
    """
    Test Runner page - configure and run all quality checks from one place.
    Single source of truth with quality_check_config table.
    """
    from calidad.post_crawl_runner import PostCrawlQualityRunner

    with db_cursor(commit=False) as cursor:
        # Get current user's check configuration
        cursor.execute("""
            SELECT check_type, enabled, run_after_crawl, scope
            FROM quality_check_config
            WHERE user_id = %s
        """, (current_user.id,))
        configs = cursor.fetchall()

    # Convert to dict for easier access in template
    config_dict = {cfg['check_type']: cfg for cfg in configs}

    return render_template(
        'crawler/test_runner.html',
        config_dict=config_dict,
        available_checks=PostCrawlQualityRunner.AVAILABLE_CHECKS,
        current_user=current_user
    )


@crawler_bp.route('/quality/check/<int:section_id>', methods=['POST'])
@login_required
def run_quality_check(section_id):
    """
    Run image quality check on a specific URL.
    """
    from calidad import ImagenesChecker
    import json
    import logging

    logger = logging.getLogger(__name__)

    try:
        with db_cursor() as cursor:
            # Get URL from sections table
            cursor.execute("SELECT id, url, name FROM sections WHERE id = %s", (section_id,))
            section = cursor.fetchone()

            if not section:
                return jsonify({'success': False, 'error': 'URL not found'}), 404

            # Run image quality check
            checker = ImagenesChecker(config={'check_format': True})
            result = checker.check(section['url'])

            # Save result to quality_checks table
            cursor.execute("""
                INSERT INTO quality_checks (
                    section_id, check_type, status, score, message,
                    details, issues_found, checked_at, execution_time_ms
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (
                section_id,
                result.check_type,
                result.status,
                result.score,
                result.message,
                json.dumps(result.details),
                result.issues_found,
                result.checked_at,
                result.execution_time_ms
            ))

            check_id = cursor.fetchone()['id']

            logger.info(f"Quality check completed for {section['url']}: {result.status} (score: {result.score})")

            return jsonify({
                'success': True,
                'check_id': check_id,
                'status': result.status,
                'score': result.score,
                'message': result.message,
                'issues_found': result.issues_found
            })

    except Exception as e:
        logger.error(f"Error running quality check: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@crawler_bp.route('/quality/batch', methods=['POST'])
@login_required
def run_batch_quality_check():
    """
    Run quality checks on multiple URLs in batch.
    Expects JSON with list of section_ids.
    """
    from calidad import ImagenesChecker
    from calidad.batch import BatchQualityCheckRunner
    import logging

    logger = logging.getLogger(__name__)

    try:
        data = request.get_json()
        section_ids = data.get('section_ids', [])

        if not section_ids:
            return jsonify({'success': False, 'error': 'No section IDs provided'}), 400

        # Create batch runner
        runner = BatchQualityCheckRunner(
            batch_type='image_quality',
            checker_class=ImagenesChecker,
            checker_config={'check_format': True}
        )

        # Run batch in current thread (for simplicity)
        # TODO: In production, consider using Celery or background thread
        result = runner.run_batch(section_ids, created_by=current_user.full_name)

        logger.info(f"Batch {result['batch_id']} completed: {result['successful']}/{result['total']} successful")

        return jsonify({
            'success': True,
            'batch_id': result['batch_id'],
            'total': result['total'],
            'successful': result['successful'],
            'failed': result['failed']
        })

    except Exception as e:
        logger.error(f"Error running batch quality check: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@crawler_bp.route('/quality/batch/<int:batch_id>', methods=['GET'])
@login_required
def get_batch_quality_status(batch_id):
    """
    Get status of a batch quality check.
    """
    from calidad.batch import get_batch_status

    try:
        status = get_batch_status(batch_id)

        if not status:
            return jsonify({'success': False, 'error': 'Batch not found'}), 404

        return jsonify({
            'success': True,
            'batch': status
        })

    except Exception as e:
        logger = logging.getLogger(__name__)
        logger.error(f"Error getting batch status: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


# ============================================================
# QUALITY CHECK CONFIGURATION ROUTES
# ============================================================

@crawler_bp.route('/config/checks', methods=['GET'])
@login_required
def get_quality_check_config():
    """
    Get quality check configuration for current user.
    Returns list of available checks with their settings.
    """
    from calidad.post_crawl_runner import get_user_check_config
    import logging

    logger = logging.getLogger(__name__)

    try:
        config = get_user_check_config(current_user.id)

        return jsonify({
            'success': True,
            'checks': config
        })

    except Exception as e:
        logger.error(f"Error getting check config: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@crawler_bp.route('/config/checks', methods=['POST'])
@login_required
def update_quality_check_config():
    """
    Update quality check configuration for current user.

    Expects JSON: {
        "check_type": "image_quality",
        "enabled": true,
        "run_after_crawl": true,
        "scope": "priority"  # 'all' or 'priority'
    }
    """
    from calidad.post_crawl_runner import update_user_check_config
    import logging

    logger = logging.getLogger(__name__)

    try:
        data = request.get_json()
        check_type = data.get('check_type')
        enabled = data.get('enabled', False)
        run_after_crawl = data.get('run_after_crawl', False)
        scope = data.get('scope', 'priority')  # Default to 'priority' if not provided

        if not check_type:
            return jsonify({'success': False, 'error': 'check_type is required'}), 400

        success = update_user_check_config(
            user_id=current_user.id,
            check_type=check_type,
            enabled=enabled,
            run_after_crawl=run_after_crawl,
            scope=scope
        )

        if success:
            return jsonify({'success': True})
        else:
            return jsonify({'success': False, 'error': 'Failed to update config'}), 500

    except Exception as e:
        logger.error(f"Error updating check config: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@crawler_bp.route('/results/<int:crawl_run_id>/run-checks', methods=['POST'])
@login_required
def run_crawl_quality_checks(crawl_run_id):
    """
    Manually run quality checks on a completed crawl.

    Expects JSON: {
        "check_types": ["broken_links", "image_quality"]
    }
    """
    from calidad.post_crawl_runner import PostCrawlQualityRunner
    import logging

    logger = logging.getLogger(__name__)

    try:
        # Verify crawl run exists
        with db_cursor(commit=False) as cursor:
            cursor.execute("""
                SELECT id, status, root_url
                FROM crawl_runs
                WHERE id = %s
            """, (crawl_run_id,))
            crawl_run = cursor.fetchone()

        if not crawl_run:
            return jsonify({'success': False, 'error': 'Crawl run not found'}), 404

        # Get requested checks
        data = request.get_json()
        check_types = data.get('check_types', [])

        if not check_types:
            return jsonify({'success': False, 'error': 'check_types is required'}), 400

        # Run checks
        runner = PostCrawlQualityRunner(crawl_run_id)
        results = runner.run_selected_checks(check_types)

        return jsonify({
            'success': True,
            'results': results
        })

    except Exception as e:
        logger.error(f"Error running checks: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@crawler_bp.route('/quality/run', methods=['POST'])
@login_required
def run_quality_checks_manual():
    """
    Run quality checks manually on-demand (without crawl).

    Works on discovered_urls already in database.
    User can select which checks to run and scope (all/priority).

    Expects JSON: {
        "check_types": ["broken_links", "image_quality"],
        "scope": "priority"  # 'all' or 'priority'
    }
    """
    from calidad.post_crawl_runner import PostCrawlQualityRunner
    import logging

    logger = logging.getLogger(__name__)

    try:
        # Get request data
        data = request.get_json()
        check_types = data.get('check_types', [])
        scope = data.get('scope', 'priority')

        if not check_types:
            return jsonify({'success': False, 'error': 'check_types is required'}), 400

        if scope not in ['all', 'priority']:
            return jsonify({'success': False, 'error': 'scope must be "all" or "priority"'}), 400

        # Get latest completed crawl run to use as reference
        with db_cursor(commit=False) as cursor:
            latest_crawl = get_latest_crawl_run(cursor, status='completed')

        if not latest_crawl:
            return jsonify({
                'success': False,
                'error': 'No completed crawl found. Please run a crawl first.'
            }), 400

        crawl_run_id = latest_crawl['id']

        logger.info(f"Running manual quality checks on crawl {crawl_run_id}")
        logger.info(f"  - Check types: {check_types}")
        logger.info(f"  - Scope: {scope}")

        # Create check configs with scope
        check_configs = [{'check_type': ct, 'scope': scope} for ct in check_types]

        # Run checks
        runner = PostCrawlQualityRunner(crawl_run_id)
        results = runner.run_selected_checks_with_scope(check_configs)

        logger.info(f"Manual quality checks completed for crawl {crawl_run_id}")
        logger.info(f"  - Executed: {results.get('executed', False)}")
        logger.info(f"  - Checks run: {len(results.get('checks', []))}")

        return jsonify({
            'success': True,
            'crawl_run_id': crawl_run_id,
            'results': results
        })

    except Exception as e:
        logger.error(f"Error running manual quality checks: {e}", exc_info=True)
        return jsonify({'success': False, 'error': str(e)}), 500
