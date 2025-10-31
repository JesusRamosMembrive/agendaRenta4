-- Migration 007: Add quality_check_batches table for batch processing tracking
-- Date: 2025-10-31
-- Description: Track batch quality check executions with progress

CREATE TABLE IF NOT EXISTS quality_check_batches (
    id SERIAL PRIMARY KEY,
    batch_type VARCHAR(50) NOT NULL,  -- 'image_quality', 'broken_links', etc.
    status VARCHAR(20) NOT NULL,      -- 'pending', 'running', 'completed', 'failed'
    total_urls INTEGER NOT NULL DEFAULT 0,
    processed_urls INTEGER NOT NULL DEFAULT 0,
    successful_checks INTEGER NOT NULL DEFAULT 0,
    failed_checks INTEGER NOT NULL DEFAULT 0,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    created_by VARCHAR(100),
    error_message TEXT,
    CONSTRAINT batch_status_check CHECK (status IN ('pending', 'running', 'completed', 'failed'))
);

-- Index for querying recent batches
CREATE INDEX IF NOT EXISTS idx_quality_check_batches_started ON quality_check_batches(started_at DESC);

-- Index for filtering by status
CREATE INDEX IF NOT EXISTS idx_quality_check_batches_status ON quality_check_batches(status);

-- Comments
COMMENT ON TABLE quality_check_batches IS 'Tracks batch quality check executions';
COMMENT ON COLUMN quality_check_batches.batch_type IS 'Type of quality check being run';
COMMENT ON COLUMN quality_check_batches.status IS 'Current status of the batch: pending, running, completed, failed';
COMMENT ON COLUMN quality_check_batches.total_urls IS 'Total number of URLs to process in this batch';
COMMENT ON COLUMN quality_check_batches.processed_urls IS 'Number of URLs processed so far';
