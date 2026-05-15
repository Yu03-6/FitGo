

-- Create users table
CREATE TABLE users (
  id CHAR(36) PRIMARY KEY COMMENT 'UUID',
  email VARCHAR(255) NOT NULL UNIQUE COMMENT 'User email',
  password_hash VARCHAR(255) NOT NULL COMMENT 'Hashed password',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User accounts';

-- Create user_profiles table
CREATE TABLE user_profiles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id CHAR(36) NOT NULL UNIQUE,
  height INT NOT NULL COMMENT 'Height in cm',
  weight DECIMAL(5, 2) NOT NULL COMMENT 'Weight in kg',
  age INT NOT NULL COMMENT 'Age in years',
  gender ENUM('male', 'female') NOT NULL,
  activity_level FLOAT NOT NULL COMMENT 'Activity multiplier: 1.2-1.9',
  goal ENUM('lose_weight', 'build_muscle', 'keep_fit') NOT NULL,
  diet_preference ENUM('standard', 'vegetarian', 'keto', 'vegan') NOT NULL,
  disliked_ingredients VARCHAR(500) COMMENT 'Comma-separated ingredients to exclude',
  calculated_calories INT COMMENT 'Calculated TDEE for the user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User biometric and preference data';

-- Create saved_meal_plans table
CREATE TABLE saved_meal_plans (
  id CHAR(36) PRIMARY KEY COMMENT 'UUID',
  user_id CHAR(36) NOT NULL,
  plan_data JSON NOT NULL COMMENT 'Complete Spoonacular API response',
  summary VARCHAR(255) COMMENT 'Human-readable summary (e.g., "2500kcal • High Protein")',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_meal_plans_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Saved meal plans and recipes';
