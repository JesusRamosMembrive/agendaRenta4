-- Migration 012: Custom pending alerts (alertas personalizadas)
-- Permite crear alertas sueltas con título/notas y fecha de aviso.

CREATE TABLE custom_pending_alerts (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    notes TEXT,
    due_date DATE NOT NULL,
    dismissed BOOLEAN DEFAULT FALSE,
    dismissed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by TEXT
);

-- Evitar duplicados accidentales por título y fecha
ALTER TABLE custom_pending_alerts
ADD CONSTRAINT custom_pending_alerts_title_date_unique
UNIQUE (title, due_date);

-- Índices de soporte
CREATE INDEX idx_custom_pending_alerts_due_date ON custom_pending_alerts(due_date);
CREATE INDEX idx_custom_pending_alerts_dismissed ON custom_pending_alerts(dismissed);
