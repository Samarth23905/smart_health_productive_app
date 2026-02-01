-- Migration: update severities.severity_level check constraint to include 'low' and 'very_severe'
-- Run this on your PostgreSQL database

ALTER TABLE severities
  DROP CONSTRAINT IF EXISTS severities_severity_level_check;

ALTER TABLE severities
  ADD CONSTRAINT severities_severity_level_check
  CHECK (severity_level IN ('low','mild','moderate','severe','very_severe'));

-- Optional: verify existing data
-- SELECT severity_level, COUNT(*) FROM severities GROUP BY severity_level;
