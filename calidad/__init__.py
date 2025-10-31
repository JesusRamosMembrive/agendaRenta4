"""
Quality Checks Module

This module provides a framework for running automated quality checks
on web content and URLs managed by the Agenda Renta4 system.

Available checkers:
- Image Quality Checker (Stage 3.1)
- Typo Checker (Stage 3.2)
- Broken Links Checker (Stage 3.3) - Migrated from crawler
- Accessibility Checker (Stage 3.4)
- SEO Checker (Stage 3.5)
- Performance Checker (Stage 3.6)
- Security Headers Checker (Stage 3.7)
- Content Freshness Checker (Stage 3.8)
"""

from calidad.base import QualityCheck, QualityCheckResult, QualityCheckRunner
from calidad.enlaces import EnlacesChecker
from calidad.imagenes import ImagenesChecker

__all__ = [
    "QualityCheck",
    "QualityCheckResult",
    "QualityCheckRunner",
    "EnlacesChecker",
    "ImagenesChecker",
]
