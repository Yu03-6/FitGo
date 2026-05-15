const pool = require("../config/database");
const calculator = require("../utils/calculator");

/**
 * Get user profile with calculated nutrition
 */
async function getUserProfile(userId) {
  const conn = await pool.getConnection();
  try {
    const [rows] = await conn.query(
      "SELECT * FROM user_profiles WHERE user_id = ?",
      [userId],
    );
    return rows[0] || null;
  } finally {
    conn.release();
  }
}

/**
 * Update user profile and recalculate nutrition
 */
async function updateUserProfile(userId, profileData) {
  const conn = await pool.getConnection();
  try {
    // Calculate nutrition
    const nutrition = calculator.calculateNutrition(profileData);
    const calculatedCalories = nutrition.dailyCalories;

    // Update or insert profile
    const [existing] = await conn.query(
      "SELECT id FROM user_profiles WHERE user_id = ?",
      [userId],
    );

    if (existing.length > 0) {
      await conn.query(
        `UPDATE user_profiles SET 
          height = ?, weight = ?, age = ?, gender = ?, 
          activity_level = ?, goal = ?, diet_preference = ?, 
          disliked_ingredients = ?, calculated_calories = ?
          WHERE user_id = ?`,
        [
          profileData.height,
          profileData.weight,
          profileData.age,
          profileData.gender,
          profileData.activity_level,
          profileData.goal,
          profileData.diet_preference,
          profileData.disliked_ingredients,
          calculatedCalories,
          userId,
        ],
      );
    } else {
      await conn.query(
        `INSERT INTO user_profiles 
          (user_id, height, weight, age, gender, activity_level, goal, diet_preference, disliked_ingredients, calculated_calories)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          userId,
          profileData.height,
          profileData.weight,
          profileData.age,
          profileData.gender,
          profileData.activity_level,
          profileData.goal,
          profileData.diet_preference,
          profileData.disliked_ingredients,
          calculatedCalories,
        ],
      );
    }

    return nutrition;
  } finally {
    conn.release();
  }
}

module.exports = {
  getUserProfile,
  updateUserProfile,
};
