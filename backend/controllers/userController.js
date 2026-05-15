const userService = require("../services/userService");

/**
 * POST /user/profile
 * Update user profile and auto-calculate calories
 */
async function updateProfile(req, res) {
  try {
    const userId = req.userId;
    const {
      height,
      weight,
      age,
      gender,
      activity_level,
      goal,
      diet_preference,
      disliked_ingredients,
    } = req.body;

    // Validation
    if (
      !height ||
      !weight ||
      !age ||
      !gender ||
      !activity_level ||
      !goal ||
      !diet_preference
    ) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    if (activity_level < 1.2 || activity_level > 1.9) {
      return res
        .status(400)
        .json({ error: "Activity level must be between 1.2 and 1.9" });
    }

    const profileData = {
      height,
      weight,
      age,
      gender,
      activity_level,
      goal,
      diet_preference,
      disliked_ingredients: disliked_ingredients || "",
    };

    const nutrition = await userService.updateUserProfile(userId, profileData);

    res.json({
      message: "Profile updated successfully",
      nutrition,
    });
  } catch (error) {
    console.error("Profile update error:", error);
    res.status(500).json({ error: "Failed to update profile" });
  }
}

/**
 * GET /user/profile
 * Retrieve user profile
 */
async function getProfile(req, res) {
  try {
    const userId = req.userId;
    const profile = await userService.getUserProfile(userId);

    if (!profile) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(profile);
  } catch (error) {
    console.error("Profile fetch error:", error);
    res.status(500).json({ error: "Failed to fetch profile" });
  }
}

module.exports = {
  updateProfile,
  getProfile,
};
