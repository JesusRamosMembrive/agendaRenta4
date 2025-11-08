-- Migration: Create CTA Validation Tables
-- Date: 2025-11-08
-- Stage: Stage 5 - CTA Quality Checks
-- Description: Tables for validating Call-To-Action buttons/links on pages

-- 1. Page Types Table
-- Stores different types of pages (homepage, product pages, etc.)
CREATE TABLE IF NOT EXISTS cta_page_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    url_pattern VARCHAR(255),  -- Regex pattern to auto-match URLs (for future auto-classification)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add comment for clarity
COMMENT ON TABLE cta_page_types IS 'Types of pages with different CTA requirements';
COMMENT ON COLUMN cta_page_types.url_pattern IS 'Regex pattern for auto-classification (future use)';

-- 2. CTA Validation Rules Table
-- Defines expected CTAs for each page type
CREATE TABLE IF NOT EXISTS cta_validation_rules (
    id SERIAL PRIMARY KEY,
    page_type_id INTEGER REFERENCES cta_page_types(id) ON DELETE CASCADE,
    is_global BOOLEAN DEFAULT FALSE,  -- If TRUE, applies to ALL pages regardless of type
    expected_text VARCHAR(255) NOT NULL,
    expected_url_pattern VARCHAR(500),  -- Expected URL (can be exact or regex)
    url_match_type VARCHAR(20) DEFAULT 'exact' CHECK (url_match_type IN ('exact', 'contains', 'regex', 'domain')),
    is_optional BOOLEAN DEFAULT FALSE,  -- If TRUE, CTA is optional (warning instead of error)
    priority INTEGER DEFAULT 0,  -- Higher priority = more important CTA
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_rule UNIQUE(page_type_id, expected_text, is_global)
);

-- Add comments
COMMENT ON TABLE cta_validation_rules IS 'Expected CTAs for each page type';
COMMENT ON COLUMN cta_validation_rules.is_global IS 'Global rules apply to all pages (e.g., "Abre una cuenta")';
COMMENT ON COLUMN cta_validation_rules.url_match_type IS 'How to match URL: exact, contains, regex, or domain';
COMMENT ON COLUMN cta_validation_rules.priority IS 'Higher = more important (0=normal, 1=high, 2=critical)';

-- 3. URL to Page Type Assignments
-- Maps discovered URLs to page types
CREATE TABLE IF NOT EXISTS cta_url_assignments (
    id SERIAL PRIMARY KEY,
    url_id INTEGER REFERENCES discovered_urls(id) ON DELETE CASCADE,
    page_type_id INTEGER REFERENCES cta_page_types(id) ON DELETE CASCADE,
    assigned_by VARCHAR(50) DEFAULT 'manual',  -- 'manual', 'auto', or user_id
    confidence FLOAT DEFAULT 1.0,  -- Confidence score for auto-assignments (0.0-1.0)
    notes TEXT,  -- Optional notes about the assignment
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_assignment UNIQUE(url_id, page_type_id)
);

-- Add comments
COMMENT ON TABLE cta_url_assignments IS 'Maps URLs to page types for CTA validation';
COMMENT ON COLUMN cta_url_assignments.confidence IS 'Confidence score for auto-assignments (1.0 = certain)';

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_cta_rules_page_type ON cta_validation_rules(page_type_id);
CREATE INDEX IF NOT EXISTS idx_cta_rules_global ON cta_validation_rules(is_global) WHERE is_global = true;
CREATE INDEX IF NOT EXISTS idx_cta_assignments_url ON cta_url_assignments(url_id);
CREATE INDEX IF NOT EXISTS idx_cta_assignments_page_type ON cta_url_assignments(page_type_id);

-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to auto-update updated_at
CREATE TRIGGER update_cta_page_types_updated_at
    BEFORE UPDATE ON cta_page_types
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cta_validation_rules_updated_at
    BEFORE UPDATE ON cta_validation_rules
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cta_url_assignments_updated_at
    BEFORE UPDATE ON cta_url_assignments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
