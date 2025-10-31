-- Migration 004: Add health_snapshots table for historical tracking
-- Phase 2.4: Automatic Revalidation System

-- Table to store health metrics over time
CREATE TABLE IF NOT EXISTS health_snapshots (
    id SERIAL PRIMARY KEY,
    snapshot_date TIMESTAMP DEFAULT NOW(),
    health_score FLOAT NOT NULL,  -- Percentage (0-100)
    total_urls INTEGER NOT NULL,
    ok_urls INTEGER NOT NULL,
    broken_urls INTEGER NOT NULL,
    redirect_urls INTEGER DEFAULT 0,
    error_urls INTEGER DEFAULT 0
);

-- Index for date-based queries
CREATE INDEX idx_health_snapshots_date ON health_snapshots(snapshot_date DESC);

-- Comments
COMMENT ON TABLE health_snapshots IS 'Historical health metrics for URL validation tracking (Phase 2.4)';
COMMENT ON COLUMN health_snapshots.health_score IS 'Percentage of healthy URLs (0-100)';
COMMENT ON COLUMN health_snapshots.total_urls IS 'Total number of URLs validated';
COMMENT ON COLUMN health_snapshots.ok_urls IS 'Number of URLs with 2xx/3xx status';
COMMENT ON COLUMN health_snapshots.broken_urls IS 'Number of URLs with 4xx/5xx status';
