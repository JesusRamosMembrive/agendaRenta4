"""
Batch Quality Check Processing

Handles batch execution of quality checks on multiple URLs with progress tracking.
"""

import json
import logging
from typing import Any

from utils import db_cursor

logger = logging.getLogger(__name__)


class BatchQualityCheckRunner:
    """
    Runner for executing quality checks on multiple URLs in batch.
    Tracks progress in database for real-time updates.
    """

    def __init__(
        self, batch_type: str, checker_class, checker_config: dict | None = None
    ):
        """
        Initialize batch runner.

        Args:
            batch_type: Type of check (e.g., 'image_quality', 'broken_links')
            checker_class: Class to instantiate for checking (e.g., ImagenesChecker)
            checker_config: Optional configuration for the checker
        """
        self.batch_type = batch_type
        self.checker_class = checker_class
        self.checker_config = checker_config or {}
        self.batch_id = None

    def create_batch(self, total_urls: int, created_by: str = "system") -> int:
        """
        Create a new batch record in database.

        Args:
            total_urls: Total number of URLs to process
            created_by: User who initiated the batch

        Returns:
            Batch ID
        """
        with db_cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO quality_check_batches (
                    batch_type, status, total_urls, processed_urls,
                    successful_checks, failed_checks, created_by
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            """,
                (self.batch_type, "pending", total_urls, 0, 0, 0, created_by),
            )

            self.batch_id = cursor.fetchone()["id"]
            logger.info(f"Created batch {self.batch_id} for {total_urls} URLs")
            return self.batch_id

    def update_batch_status(self, status: str, error_message: str | None = None):
        """
        Update batch status.

        Args:
            status: New status ('pending', 'running', 'completed', 'failed')
            error_message: Optional error message if failed
        """
        if not self.batch_id:
            raise ValueError("Batch not created yet")

        with db_cursor() as cursor:
            if status in ["completed", "failed"]:
                cursor.execute(
                    """
                    UPDATE quality_check_batches
                    SET status = %s, completed_at = CURRENT_TIMESTAMP, error_message = %s
                    WHERE id = %s
                """,
                    (status, error_message, self.batch_id),
                )
            else:
                cursor.execute(
                    """
                    UPDATE quality_check_batches
                    SET status = %s
                    WHERE id = %s
                """,
                    (status, self.batch_id),
                )

            logger.info(f"Batch {self.batch_id} status updated to: {status}")

    def update_progress(self, processed: int, successful: int, failed: int):
        """
        Update batch progress.

        Args:
            processed: Number of URLs processed so far
            successful: Number of successful checks
            failed: Number of failed checks
        """
        if not self.batch_id:
            raise ValueError("Batch not created yet")

        with db_cursor() as cursor:
            cursor.execute(
                """
                UPDATE quality_check_batches
                SET processed_urls = %s, successful_checks = %s, failed_checks = %s
                WHERE id = %s
            """,
                (processed, successful, failed, self.batch_id),
            )

    def run_batch(
        self, section_ids: list[int], created_by: str = "system"
    ) -> dict[str, Any]:
        """
        Execute quality checks on a batch of URLs.

        Args:
            section_ids: List of section IDs to check
            created_by: User who initiated the batch

        Returns:
            Dictionary with batch execution results
        """
        # Create batch record
        self.create_batch(len(section_ids), created_by)

        # Update status to running
        self.update_batch_status("running")

        # Initialize counters
        processed = 0
        successful = 0
        failed = 0
        results = []

        try:
            # Create checker instance
            checker = self.checker_class(config=self.checker_config)

            # Process each URL
            for section_id in section_ids:
                try:
                    # Get URL from database
                    with db_cursor(commit=False) as cursor:
                        cursor.execute(
                            """
                            SELECT id, url, name FROM sections WHERE id = %s
                        """,
                            (section_id,),
                        )
                        section = cursor.fetchone()

                        if not section:
                            logger.warning(f"Section {section_id} not found")
                            failed += 1
                            continue

                    # Run quality check
                    logger.info(f"Checking {section['url']}...")
                    result = checker.check(section["url"])

                    # Save result to database
                    with db_cursor() as cursor:
                        cursor.execute(
                            """
                            INSERT INTO quality_checks (
                                section_id, check_type, status, score, message,
                                details, issues_found, checked_at, execution_time_ms
                            )
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                            RETURNING id
                        """,
                            (
                                section_id,
                                result.check_type,
                                result.status,
                                result.score,
                                result.message,
                                json.dumps(result.details),
                                result.issues_found,
                                result.checked_at,
                                result.execution_time_ms,
                            ),
                        )

                        check_id = cursor.fetchone()["id"]

                    successful += 1
                    results.append(
                        {
                            "section_id": section_id,
                            "url": section["url"],
                            "check_id": check_id,
                            "status": result.status,
                            "score": result.score,
                            "issues_found": result.issues_found,
                        }
                    )

                    logger.info(
                        f"✓ {section['url']}: {result.status} (score: {result.score})"
                    )

                except Exception as e:
                    logger.error(f"Error checking section {section_id}: {e}")
                    failed += 1
                    results.append({"section_id": section_id, "error": str(e)})

                finally:
                    processed += 1
                    # Update progress after each URL
                    self.update_progress(processed, successful, failed)

            # Mark batch as completed
            self.update_batch_status("completed")

            return {
                "batch_id": self.batch_id,
                "status": "completed",
                "total": len(section_ids),
                "processed": processed,
                "successful": successful,
                "failed": failed,
                "results": results,
            }

        except Exception as e:
            logger.error(f"Batch execution failed: {e}")
            self.update_batch_status("failed", str(e))
            raise


def get_batch_status(batch_id: int) -> dict[str, Any] | None:
    """
    Get current status of a batch.

    Args:
        batch_id: ID of the batch to query

    Returns:
        Dictionary with batch information or None if not found
    """
    with db_cursor(commit=False) as cursor:
        cursor.execute(
            """
            SELECT
                id,
                batch_type,
                status,
                total_urls,
                processed_urls,
                successful_checks,
                failed_checks,
                started_at,
                completed_at,
                created_by,
                error_message
            FROM quality_check_batches
            WHERE id = %s
        """,
            (batch_id,),
        )

        batch = cursor.fetchone()

        if not batch:
            return None

        # Calculate progress percentage
        progress_pct = 0
        if batch["total_urls"] > 0:
            progress_pct = int((batch["processed_urls"] / batch["total_urls"]) * 100)

        return {
            "id": batch["id"],
            "batch_type": batch["batch_type"],
            "status": batch["status"],
            "total_urls": batch["total_urls"],
            "processed_urls": batch["processed_urls"],
            "successful_checks": batch["successful_checks"],
            "failed_checks": batch["failed_checks"],
            "progress_pct": progress_pct,
            "started_at": batch["started_at"].isoformat()
            if batch["started_at"]
            else None,
            "completed_at": batch["completed_at"].isoformat()
            if batch["completed_at"]
            else None,
            "created_by": batch["created_by"],
            "error_message": batch["error_message"],
        }
