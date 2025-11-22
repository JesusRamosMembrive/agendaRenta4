-- Migration 015: Soporte de fecha límite en alertas personalizadas

ALTER TABLE custom_alert_rules
ADD COLUMN deadline_date DATE;

-- Índice auxiliar para consultas por fecha de deadline
CREATE INDEX IF NOT EXISTS idx_custom_alert_rules_deadline_date
ON custom_alert_rules(deadline_date);
