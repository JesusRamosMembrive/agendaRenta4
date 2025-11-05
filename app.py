#!/usr/bin/env python3
"""
Agenda Renta4 - Task Manager Manual
Flask application principal
"""

import calendar
import os
from datetime import date, datetime, timedelta

from dotenv import load_dotenv
from flask import (
    Flask,
    flash,
    jsonify,
    redirect,
    render_template,
    request,
    session,
    url_for,
)
from flask_login import (
    LoginManager,
    UserMixin,
    current_user,
    login_required,
    login_user,
    logout_user,
)
from flask_mail import Mail, Message
from werkzeug.security import check_password_hash

# Load environment variables
load_dotenv()

# Import shared utilities
# Import constants
from constants import (
    ANNUAL_MONTH,
    DEFAULT_EMAIL_SENDER,
    DEFAULT_PORT,
    DEFAULT_SMTP_PORT,
    LOGIN_SESSION_DAYS,
    PROBLEMS_RETENTION_DAYS,
    QUARTERLY_MONTHS,
    SEMIANNUAL_MONTHS,
    TASK_STATUS_OK,
    TASK_STATUS_PROBLEM,
    WEEKDAY_MAP,
)
from utils import db_cursor, format_date, format_period, generate_available_periods

# Initialize Flask app
app = Flask(__name__)

# SECRET_KEY validation (required in production)
secret_key = os.getenv("SECRET_KEY")
if not secret_key:
    raise ValueError(
        "❌ CRITICAL: SECRET_KEY environment variable is required. "
        "Set it in your .env file or environment."
    )
app.secret_key = secret_key

# Email Configuration
app.config["MAIL_SERVER"] = os.getenv("MAIL_SERVER", "smtp.gmail.com")
app.config["MAIL_PORT"] = int(os.getenv("MAIL_PORT", DEFAULT_SMTP_PORT))
app.config["MAIL_USE_TLS"] = os.getenv("MAIL_USE_TLS", "True") == "True"
app.config["MAIL_USE_SSL"] = os.getenv("MAIL_USE_SSL", "False") == "True"
app.config["MAIL_USERNAME"] = os.getenv("MAIL_USERNAME")
app.config["MAIL_PASSWORD"] = os.getenv("MAIL_PASSWORD")
app.config["MAIL_DEFAULT_SENDER"] = os.getenv(
    "MAIL_DEFAULT_SENDER", DEFAULT_EMAIL_SENDER
)
app.config["MAIL_DEBUG"] = os.getenv("MAIL_DEBUG", "True") == "True"

# Initialize Flask-Mail
mail = Mail(app)

# Initialize Flask-Login
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = "login"
login_manager.login_message = (
    None  # Disable automatic flash messages to prevent accumulation
)

# Register Blueprints
from config.routes import config_bp
from crawler.routes import crawler_bp
from dev.routes import dev_bp

app.register_blueprint(crawler_bp)
app.register_blueprint(config_bp)
app.register_blueprint(dev_bp)


# ==============================================================================
# USER AUTHENTICATION
# ==============================================================================


class User(UserMixin):
    """User class for Flask-Login"""

    def __init__(self, id, username, full_name):
        self.id = id
        self.username = username
        self.full_name = full_name


@login_manager.user_loader
def load_user(user_id):
    """Load user by ID for Flask-Login"""
    with db_cursor(commit=False) as cursor:
        cursor.execute(
            "SELECT id, username, full_name FROM users WHERE id = %s", (user_id,)
        )
        user_data = cursor.fetchone()

    if user_data:
        return User(
            id=user_data["id"],
            username=user_data["username"],
            full_name=user_data["full_name"],
        )
    return None


# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================


def get_task_counts() -> dict:
    """
    Get counts of pending, problem, completed tasks, and pending alerts.

    Returns:
        dict: Dictionary with keys 'pending', 'problems', 'completed', 'alerts'
    """
    with db_cursor(commit=False) as cursor:
        current_period = datetime.now().strftime("%Y-%m")

        # Count total possible tasks (active sections * task types) for current period
        cursor.execute("SELECT COUNT(*) as count FROM sections WHERE active = TRUE")
        total_sections = cursor.fetchone()["count"]

        cursor.execute("SELECT COUNT(*) as count FROM task_types")
        total_task_types = cursor.fetchone()["count"]

        total_possible_tasks = total_sections * total_task_types

        # Count completed tasks (status='ok') for current period
        cursor.execute(
            """
            SELECT COUNT(*) as count
            FROM tasks t
            INNER JOIN sections s ON t.section_id = s.id
            WHERE s.active = TRUE
              AND t.status = %s
              AND t.period = %s
        """,
            (TASK_STATUS_OK, current_period),
        )
        ok_count = cursor.fetchone()["count"]

        # Count problem tasks for current period
        cursor.execute(
            """
            SELECT COUNT(*) as count
            FROM tasks t
            INNER JOIN sections s ON t.section_id = s.id
            WHERE s.active = TRUE
              AND t.status = %s
              AND t.period = %s
        """,
            (TASK_STATUS_PROBLEM, current_period),
        )
        problems_count = cursor.fetchone()["count"]

        # Pending = Total possible - OK - Problems
        pending_count = total_possible_tasks - ok_count - problems_count

        # Count completed tasks (all history) for "Realizadas" page
        cursor.execute("""
            SELECT COUNT(*) as count
            FROM tasks t
            INNER JOIN sections s ON t.section_id = s.id
            WHERE s.active = TRUE
              AND t.status = 'ok'
        """)
        completed_count = cursor.fetchone()["count"]

        # Count pending alerts (not dismissed)
        cursor.execute("""
            SELECT COUNT(*) as count
            FROM pending_alerts
            WHERE dismissed = FALSE
        """)
        alerts_count = cursor.fetchone()["count"]

    return {
        "pending": pending_count,
        "problems": problems_count,
        "completed": completed_count,
        "alerts": alerts_count,
    }


def _should_create_alert(reference_date, frequency, alert_day):
    """
    Determine if an alert should be created for the given criteria.

    Args:
        reference_date: Date to check
        frequency: Alert frequency (weekly, monthly, etc.)
        alert_day: Configured day for alert

    Returns:
        bool: True if alert should be created
    """
    return check_alert_day(reference_date, frequency, alert_day)


def _create_alert_for_task_type(cursor, task_type_id, reference_date):
    """
    Create a pending alert for a specific task type.

    Args:
        cursor: Database cursor
        task_type_id: ID of the task type
        reference_date: Due date for the alert

    Returns:
        bool: True if alert was created (not skipped due to duplicate)
    """
    cursor.execute(
        """
        INSERT INTO pending_alerts
        (task_type_id, due_date)
        VALUES (%s, %s)
        ON CONFLICT (task_type_id, due_date) DO NOTHING
    """,
        (task_type_id, reference_date),
    )
    return cursor.rowcount > 0


def _fetch_alerts_for_notification(cursor, reference_date):
    """
    Fetch all non-dismissed alerts for a specific date (for email notification).

    Args:
        cursor: Database cursor
        reference_date: Date to fetch alerts for

    Returns:
        list: Alert dicts with keys: task_type_name, due_date, periodicity
    """
    cursor.execute(
        """
        SELECT
            tt.display_name as task_type_name,
            pa.due_date,
            tt.periodicity
        FROM pending_alerts pa
        INNER JOIN task_types tt ON pa.task_type_id = tt.id
        WHERE pa.due_date = %s AND pa.dismissed = FALSE
        ORDER BY tt.display_name ASC
    """,
        (reference_date,),
    )
    return cursor.fetchall()


def generate_alerts(reference_date: date = None) -> dict:
    """
    Generate pending alerts based on alert_settings configuration (orchestrator).

    Creates one alert per task_type (not per section).
    This function should be run periodically (daily) to create alerts.

    Args:
        reference_date: Date to use as reference (default: today)

    Returns:
        dict: Statistics with keys 'generated', 'skipped', 'errors', 'email_stats'
    """
    if reference_date is None:
        reference_date = date.today()

    stats = {"generated": 0, "skipped": 0, "errors": [], "email_stats": None}

    try:
        with db_cursor() as cursor:
            # Get all active alert settings
            cursor.execute("""
                SELECT task_type_id, alert_frequency, alert_day, enabled
                FROM alert_settings
                WHERE enabled = TRUE
            """)
            alert_settings = cursor.fetchall()

            # Process each alert setting
            for alert_setting in alert_settings:
                task_type_id = alert_setting["task_type_id"]
                frequency = alert_setting["alert_frequency"]
                alert_day = alert_setting["alert_day"]

                # Check if today matches the alert criteria
                if not _should_create_alert(reference_date, frequency, alert_day):
                    stats["skipped"] += 1
                    continue

                # Try to create the alert
                try:
                    if _create_alert_for_task_type(
                        cursor, task_type_id, reference_date
                    ):
                        stats["generated"] += 1
                    else:
                        stats["skipped"] += 1  # Duplicate
                except Exception as e:
                    stats["errors"].append(
                        f"Error creating alert for task_type={task_type_id}: {str(e)}"
                    )

            # Fetch all alerts for today to send email notifications
            alerts_for_email = _fetch_alerts_for_notification(cursor, reference_date)

        # Send email notifications if there are alerts
        if alerts_for_email:
            email_stats = send_email_notifications(alerts_for_email)
            stats["email_stats"] = email_stats

    except Exception as e:
        stats["errors"].append(f"Fatal error: {str(e)}")

    return stats


# ==============================================================================
# ALERT DAY CHECKERS (Strategy Pattern)
# ==============================================================================


def _check_daily_alert(reference_date, alert_day):
    """Daily alerts always trigger."""
    return True


def _check_weekly_alert(reference_date, alert_day):
    """Check if today is the configured weekday."""
    target_weekday = WEEKDAY_MAP.get(alert_day)
    if target_weekday is None:
        return False
    return reference_date.weekday() == target_weekday


def _check_biweekly_alert(reference_date, alert_day):
    """
    Check if today is the configured weekday in an even week.

    Biweekly alerts trigger every two weeks on the specified weekday.
    Week numbers are ISO 8601 compliant (week 1 = first week with Thursday).

    Example:
        If alert_day='monday' and reference_date is Monday of week 4,
        this returns True (week 4 is even). If reference_date is Monday
        of week 5, returns False (week 5 is odd).

    Args:
        reference_date: Date to check
        alert_day: Day of week (e.g., 'monday', 'tuesday')

    Returns:
        bool: True if it's the correct weekday in an even-numbered week
    """
    target_weekday = WEEKDAY_MAP.get(alert_day)
    if target_weekday is None:
        return False

    # Check if today is the correct weekday
    if reference_date.weekday() != target_weekday:
        return False

    # Check if it's an even week number (ISO 8601)
    week_number = reference_date.isocalendar()[1]
    return week_number % 2 == 0


def _check_monthly_alert(reference_date, alert_day):
    """
    Check if today is the configured day of the month.

    Handles months with varying lengths gracefully. If the target day exceeds
    the month's length (e.g., day 31 in February), it adjusts to the last day.

    Example:
        If alert_day='31':
        - January 31 → True (month has 31 days)
        - February 31 → True on Feb 28/29 (month doesn't have 31 days)
        - April 31 → True on April 30 (month has only 30 days)

    Args:
        reference_date: Date to check
        alert_day: Day of month as string (e.g., '1', '15', '31')

    Returns:
        bool: True if today is the configured day (or last day if month is shorter)
    """
    try:
        target_day = int(alert_day)
    except (ValueError, TypeError):
        return False

    # Get last day of current month
    last_day = calendar.monthrange(reference_date.year, reference_date.month)[1]

    # Adjust target day if month doesn't have enough days (e.g., Feb 30 -> Feb 28)
    effective_day = min(target_day, last_day)

    return reference_date.day == effective_day


def _check_quarterly_alert(reference_date, alert_day):
    """Check if today is the configured day in a quarterly month (Jan/Apr/Jul/Oct)."""
    # First check if we're in a quarterly month
    if reference_date.month not in QUARTERLY_MONTHS:
        return False

    # Then check if it's the configured day
    return _check_monthly_alert(reference_date, alert_day)


def _check_semiannual_alert(reference_date, alert_day):
    """Check if today is the configured day in a semiannual month (Jan/Jul)."""
    # First check if we're in a semiannual month
    if reference_date.month not in SEMIANNUAL_MONTHS:
        return False

    # Then check if it's the configured day
    return _check_monthly_alert(reference_date, alert_day)


def _check_annual_alert(reference_date, alert_day):
    """Check if today is the configured day in January."""
    # First check if we're in January
    if reference_date.month != ANNUAL_MONTH:
        return False

    # Then check if it's the configured day
    return _check_monthly_alert(reference_date, alert_day)


# Strategy mapping: frequency -> checker function
ALERT_CHECKERS = {
    "daily": _check_daily_alert,
    "weekly": _check_weekly_alert,
    "biweekly": _check_biweekly_alert,
    "monthly": _check_monthly_alert,
    "quarterly": _check_quarterly_alert,
    "semiannual": _check_semiannual_alert,
    "annual": _check_annual_alert,
}


def check_alert_day(reference_date: date, frequency: str, alert_day: str) -> bool:
    """
    Check if the reference_date matches the alert configuration (Strategy Pattern).

    Uses a strategy pattern to delegate to specific checker functions based on frequency.

    Args:
        reference_date: Date object to check
        frequency: Alert frequency (daily, weekly, biweekly, monthly, quarterly, semiannual, annual)
        alert_day: Specific day configuration (day of week or day of month)

    Returns:
        bool: True if alert should be generated for this date
    """
    checker = ALERT_CHECKERS.get(frequency)

    if not checker:
        # Unknown frequency - log warning and return False
        import logging

        logging.getLogger(__name__).warning(f"Unknown alert frequency: {frequency}")
        return False

    return checker(reference_date, alert_day)


def _get_email_recipients(user_name):
    """
    Get list of active email recipients and check if email notifications are enabled.

    Args:
        user_name: User name to check preferences for

    Returns:
        tuple: (email_recipients_list, error_message) - error_message is None if successful
    """
    with db_cursor(commit=False) as cursor:
        # Check if email notifications are enabled
        cursor.execute(
            """
            SELECT enable_email FROM notification_preferences
            WHERE user_name = %s AND enable_email = 1
            LIMIT 1
        """,
            (user_name,),
        )

        email_prefs_row = cursor.fetchone()
        if not email_prefs_row:
            return None, "Email notifications not enabled"

        # Get active email addresses
        cursor.execute("""
            SELECT email, name FROM notification_emails
            WHERE active = TRUE
            ORDER BY id ASC
        """)

        email_recipients = cursor.fetchall()

    if not email_recipients:
        return None, "No active email recipients configured"

    return email_recipients, None


def _build_email_body(alert_list):
    """
    Build HTML email body with alert details.

    Args:
        alert_list: List of alert dicts with keys: task_type_name, due_date, etc.

    Returns:
        str: HTML email body
    """
    alertas_url = url_for("alertas", _external=True)

    # Build alert items HTML
    alert_items_html = ""
    for alert in alert_list:
        alert_items_html += f"""
                    <div class="alert-item">
                        <div class="alert-title">{alert["task_type_name"]}</div>
                        <div class="alert-date">Fecha de aviso: {alert["due_date"]}</div>
                        <p style="margin: 8px 0 0 0; color: #6b7280; font-size: 0.9em;">
                            Revisar todas las URLs para esta tarea
                        </p>
                    </div>
        """

    # Complete HTML template
    html_body = f"""
    <html>
    <head>
        <style>
            body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
            .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
            .header {{ background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
                      color: white; padding: 20px; border-radius: 8px 8px 0 0; }}
            .content {{ background: #f9fafb; padding: 20px; }}
            .alert-item {{ background: white; padding: 15px; margin: 10px 0;
                           border-left: 4px solid #f59e0b; border-radius: 4px; }}
            .alert-title {{ font-weight: bold; color: #f59e0b; font-size: 1.1em; }}
            .alert-date {{ color: #6b7280; font-size: 0.9em; }}
            .footer {{ background: #1f2937; color: #9ca3af; padding: 15px;
                      border-radius: 0 0 8px 8px; text-align: center; font-size: 0.85em; }}
            .btn {{ background: #5b8cff; color: white; padding: 10px 20px;
                   text-decoration: none; border-radius: 6px; display: inline-block;
                   margin-top: 10px; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h2 style="margin: 0;">⚠️ Nuevas Alertas - Agenda Renta4</h2>
                <p style="margin: 5px 0 0 0; opacity: 0.9;">
                    Se han generado {len(alert_list)} nueva(s) alerta(s) pendiente(s)
                </p>
            </div>

            <div class="content">
                <p><strong>Hola,</strong></p>
                <p>Se han generado las siguientes alertas que requieren tu atención:</p>
                {alert_items_html}
                <p style="margin-top: 20px;">
                    <a href="{alertas_url}" class="btn">Ver Alertas Pendientes</a>
                </p>
            </div>

            <div class="footer">
                <p style="margin: 0;">
                    Este es un mensaje automático de Agenda Renta4. Por favor, no respondas a este email.
                </p>
            </div>
        </div>
    </body>
    </html>
    """

    return html_body


def _send_email_to_recipient(recipient, html_body, alert_count):
    """
    Send email to a single recipient.

    Args:
        recipient: Dict with keys: email, name
        html_body: HTML content of the email
        alert_count: Number of alerts (for subject line)

    Returns:
        tuple: (success: bool, error_message: str or None)
    """
    try:
        msg = Message(
            subject=f"🔔 {alert_count} Nueva(s) Alerta(s) - Agenda Renta4",
            recipients=[recipient["email"]],
            html=html_body,
        )
        mail.send(msg)
        return True, None
    except Exception as e:
        return False, f"Failed to send to {recipient['email']}: {str(e)}"


def send_email_notifications(alert_list: list, user_name: str = None) -> dict:
    """
    Send email notifications for newly generated alerts (orchestrator function).

    Args:
        alert_list: List of dicts with keys: task_type_name, due_date, etc.
        user_name: User name to check preferences for. If None, uses current_user.

    Returns:
        dict: Statistics with keys 'sent', 'failed', 'errors'
    """
    stats = {"sent": 0, "failed": 0, "errors": []}

    # Determine user name
    if user_name is None:
        try:
            user_name = current_user.full_name
        except (AttributeError, RuntimeError):
            stats["errors"].append(
                "No user context available and user_name not provided"
            )
            return stats

    # Validate inputs
    if not alert_list:
        return stats

    # Check SMTP configuration
    if not app.config["MAIL_USERNAME"] or not app.config["MAIL_PASSWORD"]:
        stats["errors"].append(
            "SMTP not configured. Set MAIL_USERNAME and MAIL_PASSWORD in .env"
        )
        return stats

    # Get email recipients
    email_recipients, error = _get_email_recipients(user_name)
    if error:
        stats["errors"].append(error)
        return stats

    # Build email body
    try:
        html_body = _build_email_body(alert_list)
    except Exception as e:
        stats["errors"].append(f"Error building email: {str(e)}")
        return stats

    # Send to all recipients
    for recipient in email_recipients:
        success, error = _send_email_to_recipient(recipient, html_body, len(alert_list))
        if success:
            stats["sent"] += 1
        else:
            stats["failed"] += 1
            stats["errors"].append(error)

    return stats


# ==============================================================================
# CONTEXT PROCESSORS
# ==============================================================================


@app.context_processor
def inject_task_counts():
    """
    Make task counts and crawler stats available to all templates
    """
    # Get broken links count for crawler
    broken_count = 0
    image_issues_count = 0
    spell_issues_count = 0

    try:
        with db_cursor(commit=False) as cursor:
            # Get latest crawl run
            cursor.execute("""
                SELECT id FROM crawl_runs
                ORDER BY id DESC
                LIMIT 1
            """)
            crawl_run = cursor.fetchone()

            if crawl_run:
                # Count broken URLs
                cursor.execute(
                    """
                    SELECT COUNT(*) as count
                    FROM discovered_urls
                    WHERE crawl_run_id = %s AND is_broken = TRUE
                """,
                    (crawl_run["id"],),
                )
                result = cursor.fetchone()
                broken_count = result["count"] if result else 0

                # Count image quality issues (status = 'error')
                cursor.execute(
                    """
                    SELECT COUNT(*) as count
                    FROM quality_checks qc
                    JOIN discovered_urls du ON qc.discovered_url_id = du.id
                    WHERE du.crawl_run_id = %s
                      AND qc.check_type = 'image_quality'
                      AND qc.status = 'error'
                """,
                    (crawl_run["id"],),
                )
                result = cursor.fetchone()
                image_issues_count = result["count"] if result else 0

                # Count spelling issues (status = 'warning')
                cursor.execute(
                    """
                    SELECT COUNT(*) as count
                    FROM quality_checks qc
                    JOIN discovered_urls du ON qc.discovered_url_id = du.id
                    WHERE du.crawl_run_id = %s
                      AND qc.check_type = 'spell_check'
                      AND qc.status = 'warning'
                """,
                    (crawl_run["id"],),
                )
                result = cursor.fetchone()
                spell_issues_count = result["count"] if result else 0
    except Exception:
        # If crawler tables don't exist yet, just return 0
        broken_count = 0
        image_issues_count = 0
        spell_issues_count = 0

    return {
        "task_counts": get_task_counts(),
        "broken_count": broken_count,
        "image_issues_count": image_issues_count,
        "spell_issues_count": spell_issues_count,
    }


# ==============================================================================
# TEMPLATE FILTERS
# ==============================================================================

# Register utility functions as template filters
app.template_filter("format_date")(format_date)
app.template_filter("format_period")(format_period)


# ==============================================================================
# AUTHENTICATION ROUTES
# ==============================================================================


@app.route("/login", methods=["GET", "POST"])
def login():
    """Login page and authentication"""
    # If user is already logged in, redirect to inicio
    if current_user.is_authenticated:
        return redirect(url_for("inicio"))

    if request.method == "POST":
        username = request.form.get("username")
        password = request.form.get("password")

        with db_cursor(commit=False) as cursor:
            cursor.execute(
                "SELECT id, username, password_hash, full_name FROM users WHERE username = %s",
                (username,),
            )
            user_data = cursor.fetchone()

        if user_data and check_password_hash(user_data["password_hash"], password):
            # Create user object and log in
            user = User(
                id=user_data["id"],
                username=user_data["username"],
                full_name=user_data["full_name"],
            )
            login_user(user, remember=True, duration=timedelta(days=LOGIN_SESSION_DAYS))
            flash(f"¡Bienvenido/a, {user_data['full_name']}!", "success")

            # Redirect to next page or inicio
            next_page = request.args.get("next")
            return redirect(next_page) if next_page else redirect(url_for("inicio"))
        else:
            flash("Usuario o contraseña incorrectos", "error")
    else:
        # GET request: show message only if redirected from protected page
        if request.args.get("next"):
            flash("Por favor inicia sesión para acceder a esta página.", "info")

    return render_template("login.html")


@app.route("/logout")
@login_required
def logout():
    """Logout current user"""
    logout_user()
    flash("Has cerrado sesión correctamente", "success")
    return redirect(url_for("login"))


# ==============================================================================
# APPLICATION ROUTES
# ==============================================================================


@app.route("/")
@login_required
def index():
    """
    Redirect to inicio page (main dashboard)
    """
    return redirect(url_for("inicio"))


@app.route("/inicio")
@login_required
def inicio():
    """
    Main dashboard - Table with all URLs and their 8 task types
    """
    # Get selected period from query params or session (default: current month)
    period = request.args.get("period")
    if not period:
        period = session.get("current_period", datetime.now().strftime("%Y-%m"))
    else:
        session["current_period"] = period

    # Get database connection
    with db_cursor(commit=False) as cursor:
        # Get all active sections (URLs)
        cursor.execute("""
            SELECT id, name, url
            FROM sections
            WHERE active = TRUE
            ORDER BY name ASC
        """)
        sections_raw = cursor.fetchall()

        # Get all task types (8 types)
        cursor.execute("""
            SELECT id, name, display_name, periodicity, display_order
            FROM task_types
            ORDER BY display_order ASC
        """)
        task_types = cursor.fetchall()

        # For each section, get tasks of the current period
        sections = []
        for section_row in sections_raw:
            section = dict(section_row)

            # Get tasks for this section in this period
            cursor.execute(
                """
                SELECT id, task_type_id, status, observations, completed_date, completed_by
                FROM tasks
                WHERE section_id = %s AND period = %s
            """,
                (section["id"], period),
            )

            tasks = cursor.fetchall()

            # Create a dict indexed by task_type_id for easy lookup
            tasks_by_type = {}
            section_observations = None

            for task in tasks:
                tasks_by_type[task["task_type_id"]] = dict(task)
                # Usar las observaciones de la primera tarea con observaciones
                if task["observations"] and not section_observations:
                    section_observations = task["observations"]

            section["tasks_by_type"] = tasks_by_type
            section["observations"] = section_observations
            sections.append(section)

    # Generate available periods (last 6 months + next 6 months)
    available_periods = generate_available_periods()

    return render_template(
        "inicio.html",
        period=period,
        sections=sections,
        task_types=task_types,
        available_periods=available_periods,
        current_user=current_user,
    )


@app.route("/pendientes")
@login_required
def pendientes():
    """
    List of ALL pending tasks (not marked as OK or Problem)
    Generates all possible combinations and excludes completed/problem tasks
    """
    period = session.get("current_period", datetime.now().strftime("%Y-%m"))
    current_period = datetime.now().strftime("%Y-%m")

    with db_cursor(commit=False) as cursor:
        # Get all active sections
        cursor.execute(
            "SELECT id, name, url FROM sections WHERE active = TRUE ORDER BY name ASC"
        )
        sections = cursor.fetchall()

        # Get all task types
        cursor.execute(
            "SELECT id, display_name, periodicity, display_order FROM task_types ORDER BY display_order ASC"
        )
        task_types = cursor.fetchall()

        # Get all tasks that are OK or Problem for current period
        cursor.execute(
            """
            SELECT section_id, task_type_id, status
            FROM tasks
            WHERE period = %s AND status IN ('ok', 'problem')
        """,
            (current_period,),
        )
        completed_tasks = cursor.fetchall()

        # Create a set of (section_id, task_type_id) tuples that are already done
        completed_task_keys = {
            (task["section_id"], task["task_type_id"]) for task in completed_tasks
        }

        # Generate all pending tasks (combinations not in completed_task_keys)
        pending_tasks = []
        for section in sections:
            for task_type in task_types:
                task_key = (section["id"], task_type["id"])
                if task_key not in completed_task_keys:
                    pending_tasks.append(
                        {
                            "id": None,
                            "period": current_period,
                            "status": "pending",
                            "section_name": section["name"],
                            "section_url": section["url"],
                            "task_type_name": task_type["display_name"],
                            "periodicity": task_type["periodicity"],
                            "observations": None,
                            "completed_date": None,
                            "completed_by": None,
                        }
                    )

    # Generate available periods
    available_periods = generate_available_periods()

    return render_template(
        "pendientes.html",
        period=period,
        pending_tasks=pending_tasks,
        available_periods=available_periods,
        current_user=current_user,
    )


@app.route("/problemas")
@login_required
def problemas():
    """
    List of tasks with problems (status='problem')
    Shows tasks from last 90 days (3 months) that have issues
    """
    period = session.get("current_period", datetime.now().strftime("%Y-%m"))
    current_period = datetime.now().strftime("%Y-%m")

    # Calculate cutoff date (problems retention period)
    cutoff_date = (datetime.now() - timedelta(days=PROBLEMS_RETENTION_DAYS)).strftime(
        "%Y-%m"
    )

    with db_cursor(commit=False) as cursor:
        # Query problem tasks from last 3 months to current month
        cursor.execute(
            """
            SELECT
                t.id,
                t.period,
                t.status,
                t.observations,
                t.completed_date,
                t.completed_by,
                s.name as section_name,
                s.url as section_url,
                tt.display_name as task_type_name,
                tt.periodicity
            FROM tasks t
            INNER JOIN sections s ON t.section_id = s.id
            INNER JOIN task_types tt ON t.task_type_id = tt.id
            WHERE
                s.active = TRUE
                AND t.status = 'problem'
                AND t.period >= %s
                AND t.period <= %s
            ORDER BY t.period DESC, s.name ASC, tt.display_order ASC
        """,
            (cutoff_date, current_period),
        )

        tasks_raw = cursor.fetchall()
        problem_tasks = [dict(row) for row in tasks_raw]

    # Generate available periods
    available_periods = generate_available_periods()

    return render_template(
        "problemas.html",
        period=period,
        problem_tasks=problem_tasks,
        available_periods=available_periods,
        current_user=current_user,
    )


@app.route("/realizadas")
@login_required
def realizadas():
    """
    List of completed tasks (status='ok')
    Shows complete history of all tasks marked as OK
    """
    period = session.get("current_period", datetime.now().strftime("%Y-%m"))

    with db_cursor(commit=False) as cursor:
        # Query all completed tasks (status='ok') from complete history
        cursor.execute("""
            SELECT
                t.id,
                t.period,
                t.completed_date,
                t.completed_by,
                s.name as section_name,
                s.url as section_url,
                tt.display_name as task_type_name,
                tt.periodicity
            FROM tasks t
            INNER JOIN sections s ON t.section_id = s.id
            INNER JOIN task_types tt ON t.task_type_id = tt.id
            WHERE
                s.active = TRUE
                AND t.status = 'ok'
            ORDER BY t.completed_date DESC, t.period DESC, s.name ASC
        """)

        tasks_raw = cursor.fetchall()
        completed_tasks = [dict(row) for row in tasks_raw]

    # Generate available periods
    available_periods = generate_available_periods()

    return render_template(
        "realizadas.html",
        period=period,
        completed_tasks=completed_tasks,
        available_periods=available_periods,
        current_user=current_user,
    )


@app.route("/tasks/update", methods=["POST"])
@login_required
def update_task():
    """
    Update task status (ok/problem) via AJAX
    Returns JSON response
    """
    try:
        task_id = request.form.get("task_id")
        status = request.form.get("status")  # 'ok' or 'problem'
        section_id = request.form.get("section_id")
        task_type_id = request.form.get("task_type_id")
        period = request.form.get("period")

        # Determine completed_date and completed_by based on status
        if status in ("ok", "problem"):
            completed_date = datetime.now().strftime("%Y-%m-%d")
            completed_by = current_user.full_name
        else:
            # status='pending' means not completed yet
            completed_date = None
            completed_by = None

        with db_cursor() as cursor:
            # If task_id exists, update existing task
            if task_id:
                cursor.execute(
                    """
                    UPDATE tasks
                    SET status = %s,
                        completed_date = %s,
                        completed_by = %s
                    WHERE id = %s
                """,
                    (status, completed_date, completed_by, task_id),
                )
                new_task_id = task_id
            else:
                # Create new task if it doesn't exist yet
                cursor.execute(
                    """
                    INSERT INTO tasks (section_id, task_type_id, period, status, completed_date, completed_by)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """,
                    (
                        section_id,
                        task_type_id,
                        period,
                        status,
                        completed_date,
                        completed_by,
                    ),
                )
                new_task_id = cursor.lastrowid

        return jsonify({"success": True, "task_id": new_task_id})

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/save_observations", methods=["POST"])
@login_required
def save_observations():
    """
    Save observations for all tasks of a section (when there are problems)
    Returns JSON response
    """
    try:
        section_id = request.form.get("section_id")
        period = request.form.get("period")
        observations = request.form.get("observations", "")

        with db_cursor() as cursor:
            # Update observations for all tasks of this section in this period
            cursor.execute(
                """
                UPDATE tasks
                SET observations = %s
                WHERE section_id = %s AND period = %s
            """,
                (observations, section_id, period),
            )

        return jsonify({"success": True})

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ==============================================================================
# ALERTS ROUTES
# ==============================================================================


@app.route("/admin/generate-alerts", methods=["POST"])
@login_required
def trigger_generate_alerts():
    """
    Manually trigger alert generation for testing.
    Can accept optional date parameter (YYYY-MM-DD format).
    """
    try:
        # Get optional date from request
        date_str = request.form.get("date") or request.args.get("date")

        if date_str:
            try:
                reference_date = datetime.strptime(date_str, "%Y-%m-%d").date()
            except ValueError:
                return jsonify(
                    {"success": False, "error": "Invalid date format. Use YYYY-MM-DD"}
                ), 400
        else:
            reference_date = None  # Will use today by default

        # Generate alerts
        stats = generate_alerts(reference_date)

        return jsonify(
            {
                "success": True,
                "message": "Alertas generadas correctamente",
                "stats": stats,
            }
        )

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/alertas")
@login_required
def alertas():
    """
    Display ALL alerts (both active and dismissed)
    One alert per task_type, not per section
    """
    period = session.get("current_period", datetime.now().strftime("%Y-%m"))

    with db_cursor(commit=False) as cursor:
        # Get ALL alerts with task type info (both active and dismissed)
        cursor.execute("""
            SELECT
                pa.id,
                pa.due_date,
                pa.generated_at,
                pa.dismissed,
                pa.dismissed_at,
                tt.display_name as task_type_name,
                tt.periodicity
            FROM pending_alerts pa
            INNER JOIN task_types tt ON pa.task_type_id = tt.id
            ORDER BY pa.dismissed ASC, pa.due_date ASC, tt.display_order ASC
        """)

        alerts_raw = cursor.fetchall()
        all_alerts = [dict(row) for row in alerts_raw]

    # Generate available periods
    available_periods = generate_available_periods()

    return render_template(
        "alertas.html",
        period=period,
        pending_alerts=all_alerts,
        available_periods=available_periods,
        current_user=current_user,
    )


@app.route("/alertas/dismiss/<int:alert_id>", methods=["POST"])
@login_required
def dismiss_alert(alert_id):
    """
    Toggle alert status (active ↔ dismissed)
    """
    try:
        with db_cursor() as cursor:
            # Get current status
            cursor.execute(
                "SELECT dismissed FROM pending_alerts WHERE id = %s", (alert_id,)
            )
            row = cursor.fetchone()

            if not row:
                return jsonify({"success": False, "error": "Alerta no encontrada"}), 404

            current_dismissed = row["dismissed"]
            new_dismissed = False if current_dismissed else True

            # Toggle dismissed status
            if new_dismissed:
                # Mark as dismissed
                cursor.execute(
                    """
                    UPDATE pending_alerts
                    SET dismissed = TRUE, dismissed_at = CURRENT_TIMESTAMP
                    WHERE id = %s
                """,
                    (alert_id,),
                )
                message = "Alerta marcada como resuelta"
            else:
                # Mark as active again
                cursor.execute(
                    """
                    UPDATE pending_alerts
                    SET dismissed = FALSE, dismissed_at = NULL
                    WHERE id = %s
                """,
                    (alert_id,),
                )
                message = "Alerta reactivada"

        return jsonify(
            {"success": True, "message": message, "dismissed": new_dismissed}
        )

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ==============================================================================
# CUSTOM DICTIONARY ROUTES
# ==============================================================================


@app.route("/diccionario-personalizado")
@login_required
def custom_dictionary():
    """
    Custom dictionary management page
    Shows:
    - Candidate words (errors from quality_checks that could be added)
    - Current custom dictionary words
    - Manual word addition form
    """
    from calidad.dictionary_manager import (
        get_dictionary_stats,
        get_dictionary_words,
    )

    try:
        # Get current dictionary words
        dictionary_words = get_dictionary_words()

        # Get dictionary stats
        stats = get_dictionary_stats()

        # Get candidate words from quality_checks
        # Extract spelling errors from quality checks, group by word, count frequency
        with db_cursor(commit=False) as cursor:
            cursor.execute(
                """
                SELECT
                    jsonb_array_elements(details->'spelling_errors')->>'word' as word,
                    COUNT(*) as frequency,
                    STRING_AGG(DISTINCT du.url, ', ') as example_urls
                FROM quality_checks qc
                LEFT JOIN discovered_urls du ON qc.discovered_url_id = du.id
                WHERE qc.check_type = 'spell_check'
                    AND qc.status IN ('warning', 'error')
                    AND details->'spelling_errors' IS NOT NULL
                    AND jsonb_array_length(details->'spelling_errors') > 0
                GROUP BY word
                HAVING COUNT(*) >= 2  -- Only show words that appear at least twice
                ORDER BY COUNT(*) DESC, word
                LIMIT 100
            """
            )
            candidate_words = cursor.fetchall()

        # Filter out words already in dictionary
        existing_words_lower = {w["word_lower"] for w in dictionary_words}
        candidates = [
            c for c in candidate_words if c["word"].lower() not in existing_words_lower
        ]

        return render_template(
            "diccionario_personalizado.html",
            dictionary_words=dictionary_words,
            candidates=candidates,
            stats=stats,
            current_user=current_user,
        )

    except Exception as e:
        flash(f"Error cargando diccionario: {str(e)}", "error")
        return redirect(url_for("inicio"))


@app.route("/diccionario-personalizado/add", methods=["POST"])
@login_required
def add_custom_word():
    """
    Add a word to the custom dictionary
    """
    from calidad.dictionary_manager import add_word_to_dictionary

    try:
        word = request.form.get("word", "").strip()
        category = request.form.get("category", "other")
        frequency = int(request.form.get("frequency", 0))
        notes = request.form.get("notes", "").strip()

        if not word:
            return jsonify({"success": False, "error": "Palabra requerida"}), 400

        result = add_word_to_dictionary(
            word=word,
            category=category,
            frequency=frequency,
            approved_by=current_user.id,
            notes=notes,
        )

        if result["success"]:
            return jsonify(
                {
                    "success": True,
                    "message": f"Palabra '{word}' añadida al diccionario",
                    "word_id": result["word_id"],
                }
            )
        else:
            return jsonify({"success": False, "error": result["message"]}), 400

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route("/diccionario-personalizado/remove/<int:word_id>", methods=["POST"])
@login_required
def remove_custom_word(word_id):
    """
    Remove a word from the custom dictionary
    """
    from calidad.dictionary_manager import get_dictionary_words

    try:
        # Get word first
        words = get_dictionary_words()
        word_obj = next((w for w in words if w["id"] == word_id), None)

        if not word_obj:
            return jsonify({"success": False, "error": "Palabra no encontrada"}), 404

        from calidad.dictionary_manager import remove_word_from_dictionary

        result = remove_word_from_dictionary(word_obj["word"])

        if result["success"]:
            return jsonify(
                {
                    "success": True,
                    "message": f"Palabra '{word_obj['word']}' eliminada del diccionario",
                }
            )
        else:
            return jsonify({"success": False, "error": result["message"]}), 400

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


# ==============================================================================
# ERROR HANDLERS
# ==============================================================================


@app.errorhandler(404)
def not_found(error):
    """
    Handle 404 errors
    """
    # Provide minimal context for base template
    # current_user is available from Flask-Login (AnonymousUserMixin if not logged in)
    return render_template(
        "errors/404.html", period=None, available_periods=[], current_user=current_user
    ), 404


@app.errorhandler(500)
def internal_error(error):
    """
    Handle 500 errors
    """
    # Provide minimal context for base template
    # current_user is available from Flask-Login (AnonymousUserMixin if not logged in)
    return render_template(
        "errors/500.html", period=None, available_periods=[], current_user=current_user
    ), 500


# ==============================================================================
# MAIN
# ==============================================================================

if __name__ == "__main__":
    # Initialize scheduler on startup (optional)
    # Uncomment to auto-start scheduler when app starts
    # from crawler.scheduler import start_scheduler
    # start_scheduler(frequency='daily', hour=3, minute=0)

    # Run Flask development server
    port = int(os.getenv("PORT", DEFAULT_PORT))
    app.run(debug=True, host="0.0.0.0", port=port)
