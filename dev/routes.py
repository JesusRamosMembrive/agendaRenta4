"""
Dev Blueprint - Development tools for database management
Provides safe cleanup operations for quality checks and crawl data
"""

import os
import subprocess
import tempfile
from flask import Blueprint, render_template, request, jsonify, send_file
from flask_login import login_required, current_user
from utils import db_cursor
from datetime import datetime, timedelta

dev_bp = Blueprint('dev', __name__, url_prefix='/dev')


@dev_bp.route('/cleanup')
@login_required
def cleanup_page():
    """Show cleanup operations dashboard with current database stats"""

    stats = {}

    with db_cursor() as cursor:
        # Quality checks stats by type
        cursor.execute("""
            SELECT
                check_type,
                COUNT(*) as total,
                SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) as errors,
                SUM(CASE WHEN status = 'warning' THEN 1 ELSE 0 END) as warnings,
                SUM(CASE WHEN status = 'ok' THEN 1 ELSE 0 END) as ok
            FROM quality_checks
            GROUP BY check_type
        """)
        stats['quality_checks'] = cursor.fetchall()

        # Total quality checks
        cursor.execute("SELECT COUNT(*) as total FROM quality_checks")
        stats['total_quality_checks'] = cursor.fetchone()['total']

        # Crawl runs stats
        cursor.execute("""
            SELECT
                COUNT(*) as total,
                SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
                SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
                SUM(CASE WHEN status = 'running' THEN 1 ELSE 0 END) as running
            FROM crawl_runs
        """)
        stats['crawl_runs'] = cursor.fetchone()

        # Quality check batches stats
        cursor.execute("""
            SELECT
                COUNT(*) as total,
                SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed
            FROM quality_check_batches
        """)
        stats['batches'] = cursor.fetchone()

        # Discovered URLs stats
        cursor.execute("""
            SELECT
                COUNT(*) as total,
                SUM(CASE WHEN is_broken THEN 1 ELSE 0 END) as broken
            FROM discovered_urls
        """)
        stats['urls'] = cursor.fetchone()

    return render_template('dev/cleanup.html', stats=stats)


@dev_bp.route('/cleanup/preview', methods=['POST'])
@login_required
def preview_cleanup():
    """Preview what will be deleted without actually deleting"""

    data = request.get_json()
    operation = data.get('operation')
    check_type = data.get('check_type')

    result = {'success': True, 'count': 0, 'details': {}}

    try:
        with db_cursor() as cursor:
            if operation == 'quality_checks_by_type':
                if check_type == 'all':
                    cursor.execute("SELECT COUNT(*) as count FROM quality_checks")
                else:
                    cursor.execute(
                        "SELECT COUNT(*) as count FROM quality_checks WHERE check_type = %s",
                        (check_type,)
                    )
                result['count'] = cursor.fetchone()['count']
                result['details']['message'] = f"Se borrarán {result['count']} registros de quality_checks"

            elif operation == 'crawl_runs':
                older_than_days = data.get('older_than_days', 30)
                status_filter = data.get('status')

                query = "SELECT COUNT(*) as count FROM crawl_runs WHERE finished_at < NOW() - INTERVAL '%s days'"
                params = [older_than_days]

                if status_filter:
                    query += " AND status = %s"
                    params.append(status_filter)

                cursor.execute(query, tuple(params))
                result['count'] = cursor.fetchone()['count']
                result['details']['message'] = f"Se borrarán {result['count']} crawl runs"

            elif operation == 'batches_failed':
                cursor.execute("SELECT COUNT(*) as count FROM quality_check_batches WHERE status = 'failed'")
                result['count'] = cursor.fetchone()['count']
                result['details']['message'] = f"Se borrarán {result['count']} batches fallidos"

    except Exception as e:
        result = {
            'success': False,
            'error': str(e)
        }

    return jsonify(result)


@dev_bp.route('/cleanup/quality-checks', methods=['POST'])
@login_required
def cleanup_quality_checks():
    """
    Delete quality checks by type or all.
    Expects JSON: {
        "check_type": "broken_links" | "image_quality" | "spell_check" | "all"
    }
    """

    data = request.get_json()
    check_type = data.get('check_type')

    if not check_type:
        return jsonify({
            'success': False,
            'error': 'El parámetro check_type es requerido'
        }), 400

    try:
        with db_cursor() as cursor:
            if check_type == 'all':
                cursor.execute("SELECT COUNT(*) as count FROM quality_checks")
                count_before = cursor.fetchone()['count']

                cursor.execute("DELETE FROM quality_checks")

                message = f"Se borraron {count_before} registros de quality_checks"
            else:
                # Validate check_type
                valid_types = ['broken_links', 'image_quality', 'spell_check']
                if check_type not in valid_types:
                    return jsonify({
                        'success': False,
                        'error': f'check_type inválido. Debe ser uno de: {", ".join(valid_types)}'
                    }), 400

                cursor.execute(
                    "SELECT COUNT(*) as count FROM quality_checks WHERE check_type = %s",
                    (check_type,)
                )
                count_before = cursor.fetchone()['count']

                cursor.execute(
                    "DELETE FROM quality_checks WHERE check_type = %s",
                    (check_type,)
                )

                check_names = {
                    'broken_links': 'Enlaces Rotos',
                    'image_quality': 'Calidad de Imágenes',
                    'spell_check': 'Corrección Ortográfica'
                }

                message = f"Se borraron {count_before} registros de {check_names.get(check_type, check_type)}"

        return jsonify({
            'success': True,
            'message': message,
            'deleted_count': count_before
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Error al borrar quality checks: {str(e)}'
        }), 500


@dev_bp.route('/cleanup/crawl-runs', methods=['POST'])
@login_required
def cleanup_crawl_runs():
    """
    Delete old or failed crawl runs.
    Expects JSON: {
        "older_than_days": 30 (optional, default 30),
        "status": "failed" | "completed" (optional)
    }

    WARNING: This will CASCADE delete associated discovered_urls and their quality_checks!
    """

    data = request.get_json()
    older_than_days = data.get('older_than_days', 30)
    status_filter = data.get('status')

    try:
        with db_cursor() as cursor:
            # Build query
            query = "SELECT COUNT(*) as count FROM crawl_runs WHERE finished_at < NOW() - INTERVAL '%s days'"
            params = [older_than_days]

            if status_filter:
                query += " AND status = %s"
                params.append(status_filter)

            cursor.execute(query, tuple(params))
            count_before = cursor.fetchone()['count']

            if count_before == 0:
                return jsonify({
                    'success': True,
                    'message': 'No hay crawl runs que borrar con los criterios especificados',
                    'deleted_count': 0
                })

            # Delete (will CASCADE to discovered_urls and quality_checks)
            delete_query = query.replace("SELECT COUNT(*) as count", "DELETE")
            cursor.execute(delete_query, tuple(params))

            status_text = f" ({status_filter})" if status_filter else ""
            message = f"Se borraron {count_before} crawl runs{status_text} y sus URLs asociadas"

        return jsonify({
            'success': True,
            'message': message,
            'deleted_count': count_before,
            'warning': 'Se borraron también las URLs descubiertas y quality checks asociados (CASCADE)'
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Error al borrar crawl runs: {str(e)}'
        }), 500


@dev_bp.route('/cleanup/batches', methods=['POST'])
@login_required
def cleanup_batches():
    """Delete failed quality check batches"""

    try:
        with db_cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as count FROM quality_check_batches WHERE status = 'failed'")
            count_before = cursor.fetchone()['count']

            if count_before == 0:
                return jsonify({
                    'success': True,
                    'message': 'No hay batches fallidos que borrar',
                    'deleted_count': 0
                })

            cursor.execute("DELETE FROM quality_check_batches WHERE status = 'failed'")

            message = f"Se borraron {count_before} batches fallidos"

        return jsonify({
            'success': True,
            'message': message,
            'deleted_count': count_before
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Error al borrar batches: {str(e)}'
        }), 500


@dev_bp.route('/stats')
@login_required
def database_stats():
    """Show detailed database statistics"""

    stats = {}

    with db_cursor() as cursor:
        # Quality checks detailed stats
        cursor.execute("""
            SELECT
                check_type,
                status,
                COUNT(*) as count,
                AVG(execution_time_ms) as avg_time_ms,
                MAX(checked_at) as last_check
            FROM quality_checks
            GROUP BY check_type, status
            ORDER BY check_type, status
        """)
        stats['quality_checks_detailed'] = cursor.fetchall()

        # Crawl runs detailed
        cursor.execute("""
            SELECT
                id,
                started_at,
                finished_at,
                status,
                urls_discovered,
                urls_broken,
                EXTRACT(EPOCH FROM (finished_at - started_at)) as duration_seconds
            FROM crawl_runs
            ORDER BY started_at DESC
            LIMIT 10
        """)
        stats['recent_crawls'] = cursor.fetchall()

        # URLs by depth
        cursor.execute("""
            SELECT
                depth,
                COUNT(*) as count,
                SUM(CASE WHEN is_broken THEN 1 ELSE 0 END) as broken
            FROM discovered_urls
            GROUP BY depth
            ORDER BY depth
        """)
        stats['urls_by_depth'] = cursor.fetchall()

        # Database size (PostgreSQL specific)
        cursor.execute("""
            SELECT
                pg_size_pretty(pg_database_size(current_database())) as db_size
        """)
        stats['database_size'] = cursor.fetchone()

        # Table sizes
        cursor.execute("""
            SELECT
                schemaname,
                tablename,
                pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
            FROM pg_tables
            WHERE schemaname = 'public'
            ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
            LIMIT 10
        """)
        stats['table_sizes'] = cursor.fetchall()

    return render_template('dev/stats.html', stats=stats)


@dev_bp.route('/backup/database', methods=['GET'])
@login_required
def backup_database():
    """
    Create a PostgreSQL backup using pg_dump and return it as a downloadable file.
    Uses DATABASE_URL environment variable or local connection settings.
    """

    try:
        # Get database connection details from environment
        database_url = os.getenv('DATABASE_URL')

        # Generate filename with timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'agendaRenta4_backup_{timestamp}.sql'

        # Create temporary file for backup
        temp_dir = tempfile.gettempdir()
        backup_path = os.path.join(temp_dir, filename)

        # Build pg_dump command
        if database_url:
            # Production: Use DATABASE_URL (Render, Heroku, etc.)
            # Parse DATABASE_URL if needed or use it directly
            cmd = [
                'pg_dump',
                '--no-owner',           # Don't include ownership commands
                '--no-acl',             # Don't include ACL commands
                '--clean',              # Include DROP commands
                '--if-exists',          # Add IF EXISTS to DROP commands
                '-f', backup_path,      # Output file
                database_url            # Connection string
            ]
        else:
            # Local development: Use individual connection parameters
            db_host = os.getenv('DB_HOST', 'localhost')
            db_port = os.getenv('DB_PORT', '5432')
            db_name = os.getenv('DB_NAME', 'agendaRenta4')
            db_user = os.getenv('DB_USER', 'jesusramos')
            db_password = os.getenv('DB_PASSWORD', 'dev-password')

            cmd = [
                'pg_dump',
                '--no-owner',
                '--no-acl',
                '--clean',
                '--if-exists',
                '-h', db_host,
                '-p', db_port,
                '-U', db_user,
                '-d', db_name,
                '-f', backup_path
            ]

            # Set password via environment variable (safer than command line)
            env = os.environ.copy()
            env['PGPASSWORD'] = db_password

        # Execute pg_dump
        result = subprocess.run(
            cmd,
            env=env if not database_url else None,
            capture_output=True,
            text=True,
            timeout=300  # 5 minutes timeout
        )

        if result.returncode != 0:
            error_msg = result.stderr or 'Unknown error during backup'
            return jsonify({
                'success': False,
                'error': f'pg_dump failed: {error_msg}'
            }), 500

        # Check if backup file was created
        if not os.path.exists(backup_path):
            return jsonify({
                'success': False,
                'error': 'Backup file was not created'
            }), 500

        # Get file size
        file_size = os.path.getsize(backup_path)

        # Send file to user
        return send_file(
            backup_path,
            as_attachment=True,
            download_name=filename,
            mimetype='application/sql'
        )

    except subprocess.TimeoutExpired:
        return jsonify({
            'success': False,
            'error': 'Backup timeout (>5 minutes). Database might be too large.'
        }), 500

    except FileNotFoundError:
        return jsonify({
            'success': False,
            'error': 'pg_dump command not found. Make sure PostgreSQL client tools are installed.'
        }), 500

    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Backup error: {str(e)}'
        }), 500


@dev_bp.route('/backup/local', methods=['GET'])
@login_required
def backup_local_database():
    """
    Create a backup of the local PostgreSQL database and save it to a local file.
    Saves the backup in a 'backups/' directory in the project root.
    """

    try:
        # Create backups directory if it doesn't exist
        project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        backups_dir = os.path.join(project_root, 'backups')
        os.makedirs(backups_dir, exist_ok=True)

        # Generate filename with timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'local_backup_{timestamp}.sql'
        backup_path = os.path.join(backups_dir, filename)

        # Get local database connection details
        db_host = os.getenv('DB_HOST', 'localhost')
        db_port = os.getenv('DB_PORT', '5432')
        db_name = os.getenv('DB_NAME', 'agendaRenta4')
        db_user = os.getenv('DB_USER', 'jesusramos')
        db_password = os.getenv('DB_PASSWORD', 'dev-password')

        # Build pg_dump command for local database
        cmd = [
            'pg_dump',
            '--no-owner',
            '--no-acl',
            '--clean',
            '--if-exists',
            '-h', db_host,
            '-p', db_port,
            '-U', db_user,
            '-d', db_name,
            '-f', backup_path
        ]

        # Set password via environment variable
        env = os.environ.copy()
        env['PGPASSWORD'] = db_password

        # Execute pg_dump
        result = subprocess.run(
            cmd,
            env=env,
            capture_output=True,
            text=True,
            timeout=300  # 5 minutes timeout
        )

        if result.returncode != 0:
            error_msg = result.stderr or 'Unknown error during backup'
            return jsonify({
                'success': False,
                'error': f'pg_dump failed: {error_msg}'
            }), 500

        # Check if backup file was created
        if not os.path.exists(backup_path):
            return jsonify({
                'success': False,
                'error': 'Backup file was not created'
            }), 500

        # Get file size in MB
        file_size_bytes = os.path.getsize(backup_path)
        file_size_mb = file_size_bytes / (1024 * 1024)

        return jsonify({
            'success': True,
            'message': f'Backup creado exitosamente',
            'filename': filename,
            'path': backup_path,
            'size_mb': round(file_size_mb, 2),
            'timestamp': timestamp
        })

    except subprocess.TimeoutExpired:
        return jsonify({
            'success': False,
            'error': 'Backup timeout (>5 minutes). Database might be too large.'
        }), 500

    except FileNotFoundError:
        return jsonify({
            'success': False,
            'error': 'pg_dump command not found. Make sure PostgreSQL client tools are installed.'
        }), 500

    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Backup error: {str(e)}'
        }), 500


@dev_bp.route('/backup/list', methods=['GET'])
@login_required
def list_local_backups():
    """
    List all local backup files in the backups/ directory.
    Returns file info including name, size, and creation date.
    """

    try:
        project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        backups_dir = os.path.join(project_root, 'backups')

        # Create directory if it doesn't exist
        os.makedirs(backups_dir, exist_ok=True)

        # Get all .sql files in backups directory
        backup_files = []
        for filename in os.listdir(backups_dir):
            if filename.endswith('.sql'):
                filepath = os.path.join(backups_dir, filename)
                file_stat = os.stat(filepath)

                backup_files.append({
                    'filename': filename,
                    'size_bytes': file_stat.st_size,
                    'size_mb': round(file_stat.st_size / (1024 * 1024), 2),
                    'created_at': datetime.fromtimestamp(file_stat.st_ctime).strftime('%Y-%m-%d %H:%M:%S'),
                    'modified_at': datetime.fromtimestamp(file_stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
                })

        # Sort by creation date (newest first)
        backup_files.sort(key=lambda x: x['created_at'], reverse=True)

        return jsonify({
            'success': True,
            'backups': backup_files,
            'total': len(backup_files),
            'backup_dir': backups_dir
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Error listing backups: {str(e)}'
        }), 500
