#!/usr/bin/env python3
"""
Crawler Scheduler - Phase 2.4
Automatic revalidation of URLs with configurable frequency and email notifications
"""

import logging
from datetime import datetime
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from crawler.validator import URLValidator, get_validation_config
from utils import db_cursor

logger = logging.getLogger('scheduler')


class ValidationScheduler:
    """
    Manages automatic URL revalidation with configurable schedule.

    Features:
    - Periodic revalidation (daily, weekly, custom cron)
    - Track validation history
    - Email notifications for broken links
    - Health score tracking over time
    """

    def __init__(self):
        self.scheduler = BackgroundScheduler()
        self.validator = None

    def start(self, frequency='daily', hour=3, minute=0):
        """
        Start the scheduler with specified frequency.

        Args:
            frequency: 'daily', 'weekly', 'custom'
            hour: Hour to run (0-23)
            minute: Minute to run (0-59)
        """

        # Configure cron trigger based on frequency
        if frequency == 'daily':
            trigger = CronTrigger(hour=hour, minute=minute)
        elif frequency == 'weekly':
            trigger = CronTrigger(day_of_week='mon', hour=hour, minute=minute)
        else:
            # Default to daily
            trigger = CronTrigger(hour=hour, minute=minute)

        # Add job to scheduler
        self.scheduler.add_job(
            func=self.run_revalidation,
            trigger=trigger,
            id='url_revalidation',
            name='URL Revalidation Job',
            replace_existing=True
        )

        self.scheduler.start()
        logger.info(f"Scheduler started: {frequency} at {hour:02d}:{minute:02d}")

    def stop(self):
        """Stop the scheduler"""
        if self.scheduler.running:
            self.scheduler.shutdown()
            logger.info("Scheduler stopped")

    def run_revalidation(self):
        """
        Main revalidation function - called by scheduler.

        Steps:
        1. Get all URLs from latest crawl
        2. Validate them
        3. Track changes
        4. Calculate health score
        5. Send email if broken links found
        """
        logger.info("=" * 80)
        logger.info("AUTOMATIC REVALIDATION STARTED")
        logger.info("=" * 80)

        start_time = datetime.now()

        try:
            # 1. Get URLs to validate
            urls = self._get_urls_to_revalidate()

            if not urls:
                logger.warning("No URLs found to revalidate")
                return

            logger.info(f"Found {len(urls)} URLs to revalidate")

            # 2. Create validator
            config = get_validation_config()
            self.validator = URLValidator(config)

            # 3. Validate URLs
            urls_to_validate = [
                (url['id'], url['url'], url.get('status_code'))
                for url in urls
            ]

            stats = self.validator.validate_batch(urls_to_validate, track_changes=True)

            # 4. Calculate and save health metrics
            health_score = self._calculate_health_score(stats)
            self._save_health_snapshot(health_score, stats)

            # 5. Check for new broken links
            new_broken = self._get_newly_broken_urls()

            # 6. Send email if there are new broken links
            if new_broken:
                logger.warning(f"Found {len(new_broken)} newly broken URLs")
                self._send_notification_email(new_broken, stats, health_score)

            duration = (datetime.now() - start_time).total_seconds()

            logger.info("=" * 80)
            logger.info("AUTOMATIC REVALIDATION COMPLETED")
            logger.info(f"Duration: {duration:.1f} seconds ({duration/60:.1f} minutes)")
            logger.info(f"Health Score: {health_score:.1f}%")
            logger.info(f"Newly Broken URLs: {len(new_broken)}")
            logger.info("=" * 80)

        except Exception as e:
            logger.error(f"Revalidation failed: {e}", exc_info=True)

    def _get_urls_to_revalidate(self):
        """Get all URLs from latest crawl run"""
        with db_cursor() as cursor:
            cursor.execute("""
                SELECT
                    d.id,
                    d.url,
                    d.status_code,
                    d.is_priority
                FROM discovered_urls d
                WHERE d.crawl_run_id = (
                    SELECT id FROM crawl_runs ORDER BY id DESC LIMIT 1
                )
                ORDER BY d.is_priority DESC, d.id
            """)
            return cursor.fetchall()

    def _calculate_health_score(self, stats):
        """
        Calculate overall health score (0-100).

        Health = (OK URLs / Total URLs) * 100
        """
        if stats['validated'] == 0:
            return 0.0

        return (stats['ok'] / stats['validated']) * 100

    def _save_health_snapshot(self, health_score, stats):
        """Save health metrics snapshot for historical tracking"""
        with db_cursor() as cursor:
            cursor.execute("""
                INSERT INTO health_snapshots (
                    snapshot_date,
                    health_score,
                    total_urls,
                    ok_urls,
                    broken_urls,
                    redirect_urls,
                    error_urls
                )
                VALUES (NOW(), %s, %s, %s, %s, %s, %s)
            """, (
                health_score,
                stats['validated'],
                stats['ok'],
                stats['broken'],
                stats['redirects'],
                stats['errors']
            ))
            cursor.connection.commit()
            logger.info("Health snapshot saved")

    def _get_newly_broken_urls(self):
        """
        Get URLs that broke since last revalidation.

        Returns URLs that:
        - Changed from OK (200) to broken (4xx, 5xx)
        - Detected in last 24 hours
        """
        with db_cursor() as cursor:
            cursor.execute("""
                SELECT
                    c.url_id,
                    d.url,
                    d.status_code,
                    d.is_priority,
                    c.old_value as old_status,
                    c.new_value as new_status,
                    c.detected_at
                FROM url_changes c
                JOIN discovered_urls d ON c.url_id = d.id
                WHERE
                    c.change_type = 'broken'
                    AND c.detected_at >= NOW() - INTERVAL '24 hours'
                ORDER BY d.is_priority DESC, c.detected_at DESC
            """)
            return cursor.fetchall()

    def _send_notification_email(self, broken_urls, stats, health_score):
        """
        Send email notification about broken links.

        Args:
            broken_urls: List of newly broken URLs
            stats: Validation statistics
            health_score: Current health score
        """
        from flask_mail import Message
        from flask import current_app, render_template

        try:
            # Get recipient from notification preferences
            with db_cursor() as cursor:
                cursor.execute("""
                    SELECT email
                    FROM notification_preferences
                    WHERE enable_email = TRUE
                    LIMIT 1
                """)
                result = cursor.fetchone()

                if not result:
                    logger.warning("No email recipients configured")
                    return

                recipient = result['email']

            # Prepare email
            priority_broken = sum(1 for u in broken_urls if u['is_priority'])

            msg = Message(
                subject=f"⚠️ Alerta: {len(broken_urls)} enlaces rotos detectados",
                recipients=[recipient],
                html=render_template(
                    'emails/revalidation_report.html',
                    broken_urls=broken_urls,
                    stats=stats,
                    health_score=health_score,
                    priority_broken=priority_broken,
                    timestamp=datetime.now()
                )
            )

            # Send email
            current_app.extensions['mail'].send(msg)
            logger.info(f"Notification email sent to {recipient}")

        except Exception as e:
            logger.error(f"Failed to send email: {e}", exc_info=True)

    def get_schedule_info(self):
        """Get information about scheduled jobs"""
        jobs = self.scheduler.get_jobs()

        if not jobs:
            return None

        job = jobs[0]

        return {
            'job_id': job.id,
            'name': job.name,
            'next_run': job.next_run_time,
            'trigger': str(job.trigger)
        }


# Global scheduler instance
_scheduler = None


def get_scheduler():
    """Get or create global scheduler instance"""
    global _scheduler

    if _scheduler is None:
        _scheduler = ValidationScheduler()

    return _scheduler


def start_scheduler(frequency='daily', hour=3, minute=0):
    """
    Start the global scheduler.

    Args:
        frequency: 'daily', 'weekly'
        hour: Hour to run (0-23)
        minute: Minute to run (0-59)
    """
    scheduler = get_scheduler()
    scheduler.start(frequency, hour, minute)
    return scheduler


def stop_scheduler():
    """Stop the global scheduler"""
    scheduler = get_scheduler()
    scheduler.stop()
