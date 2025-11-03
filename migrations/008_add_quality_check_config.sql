-- Migration 008: Add quality_check_config table for user preferences
-- Date: 2025-10-31
-- Description: Allows users to configure which quality checks run automatically after crawl

CREATE TABLE IF NOT EXISTS quality_check_config (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    check_type VARCHAR(50) NOT NULL,  -- 'broken_links', 'image_quality', 'seo', etc.
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    run_after_crawl BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_user_check_type UNIQUE (user_id, check_type),
    CONSTRAINT valid_check_type CHECK (check_type IN ('broken_links', 'image_quality', 'seo', 'performance', 'accessibility'))
);

-- Index for quick lookup by user
CREATE INDEX IF NOT EXISTS idx_quality_check_config_user ON quality_check_config(user_id);

-- Index for enabled checks
CREATE INDEX IF NOT EXISTS idx_quality_check_config_enabled ON quality_check_config(user_id, enabled, run_after_crawl);

-- Comments
COMMENT ON TABLE quality_check_config IS 'User preferences for automated quality checks';
COMMENT ON COLUMN quality_check_config.check_type IS 'Type of quality check: broken_links, image_quality, seo, performance, accessibility';
COMMENT ON COLUMN quality_check_config.enabled IS 'Whether this check is enabled for the user';
COMMENT ON COLUMN quality_check_config.run_after_crawl IS 'Whether to run this check automatically after crawl completion';

-- Insert default configuration for existing users
INSERT INTO quality_check_config (user_id, check_type, enabled, run_after_crawl)
SELECT
    id,
    check_type,
    FALSE,  -- Disabled by default to not surprise users
    FALSE
FROM users
CROSS JOIN (
    VALUES ('broken_links'), ('image_quality')
) AS check_types(check_type)
ON CONFLICT (user_id, check_type) DO NOTHING;
