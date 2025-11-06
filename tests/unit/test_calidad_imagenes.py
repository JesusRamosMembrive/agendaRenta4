"""
Unit tests for calidad/imagenes.py

Tests the ImagenesChecker (image quality checker)

TDD Approach: Tests written BEFORE implementation
"""

from unittest.mock import Mock, patch

from calidad.base import QualityCheckResult
from calidad.imagenes import ImagenesChecker


class TestImagenesChecker:
    """Tests for ImagenesChecker"""

    def test_get_check_type(self):
        """Test check type identifier"""
        checker = ImagenesChecker()
        assert checker.check_type == "image_quality"

    def test_instantiate_with_default_config(self):
        """Test creating checker with default configuration"""
        checker = ImagenesChecker()

        assert isinstance(checker.config, dict)
        assert checker.check_type == "image_quality"

    def test_instantiate_with_custom_config(self):
        """Test creating checker with custom configuration"""
        config = {
            "max_size_mb": 2.0,
            "timeout": 5,
            "check_format": True,
            "check_alt_text": True,
        }
        checker = ImagenesChecker(config=config)

        assert checker.config["max_size_mb"] == 2.0
        assert checker.config["timeout"] == 5
        assert checker.config["check_format"] is True

    def test_check_invalid_url(self):
        """Test checking an invalid URL"""
        checker = ImagenesChecker()
        result = checker.check("not-a-valid-url")

        assert isinstance(result, QualityCheckResult)
        assert result.status == "error"
        assert result.score == 0
        assert "Invalid URL" in result.message

    @patch("calidad.imagenes.requests.get")
    def test_check_fetch_failure(self, mock_get):
        """Test checking when URL fetch fails"""
        mock_get.side_effect = Exception("Connection error")

        checker = ImagenesChecker()
        result = checker.check("https://example.com")

        assert result.status == "error"
        assert result.score == 0
        assert "Failed to fetch URL" in result.message

    @patch("calidad.imagenes.requests.get")
    def test_check_no_images_found(self, mock_get):
        """Test checking a page with no images"""
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.text = "<html><body><p>No images here</p></body></html>"
        mock_get.return_value = mock_response

        checker = ImagenesChecker()
        result = checker.check("https://example.com")

        assert result.status == "ok"
        assert result.score == 100
        assert result.issues_found == 0
        assert result.details["total_images"] == 0

    @patch("calidad.imagenes.requests.head")
    @patch("calidad.imagenes.requests.get")
    def test_check_images_with_alt_text(self, mock_get, mock_head):
        """Test checking images that have alt text"""
        html = """
        <html><body>
            <img src="https://example.com/img1.jpg" alt="Description 1">
            <img src="https://example.com/img2.png" alt="Description 2">
        </body></html>
        """
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.text = html
        mock_get.return_value = mock_response

        # Mock HEAD requests for images
        mock_head.return_value = Mock(
            status_code=200, headers={"content-length": "10000"}
        )

        checker = ImagenesChecker()
        result = checker.check("https://example.com")

        assert result.status == "ok"
        assert result.score == 100
        assert result.details["total_images"] == 2
        assert result.details["images_without_alt"] == 0

    @patch("calidad.imagenes.requests.head")
    @patch("calidad.imagenes.requests.get")
    def test_check_images_without_alt_text(self, mock_get, mock_head):
        """Test checking images missing alt text"""
        html = """
        <html><body>
            <img src="https://example.com/img1.jpg" alt="Good">
            <img src="https://example.com/img2.png">
            <img src="https://example.com/img3.gif" alt="">
        </body></html>
        """
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.text = html
        mock_get.return_value = mock_response

        # Mock HEAD requests for images
        mock_head.return_value = Mock(
            status_code=200, headers={"content-length": "10000"}
        )

        checker = ImagenesChecker()
        result = checker.check("https://example.com")

        assert result.status == "warning"  # Some images without alt
        assert result.details["total_images"] == 3
        assert result.details["images_without_alt"] == 2
        assert result.issues_found == 2

    @patch("calidad.imagenes.requests.head")
    @patch("calidad.imagenes.requests.get")
    def test_check_image_size_ok(self, mock_get, mock_head):
        """Test checking image sizes (under limit)"""
        html = (
            '<html><body><img src="https://example.com/img.jpg" alt="OK"></body></html>'
        )
        mock_get.return_value = Mock(status_code=200, text=html)

        # Mock image HEAD request (size check)
        mock_head.return_value = Mock(
            status_code=200,
            headers={"content-length": "500000"},  # 500KB
        )

        checker = ImagenesChecker(config={"max_size_mb": 1.0})
        result = checker.check("https://example.com")

        assert result.details["oversized_images"] == 0

    @patch("calidad.imagenes.requests.head")
    @patch("calidad.imagenes.requests.get")
    def test_check_image_size_too_large(self, mock_get, mock_head):
        """Test checking oversized images"""
        html = '<html><body><img src="https://example.com/large.jpg" alt="Big"></body></html>'
        mock_get.return_value = Mock(status_code=200, text=html)

        # Mock large image (2MB)
        mock_head.return_value = Mock(
            status_code=200, headers={"content-length": str(2 * 1024 * 1024)}
        )

        checker = ImagenesChecker(config={"max_size_mb": 1.0})
        result = checker.check("https://example.com")

        assert result.status == "warning"
        assert result.details["oversized_images"] == 1
        assert result.issues_found >= 1

    @patch("calidad.imagenes.requests.head")
    @patch("calidad.imagenes.requests.get")
    def test_check_broken_images(self, mock_get, mock_head):
        """Test detecting broken images (404)"""
        html = """
        <html><body>
            <img src="https://example.com/ok.jpg" alt="OK">
            <img src="https://example.com/404.jpg" alt="Broken">
        </body></html>
        """
        mock_get.return_value = Mock(status_code=200, text=html)

        def head_side_effect(url, *args, **kwargs):
            if "404" in url:
                response = Mock()
                response.status_code = 404
                return response
            return Mock(status_code=200, headers={"content-length": "10000"})

        mock_head.side_effect = head_side_effect

        checker = ImagenesChecker()
        result = checker.check("https://example.com")

        assert result.status == "warning"
        assert result.details["broken_images"] == 1
        assert result.issues_found >= 1

    @patch("calidad.imagenes.requests.head")
    @patch("calidad.imagenes.requests.get")
    def test_check_image_format_webp_is_optimal(self, mock_get, mock_head):
        """Test that WebP format is considered optimal"""
        html = '<html><body><img src="https://example.com/img.webp" alt="Modern"></body></html>'
        mock_get.return_value = Mock(status_code=200, text=html)
        mock_head.return_value = Mock(
            status_code=200, headers={"content-length": "10000"}
        )

        checker = ImagenesChecker(config={"check_format": True})
        result = checker.check("https://example.com")

        # WebP should not be flagged as suboptimal
        assert result.details.get("suboptimal_format", 0) == 0

    @patch("calidad.imagenes.requests.head")
    @patch("calidad.imagenes.requests.get")
    def test_check_image_format_jpg_is_suboptimal(self, mock_get, mock_head):
        """Test that JPG/PNG are flagged as suboptimal format"""
        html = """
        <html><body>
            <img src="https://example.com/img1.jpg" alt="Old format">
            <img src="https://example.com/img2.png" alt="Also old">
        </body></html>
        """
        mock_get.return_value = Mock(status_code=200, text=html)
        mock_head.return_value = Mock(
            status_code=200, headers={"content-length": "10000"}
        )

        checker = ImagenesChecker(config={"check_format": True})
        result = checker.check("https://example.com")

        # JPG and PNG should be flagged as suboptimal
        assert result.details.get("suboptimal_format", 0) == 2

    @patch("calidad.imagenes.requests.get")
    def test_check_with_provided_html_content(self, mock_get):
        """Test checking with pre-fetched HTML content"""
        html = (
            '<html><body><img src="https://example.com/img.jpg" alt="OK"></body></html>'
        )

        checker = ImagenesChecker()
        result = checker.check("https://example.com", html_content=html)

        # Should NOT call requests.get since html_content was provided
        mock_get.assert_not_called()
        assert result.details["total_images"] == 1

    @patch("calidad.imagenes.requests.get")
    def test_check_ignores_external_images_option(self, mock_get):
        """Test option to ignore external images (different domain)"""
        html = """
        <html><body>
            <img src="https://example.com/local.jpg" alt="Local">
            <img src="https://external.com/remote.jpg" alt="External">
        </body></html>
        """
        mock_get.return_value = Mock(status_code=200, text=html)

        checker = ImagenesChecker(config={"ignore_external": True})
        result = checker.check("https://example.com")

        # Should only check local domain images
        assert result.details["total_images"] == 1

    @patch("calidad.imagenes.requests.head")
    @patch("calidad.imagenes.requests.get")
    def test_check_handles_request_timeout(self, mock_get, mock_head):
        """Test handling of timeout when checking images"""
        html = '<html><body><img src="https://example.com/slow.jpg" alt="Slow"></body></html>'
        mock_get.return_value = Mock(status_code=200, text=html)

        import requests

        mock_head.side_effect = requests.Timeout("Timeout")

        checker = ImagenesChecker()
        result = checker.check("https://example.com")

        # Should handle timeout gracefully
        assert result.status in ["ok", "warning"]
        assert (
            "timeout" in str(result.details).lower()
            or result.details.get("check_errors", 0) > 0
        )

    @patch("calidad.imagenes.requests.get")
    def test_check_multiple_issues(self, mock_get):
        """Test detecting multiple issues at once"""
        html = """
        <html><body>
            <img src="https://example.com/good.webp" alt="Perfect">
            <img src="https://example.com/no-alt.jpg">
            <img src="https://example.com/old-format.png" alt="Suboptimal">
        </body></html>
        """
        mock_get.return_value = Mock(status_code=200, text=html)

        with patch("calidad.imagenes.requests.head") as mock_head:
            mock_head.return_value = Mock(
                status_code=200, headers={"content-length": "10000"}
            )

            checker = ImagenesChecker(config={"check_format": True})
            result = checker.check("https://example.com")

            # Should detect: 1 missing alt + 2 suboptimal formats
            assert result.issues_found >= 2
            assert result.details["images_without_alt"] >= 1
            assert result.details.get("suboptimal_format", 0) >= 1

    def test_score_calculation_logic(self):
        """Test that score is calculated correctly based on issues"""
        checker = ImagenesChecker()

        # Perfect score: no images
        result_data = {
            "total_images": 0,
            "images_without_alt": 0,
            "broken_images": 0,
            "oversized_images": 0,
        }
        score = checker._calculate_score(result_data)
        assert score == 100

        # All images have issues
        result_data = {
            "total_images": 10,
            "images_without_alt": 10,
            "broken_images": 0,
            "oversized_images": 0,
        }
        score = checker._calculate_score(result_data)
        assert score < 100

        # Half images have issues
        result_data = {
            "total_images": 10,
            "images_without_alt": 5,
            "broken_images": 0,
            "oversized_images": 0,
        }
        score = checker._calculate_score(result_data)
        assert 40 <= score <= 60  # Should be around 50%
