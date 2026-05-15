/**
 * Calculator Utility
 * Implements Mifflin-St Jeor formula and macro distribution
 */

/**
 * Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor formula
 * @param {number} weight - Weight in kg
 * @param {number} height - Height in cm
 * @param {number} age - Age in years
 * @param {string} gender - 'male' or 'female'
 * @returns {number} BMR in kcal
 */
function calculateBMR(weight, height, age, gender) {
  if (gender === 'male') {
    return (10 * weight) + (6.25 * height) - (5 * age) + 5;
  } else {
    return (10 * weight) + (6.25 * height) - (5 * age) - 161;
  }
}

/**
 * Calculate TDEE (Total Daily Energy Expenditure)
 * @param {number} bmr - Basal Metabolic Rate
 * @param {number} activityLevel - Activity multiplier (1.2-1.9)
 * @returns {number} TDEE in kcal
 */
function calculateTDEE(bmr, activityLevel) {
  return Math.round(bmr * activityLevel);
}

/**
 * Adjust calories based on fitness goal
 * @param {number} tdee - Total Daily Energy Expenditure
 * @param {string} goal - 'lose_weight', 'build_muscle', or 'keep_fit'
 * @returns {number} Adjusted daily calories
 */
function adjustCaloriesByGoal(tdee, goal) {
  switch (goal) {
    case 'lose_weight':
      return tdee - 500;
    case 'build_muscle':
      return tdee + 400;
    case 'keep_fit':
    default:
      return tdee;
  }
}

/**
 * Get macro distribution percentages based on goal
 * @param {string} goal - 'lose_weight', 'build_muscle', or 'keep_fit'
 * @returns {object} { carbPercent, proteinPercent, fatPercent }
 */
function getMacroDistribution(goal) {
  switch (goal) {
    case 'build_muscle':
      return { carbPercent: 40, proteinPercent: 30, fatPercent: 30 };
    case 'lose_weight':
      return { carbPercent: 25, proteinPercent: 45, fatPercent: 30 };
    case 'keep_fit':
    default:
      return { carbPercent: 45, proteinPercent: 25, fatPercent: 30 };
  }
}

/**
 * Calculate macronutrient breakdown
 * @param {number} dailyCalories - Total daily calories
 * @param {string} goal - Fitness goal
 * @returns {object} { carbGrams, proteinGrams, fatGrams }
 */
function calculateMacros(dailyCalories, goal) {
  const distribution = getMacroDistribution(goal);

  // Calculate calories from each macro
  const carbCalories = dailyCalories * (distribution.carbPercent / 100);
  const proteinCalories = dailyCalories * (distribution.proteinPercent / 100);
  const fatCalories = dailyCalories * (distribution.fatPercent / 100);

  // Convert to grams (carbs: 4 kcal/g, protein: 4 kcal/g, fat: 9 kcal/g)
  return {
    carbGrams: Math.round(carbCalories / 4),
    proteinGrams: Math.round(proteinCalories / 4),
    fatGrams: Math.round(fatCalories / 9)
  };
}

/**
 * Complete calculation pipeline
 * @param {object} userProfile - { weight, height, age, gender, activity_level, goal }
 * @returns {object} { dailyCalories, carbGrams, proteinGrams, fatGrams }
 */
function calculateNutrition(userProfile) {
  const { weight, height, age, gender, activity_level, goal } = userProfile;

  const bmr = calculateBMR(weight, height, age, gender);
  const tdee = calculateTDEE(bmr, activity_level);
  const dailyCalories = adjustCaloriesByGoal(tdee, goal);
  const macros = calculateMacros(dailyCalories, goal);

  return {
    dailyCalories,
    ...macros
  };
}

module.exports = {
  calculateBMR,
  calculateTDEE,
  adjustCaloriesByGoal,
  getMacroDistribution,
  calculateMacros,
  calculateNutrition
};
