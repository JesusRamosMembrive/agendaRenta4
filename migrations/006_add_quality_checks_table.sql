-- Migration 006: Add quality_checks table
-- Purpose: Store automated quality check results for URLs
-- Date: 2025-10-31
-- Stage: 3.0 (Preparation for quality checkers)

-- Table to store quality check results
CREATE TABLE IF NOT EXISTS quality_checks (
    id SERIAL PRIMARY KEY,
    section_id INTEGER NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    check_type VARCHAR(50) NOT NULL,  -- 'image_quality', 'typo', 'broken_links', etc.
    status VARCHAR(20) NOT NULL,       -- 'ok', 'warning', 'error'
    score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),  -- 0-100
    message TEXT NOT NULL,
    details JSONB,                     -- Additional details (JSON format)
    issues_found INTEGER DEFAULT 0,
    execution_time_ms INTEGER,         -- Time taken to execute check in milliseconds
    checked_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index for fast lookups by section and check type
CREATE INDEX idx_quality_checks_section_id ON quality_checks(section_id);
CREATE INDEX idx_quality_checks_type ON quality_checks(check_type);
CREATE INDEX idx_quality_checks_status ON quality_checks(status);
CREATE INDEX idx_quality_checks_checked_at ON quality_checks(checked_at DESC);

-- Composite index for section + check_type (common query pattern)
CREATE INDEX idx_quality_checks_section_type ON quality_checks(section_id, check_type);

-- Comments for documentation
COMMENT ON TABLE quality_checks IS 'Stores automated quality check results for monitored URLs';
COMMENT ON COLUMN quality_checks.check_type IS 'Type of quality check: image_quality, typo, broken_links, accessibility, seo, performance, security_headers, content_freshness';
COMMENT ON COLUMN quality_checks.status IS 'Overall check status: ok (score >= 80), warning (score >= 50), error (score < 50)';
COMMENT ON COLUMN quality_checks.score IS 'Numeric score 0-100 where 100 is perfect quality';
COMMENT ON COLUMN quality_checks.details IS 'JSON object with additional check-specific details (broken links list, image issues, etc.)';
COMMENT ON COLUMN quality_checks.issues_found IS 'Number of issues detected during the check';
COMMENT ON COLUMN quality_checks.execution_time_ms IS 'Time taken to execute the check in milliseconds';
COMMENT ON COLUMN quality_checks.checked_at IS 'When the check was performed (may differ from created_at for batch imports)';
