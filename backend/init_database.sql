CREATE DATABASE IF NOT EXISTS fitgo;

USE fitgo;

CREATE TABLE IF NOT EXISTS users (
    id CHAR(36) PRIMARY KEY COMMENT 'UUID',
    email VARCHAR(255) NOT NULL UNIQUE COMMENT 'User email',
    username VARCHAR(50) NULL COMMENT 'User display name',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hashed password',
    is_email_verified BOOLEAN DEFAULT FALSE COMMENT 'Email verification status',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_is_email_verified (is_email_verified)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'User accounts';

CREATE TABLE IF NOT EXISTS user_profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36) NOT NULL UNIQUE,
    height INT NOT NULL COMMENT 'Height in cm',
    weight DECIMAL(5, 2) NOT NULL COMMENT 'Weight in kg',
    age INT NOT NULL COMMENT 'Age in years',
    gender ENUM('male', 'female') NOT NULL,
    activity_level FLOAT NOT NULL COMMENT 'Activity multiplier: 1.2-1.9',
    goal ENUM(
        'lose_weight',
        'build_muscle',
        'keep_fit'
    ) NOT NULL,
    diet_preference ENUM(
        'standard',
        'vegetarian',
        'keto',
        'vegan'
    ) NOT NULL,
    disliked_ingredients VARCHAR(500) COMMENT 'Comma-separated ingredients to exclude',
    calculated_calories INT COMMENT 'Calculated TDEE for the user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'User biometric and preference data';

CREATE TABLE IF NOT EXISTS saved_meal_plans (
    id CHAR(36) PRIMARY KEY COMMENT 'UUID',
    user_id CHAR(36) NOT NULL,
    plan_data JSON NOT NULL COMMENT 'Complete Spoonacular API response',
    summary VARCHAR(255) COMMENT 'Human-readable summary (e.g., "2500kcal • High Protein")',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_meal_plans_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Saved meal plans and recipes';

CREATE TABLE IF NOT EXISTS otp_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL COMMENT 'Email address for OTP',
    code VARCHAR(6) NOT NULL COMMENT '6-digit OTP code',
    type ENUM(
        'registration',
        'password_reset'
    ) NOT NULL COMMENT 'Type of OTP',
    expires_at TIMESTAMP NOT NULL COMMENT 'OTP expiration time',
    is_verified BOOLEAN DEFAULT FALSE COMMENT 'Whether OTP has been verified',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_email_type (email, type),
    INDEX idx_email (email),
    INDEX idx_code (code),
    INDEX idx_expires_at (expires_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'One-time password codes for registration and password reset';

SELECT 'FitGo Database initialized successfully' as status;