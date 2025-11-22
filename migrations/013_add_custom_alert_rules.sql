-- Migration 013: Reglas de alertas personalizadas (recurrentes)

CREATE TABLE custom_alert_rules (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    notes TEXT,
    alert_frequency TEXT NOT NULL DEFAULT 'monthly',
    alert_day TEXT,
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT
);

-- Evita duplicados por título
ALTER TABLE custom_alert_rules
ADD CONSTRAINT custom_alert_rules_title_unique
UNIQUE (title);

CREATE INDEX idx_custom_alert_rules_enabled ON custom_alert_rules(enabled);
