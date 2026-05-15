const { v4: uuidv4 } = require("uuid");
const pool = require("../config/database");
const userService = require("../services/userService");
const spoonacular = require("../services/spoonacular");
const axios = require("axios");

/**
 * POST /meal/generate
 * Generate meal plan based on user profile
 */
async function generateMealPlan(req, res) {
  try {
    const userId = req.userId;

    // Get user profile with calculated calories
    const profile = await userService.getUserProfile(userId);
    if (!profile) {
      return res.status(404).json({
        error: "User profile not found. Please complete profile setup.",
      });
    }

    // Use provided parameters from request, fallback to profile data
    const dailyCalories = req.body.dailyCalories || profile.calculated_calories;
    const dietPreference = req.body.dietPreference || profile.diet_preference;
    const dislikedIngredients =
      req.body.dislikedIngredients || profile.disliked_ingredients;

    if (!dailyCalories) {
      return res.status(400).json({
        error: "Calories not calculated. Please update profile first.",
      });
    }

    console.log(
      `Generating Meal Plan: user=${userId}, calories=${dailyCalories}, diet=${dietPreference}`,
    );

    // Generate meal plan from Spoonacular
    let mealPlan = await spoonacular.generateMealPlan(
      dailyCalories,
      dietPreference,
      dislikedIngredients,
    );

    console.log("Meal Plan API raw response:");
    if (mealPlan.meals) {
      mealPlan.meals.forEach((meal, i) => {
        console.log(`   Meal ${i + 1}: ${meal.title}`);
        console.log(`     - original image: ${meal.image}`);
      });
    }

    // Enrich with detailed recipe information
    mealPlan = await spoonacular.enrichMealPlan(mealPlan);

    // Manually ensure all image URLs are complete, and provide same-origin proxy for CORS
    if (mealPlan.meals && Array.isArray(mealPlan.meals)) {
      const baseUrl = `${req.protocol}://${req.get("host")}`;

      mealPlan.meals = mealPlan.meals.map((meal) => {
        let image = meal.image;
        if (
          image &&
          !image.startsWith("http://") &&
          !image.startsWith("https://")
        ) {
          console.log(`Fixing image URL: ${meal.title}`);
          console.log(`   original: ${image}`);
          image = `https://spoonacular.com/recipeImages/${image}`;
          console.log(`   fixed: ${image}`);
        }

        // Provide same-origin proxy URL to avoid CORS restrictions for Flutter Web CanvasKit
        const proxyImage = meal.id
          ? `${baseUrl}/meal/image/${meal.id}`
          : undefined;

        return { ...meal, image, imageProxy: proxyImage };
      });
    }

    console.log(
      `Meal Plan generated successfully: total calories=${mealPlan.nutrients?.calories || 0} kcal`,
    );

    // Debug: print final meal image URLs to be returned to frontend
    console.log("\nMeal Plan to be returned to frontend:");
    if (mealPlan.meals && Array.isArray(mealPlan.meals)) {
      mealPlan.meals.forEach((meal, index) => {
        console.log(`   Meal ${index + 1}: ${meal.title}`);
        console.log(`     - image: ${meal.image}`);
        console.log(
          `     - is full URL: ${meal.image?.startsWith("http") ? "yes" : "no"}`,
        );
      });
    }

    res.json({
      message: "Meal plan generated successfully",
      mealPlan,
    });
  } catch (error) {
    console.error("Generate meal plan error:", error);
    res
      .status(500)
      .json({ error: error.message || "Failed to generate meal plan" });
  }
}

/**
 * GET /meal/image/:id
 * Proxy recipe images to add CORS headers for web/CanvasKit
 */
async function proxyMealImage(req, res) {
  const { id } = req.params;
  const size = req.query.size || "556x370";

  if (!id || !/^\d+$/.test(id)) {
    return res.status(400).json({ error: "Invalid recipe id" });
  }

  const imageUrl = `https://img.spoonacular.com/recipes/${id}-${size}.jpg`;

  try {
    const response = await axios.get(imageUrl, {
      responseType: "arraybuffer",
      timeout: 10000,
    });

    res.set("Content-Type", response.headers["content-type"] || "image/jpeg");
    res.set("Cache-Control", "public, max-age=86400");
    res.set("Access-Control-Allow-Origin", "*");
    return res.send(Buffer.from(response.data, "binary"));
  } catch (error) {
    console.error("Image proxy error:", error.message);
    return res.status(502).json({ error: "Failed to fetch meal image" });
  }
}

/**
 * POST /meal/save
 * Save meal plan to database
 */
async function saveMealPlan(req, res) {
  try {
    const userId = req.userId;
    const { plan_data, summary } = req.body;

    if (!plan_data) {
      return res.status(400).json({ error: "Meal plan data required" });
    }

    const conn = await pool.getConnection();
    try {
      const planId = uuidv4();
      await conn.query(
        "INSERT INTO saved_meal_plans (id, user_id, plan_data, summary) VALUES (?, ?, ?, ?)",
        [planId, userId, JSON.stringify(plan_data), summary || null],
      );

      res.status(201).json({
        message: "Meal plan saved successfully",
        planId,
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Save meal plan error:", error);
    res.status(500).json({ error: "Failed to save meal plan" });
  }
}

/**
 * GET /meal/favorites
 * Retrieve all saved meal plans
 */
async function getFavoritePlans(req, res) {
  try {
    const userId = req.userId;

    const conn = await pool.getConnection();
    try {
      const [rows] = await conn.query(
        "SELECT id, summary, created_at FROM saved_meal_plans WHERE user_id = ? ORDER BY created_at DESC",
        [userId],
      );

      res.json({
        count: rows.length,
        plans: rows,
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Fetch plans error:", error);
    res.status(500).json({ error: "Failed to fetch meal plans" });
  }
}

/**
 * GET /meal/favorites/:id
 * Retrieve specific saved meal plan
 */
async function getMealPlanDetail(req, res) {
  try {
    const userId = req.userId;
    const { id } = req.params;

    const conn = await pool.getConnection();
    try {
      const [rows] = await conn.query(
        "SELECT * FROM saved_meal_plans WHERE id = ? AND user_id = ?",
        [id, userId],
      );

      if (rows.length === 0) {
        return res.status(404).json({ error: "Meal plan not found" });
      }

      const plan = rows[0];
      // Parse JSON if stored as string
      const planData =
        typeof plan.plan_data === "string"
          ? JSON.parse(plan.plan_data)
          : plan.plan_data;

      res.json({
        ...plan,
        plan_data: planData,
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Fetch plan detail error:", error);
    res.status(500).json({ error: "Failed to fetch meal plan" });
  }
}

/**
 * DELETE /meal/favorites/:id
 * Delete saved meal plan
 */
async function deleteMealPlan(req, res) {
  try {
    const userId = req.userId;
    const { id } = req.params;

    const conn = await pool.getConnection();
    try {
      const [result] = await conn.query(
        "DELETE FROM saved_meal_plans WHERE id = ? AND user_id = ?",
        [id, userId],
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: "Meal plan not found" });
      }

      res.json({ message: "Meal plan deleted successfully" });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Delete meal plan error:", error);
    res.status(500).json({ error: "Failed to delete meal plan" });
  }
}

module.exports = {
  generateMealPlan,
  saveMealPlan,
  getFavoritePlans,
  getMealPlanDetail,
  deleteMealPlan,
  proxyMealImage,
};
