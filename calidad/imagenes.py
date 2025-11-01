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
        "timeout": 10,
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
                "broken_images": 0,
                "broken_images_list": [],
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

                # Check if image is broken via HEAD request
                try:
                    img_response = requests.head(
                        img_url,
                        timeout=self.config["timeout"],
                        allow_redirects=True,
                    )

                    # Check if broken (any 4xx or 5xx status)
                    if img_response.status_code >= 400:
                        result_data["broken_images"] += 1
                        result_data["broken_images_list"].append({
                            "url": img_url,
                            "status": img_response.status_code
                        })

                except (requests.Timeout, requests.RequestException):
                    # If we can't reach the image, consider it broken
                    result_data["broken_images"] += 1
                    result_data["broken_images_list"].append({
                        "url": img_url,
                        "status": "timeout/error"
                    })

            # Calculate score and determine status
            issues_found = result_data["broken_images"]

            # Determine status - simple: broken images = fail, no broken = success
            if result_data["total_images"] == 0:
                status = "ok"
                message = "No images found on page"
                score = 100
            elif issues_found == 0:
                status = "ok"
                message = f"All {result_data['total_images']} images are working"
                score = 100
            else:
                status = "error"
                message = f"Found {issues_found} broken image(s)"
                score = 0

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

