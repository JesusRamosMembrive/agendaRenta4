"""
Unit tests for calidad/enlaces.py

Tests the EnlacesChecker (broken links checker)
"""

from unittest.mock import Mock, patch

from calidad.base import QualityCheckResult
from calidad.enlaces import EnlacesChecker


class TestEnlacesChecker:
    """Tests for EnlacesChecker"""

    def test_get_check_type(self):
        """Test check type identifier"""
        checker = EnlacesChecker()
        assert checker.check_type == "broken_links"

    def test_instantiate_with_default_config(self):
        """Test creating checker with default configuration"""
        checker = EnlacesChecker()

        assert isinstance(checker.config, dict)
        assert checker.check_type == "broken_links"

    def test_instantiate_with_custom_config(self):
        """Test creating checker with custom configuration"""
        config = {"timeout": 5, "max_links": 20, "follow_redirects": False}
        checker = EnlacesChecker(config=config)

        assert checker.config["timeout"] == 5
        assert checker.config["max_links"] == 20
        assert checker.config["follow_redirects"] is False

    def test_check_invalid_url(self):
        """Test checking an invalid URL"""
        checker = EnlacesChecker()
        result = checker.check("not-a-valid-url")

        assert isinstance(result, QualityCheckResult)
        assert result.status == "error"
        assert result.score == 0
        assert "Invalid URL" in result.message
        assert result.issues_found == 0

    @patch("calidad.enlaces.requests.get")
    def test_check_fetch_failure(self, mock_get):
        """Test checking when URL fetch fails"""
        mock_get.side_effect = Exception("Connection error")

        checker = EnlacesChecker()
        result = checker.check("https://example.com")

        assert result.status == "error"
        assert result.score == 0
        assert "Failed to fetch URL" in result.message
        assert "Connection error" in result.details["error"]

    @patch("calidad.enlaces.requests.get")
    @patch("calidad.enlaces.requests.head")
    def test_check_no_links_found(self, mock_head, mock_get):
        """Test checking a page with no links"""
        # Mock HTML fetch
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.text = "<html><body><p>No links here</p></body></html>"
        mock_get.return_value = mock_response

        checker = EnlacesChecker()
        result = checker.check("https://example.com")

        assert result.status == "ok"
        assert result.score == 100
        assert result.issues_found == 0
        assert result.details["total_links"] == 0

    @patch("calidad.enlaces.requests.get")
    @patch("calidad.enlaces.requests.head")
    def test_check_all_links_ok(self, mock_head, mock_get):
        """Test checking a page where all links are working"""
        # Mock HTML fetch
        mock_get_response = Mock()
        mock_get_response.status_code = 200
        mock_get_response.text = """
        <html>
        <body>
            <a href="https://example.com/page1">Link 1</a>
            <a href="https://example.com/page2">Link 2</a>
            <img src="https://example.com/image.jpg">
        </body>
        </html>
        """
        mock_get.return_value = mock_get_response

        # Mock link validation (all OK)
        mock_head_response = Mock()
        mock_head_response.status_code = 200
        mock_head.return_value = mock_head_response

        checker = EnlacesChecker()
        result = checker.check("https://example.com")

        assert result.status == "ok"
        assert result.score == 100
        assert result.issues_found == 0
        assert result.details["total_links"] == 3
        assert len(result.details["broken_links"]) == 0

    @patch("calidad.enlaces.requests.get")
    @patch("calidad.enlaces.requests.head")
    def test_check_some_broken_links(self, mock_head, mock_get):
        """Test checking a page with some broken links"""
        # Mock HTML fetch
        mock_get_response = Mock()
        mock_get_response.status_code = 200
        mock_get_response.text = """
        <html>
        <body>
            <a href="https://example.com/ok1">OK Link</a>
            <a href="https://example.com/404">Broken Link</a>
            <a href="https://example.com/ok2">OK Link</a>
        </body>
        </html>
        """
        mock_get.return_value = mock_get_response

        # Mock link validation (1 broken out of 3)
        def mock_head_side_effect(url, *args, **kwargs):
            response = Mock()
            if "404" in url:
                response.status_code = 404
            else:
                response.status_code = 200
            return response

        mock_head.side_effect = mock_head_side_effect

        checker = EnlacesChecker()
        result = checker.check("https://example.com")

        assert result.status == "warning"  # 66% OK = warning
        assert result.score == 66  # 2/3 = 66%
        assert result.issues_found == 1
        assert result.details["total_links"] == 3
        assert len(result.details["broken_links"]) == 1
        assert "404" in result.details["broken_links"][0]["url"]

    @patch("calidad.enlaces.requests.get")
    @patch("calidad.enlaces.requests.head")
    def test_check_many_broken_links(self, mock_head, mock_get):
        """Test checking a page with many broken links"""
        # Mock HTML fetch
        mock_get_response = Mock()
        mock_get_response.status_code = 200
        mock_get_response.text = """
        <html>
        <body>
            <a href="https://example.com/404-1">Broken 1</a>
            <a href="https://example.com/404-2">Broken 2</a>
            <a href="https://example.com/404-3">Broken 3</a>
            <a href="https://example.com/ok">OK Link</a>
        </body>
        </html>
        """
        mock_get.return_value = mock_get_response

        # Mock link validation (3 broken out of 4)
        def mock_head_side_effect(url, *args, **kwargs):
            response = Mock()
            if "404" in url:
                response.status_code = 404
            else:
                response.status_code = 200
            return response

        mock_head.side_effect = mock_head_side_effect

        checker = EnlacesChecker()
        result = checker.check("https://example.com")

        assert result.status == "error"  # 25% OK = error
        assert result.score == 25  # 1/4 = 25%
        assert result.issues_found == 3
        assert len(result.details["broken_links"]) == 3

    @patch("calidad.enlaces.requests.get")
    @patch("calidad.enlaces.requests.head")
    def test_check_respects_max_links_config(self, mock_head, mock_get):
        """Test that checker respects max_links configuration"""
        # Mock HTML with many links
        links_html = "".join(
            [f'<a href="https://example.com/link{i}">Link {i}</a>' for i in range(150)]
        )
        mock_get_response = Mock()
        mock_get_response.status_code = 200
        mock_get_response.text = f"<html><body>{links_html}</body></html>"
        mock_get.return_value = mock_get_response

        # Mock all links as OK
        mock_head_response = Mock()
        mock_head_response.status_code = 200
        mock_head.return_value = mock_head_response

        # Set max_links to 50
        checker = EnlacesChecker(config={"max_links": 50})
        result = checker.check("https://example.com")

        # Should only check first 50 unique links
        assert result.details["total_links"] <= 50

    @patch("calidad.enlaces.requests.get")
    @patch("calidad.enlaces.requests.head")
    def test_check_handles_request_exceptions(self, mock_head, mock_get):
        """Test handling of request exceptions during link validation"""
        # Mock HTML fetch
        mock_get_response = Mock()
        mock_get_response.status_code = 200
        mock_get_response.text = """
        <html><body>
            <a href="https://example.com/timeout">Timeout Link</a>
        </body></html>
        """
        mock_get.return_value = mock_get_response

        # Mock link validation with exception
        import requests

        mock_head.side_effect = requests.RequestException("Timeout")

        checker = EnlacesChecker()
        result = checker.check("https://example.com")

        assert result.issues_found == 1
        assert len(result.details["broken_links"]) == 1
        assert result.details["broken_links"][0]["status_code"] == 0
        assert "Timeout" in result.details["broken_links"][0]["error"]

    @patch("calidad.enlaces.requests.get")
    def test_check_with_provided_html_content(self, mock_get):
        """Test checking with pre-fetched HTML content"""
        html_content = """
        <html><body>
            <a href="https://example.com/link">Link</a>
        </body></html>
        """

        # Mock link validation
        with patch("calidad.enlaces.requests.head") as mock_head:
            mock_head_response = Mock()
            mock_head_response.status_code = 200
            mock_head.return_value = mock_head_response

            checker = EnlacesChecker()
            result = checker.check("https://example.com", html_content=html_content)

            # Should NOT call requests.get since html_content was provided
            mock_get.assert_not_called()

            assert result.status == "ok"
            assert result.details["total_links"] == 1

    def test_check_ignores_non_http_links(self):
        """Test that checker ignores non-HTTP links"""
        html_content = """
        <html><body>
            <a href="https://example.com/http-link">HTTP Link</a>
            <a href="mailto:test@example.com">Email</a>
            <a href="/relative/path">Relative</a>
            <a href="javascript:void(0)">JavaScript</a>
        </body></html>
        """

        with patch("calidad.enlaces.requests.head") as mock_head:
            mock_head_response = Mock()
            mock_head_response.status_code = 200
            mock_head.return_value = mock_head_response

            checker = EnlacesChecker()
            result = checker.check("https://example.com", html_content=html_content)

            # Should only check the HTTP link
            assert result.details["total_links"] == 1
