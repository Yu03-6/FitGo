const { Resend } = require("resend");

// Ensure .env is loaded
if (!process.env.RESEND_API_KEY) {
  console.warn(
    "RESEND_API_KEY is not configured, email sending will be unavailable",
  );
}

const resend = new Resend(process.env.RESEND_API_KEY);
const FROM_EMAIL = process.env.RESEND_FROM_EMAIL || "no-reply@fitgo1.xyz";

/**
 * Generate a random 6-digit OTP code
 */
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Send OTP email for registration
 */
async function sendRegistrationOTP(email, otp) {
  try {
    console.log(
      `Sending registration OTP email: ${email} (from: ${FROM_EMAIL})`,
    );
    const response = await resend.emails.send({
      from: FROM_EMAIL,
      to: email,
      subject: "FitGo - Verify Your Email (Registration)",
      html: `
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background: linear-gradient(135deg, #6b84ef 0%, #764ba2 100%); padding: 30px; border-radius: 10px; text-align: center; color: white; margin-bottom: 20px;">
            <h1 style="margin: 0; font-size: 28px;">FitGo</h1>
            <p style="margin: 10px 0 0 0; font-size: 14px;">Your Fitness Journey Starts Here</p>
          </div>
          
          <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="color: #333; margin-top: 0;">Welcome to FitGo!</h2>
            <p style="color: #666; font-size: 14px; line-height: 1.6;">
              Thank you for signing up. To complete your registration, please verify your email address using the code below:
            </p>
            
            <div style="background-color: white; padding: 25px; border-radius: 8px; text-align: center; margin: 25px 0; border: 2px solid #667eea;">
              <p style="color: #999; font-size: 12px; margin: 0 0 10px 0;">YOUR VERIFICATION CODE</p>
              <p style="color: #667eea; font-size: 32px; font-weight: bold; letter-spacing: 8px; margin: 0; font-family: 'Courier New', monospace;">${otp}</p>
              <p style="color: #999; font-size: 11px; margin: 10px 0 0 0;">This code will expire in 5 minutes</p>
            </div>
            
            <p style="color: #333; font-size: 14px; margin: 15px 0;">
              <strong>Security Tip:</strong> Never share this code with anyone. Our team will never ask for this code.
            </p>
          </div>
          
          <div style="border-top: 1px solid #e0e0e0; padding-top: 15px; text-align: center; color: #999; font-size: 12px;">
            <p style="margin: 0;">
              If you didn't create this account, you can safely ignore this email.
            </p>
            <p style="margin: 5px 0 0 0;">
              © 2026 FitGo. All rights reserved.
            </p>
          </div>
        </div>
      `,
    });

    console.log(`Registration OTP email sent, Message ID: ${response.id}`);
    return { success: true, messageId: response.id };
  } catch (error) {
    console.error("Failed to send registration OTP email:", error.message);
    console.error("Error details:", error);
    throw error;
  }
}

/**
 * Send OTP email for password reset
 */
async function sendPasswordResetOTP(email, otp) {
  try {
    console.log(
      `Sending password reset OTP email: ${email} (from: ${FROM_EMAIL})`,
    );
    const response = await resend.emails.send({
      from: FROM_EMAIL,
      to: email,
      subject: "FitGo - Reset Your Password",
      html: `
        <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px; text-align: center; color: white; margin-bottom: 20px;">
            <h1 style="margin: 0; font-size: 28px;">FitGo</h1>
            <p style="margin: 10px 0 0 0; font-size: 14px;">Your Fitness Journey Starts Here</p>
          </div>
          
          <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="color: #333; margin-top: 0;">Password Reset Request</h2>
            <p style="color: #666; font-size: 14px; line-height: 1.6;">
              We received a request to reset your password. Use the code below to proceed with resetting your password:
            </p>
            
            <div style="background-color: white; padding: 25px; border-radius: 8px; text-align: center; margin: 25px 0; border: 2px solid #667eea;">
              <p style="color: #999; font-size: 12px; margin: 0 0 10px 0;">PASSWORD RESET CODE</p>
              <p style="color: #667eea; font-size: 32px; font-weight: bold; letter-spacing: 8px; margin: 0; font-family: 'Courier New', monospace;">${otp}</p>
              <p style="color: #999; font-size: 11px; margin: 10px 0 0 0;">This code will expire in 10 minutes</p>
            </div>
            
            <p style="color: #e74c3c; font-size: 13px; margin: 15px 0; padding: 10px; background-color: #ffebee; border-left: 3px solid #e74c3c; border-radius: 4px;">
              <strong>Security Alert:</strong> If you didn't request this password reset, please ignore this email and your account will remain secure.
            </p>
          </div>
          
          <div style="border-top: 1px solid #e0e0e0; padding-top: 15px; text-align: center; color: #999; font-size: 12px;">
            <p style="margin: 0;">
              For security reasons, do not share this code with anyone.
            </p>
            <p style="margin: 5px 0 0 0;">
              © 2026 FitGo. All rights reserved.
            </p>
          </div>
        </div>
      `,
    });

    console.log(`Password reset OTP email sent, Message ID: ${response.id}`);
    return { success: true, messageId: response.id };
  } catch (error) {
    console.error("Failed to send password reset OTP email:", error.message);
    console.error("Error details:", error);
    throw error;
  }
}

module.exports = {
  generateOTP,
  sendRegistrationOTP,
  sendPasswordResetOTP,
};
