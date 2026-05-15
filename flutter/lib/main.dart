import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'models/user_profile_model.dart';
import 'router/app_router.dart';
import 'screens/onboarding_page.dart';
import 'screens/home_page.dart';
import 'screens/welcome_dialog.dart';
import 'services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auth status on app startup
    ref.watch(initAuthProvider);

    return MaterialApp(
      title: 'FitGo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.generateRoute,
      navigatorObservers: [_LoginPageState.routeObserver],
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget that routes between login and main app based on auth status
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _hasCheckedProfile = false;
  bool _hasCheckedWelcome = false;
  bool _showWelcome = false;
  final PreferenceService _preferenceService = PreferenceService();

  @override
  void initState() {
    super.initState();
    // Load user profile when authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated && !_hasCheckedProfile) {
        _fetchProfile();
      }
    });
  }

  Future<void> _fetchProfile() async {
    print('_fetchProfile called - _hasCheckedProfile: $_hasCheckedProfile');
    if (_hasCheckedProfile) return;

    setState(() {
      _hasCheckedProfile = true;
    });

    try {
      print('AuthWrapper: Fetching user profile...');
      await ref.read(userProfileProvider.notifier).fetchProfile();
      final profile = ref.read(userProfileProvider);
      print('AuthWrapper: Profile fetch complete');
      print(
          '   - Profile state: ${profile == null ? "null (no data)" : "has data"}');
      if (profile != null) {
        print('   - height: ${profile.height} cm');
        print('   - weight: ${profile.weight} kg');
      }

      // Check if welcome dialog should be shown
      print('Calling _checkWelcomeDialog after profile fetch');
      await _checkWelcomeDialog();
    } catch (e) {
      print('Failed to fetch user profile: $e');
    }
  }

  Future<void> _checkWelcomeDialog() async {
    print(
        '_checkWelcomeDialog called - _hasCheckedWelcome: $_hasCheckedWelcome');
    if (_hasCheckedWelcome) return;

    setState(() {
      _hasCheckedWelcome = true;
    });

    try {
      final shouldShow = await _preferenceService.shouldShowWelcomeDialog();
      print('shouldShowWelcomeDialog returned: $shouldShow');
      setState(() {
        _showWelcome = shouldShow;
      });
      print('_showWelcome set to: $_showWelcome');
    } catch (e) {
      print('Failed to check welcome dialog preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userProfile = ref.watch(userProfileProvider);

    // Listen for profile state changes
    ref.listen<UserProfile?>(userProfileProvider, (previous, next) {
      print(
          'UserProfile changed: previous=${previous != null ? "has data" : "null"}, next=${next != null ? "has data" : "null"}');
      // After profile is created (from null to data), reset and check welcome dialog
      if (previous == null && next != null) {
        print('Profile created! Resetting welcome check...');
        setState(() {
          _hasCheckedWelcome = false;
          _showWelcome = false;
        });
        // Check welcome dialog after a short delay to ensure state is updated
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _checkWelcomeDialog();
          }
        });
      }
    });

    // Listen for auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      print('Auth state changed: isAuthenticated=${next.isAuthenticated}');
      // Re-fetch profile after user logs in
      if (next.isAuthenticated &&
          (previous == null || !previous.isAuthenticated)) {
        setState(() {
          _hasCheckedProfile = false;
          _hasCheckedWelcome = false;
          _showWelcome = false;
        });
        _fetchProfile();
      }

      // Reset state after user logs out
      if (!next.isAuthenticated &&
          (previous != null && previous.isAuthenticated)) {
        setState(() {
          _hasCheckedProfile = false;
          _hasCheckedWelcome = false;
          _showWelcome = false;
        });
        ref.read(userProfileProvider.notifier).clearProfile();
      }
    });

    // Not authenticated - show login page
    if (!authState.isAuthenticated) {
      return const LoginPage();
    }

    // Authenticated but profile not checked - show loading
    if (!_hasCheckedProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Authenticated but no body data in database - show setup page
    if (userProfile == null) {
      print('Routing: Profile is null -> navigating to OnboardingPage');
      return const OnboardingPage();
    }

    // Show welcome dialog if needed
    if (_showWelcome) {
      print('Showing WelcomeDialog with username: ${authState.username}');
      return WelcomeDialog(
        username: authState.username,
        onContinue: () {
          setState(() {
            _showWelcome = false;
          });
        },
      );
    }

    // Authenticated with body data - navigate to home page
    print('Routing: Profile exists -> navigating to HomePage');
    return const HomePage();
  }
}

/// Login page
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with RouteAware {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _showRegisterForm = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // RouteObserver for tracking route changes
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  /// Validate email format
  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    // Basic email regex validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password requirements
  String? _validatePassword(String? password, {bool isConfirm = false}) {
    if (password == null || password.isEmpty) {
      return isConfirm
          ? 'Please confirm your password'
          : 'Password is required';
    }

    if (!_showRegisterForm) {
      return null; // Skip validation for login
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (password.length > 15) {
      return 'Password must be at most 15 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number';
    }
    return null;
  }

  /// Validate password confirmation matches
  String? _validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    // Called when returning to this page from another page
    // Clear all input fields when returning from registration
    if (mounted) {
      setState(() {
        emailController.clear();
        usernameController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        _passwordVisible = false;
        _confirmPasswordVisible = false;
        _showRegisterForm = false;
      });
      ref.read(authProvider.notifier).clearError();
      _formKey.currentState?.reset();
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitGo'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // App Icon or Logo
              Icon(
                Icons.fitness_center,
                size: 64,
                color: Colors.blue[700],
              ),
              const SizedBox(height: 24),
              Text(
                _showRegisterForm ? 'Create Account' : 'Welcome Back',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _showRegisterForm
                    ? 'Start Your Fitness Journey'
                    : 'Login to continue',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),

              // Username Field (only for registration)
              if (_showRegisterForm) ...[
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your display name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
              ],

              // Password Field
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: _showRegisterForm
                      ? 'Create a strong password'
                      : 'Enter your password',
                  helperText: _showRegisterForm
                      ? '8-10 chars with uppercase, lowercase, and number'
                      : null,
                  helperMaxLines: 2,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  counterText: '',
                ),
                obscureText: !_passwordVisible,
                maxLength: 10,
                textInputAction: _showRegisterForm
                    ? TextInputAction.next
                    : TextInputAction.done,
                validator: (value) => _validatePassword(value),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),

              // Confirm Password Field (only for registration)
              if (_showRegisterForm) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    counterText: '',
                  ),
                  obscureText: !_confirmPasswordVisible,
                  maxLength: 10,
                  textInputAction: TextInputAction.done,
                  validator: _validateConfirmPassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ],

              const SizedBox(height: 24),

              // Error Message
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error ?? '',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              if (authState.error != null) const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          // Validate form
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          try {
                            if (_showRegisterForm) {
                              // Send OTP to email for registration
                              await ref.read(authProvider.notifier).sendOTP(
                                    emailController.text.trim(),
                                    'registration',
                                    username: usernameController.text.trim(),
                                    password: passwordController.text,
                                    repassword: confirmPasswordController.text,
                                  );

                              // Only navigate if sendOTP succeeded (no exception thrown)
                              if (mounted) {
                                Navigator.of(context).pushNamed(
                                  '/registration-otp',
                                  arguments: {
                                    'email': emailController.text.trim(),
                                  },
                                );
                              }
                            } else {
                              // Login user
                              await ref.read(authProvider.notifier).login(
                                    emailController.text.trim(),
                                    passwordController.text,
                                  );
                              // Clear form only on successful login
                              if (ref.read(authProvider).error == null) {
                                emailController.clear();
                                passwordController.clear();
                              }
                            }
                          } catch (e) {
                            // sendOTP rethrows; error already in authState.error
                            print('Auth error: $e');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _showRegisterForm ? 'Create Account' : 'Login',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Forgot Password Button (only for login)
              if (!_showRegisterForm)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/forgot-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ),

              // Toggle between Login and Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _showRegisterForm
                        ? 'Already have an account?'
                        : 'Don\'t have an account?',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showRegisterForm = !_showRegisterForm;
                        emailController.clear();
                        usernameController.clear();
                        passwordController.clear();
                        confirmPasswordController.clear();
                        _passwordVisible = false;
                        _confirmPasswordVisible = false;
                      });
                      ref.read(authProvider.notifier).clearError();
                      _formKey.currentState?.reset();
                    },
                    child: Text(
                      _showRegisterForm ? 'Login' : 'Create Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
