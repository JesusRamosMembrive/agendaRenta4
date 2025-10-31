-- Migration 002: Add Crawler Tables
-- Stage 2 - Web Crawler Automático
-- Created: 2025-10-30

-- Table: discovered_urls
-- Stores URLs discovered by the crawler
CREATE TABLE IF NOT EXISTS discovered_urls (
    id SERIAL PRIMARY KEY,
    url TEXT UNIQUE NOT NULL,
    parent_url_id INTEGER REFERENCES discovered_urls(id) ON DELETE SET NULL,
    depth INTEGER NOT NULL DEFAULT 0,
    discovered_at TIMESTAMP DEFAULT NOW(),
    last_checked TIMESTAMP,
    status_code INTEGER,
    response_time FLOAT,
    is_broken BOOLEAN DEFAULT FALSE,
    error_message TEXT,
    active BOOLEAN DEFAULT TRUE,
    crawl_run_id INTEGER
);

-- Indexes for discovered_urls
CREATE INDEX IF NOT EXISTS idx_discovered_urls_parent ON discovered_urls(parent_url_id);
CREATE INDEX IF NOT EXISTS idx_discovered_urls_broken ON discovered_urls(is_broken);
CREATE INDEX IF NOT EXISTS idx_discovered_urls_crawl_run ON discovered_urls(crawl_run_id);
CREATE INDEX IF NOT EXISTS idx_discovered_urls_active ON discovered_urls(active);
CREATE INDEX IF NOT EXISTS idx_discovered_urls_depth ON discovered_urls(depth);

-- Table: crawl_runs
-- Stores history of crawler executions
CREATE TABLE IF NOT EXISTS crawl_runs (
    id SERIAL PRIMARY KEY,
    started_at TIMESTAMP DEFAULT NOW(),
    finished_at TIMESTAMP,
    status TEXT CHECK (status IN ('running', 'completed', 'failed', 'cancelled')) DEFAULT 'running',
    root_url TEXT NOT NULL,
    max_depth INTEGER DEFAULT 5,
    max_urls INTEGER,
    urls_discovered INTEGER DEFAULT 0,
    urls_broken INTEGER DEFAULT 0,
    urls_timeout INTEGER DEFAULT 0,
    errors TEXT,
    created_by TEXT
);

-- Indexes for crawl_runs
CREATE INDEX IF NOT EXISTS idx_crawl_runs_status ON crawl_runs(status);
CREATE INDEX IF NOT EXISTS idx_crawl_runs_started ON crawl_runs(started_at DESC);

-- Add foreign key for crawl_run_id (after crawl_runs table exists)
ALTER TABLE discovered_urls
ADD CONSTRAINT fk_discovered_urls_crawl_run
FOREIGN KEY (crawl_run_id) REFERENCES crawl_runs(id) ON DELETE SET NULL;

-- Table: url_changes
-- Stores history of changes detected in URLs
CREATE TABLE IF NOT EXISTS url_changes (
    id SERIAL PRIMARY KEY,
    url_id INTEGER REFERENCES discovered_urls(id) ON DELETE CASCADE,
    change_type TEXT CHECK (change_type IN ('new', 'broken', 'fixed', 'removed', 'status_change')),
    old_value TEXT,
    new_value TEXT,
    detected_at TIMESTAMP DEFAULT NOW(),
    details TEXT
);

-- Indexes for url_changes
CREATE INDEX IF NOT EXISTS idx_url_changes_url_id ON url_changes(url_id);
CREATE INDEX IF NOT EXISTS idx_url_changes_type ON url_changes(change_type);
CREATE INDEX IF NOT EXISTS idx_url_changes_detected ON url_changes(detected_at DESC);

-- Grant permissions (adjust user if needed)
-- GRANT ALL PRIVILEGES ON discovered_urls, crawl_runs, url_changes TO your_db_user;
