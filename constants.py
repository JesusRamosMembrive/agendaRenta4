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
