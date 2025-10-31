"""
Unit tests for calidad/batch.py

Tests the BatchQualityCheckRunner for batch processing of quality checks.

TDD Approach: Tests written to verify batch processing functionality.
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from calidad.batch import BatchQualityCheckRunner, get_batch_status
from calidad.imagenes import ImagenesChecker
from calidad.base import QualityCheckResult
from datetime import datetime


class TestBatchQualityCheckRunner:
    """Tests for BatchQualityCheckRunner"""

    def test_instantiate_batch_runner(self):
        """Test creating a batch runner instance"""
        runner = BatchQualityCheckRunner(
            batch_type='image_quality',
            checker_class=ImagenesChecker,
            checker_config={'check_format': True}
        )

        assert runner.batch_type == 'image_quality'
        assert runner.checker_class == ImagenesChecker
        assert runner.checker_config == {'check_format': True}
        assert runner.batch_id is None

    @patch('calidad.batch.db_cursor')
    def test_create_batch(self, mock_db_cursor):
        """Test creating a batch record in database"""
        # Mock cursor
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = {'id': 123}
        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        runner = BatchQualityCheckRunner('image_quality', ImagenesChecker)
        batch_id = runner.create_batch(total_urls=10, created_by='test_user')

        assert batch_id == 123
        assert runner.batch_id == 123

        # Verify database insert was called
        mock_cursor.execute.assert_called_once()
        call_args = mock_cursor.execute.call_args
        assert 'INSERT INTO quality_check_batches' in call_args[0][0]
        assert call_args[0][1] == ('image_quality', 'pending', 10, 0, 0, 0, 'test_user')

    @patch('calidad.batch.db_cursor')
    def test_update_batch_status_to_running(self, mock_db_cursor):
        """Test updating batch status to running"""
        mock_cursor = MagicMock()
        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        runner = BatchQualityCheckRunner('image_quality', ImagenesChecker)
        runner.batch_id = 123

        runner.update_batch_status('running')

        mock_cursor.execute.assert_called_once()
        call_args = mock_cursor.execute.call_args
        assert 'UPDATE quality_check_batches' in call_args[0][0]
        assert call_args[0][1] == ('running', 123)

    @patch('calidad.batch.db_cursor')
    def test_update_batch_status_to_completed(self, mock_db_cursor):
        """Test updating batch status to completed with timestamp"""
        mock_cursor = MagicMock()
        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        runner = BatchQualityCheckRunner('image_quality', ImagenesChecker)
        runner.batch_id = 123

        runner.update_batch_status('completed')

        mock_cursor.execute.assert_called_once()
        call_args = mock_cursor.execute.call_args
        assert 'UPDATE quality_check_batches' in call_args[0][0]
        assert 'completed_at = CURRENT_TIMESTAMP' in call_args[0][0]
        assert call_args[0][1] == ('completed', None, 123)

    @patch('calidad.batch.db_cursor')
    def test_update_batch_status_to_failed_with_error(self, mock_db_cursor):
        """Test updating batch status to failed with error message"""
        mock_cursor = MagicMock()
        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        runner = BatchQualityCheckRunner('image_quality', ImagenesChecker)
        runner.batch_id = 123

        runner.update_batch_status('failed', error_message='Connection timeout')

        mock_cursor.execute.assert_called_once()
        call_args = mock_cursor.execute.call_args
        assert call_args[0][1] == ('failed', 'Connection timeout', 123)

    @patch('calidad.batch.db_cursor')
    def test_update_progress(self, mock_db_cursor):
        """Test updating batch progress"""
        mock_cursor = MagicMock()
        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        runner = BatchQualityCheckRunner('image_quality', ImagenesChecker)
        runner.batch_id = 123

        runner.update_progress(processed=5, successful=4, failed=1)

        mock_cursor.execute.assert_called_once()
        call_args = mock_cursor.execute.call_args
        assert 'UPDATE quality_check_batches' in call_args[0][0]
        assert 'processed_urls' in call_args[0][0]
        assert call_args[0][1] == (5, 4, 1, 123)

    def test_update_batch_status_without_batch_id_raises_error(self):
        """Test that updating status without creating batch raises error"""
        runner = BatchQualityCheckRunner('image_quality', ImagenesChecker)

        with pytest.raises(ValueError, match="Batch not created yet"):
            runner.update_batch_status('running')

    def test_update_progress_without_batch_id_raises_error(self):
        """Test that updating progress without creating batch raises error"""
        runner = BatchQualityCheckRunner('image_quality', ImagenesChecker)

        with pytest.raises(ValueError, match="Batch not created yet"):
            runner.update_progress(1, 1, 0)

    @patch('calidad.batch.db_cursor')
    @patch('calidad.batch.logger')
    def test_run_batch_with_single_url_success(self, mock_logger, mock_db_cursor):
        """Test running batch with one URL successfully"""
        # Mock database responses
        mock_cursor = MagicMock()

        # Mock create_batch (returns batch_id)
        mock_cursor.fetchone.side_effect = [
            {'id': 456},  # create_batch
            {'id': 1, 'url': 'https://example.com', 'name': 'Example'},  # get section
            {'id': 789}  # insert quality_check
        ]

        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        # Mock checker
        mock_checker = Mock()
        mock_result = QualityCheckResult(
            check_type='image_quality',
            status='ok',
            score=100,
            message='All images OK',
            details={'total_images': 2},
            issues_found=0,
            checked_at=datetime.now(),
            execution_time_ms=500
        )
        mock_checker.check.return_value = mock_result

        # Mock checker class
        mock_checker_class = Mock(return_value=mock_checker)

        runner = BatchQualityCheckRunner('image_quality', mock_checker_class)
        result = runner.run_batch(section_ids=[1], created_by='test_user')

        assert result['batch_id'] == 456
        assert result['status'] == 'completed'
        assert result['total'] == 1
        assert result['processed'] == 1
        assert result['successful'] == 1
        assert result['failed'] == 0
        assert len(result['results']) == 1

        # Verify checker was called
        mock_checker.check.assert_called_once_with('https://example.com')

    @patch('calidad.batch.db_cursor')
    def test_run_batch_with_nonexistent_section(self, mock_db_cursor):
        """Test running batch when section doesn't exist"""
        # We need to handle multiple context manager calls in sequence:
        # 1. create_batch
        # 2. update_batch_status('running')
        # 3. get section (commit=False) - returns None
        # 4. update_progress (finally block) - only once
        # 5. update_batch_status('completed')

        mock_db_cursor.side_effect = [
            # First call: create_batch
            MagicMock(__enter__=MagicMock(return_value=MagicMock(fetchone=MagicMock(return_value={'id': 456})))),
            # Second call: update_batch_status ('running')
            MagicMock(__enter__=MagicMock(return_value=MagicMock())),
            # Third call: get section (not found)
            MagicMock(__enter__=MagicMock(return_value=MagicMock(fetchone=MagicMock(return_value=None)))),
            # Fourth call: update_progress (finally block)
            MagicMock(__enter__=MagicMock(return_value=MagicMock())),
            # Fifth call: update_batch_status ('completed')
            MagicMock(__enter__=MagicMock(return_value=MagicMock()))
        ]

        mock_checker = Mock()
        mock_checker_class = Mock(return_value=mock_checker)

        runner = BatchQualityCheckRunner('image_quality', mock_checker_class)
        result = runner.run_batch(section_ids=[999], created_by='test_user')

        assert result['successful'] == 0
        assert result['failed'] == 1
        assert result['processed'] == 1

        # Checker should not have been called
        mock_checker.check.assert_not_called()

    @patch('calidad.batch.db_cursor')
    def test_run_batch_with_checker_exception(self, mock_db_cursor):
        """Test running batch when checker raises exception"""
        mock_cursor = MagicMock()

        # Mock responses
        mock_cursor.fetchone.side_effect = [
            {'id': 456},  # create_batch
            {'id': 1, 'url': 'https://example.com', 'name': 'Example'}  # get section
        ]

        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        # Mock checker that raises exception
        mock_checker = Mock()
        mock_checker.check.side_effect = Exception('Network error')
        mock_checker_class = Mock(return_value=mock_checker)

        runner = BatchQualityCheckRunner('image_quality', mock_checker_class)
        result = runner.run_batch(section_ids=[1], created_by='test_user')

        assert result['successful'] == 0
        assert result['failed'] == 1
        assert result['results'][0]['error'] == 'Network error'

    @patch('calidad.batch.db_cursor')
    def test_run_batch_with_multiple_urls_mixed_results(self, mock_db_cursor):
        """Test running batch with multiple URLs, some succeed and some fail"""
        mock_cursor = MagicMock()

        # Mock responses for 3 URLs
        mock_cursor.fetchone.side_effect = [
            {'id': 456},  # create_batch
            {'id': 1, 'url': 'https://example1.com', 'name': 'Ex1'},
            {'id': 101},  # quality_check insert
            {'id': 2, 'url': 'https://example2.com', 'name': 'Ex2'},  # This will fail
            {'id': 3, 'url': 'https://example3.com', 'name': 'Ex3'},
            {'id': 102}  # quality_check insert
        ]

        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        # Mock checker with one failure
        mock_checker = Mock()
        mock_result_ok = QualityCheckResult(
            check_type='image_quality', status='ok', score=100,
            message='OK', details={}, issues_found=0,
            checked_at=datetime.now(), execution_time_ms=100
        )

        # First call succeeds, second fails, third succeeds
        mock_checker.check.side_effect = [
            mock_result_ok,
            Exception('Timeout'),
            mock_result_ok
        ]

        mock_checker_class = Mock(return_value=mock_checker)

        runner = BatchQualityCheckRunner('image_quality', mock_checker_class)
        result = runner.run_batch(section_ids=[1, 2, 3], created_by='test_user')

        assert result['total'] == 3
        assert result['processed'] == 3
        assert result['successful'] == 2
        assert result['failed'] == 1


class TestGetBatchStatus:
    """Tests for get_batch_status function"""

    @patch('calidad.batch.db_cursor')
    def test_get_batch_status_found(self, mock_db_cursor):
        """Test getting batch status when batch exists"""
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = {
            'id': 123,
            'batch_type': 'image_quality',
            'status': 'running',
            'total_urls': 10,
            'processed_urls': 5,
            'successful_checks': 4,
            'failed_checks': 1,
            'started_at': datetime(2025, 10, 31, 10, 0, 0),
            'completed_at': None,
            'created_by': 'test_user',
            'error_message': None
        }
        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        status = get_batch_status(123)

        assert status is not None
        assert status['id'] == 123
        assert status['status'] == 'running'
        assert status['progress_pct'] == 50  # 5/10 = 50%

    @patch('calidad.batch.db_cursor')
    def test_get_batch_status_not_found(self, mock_db_cursor):
        """Test getting batch status when batch doesn't exist"""
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = None
        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        status = get_batch_status(999)

        assert status is None

    @patch('calidad.batch.db_cursor')
    def test_get_batch_status_completed(self, mock_db_cursor):
        """Test getting batch status for completed batch"""
        mock_cursor = MagicMock()
        mock_cursor.fetchone.return_value = {
            'id': 123,
            'batch_type': 'image_quality',
            'status': 'completed',
            'total_urls': 10,
            'processed_urls': 10,
            'successful_checks': 9,
            'failed_checks': 1,
            'started_at': datetime(2025, 10, 31, 10, 0, 0),
            'completed_at': datetime(2025, 10, 31, 10, 5, 0),
            'created_by': 'test_user',
            'error_message': None
        }
        mock_db_cursor.return_value.__enter__.return_value = mock_cursor

        status = get_batch_status(123)

        assert status['status'] == 'completed'
        assert status['progress_pct'] == 100
        assert status['completed_at'] is not None
