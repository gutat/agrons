-- ============================================
-- i18n Phase 3: translations columns
-- Run ONCE in Supabase SQL Editor on the existing database.
--
-- Adds a `translations` JSONB column to every content table.
-- Shape: { "field": { "en": "...", "id": "..." } }
-- Existing columns stay as the English fallback — no data migration needed.
-- Array fields (values, specifications, applications) are localized in place
-- as { "en": "...", "id": "..." } elements; plain strings keep working.
-- ============================================

ALTER TABLE home_section    ADD COLUMN IF NOT EXISTS translations JSONB DEFAULT '{}';
ALTER TABLE about_section   ADD COLUMN IF NOT EXISTS translations JSONB DEFAULT '{}';
ALTER TABLE gallery_section ADD COLUMN IF NOT EXISTS translations JSONB DEFAULT '{}';
ALTER TABLE gallery_items   ADD COLUMN IF NOT EXISTS translations JSONB DEFAULT '{}';
ALTER TABLE products        ADD COLUMN IF NOT EXISTS translations JSONB DEFAULT '{}';
