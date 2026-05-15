const mysql = require("mysql2/promise");
require("dotenv").config();

async function initDB() {
  const conn = await mysql.createConnection({
    host: process.env.MYSQL_HOST || "localhost",
    port: process.env.MYSQL_PORT || 3306,
    user: process.env.MYSQL_USER || "root",
    password: process.env.MYSQL_PASSWORD || "",
  });

  console.log("Connected to MySQL server");

  try {
    // Create database
    await conn.query("CREATE DATABASE IF NOT EXISTS fitgo");
    console.log("Database created");

    // Use database
    await conn.query("USE fitgo");
    console.log("Switched to fitgo database");

    // Create users table
    await conn.query(`
      CREATE TABLE IF NOT EXISTS users (
        id CHAR(36) PRIMARY KEY,
        email VARCHAR(255) NOT NULL UNIQUE,
        username VARCHAR(50) NULL,
        password_hash VARCHAR(255) NOT NULL,
        is_email_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_email (email),
        INDEX idx_username (username)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log("Created users table");

    // Create user_profiles table
    await conn.query(`
      CREATE TABLE IF NOT EXISTS user_profiles (
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
      CREATE TABLE IF NOT EXISTS saved_meal_plans (
        id CHAR(36) PRIMARY KEY,
        user_id CHAR(36) NOT NULL,
        plan_data JSON NOT NULL,
        summary VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_meal_plans_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        INDEX idx_user_id (user_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log("Created saved_meal_plans table");

    // Create OTP codes table
    await conn.query(`
      CREATE TABLE IF NOT EXISTS otp_codes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        code VARCHAR(6) NOT NULL,
        type ENUM('registration', 'password_reset') NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        is_verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY unique_email_type (email, type),
        INDEX idx_email (email)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    `);
    console.log("Created otp_codes table");

    console.log("\nDatabase initialization complete!");
    process.exit(0);
  } catch (error) {
    console.error("Error:", error.message);
    process.exit(1);
  } finally {
    await conn.end();
  }
}

initDB();
