"""
Spell checker quality check module.

Uses pyspellchecker to detect spelling errors in web page content.
"""

import logging
import re
import time
from typing import Optional, Dict, Any, List
from urllib.parse import urlparse

import requests
from bs4 import BeautifulSoup
from spellchecker import SpellChecker as PySpellChecker

from calidad.base import QualityCheck, QualityCheckResult
from calidad.whitelist_terms import is_whitelisted
from constants import QualityCheckDefaults

logger = logging.getLogger(__name__)


class SpellChecker(QualityCheck):
    """
    Checks for spelling errors in page content using pyspellchecker.

    This checker:
    - Extracts visible text from HTML
    - Filters out technical elements (code, scripts, styles)
    - Excludes URLs, emails, numbers, and short words
    - Uses whitelist for domain-specific terms
    - Provides detailed error reports with context
    """

    DEFAULT_CONFIG = {
        "timeout": QualityCheckDefaults.SPELL_CHECK_TIMEOUT,
        "max_text_length": QualityCheckDefaults.SPELL_CHECK_MAX_TEXT_LENGTH,
        "min_word_length": QualityCheckDefaults.SPELL_CHECK_MIN_WORD_LENGTH,
        "language": "es"  # Spanish
    }

    # Regex patterns for filtering
    URL_PATTERN = re.compile(
        r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+'
    )
    EMAIL_PATTERN = re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
    NUMBER_PATTERN = re.compile(r'\b\d+([.,]\d+)*\b')

    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """Initialize spell checker with configuration."""
        merged_config = {**self.DEFAULT_CONFIG}
        if config:
            merged_config.update(config)

        super().__init__(merged_config)

        # Initialize Spanish spell checker
        logger.debug("Initializing Spanish spell checker with pyspellchecker...")
        self.spell = PySpellChecker(language='es')

        # Add common Spanish words that might be missing from dictionary
        common_words = {
            # Plurals and conjugations
            'servicios', 'clientes', 'fondos', 'disponibles', 'oportunidades',
            'tenemos', 'ofrecemos', 'contáctenos', 'también', 'están', 'nuestros',
            'podrá', 'podrás', 'pueden', 'puedes', 'deberá', 'deberás',
            # Common business/finance terms
            'inversión', 'inversiones', 'inversionistas', 'mercados', 'evolución', 'evoluciona',
            'acciones', 'bonos', 'divisas', 'bróker', 'trading', 'información',
            'financiero', 'financiera', 'financieros', 'financieras',
            'rentabilidad', 'rentable', 'cotización', 'operaciones', 'constantemente',
            # Web/tech common words
            'online', 'web', 'app', 'click', 'email', 'página', 'páginas',
            'usuario', 'usuarios', 'contraseña', 'descargar', 'archivo', 'archivos',
            # Common verbs
            'registrarse', 'iniciar', 'acceder', 'consultar', 'enviar',
            'permite', 'ofrece', 'incluye', 'proporciona', 'garantiza'
        }
        self.spell.word_frequency.load_words(common_words)

        logger.debug("Spell checker initialized with extended Spanish dictionary")

    def _get_check_type(self) -> str:
        """Return the check type identifier."""
        return "spell_check"

    def check(self, url: str, html_content: Optional[str] = None) -> QualityCheckResult:
        """
        Check spelling in a URL's content.

        Args:
            url: URL to check
            html_content: Optional pre-fetched HTML content

        Returns:
            QualityCheckResult with spelling analysis
        """
        start_time = time.time()

        try:
            # 1. Validate URL
            parsed = urlparse(url)
            if not parsed.scheme or not parsed.netloc:
                return self.create_result(
                    status="error",
                    score=0,
                    message="Invalid URL format",
                    details={"error": "URL must have scheme and netloc"},
                    issues_found=0,
                    execution_time_ms=int((time.time() - start_time) * 1000)
                )

            # 2. Fetch HTML if not provided
            if html_content is None:
                timeout = self.config.get("timeout", 10)
                headers = {
                    'User-Agent': 'Mozilla/5.0 (compatible; AgendaRenta4/1.0; +https://www.r4.com)'
                }
                response = requests.get(url, timeout=timeout, headers=headers)
                response.raise_for_status()
                html_content = response.text

            # 3. Extract text from HTML
            text = self._extract_text(html_content)

            # 4. Limit text length if needed
            max_length = self.config.get("max_text_length", 50000)
            if len(text) > max_length:
                text = text[:max_length]

            # 5. Check spelling
            spelling_errors = self._check_spelling(text)

            # 6. Calculate score
            total_words = self._count_words(text)
            error_count = len(spelling_errors)

            if total_words == 0:
                score = 100
                message = "No text content found to analyze"
            else:
                # Score: 100 - (errors per 100 words)
                # Example: 5 errors in 100 words = 95 score
                #          10 errors in 100 words = 90 score
                error_rate = (error_count / total_words) * 100
                score = max(0, int(100 - error_rate))

                if error_count == 0:
                    message = f"No spelling errors found ({total_words} words checked)"
                else:
                    message = f"Found {error_count} spelling error{'s' if error_count != 1 else ''} in {total_words} words"

            status = self.determine_status(score)

            # 7. Return result
            return self.create_result(
                status=status,
                score=score,
                message=message,
                details={
                    "total_words": total_words,
                    "spelling_errors": spelling_errors,
                    "language": self.config["language"],
                    "text_length": len(text),
                    "max_text_length": max_length,
                },
                issues_found=error_count,
                execution_time_ms=int((time.time() - start_time) * 1000)
            )

        except requests.RequestException as e:
            return self.create_result(
                status="error",
                score=0,
                message=f"Failed to fetch URL: {str(e)}",
                details={"error": str(e), "error_type": "request_error"},
                issues_found=0,
                execution_time_ms=int((time.time() - start_time) * 1000)
            )
        except Exception as e:
            return self.create_result(
                status="error",
                score=0,
                message=f"Spell check failed: {str(e)}",
                details={"error": str(e), "error_type": "check_error"},
                issues_found=0,
                execution_time_ms=int((time.time() - start_time) * 1000)
            )

    def _extract_text(self, html_content: str) -> str:
        """
        Extract visible text from HTML, excluding technical elements.

        Args:
            html_content: HTML content

        Returns:
            Extracted text string
        """
        soup = BeautifulSoup(html_content, "html.parser")

        # Remove technical elements
        for tag in soup(['script', 'style', 'code', 'pre', 'kbd', 'var', 'samp']):
            tag.decompose()

        # Get text
        text = soup.get_text(separator=' ', strip=True)

        # Clean up multiple spaces
        text = re.sub(r'\s+', ' ', text)

        return text

    def _count_words(self, text: str) -> int:
        """
        Count meaningful words in text.

        Args:
            text: Text to count words in

        Returns:
            Number of words
        """
        # Split by whitespace and count words that meet minimum length
        min_length = self.config.get("min_word_length", 3)
        words = text.split()
        meaningful_words = [
            w for w in words
            if len(w) >= min_length and w.isalpha()
        ]
        return len(meaningful_words)

    def _check_spelling(self, text: str) -> List[Dict[str, Any]]:
        """
        Check spelling in text using pyspellchecker.

        Args:
            text: Text to check

        Returns:
            List of spelling errors with context
        """
        spelling_errors = []
        min_length = self.config.get("min_word_length", 3)

        # Extract words from text
        words = text.split()

        # Filter and prepare words for spell checking
        words_to_check = []
        word_positions = {}  # Map word index to original position in text

        for i, word in enumerate(words):
            # Clean word (remove punctuation from edges)
            cleaned_word = word.strip('.,;:!?¿¡()[]{}"\'-').lower()

            # Skip if:
            # - Not alphabetic
            # - Too short
            # - Is URL, email, or number
            # - Is whitelisted
            if not cleaned_word:
                continue
            if not cleaned_word.isalpha():
                continue
            if len(cleaned_word) < min_length:
                continue
            if self.URL_PATTERN.match(word) or self.EMAIL_PATTERN.match(word):
                continue
            if self.NUMBER_PATTERN.match(cleaned_word):
                continue
            if is_whitelisted(cleaned_word):
                continue

            # Store position mapping
            word_positions[len(words_to_check)] = i
            words_to_check.append(cleaned_word)

        # Find misspelled words
        misspelled = self.spell.unknown(words_to_check)

        # Build error list with context
        for misspelled_word in misspelled:
            # Find all positions of this misspelled word
            for check_idx, word in enumerate(words_to_check):
                if word == misspelled_word:
                    original_pos = word_positions[check_idx]

                    # Get context (3 words before and after)
                    start_idx = max(0, original_pos - 3)
                    end_idx = min(len(words), original_pos + 4)
                    context_words = words[start_idx:end_idx]
                    context = " ".join(context_words)

                    # Highlight the error word in context
                    # Use the original word form (with capitalization)
                    original_word = words[original_pos].strip('.,;:!?¿¡()[]{}"\'-')
                    context = context.replace(original_word, f"**{original_word}**")

                    # Get full sentence if possible (look for . ! ?)
                    sentence = self._get_sentence(words, original_pos)

                    # Get suggestions (top 3)
                    candidates = self.spell.candidates(misspelled_word)
                    suggestions = list(candidates)[:3] if candidates else []

                    spelling_errors.append({
                        "word": original_word,
                        "context": context,
                        "sentence": sentence if sentence != context else None,
                        "suggestions": suggestions,
                        "position": original_pos
                    })

                    # Only report each unique misspelling once per document
                    break

        return spelling_errors

    def _get_sentence(self, words: List[str], word_pos: int) -> str:
        """
        Extract the full sentence containing the word at word_pos.

        Args:
            words: List of words
            word_pos: Position of target word

        Returns:
            Sentence string
        """
        # Find sentence start (look backwards for . ! ?)
        start_idx = word_pos
        for i in range(word_pos - 1, -1, -1):
            if any(punct in words[i] for punct in ['.', '!', '?']):
                start_idx = i + 1
                break
            if i == 0:
                start_idx = 0

        # Find sentence end (look forwards for . ! ?)
        end_idx = word_pos
        for i in range(word_pos + 1, len(words)):
            if any(punct in words[i] for punct in ['.', '!', '?']):
                end_idx = i + 1
                break
            if i == len(words) - 1:
                end_idx = len(words)

        # Extract sentence
        sentence_words = words[start_idx:end_idx]
        return " ".join(sentence_words)
