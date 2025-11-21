-- Migration 011: Harden alerts/tasks schema with unique constraints
-- - Ensures ON CONFLICT clauses work as intended
-- - Prevents duplicate alerts and tasks per periodo/combination

-- ============================================================================
-- 1) alert_settings: dedupe + UNIQUE(task_type_id)
-- ============================================================================
WITH duplicates AS (
    SELECT task_type_id, MIN(id) AS keep_id
    FROM alert_settings
    GROUP BY task_type_id
    HAVING COUNT(*) > 1
)
DELETE FROM alert_settings a
USING duplicates d
WHERE a.task_type_id = d.task_type_id
  AND a.id <> d.keep_id;

ALTER TABLE alert_settings
ADD CONSTRAINT alert_settings_task_type_id_unique
UNIQUE (task_type_id);

-- ============================================================================
-- 2) pending_alerts: dedupe + UNIQUE(task_type_id, due_date)
-- ============================================================================
WITH duplicates AS (
    SELECT task_type_id, due_date, MIN(id) AS keep_id
    FROM pending_alerts
    GROUP BY task_type_id, due_date
    HAVING COUNT(*) > 1
)
DELETE FROM pending_alerts p
USING duplicates d
WHERE p.task_type_id = d.task_type_id
  AND p.due_date = d.due_date
  AND p.id <> d.keep_id;

ALTER TABLE pending_alerts
ADD CONSTRAINT pending_alerts_task_type_date_unique
UNIQUE (task_type_id, due_date);

-- ============================================================================
-- 3) tasks: garantizar una sola tarea por sección/tipo/periodo
-- ============================================================================
WITH duplicates AS (
    SELECT section_id, task_type_id, period, MIN(id) AS keep_id
    FROM tasks
    GROUP BY section_id, task_type_id, period
    HAVING COUNT(*) > 1
)
DELETE FROM tasks t
USING duplicates d
WHERE t.section_id = d.section_id
  AND t.task_type_id = d.task_type_id
  AND t.period = d.period
  AND t.id <> d.keep_id;

ALTER TABLE tasks
ADD CONSTRAINT tasks_section_type_period_unique
UNIQUE (section_id, task_type_id, period);
