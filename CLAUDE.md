# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Agenda Renta4** is a web quality control system for monitoring and managing the health of 173+ URLs across a corporate website. The system helps a team manually review multiple task types (authentication, speed, navigation, etc.) and generates automatic alerts based on configured periodicity.

**Current Stage**: Stage 3 - UX Improvements & Quality Automation
**Production Status**: ✅ Deployed on Render (Frankfurt region)
**Database**: PostgreSQL (Render managed)

### What Problems Does This Solve?

- Manual Excel-based tracking is error-prone
- No automatic alert system
- Difficult to track which URLs have been reviewed and which have problems
- Need for automated discovery and validation of web pages

## Tech Stack

### Core
- **Backend**: Python 3.11, Flask 3.0.0
- **Database**: PostgreSQL via psycopg2-binary 2.9.11 (raw SQL, no ORM)
- **Frontend**: HTML, Jinja2 templates, vanilla JavaScript, CSS
- **Server**: Gunicorn 21.2.0
- **Hosting**: Render (Frankfurt region)
- **Auth**: Flask-Login 0.6.3 (simple authentication)

### Stage 2+ Features (Crawler & Quality)
- **Web Crawler**: Requests 2.31.0 + BeautifulSoup4 4.12.2
- **Scheduler**: APScheduler 3.10.4
- **Image Processing**: Pillow 12.0.0
- **Email**: Flask-Mail 0.10.0

### Development
- **Testing**: pytest (see `tests/` directory)
- **Environment**: python-dotenv 1.0.0

## Architecture Overview

### Monolithic Structure (By Design)
The codebase intentionally follows a "Stage-based" evolution approach:
- **Stage 1**: Everything in 1-3 files (completed)
- **Stage 2**: Modular only when justified by pain (completed)
- **Stage 3**: Abstractions with evidence of real problems (current)

**Philosophy**: Simplicity > Completeness. Only add structure when there's clear evidence of pain.

### Current File Structure

```
agendaRenta4/
├── app.py                    # 1,129 lines - Main Flask app
├── utils.py                  # 139 lines - DB utilities
├── constants.py              # 79 lines - Constants
├── crawler/                  # ~2,200 lines - Web crawler module
│   ├── crawler.py            # Main crawler class
│   ├── routes.py             # Crawler blueprint routes
│   ├── config.py             # Crawler configuration
│   ├── validator.py          # URL validation
│   ├── scheduler.py          # Automated scheduling
│   └── progress_tracker.py   # Real-time progress tracking
├── calidad/                  # ~1,375 lines - Quality check modules
│   ├── base.py               # Base quality checker class
│   ├── enlaces.py            # Link validation
│   ├── imagenes.py           # Image quality checks
│   ├── batch.py              # Batch processing
│   └── post_crawl_runner.py  # Orchestrates post-crawl checks
├── templates/                # Jinja2 HTML templates
│   ├── base.html
│   ├── inicio.html
│   ├── pendientes.html
│   ├── problemas.html
│   ├── realizadas.html
│   ├── configuracion.html
│   ├── alertas.html
│   ├── crawler/              # Crawler-specific templates
│   │   ├── dashboard.html
│   │   ├── broken.html
│   │   ├── quality.html
│   │   ├── tree.html
│   │   └── test_runner.html
│   └── emails/               # Email templates
├── tests/                    # Test suite
│   ├── unit/                 # Unit tests
│   └── integration/          # Integration tests
└── scripts/                  # Utility scripts
    ├── create_tasks_for_period.py
    ├── load_sections.py
    ├── mark_priority_urls.py
    └── seed_users.py
```

### Database Schema (8 Core Tables)

**Stage 1 Tables** (Manual task management):
- `sections` - 173 URLs to review
- `task_types` - 8 task types with periodicities
- `tasks` - Task instances (URL × type × period)
- `alert_settings` - Alert configuration
- `notification_preferences` - User notification settings
- `pending_alerts` - Pending alerts
- `users` - System users

**Stage 2+ Tables** (Crawler & Quality):
- `discovered_urls` - URLs found by crawler (~2,800 URLs)
  - Includes `is_priority` flag (117 priority URLs)
- `crawl_runs` - Crawler execution history
- `url_changes` - Changes detected between crawls
- `quality_checks` - Quality check results
- `quality_check_config` - Per-user check configuration
- `quality_batches` - Batch processing tracking

### Key Routes

**Main App Routes** (app.py):
- `/` - Redirect to inicio
- `/login`, `/logout` - Authentication
- `/inicio` - Main dashboard
- `/pendientes` - Pending tasks
- `/problemas` - Problem tasks
- `/realizadas` - Completed tasks
- `/configuracion` - Configuration page
- `/alertas` - Alert management
- `/tasks/update` - Update task status (POST)
- `/save_observations` - Save task observations (POST)

**Crawler Routes** (crawler/routes.py):
- `/crawler` - Crawler dashboard
- `/crawler/start` - Start crawl (POST)
- `/crawler/progress` - Real-time progress (GET, polls every 2s)
- `/crawler/results` - View crawl results
- `/crawler/broken` - Broken links report
- `/crawler/health` - URL health status
- `/crawler/tree` - URL tree view
- `/crawler/quality` - Quality checks dashboard
- `/crawler/test-runner` - Manual test execution UI
- `/crawler/quality/run` - Run quality checks on-demand (POST)

## Common Development Tasks

### Setup & Installation

```bash
# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Setup environment variables
cp .env.example .env
# Edit .env with your configuration

# Initialize/seed database (if needed)
python database.py
python load_sections.py
python seed_users.py
```

### Running the Application

```bash
# Development mode
python app.py
# App runs on http://localhost:5000

# Production mode (Gunicorn)
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### Testing

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/unit/test_calidad_enlaces.py

# Run with coverage
pytest --cov=. --cov-report=html

# Run integration tests only
pytest tests/integration/
```

### Database Operations

```bash
# Connect to local PostgreSQL
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendaRenta4

# Common queries
psql -c "SELECT is_priority, COUNT(*) FROM discovered_urls GROUP BY is_priority;"
psql -c "SELECT * FROM crawl_runs ORDER BY id DESC LIMIT 5;"
psql -c "SELECT check_type, status, COUNT(*) FROM quality_checks GROUP BY check_type, status;"

# Mark URLs as priority (syncs with sections table)
python mark_priority_urls.py
```

### Crawler Operations

```bash
# Run crawler manually
python test_crawler.py

# Monitor crawler progress
python monitor_crawl.py

# Test URL validation
python validate_urls.py

# Debug broken links
python debug_broken_links.py

# Debug image quality
python debug_image_quality.py
```

### Quality Check Operations

```bash
# Run quality checks manually
python test_quality_checks_ui.py

# Generate Excel report with broken links
python export_broken_links.py

# Full crawl with comparison
python full_crawl_and_compare.py
```

## Key Design Patterns

### 1. Quality Check Architecture

All quality checkers inherit from `calidad/base.py:QualityChecker`:

```python
class QualityChecker(ABC):
    @abstractmethod
    def check_url(self, url: str) -> dict:
        """Check a single URL and return results"""
        pass

    def save_results(self, url_id: int, results: dict):
        """Save results to quality_checks table"""
        pass
```

**Existing Checkers**:
- `URLValidator` - Validates link health (broken, redirects)
- `ImagenesChecker` - Checks image quality (alt text, size, optimization)

### 2. Progress Tracking Pattern

The crawler uses a singleton pattern for real-time progress tracking:

```python
# crawler/progress_tracker.py
progress_tracker = ProgressTracker()  # Thread-safe singleton

# In crawler
progress_tracker.start_crawl(crawl_run_id, estimated_total)
progress_tracker.update_progress(urls_discovered, last_url)
progress_tracker.stop_crawl()

# In UI (polls every 2 seconds)
fetch('/crawler/progress')
```

### 3. Post-Crawl Quality Checks

After each crawl, quality checks can run automatically:

```python
# crawler/crawler.py
def _run_post_crawl_checks(self, created_by='system'):
    from calidad.post_crawl_runner import PostCrawlQualityRunner
    runner = PostCrawlQualityRunner()
    runner.run_enabled_checks(created_by=created_by)
```

### 4. Scope-Based Testing

Quality checks support two scopes:
- `priority`: Only 117 critical URLs (fast, ~3-5 min)
- `all`: All ~2,800 discovered URLs (slow, ~15-30 min)

Users can select scope via UI or API:

```python
POST /crawler/quality/run
{
  "check_types": ["broken_links", "image_quality"],
  "scope": "priority"  // or "all"
}
```

## Important Conventions

### Database Queries
- Use raw SQL with psycopg2 (no ORM)
- Always use parameterized queries: `cursor.execute(query, (param1, param2))`
- Close cursors and connections properly (use context managers)

### Error Handling
- Log errors with context: `print(f"[ERROR] Description: {error}")`
- Return meaningful error messages to users
- Use try/except blocks around external calls (HTTP, DB)

### Configuration
- Never hardcode credentials or secrets
- Use environment variables via `python-dotenv`
- Keep sensitive config in `.env` (never commit)
- Configuration objects like `CRAWLER_CONFIG` live in dedicated config files

### Code Style
- Prefer simple functions over complex classes
- Use descriptive variable names (Spanish OK for domain terms)
- Add docstrings to non-obvious functions
- Comment "why" not "what"

### Stage-Based Development Rules

**Current Stage 3 Rules** (.claude/02-stage3-rules.md):
- ✅ Abstractions with extensibility are OK
- ✅ Interfaces for clear extension points
- ✅ Layers if they reduce real coupling
- ✅ Design patterns with justification
- ⚠️ Each decision needs evidence of real problems
- ⚠️ Prefer incremental refactor over rewrite

**Never**:
- Over-engineer beyond current stage
- Implement features not in project brief
- Skip the "propose then implement" workflow

## Testing Strategy

### Test Organization
- `tests/unit/` - Pure unit tests (no DB, no network)
- `tests/integration/` - Tests with DB and external dependencies
- `conftest.py` - Shared fixtures and test configuration

### Running Specific Tests
```bash
# Test specific quality checker
pytest tests/unit/test_calidad_enlaces.py -v

# Test crawler blueprint
pytest tests/integration/test_crawler_blueprint.py -v

# Test with specific marker (if defined)
pytest -m "slow" -v
```

## Deployment

The application is deployed on Render with the following setup:

### Build Configuration
- **Build Command**: `./build.sh` (runs migrations, creates tables)
- **Start Command**: `gunicorn -w 4 -b 0.0.0.0:$PORT app:app`
- **Python Version**: 3.11.9 (defined in `runtime.txt`)

### Environment Variables (Production)
Set these in Render dashboard:
- `DATABASE_URL` - PostgreSQL connection string (auto-set by Render)
- `SECRET_KEY` - Flask secret key
- `SMTP_SERVER`, `SMTP_PORT`, `SMTP_USE_TLS` - Email config
- `EMAIL_USER`, `EMAIL_PASS` - SMTP credentials
- `EMAIL_FROM` - Sender email address

### Deploy Process
```bash
# Push to main/master branch triggers auto-deploy
git push origin master

# View logs
# Use Render dashboard or CLI

# Manual deployment
# Use Render dashboard "Manual Deploy" button
```

## Critical Context for Claude Code

### 1. Read These Files First (Every Session)
Per CLAUDE.md custom instructions, ALWAYS read at start of session:
1. `.claude/00-project-brief.md` - Project scope and constraints
2. `.claude/01-current-phase.md` - Current state and progress
3. `.claude/02-stage3-rules.md` - Rules for current stage

### 2. Update Progress at End of Session
Update `.claude/01-current-phase.md` with:
- What was implemented (with file names and line numbers)
- Decisions made and why
- What was NOT done (deferred)
- Next steps for next session

### 3. Key Technical Decisions

**Decision: Raw SQL vs ORM** (2025-10-29)
- Using psycopg2 with raw SQL
- Reason: Simplicity, full control, no ORM learning curve
- Reconsider if: Queries become too complex or repeated

**Decision: Monolithic app.py** (2025-10-30)
- app.py at 1,129 lines is still manageable
- Reason: Avoid premature modularization
- Reconsider if: Exceeds 1,500 lines or 2+ developers

**Decision: Requests + BeautifulSoup for Crawler** (2025-10-30)
- Simple, fast, sufficient for static HTML
- Alternatives discarded: Scrapy (overkill), Playwright (heavy)
- Reconsider if: Site requires JavaScript rendering

**Decision: Convivencia sections + discovered_urls** (2025-10-30)
- Stage 1 uses `sections` (173 manual URLs)
- Stage 2+ uses `discovered_urls` (~2,800 auto-discovered)
- Reason: Don't break Stage 1, gradual transition
- Full migration: Evaluate in future if needed

**Decision: Progress via Polling vs WebSockets** (2025-11-02)
- Using HTTP polling every 2 seconds
- Reason: Simpler, no WebSocket complexity, sufficient for use case
- Reconsider if: Need true real-time updates or scaling issues

### 4. Known Issues & Limitations

**Stage 1-2 Coexistence**:
- `sections` table still used for manual task management
- `discovered_urls` used for crawler-based features
- Some URLs exist in both tables (117 priority URLs)
- Script `mark_priority_urls.py` syncs them

**Crawler Performance**:
- Full crawl of ~2,800 URLs takes 15-30 minutes
- Rate-limited to 0.5-1 second between requests
- No distributed crawling (single-threaded)

**Quality Checks**:
- Image quality checks may be slow on large images
- Link validation timeouts set to 10 seconds
- No retry logic for transient failures yet

**Multi-User Concurrency**:
- No locking mechanism for simultaneous crawls
- Impact: Low (1-5 internal users)
- Future: Consider Redis-based locking if needed

## Useful Resources

### Documentation Files
- `docs/QUICK_START.md` - Workflow guide
- `docs/STAGES_COMPARISON.md` - Quick reference table
- `docs/CLAUDE_CODE_REFERENCE.md` - Claude Code tips
- `STAGE3_IMPLEMENTATION_PLAN.md` - Current stage plan
- `TESTING_STRATEGY.md` - Testing approach
- `DEPLOYMENT.md` - Deployment guide

### External Documentation
- [Flask Docs](https://flask.palletsprojects.com/)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [BeautifulSoup Docs](https://www.crummy.com/software/BeautifulSoup/bs4/doc/)
- [Render Docs](https://render.com/docs)

## Troubleshooting

### Database Connection Issues
```bash
# Check connection
PGPASSWORD=dev-password psql -h localhost -U jesusramos -d agendaRenta4 -c "SELECT 1;"

# Reset connection pool
# Restart Flask app
```

### Crawler Not Discovering URLs
```bash
# Check configuration
python -c "from crawler.config import CRAWLER_CONFIG; print(CRAWLER_CONFIG)"

# Verify robots.txt not blocking
curl https://www.r4.com/robots.txt

# Check crawler logs
tail -f logs/crawler.log  # If logging configured
```

### Quality Checks Not Running
```bash
# Verify configuration
PGPASSWORD=dev-password psql -d agendaRenta4 -c \
  "SELECT * FROM quality_check_config WHERE user_id = 1;"

# Check if URLs are marked as priority
PGPASSWORD=dev-password psql -d agendaRenta4 -c \
  "SELECT is_priority, COUNT(*) FROM discovered_urls GROUP BY is_priority;"

# Re-mark priority URLs
python mark_priority_urls.py
```

### Progress Tracker Stuck
```python
# Reset progress tracker
python -c "
from crawler.progress_tracker import progress_tracker
progress_tracker.stop_crawl()
print('Progress tracker reset')
"
```

---

**Last Updated**: 2025-11-03
**Project Stage**: Stage 3 - UX Improvements & Quality Automation
**Production URL**: [Render deployment URL]
**Contact**: Check `.claude/00-project-brief.md` for project owner info
