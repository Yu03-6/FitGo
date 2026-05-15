const axios = require("axios");
require("dotenv").config();

const SPOONACULAR_BASE_URL = process.env.SPOONACULAR_BASE_URL;
const API_KEY = process.env.SPOONACULAR_API_KEY;

/**
 * Convert diet_preference to Spoonacular diet type
 */
function mapDietType(dietPreference) {
  const dietMap = {
    standard: "balanced",
    vegetarian: "vegetarian",
    keto: "ketogenic",
    vegan: "vegan",
  };
  return dietMap[dietPreference] || "balanced";
}

/**
 * Generate meal plan from Spoonacular API
 * @param {number} calories - Target daily calories
 * @param {string} dietPreference - standard, vegetarian, keto, vegan
 * @param {string} excludeIngredients - Comma-separated ingredients to exclude
 * @returns {object} Complete meal plan JSON from API
 */
async function generateMealPlan(
  calories,
  dietPreference,
  excludeIngredients = "",
) {
  try {
    const diet = mapDietType(dietPreference);

    // Build query parameters
    const params = {
      apiKey: API_KEY,
      timeFrame: "day",
      targetCalories: calories,
      diet: diet,
    };

    // Add excluded ingredients if provided
    if (excludeIngredients && excludeIngredients.trim()) {
      params.exclude = excludeIngredients;
    }

    // Call Spoonacular API
    console.log(" Calling Spoonacular API with params:", {
      ...params,
      apiKey: "hidden",
    });
    const response = await axios.get(SPOONACULAR_BASE_URL, {
      params,
      timeout: 10000,
    });

    // The response contains the meal plan for the day
    // Structure: { meals: [...], nutrients: {...} }
    console.log("Spoonacular API responded successfully");
    console.log("API Response Status:", response.status);
    console.log("API Response Data Structure:");
    console.log("   - meals count:", response.data.meals?.length || 0);
    console.log(
      "   - nutrients:",
      response.data.nutrients ? "present" : "absent",
    );

    if (response.data.meals && response.data.meals.length > 0) {
      console.log("\nMeals Details:");
      response.data.meals.forEach((meal, index) => {
        console.log(`\n   Meal ${index + 1}:`);
        console.log(`     - id: ${meal.id}`);
        console.log(`     - title: ${meal.title}`);
        console.log(`     - readyInMinutes: ${meal.readyInMinutes}`);
        console.log(`     - servings: ${meal.servings}`);
        console.log(`     - sourceUrl: ${meal.sourceUrl}`);
        console.log(`     - image: ${meal.image}`);
        console.log(`     - imageType: ${meal.imageType}`);
      });
    }

    if (response.data.nutrients) {
      console.log("\nNutrients:");
      console.log(`   - calories: ${response.data.nutrients.calories}`);
      console.log(`   - protein: ${response.data.nutrients.protein}`);
      console.log(`   - fat: ${response.data.nutrients.fat}`);
      console.log(
        `   - carbohydrates: ${response.data.nutrients.carbohydrates}`,
      );
    }

    console.log("\nFull API Response:", JSON.stringify(response.data, null, 2));

    return response.data;
  } catch (error) {
    console.error("Spoonacular API error:", error.message);

    if ([401, 402, 403].includes(error.response?.status)) {
      throw new Error(
        `API error (${error.response?.status}). Please check your API key or quota.`,
      );
    }

    throw new Error("Failed to generate meal plan: " + error.message);
  }
}

/**
 * Get detailed recipe information
 * Useful for fetching full instructions and cooking steps
 * @param {number} recipeId - Recipe ID from meal plan
 * @returns {object} Detailed recipe information
 */
async function getRecipeInformation(recipeId) {
  try {
    console.log(`\nFetching recipe details: ID=${recipeId}`);
    const url = `https://api.spoonacular.com/recipes/${recipeId}/information`;
    const response = await axios.get(url, {
      params: {
        apiKey: API_KEY,
        addRecipeInformation: true,
        includeNutrition: true,
      },
    });

    console.log(`Recipe ${recipeId} details fetched successfully`);
    console.log("   Details:");
    console.log(`     - title: ${response.data.title}`);
    console.log(`     - readyInMinutes: ${response.data.readyInMinutes}`);
    console.log(`     - servings: ${response.data.servings}`);
    console.log(
      `     - instructions length: ${response.data.instructions?.length || 0} chars`,
    );
    console.log(`     - sourceUrl: ${response.data.sourceUrl}`);

    return response.data;
  } catch (error) {
    console.error("Recipe Information Error:", error.message);
    throw new Error("Failed to fetch recipe details: " + error.message);
  }
}

/**
 * Enrich meal plan with detailed recipe information
 * @param {object} mealPlan - Raw meal plan from API
 * @returns {object} Enriched meal plan with full instructions
 */
async function enrichMealPlan(mealPlan) {
  try {
    console.log("\nEnriching meal plan data...");

    if (!mealPlan.meals || mealPlan.meals.length === 0) {
      console.log("   No meals to enrich");
      return mealPlan;
    }

    console.log(`   Need to enrich ${mealPlan.meals.length} meals`);

    // Fetch details for each meal (if IDs available)
    const enrichedMeals = await Promise.all(
      mealPlan.meals.map(async (meal, index) => {
        try {
          if (meal.id) {
            console.log(
              `\n   [${index + 1}/${mealPlan.meals.length}] Enriching meal: ${meal.title} (ID: ${meal.id})`,
            );

            // Fix image URL if it's not a complete URL
            let imageUrl = meal.image;
            if (
              imageUrl &&
              !imageUrl.startsWith("http://") &&
              !imageUrl.startsWith("https://")
            ) {
              // Convert relative image path to full URL
              imageUrl = `https://spoonacular.com/recipeImages/${imageUrl}`;
              console.log(`       Fixed image URL: ${imageUrl}`);
            }

            const details = await getRecipeInformation(meal.id);
            // Extract key macro nutrients if available
            const nutrients = details.nutrition?.nutrients;
            const pick = (name) =>
              nutrients?.find(
                (n) => n.name?.toLowerCase() === name.toLowerCase(),
              );
            const nutrition = nutrients
              ? {
                  calories: pick("Calories")?.amount,
                  carbohydrates: pick("Carbohydrates")?.amount,
                  protein: pick("Protein")?.amount,
                  fat: pick("Fat")?.amount,
                }
              : undefined;
            // Merge original meal data with detailed information
            // Use detail's image if available (it's a full URL), otherwise use corrected meal image
            const enriched = {
              ...meal,
              image: details.image || imageUrl,
              instructions:
                details.instructions ||
                meal.instructions ||
                "No instructions available",
              servings: details.servings || meal.servings || 1,
              prepTimeMinutes:
                details.readyInMinutes || meal.readyInMinutes || 0,
              source: details.sourceUrl || meal.sourceUrl || "",
              nutrition,
            };
            console.log(`       ✅ Enriched successfully`);
            return enriched;
          }
          console.log(`   Meal ${index + 1} has no ID, skipping enrichment`);
          return meal;
        } catch (e) {
          console.warn(`   Could not enrich meal ${meal.id}:`, e.message);
          // Fix image URL even if enrichment fails
          let imageUrl = meal.image;
          if (
            imageUrl &&
            !imageUrl.startsWith("http://") &&
            !imageUrl.startsWith("https://")
          ) {
            imageUrl = `https://spoonacular.com/recipeImages/${imageUrl}`;
          }
          return { ...meal, image: imageUrl };
        }
      }),
    );

    console.log("\nMeal Plan enrichment complete");
    return {
      ...mealPlan,
      meals: enrichedMeals,
    };
  } catch (error) {
    console.error("Meal enrichment error:", error.message);
    // Return original plan if enrichment fails
    return mealPlan;
  }
}

module.exports = {
  generateMealPlan,
  getRecipeInformation,
  enrichMealPlan,
};
