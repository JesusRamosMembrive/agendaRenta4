-- Migration 010: Add custom_dictionary table for managing user-approved spell check words
-- This allows managing false positives and domain-specific terms via database

-- Create custom_dictionary table
CREATE TABLE custom_dictionary (
    id SERIAL PRIMARY KEY,
    word VARCHAR(100) NOT NULL,
    word_lower VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(50) DEFAULT 'other',
    frequency INTEGER DEFAULT 0,
    approved_by INTEGER REFERENCES users(id),
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_custom_dict_word_lower ON custom_dictionary(word_lower);
CREATE INDEX idx_custom_dict_category ON custom_dictionary(category);
CREATE INDEX idx_custom_dict_frequency ON custom_dictionary(frequency DESC);

-- Comments
COMMENT ON TABLE custom_dictionary IS 'User-approved custom dictionary words for Hunspell spell checker';
COMMENT ON COLUMN custom_dictionary.word IS 'Original word with capitalization preserved';
COMMENT ON COLUMN custom_dictionary.word_lower IS 'Lowercase version for case-insensitive matching';
COMMENT ON COLUMN custom_dictionary.category IS 'Word category: technical, geographic, brand, financial, other';
COMMENT ON COLUMN custom_dictionary.frequency IS 'Number of times this word appeared as error (for ranking)';
COMMENT ON COLUMN custom_dictionary.approved_by IS 'User who approved adding this word';
COMMENT ON COLUMN custom_dictionary.notes IS 'Optional notes about why word was added';

-- Initial seed data with common false positives
INSERT INTO custom_dictionary (word, word_lower, category, frequency, notes) VALUES
    -- Technical terms
    ('mail', 'mail', 'technical', 102, 'Common anglicism for email'),
    ('captcha', 'captcha', 'technical', 101, 'CAPTCHA security challenge'),
    ('online', 'online', 'technical', 50, 'Common web term'),
    ('app', 'app', 'technical', 40, 'Application abbreviation'),
    ('email', 'email', 'technical', 35, 'Electronic mail'),
    ('web', 'web', 'technical', 30, 'World Wide Web'),
    ('link', 'link', 'technical', 25, 'Hyperlink'),
    ('login', 'login', 'technical', 20, 'User authentication'),
    ('software', 'software', 'technical', 15, 'Computer software'),

    -- Geographic names
    ('España', 'españa', 'geographic', 33, 'Country name - Spain'),
    ('Europa', 'europa', 'geographic', 19, 'Continent name - Europe'),
    ('Madrid', 'madrid', 'geographic', 10, 'Capital of Spain'),
    ('Barcelona', 'barcelona', 'geographic', 8, 'City in Spain'),

    -- Financial/Investment brands
    ('Morningstar', 'morningstar', 'brand', 19, 'Investment research company'),
    ('BlackRock', 'blackrock', 'brand', 12, 'Asset management company'),
    ('Vanguard', 'vanguard', 'brand', 10, 'Investment company'),
    ('Renta4', 'renta4', 'brand', 45, 'Our company name'),

    -- Common verbs/words missing from es_ES
    ('suscríbete', 'suscríbete', 'verb', 25, 'Imperative of suscribirse (subscribe)'),
    ('contáctenos', 'contáctenos', 'verb', 18, 'Imperative of contactar (contact us)'),
    ('regístrate', 'regístrate', 'verb', 15, 'Imperative of registrarse (register)'),

    -- Financial terms
    ('ETF', 'etf', 'financial', 22, 'Exchange-Traded Fund'),
    ('ETFs', 'etfs', 'financial', 20, 'Exchange-Traded Funds (plural)'),
    ('IBEX', 'ibex', 'financial', 18, 'Spanish stock market index'),
    ('trading', 'trading', 'financial', 16, 'Financial trading'),

    -- Common spelling variants
    ('carácteres', 'carácteres', 'variant', 102, 'Variant of caracteres (characters)')
ON CONFLICT (word_lower) DO NOTHING;
