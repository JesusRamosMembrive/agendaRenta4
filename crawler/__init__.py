"""
Crawler Module
Stage 2 - Web Crawler Automatico
"""

from .config import CRAWLER_CONFIG, CRAWLER_CONFIG_FULL, validate_config
from .crawler import Crawler

__all__ = ["Crawler", "CRAWLER_CONFIG", "CRAWLER_CONFIG_FULL", "validate_config"]
