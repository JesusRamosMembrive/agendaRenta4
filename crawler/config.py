#!/usr/bin/env python3
"""
Crawler Configuration
Stage 2 - Phase 2.1 (MVP)
"""

from constants import USER_AGENT_CRAWLER

# Base configuration shared by all crawler variants
_BASE_CRAWLER_CONFIG = {
    # URLs
    "root_url": "https://www.r4.com",
    "allowed_domains": ["www.r4.com", "r4.com"],
    # Limits
    "max_depth": 10,  # Deep crawl (10 levels)
    "max_urls": None,  # NO LIMIT - discover all URLs
    "timeout": 10,  # seconds per request
    # Rate limiting
    "max_retries": 3,
    # Behavior
    "follow_redirects": True,
    "respect_robots_txt": True,
    "user_agent": USER_AGENT_CRAWLER,
    # Filters - ignore these patterns
    "ignore_patterns": [
        r"/static/",
        r"/media/",
        r"/assets/",
        r"\.pdf$",
        r"\.jpg$",
        r"\.jpeg$",
        r"\.png$",
        r"\.gif$",
        r"\.svg$",
        r"\.css$",
        r"\.js$",
        r"\.zip$",
        r"\.tar\.gz$",
        r"#",  # Anchors
        r"javascript:",  # JavaScript links
        r"mailto:",  # Email links
        r"tel:",  # Phone links
    ],
    # Alertas (for Phase 2.3)
    "alert_threshold_broken_links": 10,
    "alert_threshold_new_urls": 50,
}

# Standard configuration (1 second between requests)
CRAWLER_CONFIG = {
    **_BASE_CRAWLER_CONFIG,
    "delay_between_requests": 1.0,  # 1 second between requests
}

# Full crawl configuration (faster: 0.5s between requests, longer timeout)
CRAWLER_CONFIG_FULL = {
    **_BASE_CRAWLER_CONFIG,
    "delay_between_requests": 0.5,  # 0.5 seconds = 2 requests/second
    "timeout": 15,  # seconds per request (more time for slow pages)
}


# Helper function to validate config
def validate_config(config=CRAWLER_CONFIG):
    """
    Validate crawler configuration.

    Raises:
        ValueError: If configuration is invalid
    """
    required_keys = ["root_url", "allowed_domains", "max_depth", "timeout"]

    for key in required_keys:
        if key not in config:
            raise ValueError(f"Missing required config key: {key}")

    if config["max_depth"] < 0:
        raise ValueError("max_depth must be >= 0")

    if config["timeout"] <= 0:
        raise ValueError("timeout must be > 0")

    if config["delay_between_requests"] < 0:
        raise ValueError("delay_between_requests must be >= 0")

    return True
