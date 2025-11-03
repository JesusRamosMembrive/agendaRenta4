"""
Broken Links Quality Checker

This checker validates that all links on a page are working correctly.
It migrates and extends the existing broken links detection from crawler.
"""

import time
from typing import Any, Dict, Optional

import requests
from bs4 import BeautifulSoup

from calidad.base import QualityCheck, QualityCheckResult


class EnlacesChecker(QualityCheck):
    """
    Checker that validates all links on a page are not broken.

    Configuration:
        timeout: Request timeout in seconds (default: 10)
        max_links: Maximum number of links to check (default: 100)
        follow_redirects: Whether to follow redirects (default: True)
    """

    def _get_check_type(self) -> str:
        return "broken_links"

    def check(self, url: str, html_content: Optional[str] = None) -> QualityCheckResult:
        """
        Check for broken links on the page.

        Args:
            url: URL to check
            html_content: Optional pre-fetched HTML content

        Returns:
            QualityCheckResult with broken links analysis
        """
        start_time = time.time()

        # Validate URL
        if not self.validate_url(url):
            return self.create_result(
                status="error",
                score=0,
                message="Invalid URL provided",
                details={"error": "URL must start with http:// or https://"},
                issues_found=0,
                execution_time_ms=int((time.time() - start_time) * 1000),
            )

        # Fetch HTML if not provided
        if html_content is None:
            try:
                timeout = self.config.get("timeout", 10)
                response = requests.get(url, timeout=timeout)
                response.raise_for_status()
                html_content = response.text
            except Exception as e:
                return self.create_result(
                    status="error",
                    score=0,
                    message=f"Failed to fetch URL: {str(e)}",
                    details={"error": str(e)},
                    issues_found=0,
                    execution_time_ms=int((time.time() - start_time) * 1000),
                )

        # Parse HTML and extract links
        try:
            soup = BeautifulSoup(html_content, "html.parser")
            links = []

            # Extract href links
            for tag in soup.find_all("a", href=True):
                href = tag["href"]
                if href.startswith("http"):
                    links.append(href)

            # Extract src links (images, scripts, etc.)
            for tag in soup.find_all(["img", "script", "link"], src=True):
                src = tag.get("src", "")
                if src and src.startswith("http"):
                    links.append(src)

            # Limit number of links to check
            max_links = self.config.get("max_links", 100)
            links = list(set(links))[:max_links]  # Unique links only

        except Exception as e:
            return self.create_result(
                status="error",
                score=0,
                message=f"Failed to parse HTML: {str(e)}",
                details={"error": str(e)},
                issues_found=0,
                execution_time_ms=int((time.time() - start_time) * 1000),
            )

        # Check each link
        broken_links = []
        timeout = self.config.get("timeout", 10)
        follow_redirects = self.config.get("follow_redirects", True)

        for link in links:
            try:
                response = requests.head(
                    link, timeout=timeout, allow_redirects=follow_redirects
                )
                if response.status_code >= 400:
                    broken_links.append(
                        {
                            "url": link,
                            "status_code": response.status_code,
                            "error": f"HTTP {response.status_code}",
                        }
                    )
            except requests.RequestException as e:
                broken_links.append({"url": link, "status_code": 0, "error": str(e)})

        # Calculate score
        total_links = len(links)
        broken_count = len(broken_links)
        if total_links == 0:
            score = 100
        else:
            score = int(((total_links - broken_count) / total_links) * 100)

        status = self.determine_status(score)

        # Create result
        execution_time_ms = int((time.time() - start_time) * 1000)

        return self.create_result(
            status=status,
            score=score,
            message=f"Found {broken_count} broken links out of {total_links} checked",
            details={
                "total_links": total_links,
                "broken_links": broken_links,
                "checked_links": links,
            },
            issues_found=broken_count,
            execution_time_ms=execution_time_ms,
        )
