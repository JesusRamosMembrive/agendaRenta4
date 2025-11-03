"""
Base classes for quality checks

This module provides the abstract base class and result class that all
quality checkers must inherit from and use.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from typing import Any, Dict, List, Optional


@dataclass
class QualityCheckResult:
    """
    Result of a quality check execution.

    Attributes:
        check_type: Type of check (e.g., 'image_quality', 'typo', 'broken_links')
        status: Overall status ('ok', 'warning', 'error')
        score: Numeric score (0-100) where 100 is perfect
        message: Human-readable summary message
        details: Additional details about the check (JSON-serializable)
        issues_found: Number of issues detected
        checked_at: Timestamp when check was executed
        execution_time_ms: Time taken to execute check in milliseconds
    """

    check_type: str
    status: str  # 'ok', 'warning', 'error'
    score: int  # 0-100
    message: str
    details: Dict[str, Any]
    issues_found: int
    checked_at: datetime
    execution_time_ms: int

    def to_dict(self) -> Dict[str, Any]:
        """Convert result to dictionary for JSON serialization."""
        return {
            "check_type": self.check_type,
            "status": self.status,
            "score": self.score,
            "message": self.message,
            "details": self.details,
            "issues_found": self.issues_found,
            "checked_at": self.checked_at.isoformat(),
            "execution_time_ms": self.execution_time_ms,
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "QualityCheckResult":
        """Create result from dictionary."""
        return cls(
            check_type=data["check_type"],
            status=data["status"],
            score=data["score"],
            message=data["message"],
            details=data["details"],
            issues_found=data["issues_found"],
            checked_at=datetime.fromisoformat(data["checked_at"]),
            execution_time_ms=data["execution_time_ms"],
        )


class QualityCheck(ABC):
    """
    Abstract base class for all quality checkers.

    Each quality checker must inherit from this class and implement
    the check() method.
    """

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """
        Initialize quality checker.

        Args:
            config: Optional configuration dictionary for the checker
        """
        self.config = config or {}
        self.name = self.__class__.__name__
        self.check_type = self._get_check_type()

    @abstractmethod
    def check(self, url: str, html_content: Optional[str] = None) -> QualityCheckResult:
        """
        Execute the quality check on a URL.

        Args:
            url: The URL to check
            html_content: Optional pre-fetched HTML content (to avoid redundant requests)

        Returns:
            QualityCheckResult with check results

        Raises:
            Exception: If check fails critically
        """
        pass

    @abstractmethod
    def _get_check_type(self) -> str:
        """
        Return the check type identifier.

        Returns:
            String identifier (e.g., 'image_quality', 'typo', 'broken_links')
        """
        pass

    def validate_url(self, url: str) -> bool:
        """
        Validate that URL is well-formed.

        Args:
            url: URL to validate

        Returns:
            True if valid, False otherwise
        """
        if not url:
            return False
        return url.startswith("http://") or url.startswith("https://")

    def create_result(
        self,
        status: str,
        score: int,
        message: str,
        details: Dict[str, Any],
        issues_found: int,
        execution_time_ms: int,
    ) -> QualityCheckResult:
        """
        Helper method to create a QualityCheckResult.

        Args:
            status: Status ('ok', 'warning', 'error')
            score: Score 0-100
            message: Summary message
            details: Additional details dictionary
            issues_found: Number of issues detected
            execution_time_ms: Execution time in milliseconds

        Returns:
            QualityCheckResult instance
        """
        return QualityCheckResult(
            check_type=self.check_type,
            status=status,
            score=score,
            message=message,
            details=details,
            issues_found=issues_found,
            checked_at=datetime.now(),
            execution_time_ms=execution_time_ms,
        )

    def determine_status(self, score: int) -> str:
        """
        Determine status based on score.

        Args:
            score: Score 0-100

        Returns:
            Status string ('ok', 'warning', 'error')
        """
        if score >= 80:
            return "ok"
        elif score >= 50:
            return "warning"
        else:
            return "error"


class QualityCheckRunner:
    """
    Runner class to execute multiple quality checks on a URL.
    """

    def __init__(self, checkers: List[QualityCheck]):
        """
        Initialize runner with list of checkers.

        Args:
            checkers: List of QualityCheck instances to run
        """
        self.checkers = checkers

    def run_all(
        self, url: str, html_content: Optional[str] = None
    ) -> List[QualityCheckResult]:
        """
        Run all configured quality checks on a URL.

        Args:
            url: URL to check
            html_content: Optional pre-fetched HTML content

        Returns:
            List of QualityCheckResult instances
        """
        results = []

        for checker in self.checkers:
            try:
                result = checker.check(url, html_content)
                results.append(result)
            except Exception as e:
                # Create error result if checker fails
                error_result = QualityCheckResult(
                    check_type=checker.check_type,
                    status="error",
                    score=0,
                    message=f"Check failed: {str(e)}",
                    details={"error": str(e)},
                    issues_found=0,
                    checked_at=datetime.now(),
                    execution_time_ms=0,
                )
                results.append(error_result)

        return results

    def run_single(
        self, check_type: str, url: str, html_content: Optional[str] = None
    ) -> Optional[QualityCheckResult]:
        """
        Run a single quality check by type.

        Args:
            check_type: Type of check to run (e.g., 'image_quality')
            url: URL to check
            html_content: Optional pre-fetched HTML content

        Returns:
            QualityCheckResult or None if check_type not found
        """
        for checker in self.checkers:
            if checker.check_type == check_type:
                try:
                    return checker.check(url, html_content)
                except Exception as e:
                    return QualityCheckResult(
                        check_type=checker.check_type,
                        status="error",
                        score=0,
                        message=f"Check failed: {str(e)}",
                        details={"error": str(e)},
                        issues_found=0,
                        checked_at=datetime.now(),
                        execution_time_ms=0,
                    )

        return None

    def get_summary(self, results: List[QualityCheckResult]) -> Dict[str, Any]:
        """
        Generate summary statistics from multiple check results.

        Args:
            results: List of QualityCheckResult instances

        Returns:
            Dictionary with summary statistics
        """
        if not results:
            return {
                "total_checks": 0,
                "average_score": 0,
                "ok_count": 0,
                "warning_count": 0,
                "error_count": 0,
                "total_issues": 0,
            }

        ok_count = sum(1 for r in results if r.status == "ok")
        warning_count = sum(1 for r in results if r.status == "warning")
        error_count = sum(1 for r in results if r.status == "error")
        total_issues = sum(r.issues_found for r in results)
        average_score = sum(r.score for r in results) // len(results)

        return {
            "total_checks": len(results),
            "average_score": average_score,
            "ok_count": ok_count,
            "warning_count": warning_count,
            "error_count": error_count,
            "total_issues": total_issues,
        }
