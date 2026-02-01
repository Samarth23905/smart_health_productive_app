-- Migration: add updated_at to severities
-- Run this on your PostgreSQL database

ALTER TABLE severities
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Optionally update existing rows to set updated_at = created_at where NULL
UPDATE severities SET updated_at = created_at WHERE updated_at IS NULL;
