const mysql = require("mysql2/promise");
require("dotenv").config();

async function rebuildDB() {
  const conn = await mysql.createConnection({
    host: process.env.MYSQL_HOST || "localhost",
    port: process.env.MYSQL_PORT || 3306,
    user: process.env.MYSQL_USER || "root",
    password: process.env.MYSQL_PASSWORD || "",
  });

  console.log("Connected to MySQL server");

  try {
    // Drop database if exists
    await conn.query("DROP DATABASE IF EXISTS fitgo");
    console.log("Dropped existing fitgo database");

    // Create database
    await conn.query("CREATE DATABASE fitgo");
    console.log("Created new fitgo database");

    // Use database
    await conn.query("USE fitgo");
    console.log("Switched to fitgo database");

    // Create users table with username
    await conn.query(`
      CREATE TABLE users (
        id CHAR(36) PRIMARY KEY,
        email VARCHAR(255) NOT NULL UNIQUE,
        username VARCHAR(50) NULL COMMENT 'User display name',
        password_hash VARCHAR(255) NOT NULL,
        is_email_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_email (email),
        INDEX idx_username (username),
        INDEX idx_is_email_verified (is_email_verified)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log("Created users table with username field");

    // Create user_profiles table
    await conn.query(`
      CREATE TABLE user_profiles (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id CHAR(36) NOT NULL UNIQUE,
        height INT NOT NULL,
        weight DECIMAL(5, 2) NOT NULL,
        age INT NOT NULL,
        gender ENUM('male', 'female') NOT NULL,
        activity_level FLOAT NOT NULL,
        goal ENUM('lose_weight', 'build_muscle', 'keep_fit') NOT NULL,
        diet_preference ENUM('standard', 'vegetarian', 'keto', 'vegan') NOT NULL,
        disliked_ingredients VARCHAR(500),
        calculated_calories INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log("Created user_profiles table");

    // Create saved_meal_plans table
    await conn.query(`
      CREATE TABLE saved_meal_plans (
        id CHAR(36) PRIMARY KEY,
        user_id CHAR(36) NOT NULL,
        plan_data JSON NOT NULL,
        summary VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_meal_plans_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_created_at (created_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log("Created saved_meal_plans table");

    // Create otp_codes table
    await conn.query(`
      CREATE TABLE otp_codes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        code VARCHAR(6) NOT NULL,
        type ENUM('registration', 'password_reset') NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        is_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_email_type (email, type),
        INDEX idx_email (email),
        INDEX idx_code (code),
        INDEX idx_expires_at (expires_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log("Created otp_codes table");

    console.log("\n✓ Database rebuild complete!");
  } catch (error) {
    console.error("Error rebuilding database:", error);
    throw error;
  } finally {
    await conn.end();
  }
}

rebuildDB().catch((err) => {
  console.error("Fatal error:", err);
  process.exit(1);
});
