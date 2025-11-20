-- Migration 014: Add task_type_id to custom_alert_rules and backfill

ALTER TABLE custom_alert_rules
ADD COLUMN task_type_id INTEGER;

-- Backfill: crear task_type y alert_settings para reglas existentes
DO $$
DECLARE
    r RECORD;
    new_task_id INTEGER;
    next_order INTEGER;
BEGIN
    FOR r IN SELECT id, title, alert_frequency, alert_day, task_type_id FROM custom_alert_rules LOOP
        IF r.task_type_id IS NULL THEN
            SELECT COALESCE(MAX(display_order), 0) + 1 INTO next_order FROM task_types;
            INSERT INTO task_types (name, display_name, periodicity, display_order)
            VALUES ('custom_' || r.id, r.title, r.alert_frequency, next_order)
            RETURNING id INTO new_task_id;

            UPDATE custom_alert_rules SET task_type_id = new_task_id WHERE id = r.id;

            INSERT INTO alert_settings (task_type_id, alert_frequency, alert_day, enabled)
            VALUES (new_task_id, r.alert_frequency, COALESCE(r.alert_day, '1'), TRUE)
            ON CONFLICT (task_type_id) DO NOTHING;
        END IF;
    END LOOP;
END$$;
