"""
Crawler Module
Stage 2 - Web Crawler Automatico
"""

from .crawler import Crawler
from .config import CRAWLER_CONFIG, CRAWLER_CONFIG_FULL, validate_config

__all__ = ['Crawler', 'CRAWLER_CONFIG', 'CRAWLER_CONFIG_FULL', 'validate_config']
