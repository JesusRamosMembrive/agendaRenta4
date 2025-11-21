-- Migration 015: Add cta_validation to quality check types
-- Date: 2025-11-21
-- Description: Updates the valid_check_type constraint to include 'cta_validation'

-- Drop the existing constraint
ALTER TABLE quality_check_config DROP CONSTRAINT IF EXISTS valid_check_type;

-- Add new constraint with cta_validation included
ALTER TABLE quality_check_config ADD CONSTRAINT valid_check_type
CHECK (check_type IN (
    'broken_links',
    'image_quality',
    'spell_check',
    'cta_validation',
    'seo',
    'performance',
    'accessibility'
));

-- Insert default cta_validation configuration for all existing users
INSERT INTO quality_check_config (user_id, check_type, enabled, run_after_crawl, scope, created_at, updated_at)
SELECT
    id,
    'cta_validation',
    FALSE,  -- Disabled by default
    FALSE,  -- Not auto-run by default
    'priority',  -- Only priority URLs by default
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM users
ON CONFLICT (user_id, check_type) DO NOTHING;

-- Comments
COMMENT ON CONSTRAINT valid_check_type ON quality_check_config IS
    'Valid quality check types: broken_links, image_quality, spell_check, cta_validation, seo, performance, accessibility';
