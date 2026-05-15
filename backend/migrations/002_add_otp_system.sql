-- Migration: Add OTP system for email verification (v2)
-- This migration adds email verification support and OTP-based authentication

-- Add is_email_verified column to existing users table
ALTER TABLE users 
ADD COLUMN is_email_verified BOOLEAN DEFAULT FALSE COMMENT 'Email verification status' AFTER password_hash,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at,
ADD INDEX idx_is_email_verified (is_email_verified);

-- Create OTP codes table for registration and password reset flows
CREATE TABLE IF NOT EXISTS otp_codes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL COMMENT 'Email address for OTP',
  code VARCHAR(6) NOT NULL COMMENT '6-digit OTP code',
  type ENUM('registration', 'password_reset') NOT NULL COMMENT 'Type of OTP',
  expires_at TIMESTAMP NOT NULL COMMENT 'OTP expiration time',
  is_verified BOOLEAN DEFAULT FALSE COMMENT 'Whether OTP has been verified',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_email_type (email, type),
  INDEX idx_email (email),
  INDEX idx_code (code),
  INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='One-time password codes for registration and password reset';

-- Migration complete
SELECT 'Migration 002: OTP system added successfully' as status;
