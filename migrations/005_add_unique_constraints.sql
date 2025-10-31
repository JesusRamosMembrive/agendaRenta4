-- Migration 005: Add UNIQUE constraints for ON CONFLICT support
-- Date: 2025-10-31
-- Description: Adds UNIQUE constraint to notification_preferences.user_name
--              to support ON CONFLICT in PostgreSQL

-- Add UNIQUE constraint to notification_preferences
ALTER TABLE notification_preferences
ADD CONSTRAINT notification_preferences_user_name_unique
UNIQUE (user_name);

-- Note: alert_settings already has task_type_id as PRIMARY KEY,
-- which is sufficient for ON CONFLICT
