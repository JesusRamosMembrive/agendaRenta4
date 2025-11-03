-- Migration 009: Add discovered_url_id to quality_checks and scope to quality_check_config
-- This allows quality checks to work directly with discovered_urls instead of requiring sections
-- Also adds scope configuration (all vs priority) per check type

-- 1. Add discovered_url_id column to quality_checks (nullable, references discovered_urls)
ALTER TABLE quality_checks
ADD COLUMN discovered_url_id INTEGER REFERENCES discovered_urls(id) ON DELETE CASCADE;

-- 2. Make section_id nullable (for backward compatibility)
ALTER TABLE quality_checks
ALTER COLUMN section_id DROP NOT NULL;

-- 3. Add constraint to ensure at least one source is provided
ALTER TABLE quality_checks
ADD CONSTRAINT check_url_source
CHECK (
    (section_id IS NOT NULL) OR (discovered_url_id IS NOT NULL)
);

-- 4. Add index on discovered_url_id for faster lookups
CREATE INDEX idx_quality_checks_discovered_url_id
ON quality_checks(discovered_url_id);

-- 5. Add scope column to quality_check_config
ALTER TABLE quality_check_config
ADD COLUMN scope VARCHAR(20) NOT NULL DEFAULT 'priority';

-- 6. Add check constraint for scope values
ALTER TABLE quality_check_config
ADD CONSTRAINT check_scope_values
CHECK (scope IN ('all', 'priority'));

-- 7. Add comment explaining the scope
COMMENT ON COLUMN quality_check_config.scope IS 'Scope of URLs to check: "all" = all discovered URLs, "priority" = only is_priority=TRUE URLs';
