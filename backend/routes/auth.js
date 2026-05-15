const express = require("express");
const authController = require("../controllers/authController");

const router = express.Router();

// OTP flows
router.post("/send-otp", authController.sendOTP);
router.post("/verify-otp", authController.verifyOTP);
router.post("/verify-forgot-otp", authController.verifyForgotOTP);

// Registration and login
router.post("/register", authController.register);
router.post("/login", authController.login);

// Password reset
router.post("/forgot-password", authController.forgotPassword);
router.post("/reset-password", authController.resetPassword);

module.exports = router;
