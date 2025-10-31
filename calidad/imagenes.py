"""
Image Quality Checker

Checks images on a webpage for:
- Alt text presence
- File size (oversized images)
- Format optimization (WebP vs JPG/PNG)
- Broken images (404)
"""

import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
from typing import Optional, Dict, Any
from calidad.base import QualityCheck, QualityCheckResult


class ImagenesChecker(QualityCheck):
    """Checker for image quality on web pages"""

    DEFAULT_CONFIG = {
        "max_size_mb": 1.0,
        "timeout": 10,
        "check_format": False,  # Disabled by default, can be enabled
        "check_alt_text": True,
        "ignore_external": False,
    }

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize checker with optional configuration"""
        merged_config = {**self.DEFAULT_CONFIG}
        if config:
            merged_config.update(config)
        super().__init__(merged_config)

    def _get_check_type(self) -> str:
        """Return the check type identifier"""
        return "image_quality"

    def check(self, url: str, html_content: Optional[str] = None) -> QualityCheckResult:
        """
        Check image quality for a given URL

        Args:
            url: URL to check
            html_content: Optional pre-fetched HTML content

        Returns:
            QualityCheckResult with image quality details
        """
        import time
        start_time = time.time()

        # Validate URL
        if not self.validate_url(url):
            execution_time = int((time.time() - start_time) * 1000)
            return self.create_result(
                status="error",
                score=0,
                message="Invalid URL format",
                details={"error": "Invalid URL"},
                issues_found=0,
                execution_time_ms=execution_time,
            )

        try:
            # Fetch HTML if not provided
            if html_content is None:
                response = requests.get(url, timeout=self.config["timeout"])
                response.raise_for_status()
                html_content = response.text

            # Parse HTML
            soup = BeautifulSoup(html_content, "html.parser")
            images = soup.find_all("img")

            # Initialize result data
            result_data = {
                "total_images": 0,
                "images_without_alt": 0,
                "oversized_images": 0,
                "broken_images": 0,
                "suboptimal_format": 0,
                "check_errors": 0,
            }

            # Parse base domain for external image filtering
            parsed_url = urlparse(url)
            base_domain = parsed_url.netloc

            # Check each image
            for img in images:
                img_src = img.get("src")
                if not img_src:
                    continue

                # Resolve relative URLs
                img_url = urljoin(url, img_src)
                img_domain = urlparse(img_url).netloc

                # Skip external images if configured
                if self.config["ignore_external"] and img_domain != base_domain:
                    continue

                result_data["total_images"] += 1

                # Check alt text
                if self.config["check_alt_text"]:
                    alt_text = img.get("alt", "").strip()
                    if not alt_text:
                        result_data["images_without_alt"] += 1

                # Check image properties via HEAD request
                try:
                    img_response = requests.head(
                        img_url,
                        timeout=self.config["timeout"],
                        allow_redirects=True,
                    )

                    # Check if broken
                    if img_response.status_code == 404:
                        result_data["broken_images"] += 1
                        continue
                    elif img_response.status_code >= 400:
                        result_data["broken_images"] += 1
                        continue

                    # Check file size
                    content_length = img_response.headers.get("content-length")
                    if content_length:
                        size_mb = int(content_length) / (1024 * 1024)
                        if size_mb > self.config["max_size_mb"]:
                            result_data["oversized_images"] += 1

                    # Check format
                    if self.config["check_format"]:
                        img_ext = img_url.lower().split(".")[-1].split("?")[0]
                        if img_ext in ["jpg", "jpeg", "png", "gif"]:
                            result_data["suboptimal_format"] += 1

                except requests.Timeout:
                    result_data["check_errors"] += 1
                except Exception:
                    result_data["check_errors"] += 1

            # Calculate score and determine status
            score = self._calculate_score(result_data)
            issues_found = (
                result_data["images_without_alt"]
                + result_data["oversized_images"]
                + result_data["broken_images"]
                + result_data["suboptimal_format"]
            )

            # Determine status
            if issues_found == 0:
                status = "ok"
                message = f"All {result_data['total_images']} images are optimized"
            elif score >= 70:
                status = "warning"
                message = f"Found {issues_found} image quality issues"
            else:
                status = "error"
                message = f"Found {issues_found} critical image quality issues"

            # Handle no images case
            if result_data["total_images"] == 0:
                status = "ok"
                message = "No images found on page"
                score = 100

            execution_time = int((time.time() - start_time) * 1000)
            return self.create_result(
                status=status,
                score=score,
                message=message,
                details=result_data,
                issues_found=issues_found,
                execution_time_ms=execution_time,
            )

        except requests.Timeout as e:
            execution_time = int((time.time() - start_time) * 1000)
            return self.create_result(
                status="error",
                score=0,
                message=f"Failed to fetch URL: Request timeout",
                details={"error": "timeout"},
                issues_found=0,
                execution_time_ms=execution_time,
            )
        except requests.RequestException as e:
            execution_time = int((time.time() - start_time) * 1000)
            return self.create_result(
                status="error",
                score=0,
                message=f"Failed to fetch URL: {str(e)}",
                details={"error": str(e)},
                issues_found=0,
                execution_time_ms=execution_time,
            )
        except Exception as e:
            execution_time = int((time.time() - start_time) * 1000)
            return self.create_result(
                status="error",
                score=0,
                message=f"Failed to fetch URL: {str(e)}",
                details={"error": str(e)},
                issues_found=0,
                execution_time_ms=execution_time,
            )

    def _calculate_score(self, result_data: Dict[str, int]) -> int:
        """
        Calculate quality score based on result data

        Args:
            result_data: Dictionary with check results

        Returns:
            Score from 0-100
        """
        total_images = result_data.get("total_images", 0)

        # Perfect score if no images
        if total_images == 0:
            return 100

        # Calculate penalty for each issue type
        penalties = 0

        # Alt text missing: -10 points per image
        penalties += result_data.get("images_without_alt", 0) * 10

        # Oversized images: -15 points per image
        penalties += result_data.get("oversized_images", 0) * 15

        # Broken images: -20 points per image
        penalties += result_data.get("broken_images", 0) * 20

        # Suboptimal format: -5 points per image
        penalties += result_data.get("suboptimal_format", 0) * 5

        # Calculate score (minimum 0)
        score = max(0, 100 - penalties)

        return score
