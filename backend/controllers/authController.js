const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { v4: uuidv4 } = require("uuid");
const pool = require("../config/database");
const {
  generateOTP,
  sendRegistrationOTP,
  sendPasswordResetOTP,
} = require("../utils/emailService");

/**
 * Validate password strength
 * Requires: 8-10 chars, 1 uppercase, 1 lowercase, 1 number
 */
function validatePassword(password) {
  const errors = [];

  if (password.length < 8) {
    errors.push("Password must be at least 8 characters");
  }
  if (password.length > 15) {
    errors.push("Password must be at most 15 characters");
  }
  if (!/[A-Z]/.test(password)) {
    errors.push("Password must contain at least one uppercase letter");
  }
  if (!/[a-z]/.test(password)) {
    errors.push("Password must contain at least one lowercase letter");
  }
  if (!/[0-9]/.test(password)) {
    errors.push("Password must contain at least one number");
  }

  return errors;
}

/**
 * Validate email format
 */
function validateEmail(email) {
  const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
  return emailRegex.test(email);
}

/**
 * POST /auth/send-otp
 * Send OTP code to email (for registration or password reset)
 * @param {string} email - User email
 * @param {string} type - 'registration' or 'password_reset'
 */
async function sendOTP(req, res) {
  try {
    const { email, type } = req.body;

    if (!email || !type) {
      return res.status(400).json({ error: "Email and type required" });
    }

    if (!validateEmail(email)) {
      return res.status(400).json({ error: "Invalid email format" });
    }

    if (!["registration", "password_reset"].includes(type)) {
      return res.status(400).json({ error: "Invalid OTP type" });
    }

    const conn = await pool.getConnection();
    try {
      // Check email status based on type
      if (type === "registration") {
        // For registration: email must not already exist
        const [existing] = await conn.query(
          "SELECT id FROM users WHERE email = ?",
          [email],
        );
        if (existing.length > 0) {
          return res
            .status(400)
            .json({ error: "The email address already exists." });
        }
      } else if (type === "password_reset") {
        // For password reset: email must exist and be verified
        const [existing] = await conn.query(
          "SELECT id FROM users WHERE email = ? AND is_email_verified = true",
          [email],
        );
        if (existing.length === 0) {
          // For security, don't reveal if email exists
          return res.status(200).json({
            message: "If email is registered, OTP has been sent",
          });
        }
      }

      // Generate OTP (6-digit code)
      const otp = generateOTP();
      const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

      // Store OTP in database
      await conn.query(
        "INSERT INTO otp_codes (email, code, type, expires_at) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE code = ?, type = ?, expires_at = ?",
        [email, otp, type, expiresAt, otp, type, expiresAt],
      );

      // Send OTP email
      if (type === "registration") {
        await sendRegistrationOTP(email, otp);
      } else {
        await sendPasswordResetOTP(email, otp);
      }

      res.json({
        message: "OTP sent successfully",
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Send OTP error:", error);
    res.status(500).json({ error: "Failed to send OTP" });
  }
}

/**
 * POST /auth/verify-otp
 * Verify OTP code
 * @param {string} email - User email
 * @param {string} code - OTP code to verify
 * @param {string} type - 'registration' or 'password_reset'
 */
async function verifyOTP(req, res) {
  try {
    const { email, code, type } = req.body;

    if (!email || !code || !type) {
      return res.status(400).json({ error: "Email, code, and type required" });
    }

    const conn = await pool.getConnection();
    try {
      // Get OTP record
      const [rows] = await conn.query(
        "SELECT id, code, expires_at, type FROM otp_codes WHERE email = ?",
        [email],
      );

      if (rows.length === 0) {
        return res.status(400).json({ error: "OTP not found" });
      }

      const otpRecord = rows[0];

      // Check OTP type match
      if (otpRecord.type !== type) {
        return res.status(400).json({ error: "Invalid OTP type" });
      }

      // Check if OTP is expired
      if (new Date() > new Date(otpRecord.expires_at)) {
        return res.status(400).json({ error: "OTP has expired" });
      }

      // Check if code matches
      if (otpRecord.code !== code) {
        return res.status(400).json({ error: "Invalid OTP code" });
      }

      // Mark OTP as verified
      await conn.query("UPDATE otp_codes SET is_verified = true WHERE id = ?", [
        otpRecord.id,
      ]);

      res.json({
        message: "OTP verified successfully",
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Verify OTP error:", error);
    res.status(500).json({ error: "OTP verification failed" });
  }
}

/**
 * POST /auth/register
 * Register new user after OTP verification
 * @param {string} email - User email
 * @param {string} username - User display name
 * @param {string} password - User password
 * @param {string} repassword - Password confirmation
 */
async function register(req, res) {
  try {
    const { email, username, password, repassword } = req.body;

    if (!email || !username || !password || !repassword) {
      return res.status(400).json({
        error: "Email, username, password, and repassword required",
      });
    }

    // Check passwords match
    if (password !== repassword) {
      return res.status(400).json({ error: "Passwords do not match" });
    }

    // Validate email format
    if (!validateEmail(email)) {
      return res.status(400).json({ error: "Invalid email format" });
    }

    // Validate password strength
    const passwordErrors = validatePassword(password);
    if (passwordErrors.length > 0) {
      return res.status(400).json({
        error: "Password does not meet requirements",
        details: passwordErrors,
      });
    }

    const conn = await pool.getConnection();
    try {
      // Check if OTP was verified
      const [otpRecords] = await conn.query(
        "SELECT id, is_verified FROM otp_codes WHERE email = ? AND type = ?",
        [email, "registration"],
      );

      if (otpRecords.length === 0 || !otpRecords[0].is_verified) {
        return res.status(400).json({ error: "Please verify OTP first" });
      }

      // Check if email already registered
      const [existing] = await conn.query(
        "SELECT id FROM users WHERE email = ?",
        [email],
      );

      if (existing.length > 0) {
        return res
          .status(409)
          .json({ error: "The email address already exists." });
      }

      // Hash password
      const passwordHash = await bcrypt.hash(password, 10);
      const userId = uuidv4();

      // Create user with email verified
      await conn.query(
        "INSERT INTO users (id, email, username, password_hash, is_email_verified) VALUES (?, ?, ?, ?, true)",
        [userId, email, username, passwordHash],
      );

      // Clean up OTP record
      await conn.query("DELETE FROM otp_codes WHERE email = ? AND type = ?", [
        email,
        "registration",
      ]);

      // Generate JWT token
      const token = jwt.sign({ userId }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRY,
      });

      res.status(201).json({
        message: "User registered successfully",
        userId,
        token,
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Register error:", error);
    res.status(500).json({ error: "Registration failed" });
  }
}

/**
 * POST /auth/login
 * Login user with email and password
 */
async function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res
        .status(400)
        .json({ error: "Email or password is incorrect. Please try again." });
    }

    const conn = await pool.getConnection();
    try {
      // Get user with email verified check
      const [rows] = await conn.query(
        "SELECT id, username, password_hash, is_email_verified FROM users WHERE email = ?",
        [email],
      );

      if (rows.length === 0) {
        return res
          .status(401)
          .json({ error: "Email or password is incorrect. Please try again." });
      }

      const user = rows[0];

      // Check if email is verified
      if (!user.is_email_verified) {
        return res.status(401).json({ error: "Email not verified" });
      }

      // Check password
      const passwordMatch = await bcrypt.compare(password, user.password_hash);

      if (!passwordMatch) {
        return res
          .status(401)
          .json({ error: "Email or password is incorrect. Please try again." });
      }

      // Generate JWT token
      const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRY,
      });

      res.json({
        message: "Login successful",
        userId: user.id,
        username: user.username,
        token,
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ error: "Login failed" });
  }
}

/**
 * POST /auth/forgot-password
 * Initiate password reset by sending OTP
 */
async function forgotPassword(req, res) {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: "Email required" });
    }

    const conn = await pool.getConnection();
    try {
      // Check if email exists and is verified
      const [rows] = await conn.query(
        "SELECT id FROM users WHERE email = ? AND is_email_verified = true",
        [email],
      );

      // For security, don't reveal if email exists
      if (rows.length === 0) {
        return res.status(200).json({
          message: "If email is registered, OTP has been sent",
        });
      }

      // Generate OTP
      const otp = generateOTP();
      const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

      // Store OTP
      await conn.query(
        "INSERT INTO otp_codes (email, code, type, expires_at) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE code = ?, type = ?, expires_at = ?",
        [
          email,
          otp,
          "password_reset",
          expiresAt,
          otp,
          "password_reset",
          expiresAt,
        ],
      );

      // Send OTP email
      await sendPasswordResetOTP(email, otp);

      res.json({
        message: "OTP sent successfully",
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Forgot password error:", error);
    res.status(500).json({ error: "Failed to send OTP" });
  }
}

/**
 * POST /auth/verify-forgot-otp
 * Verify OTP for password reset
 */
async function verifyForgotOTP(req, res) {
  try {
    const { email, code } = req.body;

    if (!email || !code) {
      return res.status(400).json({ error: "Email and code required" });
    }

    const conn = await pool.getConnection();
    try {
      // Get OTP record
      const [rows] = await conn.query(
        "SELECT id, code, expires_at, type FROM otp_codes WHERE email = ? AND type = ?",
        [email, "password_reset"],
      );

      if (rows.length === 0) {
        return res.status(400).json({ error: "OTP not found" });
      }

      const otpRecord = rows[0];

      // Check if expired
      if (new Date() > new Date(otpRecord.expires_at)) {
        return res.status(400).json({ error: "OTP has expired" });
      }

      // Check code
      if (otpRecord.code !== code) {
        return res.status(400).json({ error: "Invalid OTP code" });
      }

      // Mark as verified
      await conn.query("UPDATE otp_codes SET is_verified = true WHERE id = ?", [
        otpRecord.id,
      ]);

      res.json({
        message: "OTP verified successfully",
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Verify forgot OTP error:", error);
    res.status(500).json({ error: "OTP verification failed" });
  }
}

/**
 * POST /auth/reset-password
 * Reset password after OTP verification
 * @param {string} email - User email
 * @param {string} password - New password
 * @param {string} repassword - Password confirmation
 */
async function resetPassword(req, res) {
  try {
    const { email, password, repassword } = req.body;

    if (!email || !password || !repassword) {
      return res.status(400).json({
        error: "Email, password, and repassword required",
      });
    }

    // Check passwords match
    if (password !== repassword) {
      return res.status(400).json({ error: "Passwords do not match" });
    }

    // Validate password strength
    const passwordErrors = validatePassword(password);
    if (passwordErrors.length > 0) {
      return res.status(400).json({
        error: "Password does not meet requirements",
        details: passwordErrors,
      });
    }

    const conn = await pool.getConnection();
    try {
      // Check if OTP was verified
      const [otpRecords] = await conn.query(
        "SELECT id, is_verified FROM otp_codes WHERE email = ? AND type = ?",
        [email, "password_reset"],
      );

      if (otpRecords.length === 0 || !otpRecords[0].is_verified) {
        return res.status(400).json({ error: "Please verify OTP first" });
      }

      // Get user
      const [userRows] = await conn.query(
        "SELECT id FROM users WHERE email = ?",
        [email],
      );

      if (userRows.length === 0) {
        return res.status(404).json({ error: "User not found" });
      }

      // Hash new password
      const passwordHash = await bcrypt.hash(password, 10);
      const userId = userRows[0].id;

      // Update password
      await conn.query("UPDATE users SET password_hash = ? WHERE id = ?", [
        passwordHash,
        userId,
      ]);

      // Clean up OTP record
      await conn.query("DELETE FROM otp_codes WHERE email = ? AND type = ?", [
        email,
        "password_reset",
      ]);

      res.json({
        message: "Password reset successfully",
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Reset password error:", error);
    res.status(500).json({ error: "Password reset failed" });
  }
}

module.exports = {
  sendOTP,
  verifyOTP,
  register,
  login,
  forgotPassword,
  verifyForgotOTP,
  resetPassword,
};
