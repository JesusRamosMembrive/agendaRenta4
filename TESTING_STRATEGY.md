# Testing Strategy - Agenda Renta4

## Overview

This document outlines our testing strategy for the Agenda Renta4 project. We follow a Test-Driven Development (TDD) approach after major refactorings to ensure code quality and prevent regressions.

## Test Structure

```
tests/
├── conftest.py                  # Shared fixtures and configuration
├── unit/                        # Fast, isolated unit tests
│   ├── test_calidad_base.py    # Tests for calidad/base.py (20 tests)
│   └── test_calidad_enlaces.py # Tests for calidad/enlaces.py (13 tests)
├── integration/                 # Tests with database and external services
│   └── test_quality_checks_db.py # Database integration tests (10 tests)
└── fixtures/                    # Test data and mock files
```

## Testing Philosophy

### When to Write Tests

1. **After Major Refactorings** ✅ (Current situation)
   - When extracting modules or blueprints
   - After significant architectural changes
   - Before adding new features to refactored code

2. **Before Adding New Features** (Upcoming)
   - Write tests for new quality checkers before implementation
   - TDD approach for Phase 3.1+ (Image Quality, Typo, etc.)

3. **When Fixing Bugs**
   - Write failing test that reproduces the bug
   - Fix the bug until test passes
   - Prevents regression

### Test Categories

#### Unit Tests (`tests/unit/`)
- **Purpose**: Test individual functions/classes in isolation
- **Speed**: Very fast (<1s for all tests)
- **Coverage Goal**: >90%
- **Mock External Dependencies**: Yes (network, database, filesystem)
- **Run Frequency**: Every commit

**Current Unit Tests:**
- ✅ `test_calidad_base.py` - 20 tests for base classes
  - QualityCheckResult dataclass
  - QualityCheck abstract base class
  - QualityCheckRunner orchestrator
- ✅ `test_calidad_enlaces.py` - 13 tests for broken links checker
  - URL validation
  - Link extraction from HTML
  - Broken link detection
  - Error handling

#### Integration Tests (`tests/integration/`)
- **Purpose**: Test interactions between components
- **Speed**: Slower (database transactions)
- **Coverage Goal**: Critical paths covered
- **Mock External Dependencies**: Partially (keep database real)
- **Run Frequency**: Before merging to main branch

**Current Integration Tests:**
- ✅ `test_quality_checks_db.py` - 10 tests for database operations
  - CRUD operations on quality_checks table
  - Complex queries (JOIN, GROUP BY, DISTINCT ON)
  - JSONB field operations
  - Constraint validation
  - CASCADE delete behavior

## Coverage Goals

| Module | Coverage Target | Current | Status |
|--------|----------------|---------|--------|
| `calidad/base.py` | >90% | 97% | ✅ Excellent |
| `calidad/enlaces.py` | >90% | 96% | ✅ Excellent |
| `calidad/__init__.py` | 100% | 100% | ✅ Perfect |
| **Overall calidad/** | >90% | **97%** | ✅ Excellent |

**Future modules:**
- `calidad/imagenes.py` - Target: >90%
- `calidad/typo.py` - Target: >90%
- `crawler/routes.py` - Target: >70% (integration tests)
- `config/routes.py` - Target: >70% (integration tests)

## Test Execution

### Running Tests

```bash
# Run all tests
pytest

# Run only unit tests
pytest tests/unit/ -v

# Run only integration tests
pytest tests/integration/ -v -m integration

# Run with coverage report
pytest --cov=calidad --cov-report=term-missing --cov-report=html

# Run specific test file
pytest tests/unit/test_calidad_base.py -v

# Run specific test
pytest tests/unit/test_calidad_base.py::TestQualityCheck::test_validate_url_valid -v
```

### Test Markers

```python
@pytest.mark.unit          # Fast, isolated unit test
@pytest.mark.integration   # Integration test with database
@pytest.mark.slow          # Slow test (>5s) - run separately
@pytest.mark.requires_db   # Requires database connection
@pytest.mark.requires_network  # Requires network access
```

## Fixtures

### Database Fixtures

**`db_connection`** - Provides database connection with automatic rollback
```python
def test_something(db_connection):
    # Changes are rolled back after test
    pass
```

**`db_cursor_fixture`** - Provides RealDictCursor for dict-like row access
```python
def test_query(db_cursor_fixture):
    cursor = db_cursor_fixture
    cursor.execute("SELECT * FROM sections WHERE id = %s", (1,))
    row = cursor.fetchone()
    assert row["name"] == "Expected"
```

**`sample_section`** - Creates a test section (URL) with automatic cleanup
```python
def test_with_section(sample_section):
    section_id = sample_section["id"]
    # Use section in test
```

**`sample_sections`** - Creates 3 test sections for bulk operations

### Mock Fixtures

**`mock_html_content`** - Sample HTML for parsing tests
```python
def test_html_parsing(mock_html_content):
    # HTML with images, links, etc.
    pass
```

**`mock_requests_get`** - Mocks requests.get() to avoid real network calls
```python
def test_url_fetch(mock_requests_get):
    # requests.get() returns mock_response
    pass
```

**`quality_check_config`** - Sample configuration for checkers
```python
def test_checker_config(quality_check_config):
    checker = MyChecker(config=quality_check_config)
```

## Best Practices

### ✅ DO

1. **Arrange-Act-Assert Pattern**
   ```python
   def test_something():
       # Arrange
       checker = MyChecker()

       # Act
       result = checker.check("https://example.com")

       # Assert
       assert result.status == "ok"
   ```

2. **One Assertion Per Test Concept**
   - Test one thing at a time
   - Multiple assertions OK if testing same concept

3. **Descriptive Test Names**
   ```python
   def test_check_returns_error_when_url_invalid():
       pass  # Clear what is being tested
   ```

4. **Use Fixtures for Setup**
   - Avoid copy-paste setup code
   - Keep tests DRY (Don't Repeat Yourself)

5. **Mock External Dependencies**
   - Mock network calls (requests.get)
   - Mock expensive operations
   - Keep tests fast

### ❌ DON'T

1. **Don't Test Implementation Details**
   ```python
   # BAD - tests internal method
   def test_internal_helper_method():
       assert checker._internal_method() == "something"

   # GOOD - tests public interface
   def test_check_returns_correct_status():
       assert checker.check(url).status == "ok"
   ```

2. **Don't Write Tests That Depend on External State**
   - Use fixtures to create known state
   - Don't depend on production data

3. **Don't Skip Tests Without Good Reason**
   ```python
   @pytest.mark.skip(reason="TODO: Implement later")  # OK if documented
   ```

4. **Don't Write Slow Tests Without Marking**
   ```python
   @pytest.mark.slow  # Mark tests that take >5s
   def test_full_crawl():
       pass
   ```

## Continuous Integration

### Pre-commit Hooks (Future)

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: pytest-unit
        name: Run unit tests
        entry: pytest tests/unit/ --maxfail=1
        language: system
        pass_filenames: false
        always_run: true
```

### CI Pipeline (Future - GitHub Actions)

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.11
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run unit tests
        run: pytest tests/unit/ --cov=calidad --cov-fail-under=90
      - name: Run integration tests
        run: pytest tests/integration/ -m integration
```

## Current Test Results

**Date**: 2025-10-31
**Total Tests**: 43
**Passing**: 43 ✅
**Failing**: 0
**Coverage**: 97%

### Breakdown

- **Unit Tests**: 33/33 ✅
  - `test_calidad_base.py`: 20/20 ✅
  - `test_calidad_enlaces.py`: 13/13 ✅

- **Integration Tests**: 10/10 ✅
  - `test_quality_checks_db.py`: 10/10 ✅

### Coverage Report

```
Name                 Stmts   Miss  Cover   Missing
--------------------------------------------------
calidad/__init__.py      2      0   100%
calidad/base.py         64      2    97%   101, 111
calidad/enlaces.py      53      2    96%   92-93
--------------------------------------------------
TOTAL                  119      4    97%
```

## Future Testing Plan

### Phase 3.1 - Image Quality Checker

Before implementing:
1. Write unit tests for `ImagenesChecker` class
2. Mock image downloads and PIL operations
3. Test alt text detection, size validation, format checks
4. Target: >90% coverage

### Phase 3.2 - Typo Checker

Before implementing:
1. Write unit tests for `TypoChecker` class
2. Mock spellchecker library
3. Test text extraction, language detection, typo detection
4. Target: >90% coverage

### Blueprint Integration Tests

When crawler and config blueprints are stable:
1. Flask route testing with test client
2. Authentication testing
3. Blueprint registration verification
4. Target: >70% coverage (critical paths)

## Maintenance

### When to Update Tests

1. **Breaking Changes**
   - Update tests when API changes
   - Tests should fail if contract breaks

2. **New Features**
   - Write tests for new quality checkers
   - Update integration tests for new database tables

3. **Bug Fixes**
   - Add test that reproduces bug
   - Verify fix doesn't break existing tests

### Test Hygiene

- Run tests before committing: `pytest tests/unit/ -v`
- Check coverage: `pytest --cov=calidad --cov-report=term-missing`
- Fix failing tests immediately (don't commit broken tests)
- Remove obsolete tests when refactoring
- Keep fixtures DRY (refactor common setup)

## Resources

- **Pytest Docs**: https://docs.pytest.org/
- **Coverage.py**: https://coverage.readthedocs.io/
- **Test Fixtures**: See `tests/conftest.py`
- **Test Examples**: See `tests/unit/` and `tests/integration/`

---

**Maintained by**: Claude Code + Jesús Ramos
**Last Updated**: 2025-10-31
