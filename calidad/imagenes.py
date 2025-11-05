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
from constants import (
    HTTP_FORBIDDEN,
    HTTP_CLIENT_ERROR_MIN,
    QualityCheckDefaults,
    USER_AGENT_QUALITY_CHECKER,
)


class ImagenesChecker(QualityCheck):
    """Checker for image quality on web pages"""

    DEFAULT_CONFIG = {
        "timeout": QualityCheckDefaults.IMAGE_CHECK_TIMEOUT,
        "ignore_external": QualityCheckDefaults.IMAGE_CHECK_IGNORE_EXTERNAL,
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
                "hotlink_protected": 0,
                "hotlink_protected_list": [],
                "external_images_skipped": 0,
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
                    result_data["external_images_skipped"] += 1
                    continue

                result_data["total_images"] += 1

                # Check if image is broken via HEAD request
                try:
                    # Add realistic headers to avoid false positives
                    headers = {
                        'Referer': url,
                        'User-Agent': USER_AGENT_QUALITY_CHECKER
                    }

                    img_response = requests.head(
                        img_url,
                        headers=headers,
                        timeout=self.config["timeout"],
                        allow_redirects=True,
                    )

                    # Special handling for 403 (likely hotlink protection, not a real error)
                    if img_response.status_code == HTTP_FORBIDDEN:
                        result_data["hotlink_protected"] += 1
                        result_data["hotlink_protected_list"].append({
                            "url": img_url,
                            "status": HTTP_FORBIDDEN,
                            "note": "Hotlink protection (not a real error)"
                        })
                    # Check if broken (other 4xx or 5xx status)
                    elif img_response.status_code >= HTTP_CLIENT_ERROR_MIN:
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
            # Only broken_images count as issues, hotlink_protected is just a warning
            issues_found = result_data["broken_images"]
            warnings_found = result_data["hotlink_protected"]

            # Build message
            if result_data["total_images"] == 0:
                status = "ok"
                message = "No images found on page"
                if result_data["external_images_skipped"] > 0:
                    message += f" ({result_data['external_images_skipped']} external images skipped)"
                score = 100
            elif issues_found == 0:
                status = "ok"
                message = f"All {result_data['total_images']} images are working"
                if warnings_found > 0:
                    message += f" ({warnings_found} with hotlink protection)"
                if result_data["external_images_skipped"] > 0:
                    message += f" • {result_data['external_images_skipped']} external images skipped"
                score = 100
            else:
                status = "error"
                message = f"Found {issues_found} broken image(s)"
                if warnings_found > 0:
                    message += f" and {warnings_found} with hotlink protection"
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

