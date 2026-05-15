import 'package:flutter/material.dart';
import '../screens/onboarding_page.dart';
import '../screens/home_page.dart';
import '../screens/recipe_detail_page.dart';
import '../screens/favorites_page.dart';
import '../screens/email_verification_page.dart';
import '../screens/forgot_password_page.dart';
import '../screens/verify_reset_code_page.dart';
import '../screens/reset_password_page.dart';
import '../screens/registration_otp_page.dart';
import '../screens/set_password_page.dart';
import '../screens/forgot_password_otp_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/onboarding':
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
      case '/recipe-detail':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RecipeDetailPage(
            recipe: args?['recipe'],
            mealType: args?['mealType'],
          ),
        );
      case '/favorites':
        return MaterialPageRoute(
          builder: (_) => const FavoritesPage(),
        );
      case '/email-verification':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EmailVerificationPage(
            email: args?['email'] ?? '',
            userId: args?['userId'] ?? '',
          ),
        );
      case '/forgot-password':
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
        );
      case '/verify-reset-code':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => VerifyResetCodePage(
            email: args?['email'] ?? '',
          ),
        );
      case '/reset-password':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordPage(
            email: args?['email'] ?? '',
          ),
        );
      case '/registration-otp':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RegistrationOTPPage(
            email: args?['email'] ?? '',
          ),
        );
      case '/set-password':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SetPasswordPage(
            email: args?['email'] ?? '',
          ),
        );
      case '/forgot-password-otp':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordOTPPage(
            email: args?['email'] ?? '',
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
