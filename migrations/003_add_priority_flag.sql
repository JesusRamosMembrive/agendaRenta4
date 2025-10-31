-- Migration 003: Add Priority Flag to Discovered URLs
-- Stage 2.2 - URL Validation (preparación)
-- Created: 2025-10-30
--
-- Purpose: Mark the 117 manually audited URLs as "priority" to differentiate
-- them from the 2,722 newly discovered URLs by the crawler.
-- This allows focused validation on the URLs that matter most to the business.

BEGIN;

-- Add is_priority column
ALTER TABLE discovered_urls
ADD COLUMN IF NOT EXISTS is_priority BOOLEAN DEFAULT FALSE;

-- Add index for fast filtering
CREATE INDEX IF NOT EXISTS idx_discovered_urls_priority ON discovered_urls(is_priority);

-- Add comment
COMMENT ON COLUMN discovered_urls.is_priority IS
'TRUE if this URL is from the original manually curated list (117 URLs from sections table)';

COMMIT;

-- Verification query
SELECT
    COUNT(*) FILTER (WHERE is_priority = TRUE) as priority_urls,
    COUNT(*) FILTER (WHERE is_priority = FALSE) as non_priority_urls,
    COUNT(*) as total_urls
FROM discovered_urls;
