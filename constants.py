#!/usr/bin/env python3
"""
Agenda Renta4 - Constants
Application-wide constants and configuration values
"""

# ==============================================================================
# TASK STATUS
# ==============================================================================

# Task status constants
TASK_STATUS_PENDING = 'pending'
TASK_STATUS_OK = 'ok'
TASK_STATUS_PROBLEM = 'problem'
TASK_STATUS_NOT_APPLY = 'not_apply'

# All valid task statuses
TASK_STATUSES = (
    TASK_STATUS_PENDING,
    TASK_STATUS_OK,
    TASK_STATUS_PROBLEM,
    TASK_STATUS_NOT_APPLY,
)


# ==============================================================================
# TASK PERIODICITY
# ==============================================================================

# Periodicity constants
PERIODICITY_WEEKLY = 'weekly'
PERIODICITY_MONTHLY = 'monthly'
PERIODICITY_QUARTERLY = 'quarterly'
PERIODICITY_BIANNUAL = 'biannual'
PERIODICITY_YEARLY = 'yearly'

# All valid periodicities
PERIODICITIES = (
    PERIODICITY_WEEKLY,
    PERIODICITY_MONTHLY,
    PERIODICITY_QUARTERLY,
    PERIODICITY_BIANNUAL,
    PERIODICITY_YEARLY,
)


# ==============================================================================
# FLASH MESSAGE CATEGORIES
# ==============================================================================

# Flash message categories
FLASH_SUCCESS = 'success'
FLASH_ERROR = 'error'
FLASH_INFO = 'info'
FLASH_WARNING = 'warning'


# ==============================================================================
# ALERT TYPES
# ==============================================================================

# Alert types
ALERT_TYPE_WEEKLY_PENDING = 'weekly_pending'
ALERT_TYPE_MONTHLY_PENDING = 'monthly_pending'
ALERT_TYPE_QUARTERLY_PENDING = 'quarterly_pending'


# ==============================================================================
# DEFAULT VALUES
# ==============================================================================

# Default port for Flask development server
DEFAULT_PORT = 5000

# Default number of months to show in period selector
DEFAULT_PERIOD_RANGE_MONTHS = 6

# Default email subject for notifications
DEFAULT_EMAIL_SUBJECT = 'Agenda Renta4 - Notificación'


# ==============================================================================
# SMTP & EMAIL SETTINGS
# ==============================================================================

# SMTP Configuration
DEFAULT_SMTP_PORT = 587
EMAIL_TIMEOUT_SECONDS = 30
DEFAULT_EMAIL_SENDER = "Agenda Renta4 <noreply@renta4.com>"


# ==============================================================================
# ALERT FREQUENCIES - SPECIAL MONTHS
# ==============================================================================

# Quarterly months (enero, abril, julio, octubre)
QUARTERLY_MONTHS = [1, 4, 7, 10]

# Semiannual months (enero, julio)
SEMIANNUAL_MONTHS = [1, 7]

# Annual month (enero)
ANNUAL_MONTH = 1


# ==============================================================================
# PAGINATION
# ==============================================================================

# URLs per page in crawler views
URLS_PER_PAGE = 50

# Quality checks per page
QUALITY_CHECKS_PER_PAGE = 20


# ==============================================================================
# HTTP STATUS CODES
# ==============================================================================

# HTTP status code constants
HTTP_OK = 200
HTTP_FORBIDDEN = 403
HTTP_CLIENT_ERROR_MIN = 400
HTTP_SERVER_ERROR_MIN = 500


# ==============================================================================
# QUALITY CHECK DEFAULTS
# ==============================================================================

class QualityCheckDefaults:
    """Default values for quality check operations"""

    # Broken links checker
    BROKEN_LINKS_TIMEOUT = 15
    BROKEN_LINKS_MAX_RETRIES = 2
    BROKEN_LINKS_RETRY_DELAY = 0.1

    # Image quality checker
    IMAGE_CHECK_TIMEOUT = 10
    IMAGE_CHECK_IGNORE_EXTERNAL = True

    # Time estimates (seconds per URL for different check types)
    # Used for UI progress estimation
    TIME_PER_URL_BROKEN_LINKS = 0.4      # ~0.4 seconds per URL (139 URLs = ~55s)
    TIME_PER_URL_IMAGE_QUALITY = 4.0     # ~4 seconds per URL (139 URLs = ~9 min)


# ==============================================================================
# USER AGENT STRINGS
# ==============================================================================

# User agent for image quality checker
USER_AGENT_IMAGE_CHECKER = 'Mozilla/5.0 (compatible; QualityChecker/1.0; +https://www.r4.com)'


# ==============================================================================
# LOGIN & SESSION
# ==============================================================================

# Login session duration (days)
LOGIN_SESSION_DAYS = 30
