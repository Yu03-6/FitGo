-- Add email verification fields to users table
ALTER TABLE users
ADD COLUMN is_email_verified BOOLEAN DEFAULT FALSE COMMENT 'Final email verification status';