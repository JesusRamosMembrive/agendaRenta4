"""
Unit tests for calidad/base.py

Tests the base classes: QualityCheck, QualityCheckResult, QualityCheckRunner
"""

from datetime import datetime

from calidad.base import QualityCheck, QualityCheckResult, QualityCheckRunner


class TestQualityCheckResult:
    """Tests for QualityCheckResult dataclass"""

    def test_create_result(self):
        """Test creating a QualityCheckResult instance"""
        result = QualityCheckResult(
            check_type="test_check",
            status="ok",
            score=85,
            message="Test passed",
            details={"test": "data"},
            issues_found=0,
            checked_at=datetime.now(),
            execution_time_ms=100,
        )

        assert result.check_type == "test_check"
        assert result.status == "ok"
        assert result.score == 85
        assert result.message == "Test passed"
        assert result.details == {"test": "data"}
        assert result.issues_found == 0
        assert result.execution_time_ms == 100

    def test_to_dict(self):
        """Test converting result to dictionary"""
        now = datetime.now()
        result = QualityCheckResult(
            check_type="test_check",
            status="warning",
            score=60,
            message="Some issues",
            details={"issues": ["issue1", "issue2"]},
            issues_found=2,
            checked_at=now,
            execution_time_ms=250,
        )

        result_dict = result.to_dict()

        assert isinstance(result_dict, dict)
        assert result_dict["check_type"] == "test_check"
        assert result_dict["status"] == "warning"
        assert result_dict["score"] == 60
        assert result_dict["message"] == "Some issues"
        assert result_dict["details"] == {"issues": ["issue1", "issue2"]}
        assert result_dict["issues_found"] == 2
        assert result_dict["checked_at"] == now.isoformat()
        assert result_dict["execution_time_ms"] == 250

    def test_from_dict(self):
        """Test creating result from dictionary"""
        now = datetime.now()
        data = {
            "check_type": "test_check",
            "status": "error",
            "score": 30,
            "message": "Critical issues",
            "details": {"error": "Something went wrong"},
            "issues_found": 5,
            "checked_at": now.isoformat(),
            "execution_time_ms": 500,
        }

        result = QualityCheckResult.from_dict(data)

        assert result.check_type == "test_check"
        assert result.status == "error"
        assert result.score == 30
        assert result.message == "Critical issues"
        assert result.details == {"error": "Something went wrong"}
        assert result.issues_found == 5
        assert result.checked_at == now
        assert result.execution_time_ms == 500


class MockQualityCheck(QualityCheck):
    """Mock implementation of QualityCheck for testing"""

    def _get_check_type(self):
        return "mock_check"

    def check(self, url, html_content=None):
        return self.create_result(
            status="ok",
            score=100,
            message="Mock check passed",
            details={"url": url},
            issues_found=0,
            execution_time_ms=10,
        )


class TestQualityCheck:
    """Tests for QualityCheck abstract base class"""

    def test_instantiate_mock_checker(self):
        """Test creating a mock checker instance"""
        checker = MockQualityCheck()
        assert checker.check_type == "mock_check"
        assert isinstance(checker.config, dict)

    def test_instantiate_with_config(self):
        """Test creating checker with custom config"""
        config = {"timeout": 20, "max_items": 50}
        checker = MockQualityCheck(config=config)

        assert checker.config == config
        assert checker.config["timeout"] == 20
        assert checker.config["max_items"] == 50

    def test_validate_url_valid(self):
        """Test URL validation with valid URLs"""
        checker = MockQualityCheck()

        assert checker.validate_url("https://example.com") is True
        assert checker.validate_url("http://test.com/path") is True
        assert checker.validate_url("https://example.com:8080/page") is True

    def test_validate_url_invalid(self):
        """Test URL validation with invalid URLs"""
        checker = MockQualityCheck()

        assert checker.validate_url("") is False
        assert checker.validate_url("not-a-url") is False
        assert checker.validate_url("ftp://example.com") is False
        assert checker.validate_url(None) is False

    def test_check_execution(self):
        """Test executing check method"""
        checker = MockQualityCheck()
        result = checker.check("https://example.com")

        assert isinstance(result, QualityCheckResult)
        assert result.check_type == "mock_check"
        assert result.status == "ok"
        assert result.score == 100

    def test_create_result_helper(self):
        """Test create_result helper method"""
        checker = MockQualityCheck()
        result = checker.create_result(
            status="warning",
            score=70,
            message="Test message",
            details={"key": "value"},
            issues_found=3,
            execution_time_ms=150,
        )

        assert result.check_type == "mock_check"
        assert result.status == "warning"
        assert result.score == 70
        assert result.message == "Test message"
        assert result.issues_found == 3
        assert result.execution_time_ms == 150

    def test_determine_status_ok(self):
        """Test status determination for high scores"""
        checker = MockQualityCheck()

        assert checker.determine_status(100) == "ok"
        assert checker.determine_status(90) == "ok"
        assert checker.determine_status(80) == "ok"

    def test_determine_status_warning(self):
        """Test status determination for medium scores"""
        checker = MockQualityCheck()

        assert checker.determine_status(79) == "warning"
        assert checker.determine_status(65) == "warning"
        assert checker.determine_status(50) == "warning"

    def test_determine_status_error(self):
        """Test status determination for low scores"""
        checker = MockQualityCheck()

        assert checker.determine_status(49) == "error"
        assert checker.determine_status(30) == "error"
        assert checker.determine_status(0) == "error"


class FailingQualityCheck(QualityCheck):
    """Mock checker that always fails for testing error handling"""

    def _get_check_type(self):
        return "failing_check"

    def check(self, url, html_content=None):
        raise Exception("Intentional failure for testing")


class TestQualityCheckRunner:
    """Tests for QualityCheckRunner"""

    def test_instantiate_runner(self):
        """Test creating a runner with checkers"""
        checker1 = MockQualityCheck()
        checker2 = MockQualityCheck(config={"test": "config"})

        runner = QualityCheckRunner([checker1, checker2])

        assert len(runner.checkers) == 2
        assert runner.checkers[0] is checker1
        assert runner.checkers[1] is checker2

    def test_run_all_successful(self):
        """Test running all checkers successfully"""
        checker1 = MockQualityCheck()
        checker2 = MockQualityCheck()

        runner = QualityCheckRunner([checker1, checker2])
        results = runner.run_all("https://example.com")

        assert len(results) == 2
        assert all(isinstance(r, QualityCheckResult) for r in results)
        assert all(r.status == "ok" for r in results)
        assert all(r.score == 100 for r in results)

    def test_run_all_with_failure(self):
        """Test running checkers when one fails"""
        checker1 = MockQualityCheck()
        checker2 = FailingQualityCheck()

        runner = QualityCheckRunner([checker1, checker2])
        results = runner.run_all("https://example.com")

        assert len(results) == 2
        assert results[0].status == "ok"
        assert results[1].status == "error"
        assert results[1].score == 0
        assert "Intentional failure" in results[1].message

    def test_run_single_found(self):
        """Test running a single checker by type"""
        checker1 = MockQualityCheck()
        checker2 = MockQualityCheck()

        runner = QualityCheckRunner([checker1, checker2])
        result = runner.run_single("mock_check", "https://example.com")

        assert result is not None
        assert isinstance(result, QualityCheckResult)
        assert result.check_type == "mock_check"

    def test_run_single_not_found(self):
        """Test running a non-existent checker type"""
        checker = MockQualityCheck()
        runner = QualityCheckRunner([checker])

        result = runner.run_single("nonexistent_check", "https://example.com")

        assert result is None

    def test_run_single_with_failure(self):
        """Test running single checker that fails"""
        checker = FailingQualityCheck()
        runner = QualityCheckRunner([checker])

        result = runner.run_single("failing_check", "https://example.com")

        assert result is not None
        assert result.status == "error"
        assert result.score == 0

    def test_get_summary_empty(self):
        """Test summary with no results"""
        runner = QualityCheckRunner([])
        summary = runner.get_summary([])

        assert summary["total_checks"] == 0
        assert summary["average_score"] == 0
        assert summary["ok_count"] == 0
        assert summary["warning_count"] == 0
        assert summary["error_count"] == 0
        assert summary["total_issues"] == 0

    def test_get_summary_with_results(self):
        """Test summary with mixed results"""
        results = [
            QualityCheckResult(
                check_type="check1",
                status="ok",
                score=90,
                message="Good",
                details={},
                issues_found=0,
                checked_at=datetime.now(),
                execution_time_ms=100,
            ),
            QualityCheckResult(
                check_type="check2",
                status="warning",
                score=60,
                message="Warning",
                details={},
                issues_found=3,
                checked_at=datetime.now(),
                execution_time_ms=200,
            ),
            QualityCheckResult(
                check_type="check3",
                status="error",
                score=30,
                message="Error",
                details={},
                issues_found=10,
                checked_at=datetime.now(),
                execution_time_ms=150,
            ),
        ]

        runner = QualityCheckRunner([])
        summary = runner.get_summary(results)

        assert summary["total_checks"] == 3
        assert summary["average_score"] == 60  # (90 + 60 + 30) // 3
        assert summary["ok_count"] == 1
        assert summary["warning_count"] == 1
        assert summary["error_count"] == 1
        assert summary["total_issues"] == 13  # 0 + 3 + 10
