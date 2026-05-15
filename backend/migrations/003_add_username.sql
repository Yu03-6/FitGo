-- Migration: Add username to users table
-- Date: 2026-02-24

ALTER TABLE users
ADD COLUMN username VARCHAR(50) NULL COMMENT 'User display name';

-- Create index for username lookup
CREATE INDEX idx_username ON users (username);