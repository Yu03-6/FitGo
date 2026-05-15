const express = require("express");
const mealController = require("../controllers/mealController");
const { verifyToken } = require("../middleware/auth");

const router = express.Router();

// Image proxy does not require auth so that Flutter web Image.network can load without headers
router.get("/image/:id", mealController.proxyMealImage);

router.use(verifyToken);

router.post("/generate", mealController.generateMealPlan);
router.post("/save", mealController.saveMealPlan);
router.get("/favorites", mealController.getFavoritePlans);
router.get("/favorites/:id", mealController.getMealPlanDetail);
router.delete("/favorites/:id", mealController.deleteMealPlan);

module.exports = router;
