-- Migration: Add spell_check support to quality_check_config
-- Date: 2025-11-04
-- Description: Updates constraint to allow spell_check and adds default config for all users

-- Update constraint to include spell_check
ALTER TABLE quality_check_config
DROP CONSTRAINT IF EXISTS valid_check_type;

ALTER TABLE quality_check_config
ADD CONSTRAINT valid_check_type
CHECK (check_type IN ('broken_links', 'image_quality', 'spell_check', 'seo', 'performance', 'accessibility'));

-- Add spell_check configuration for all existing users
INSERT INTO quality_check_config (user_id, check_type, enabled, run_after_crawl, scope, created_at, updated_at)
SELECT
    u.id,
    'spell_check',
    false,
    false,
    'priority',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM quality_check_config qcc
    WHERE qcc.user_id = u.id AND qcc.check_type = 'spell_check'
);
