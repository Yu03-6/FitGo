import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';

/// Storage service provider (跨平台，支持 Web)
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiClient(
    baseUrl: ApiConfig.apiBaseUrl,
    storageService: storageService,
  );
});

/// Auth state
class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? username;
  final String? error;
  final bool isLoading;
  // Temporary registration data
  final String? tempEmail;
  final String? tempUsername;
  final String? tempPassword;
  final String? tempRepassword;

  AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.username,
    this.error,
    this.isLoading = false,
    this.tempEmail,
    this.tempUsername,
    this.tempPassword,
    this.tempRepassword,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? username,
    String? error,
    bool? isLoading,
    String? tempEmail,
    String? tempUsername,
    String? tempPassword,
    String? tempRepassword,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      tempEmail: tempEmail ?? this.tempEmail,
      tempUsername: tempUsername ?? this.tempUsername,
      tempPassword: tempPassword ?? this.tempPassword,
      tempRepassword: tempRepassword ?? this.tempRepassword,
    );
  }
}

/// Auth provider using Riverpod
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient apiClient;
  final StorageService storageService;

  AuthNotifier({
    required this.apiClient,
    required this.storageService,
  }) : super(AuthState());

  /// Check if user is already logged in (auto-login)
  Future<void> checkAuthStatus() async {
    try {
      final token = await storageService.read(key: 'jwt_token');
      final userId = await storageService.read(key: 'user_id');
      final email = await storageService.read(key: 'user_email');
      final username = await storageService.read(key: 'user_name');

      if (token != null && token.isNotEmpty && userId != null) {
        state = AuthState(
          isAuthenticated: true,
          userId: userId,
          email: email,
          username: username,
        );
      }
    } catch (e) {
      print('Error checking auth status: $e');
      state = state.copyWith(error: 'Failed to check authentication');
    }
  }

  /// Parse error message from exception
  String _parseErrorMessage(dynamic e) {
    final message = e.toString();
    if (message.contains('Exception:')) {
      return message.replaceAll('Exception: ', '');
    } else if (message.contains('ApiException')) {
      return message.replaceAll('ApiException: ', '');
    } else if (message.contains('SocketException')) {
      return 'Connection error. Please check your internet connection';
    } else if (message.contains('Unknown error occurred')) {
      return 'An unexpected error occurred. Please try again';
    }
    return message;
  }

  /// Register user (OTP-based registration)
  Future<bool> register(
      String email, String username, String password, String repassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (email.isEmpty ||
          username.isEmpty ||
          password.isEmpty ||
          repassword.isEmpty) {
        throw Exception(
            'Email, username, password, and repassword are required');
      }

      final response = await apiClient.post<AuthResponse>(
        '/auth/register',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'repassword': repassword,
        },
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      // Save credentials to storage
      await storageService.write(key: 'jwt_token', value: response.token);
      await storageService.write(key: 'user_id', value: response.userId);
      await storageService.write(key: 'user_email', value: email);
      await storageService.write(key: 'user_name', value: username);

      state = AuthState(
        isAuthenticated: true,
        userId: response.userId,
        email: email,
        username: username,
      );

      return true;
    } catch (e) {
      final errorMessage = _parseErrorMessage(e);
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      return false;
    }
  }

  /// Login user
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (email.isEmpty) {
        throw Exception('Email is required');
      }
      if (password.isEmpty) {
        throw Exception('Password is required');
      }

      final request = LoginRequest(email: email, password: password);
      final response = await apiClient.post<AuthResponse>(
        '/auth/login',
        data: request.toJson(),
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      // Save credentials to storage
      await storageService.write(key: 'jwt_token', value: response.token);
      await storageService.write(key: 'user_id', value: response.userId);
      await storageService.write(key: 'user_email', value: email);
      if (response.username != null) {
        await storageService.write(key: 'user_name', value: response.username!);
      }

      state = AuthState(
        isAuthenticated: true,
        userId: response.userId,
        email: email,
        username: response.username,
      );
    } catch (e) {
      final errorMessage = _parseErrorMessage(e);
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Clear storage
      await storageService.delete(key: 'jwt_token');
      await storageService.delete(key: 'user_id');
      await storageService.delete(key: 'user_email');
      await storageService.delete(key: 'user_name');

      // Clear API client token
      await apiClient.clearToken();

      state = AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Send verification code to email
  Future<void> sendVerificationCode(String email) async {
    try {
      await apiClient.post<Map<String, dynamic>>(
        '/auth/send-verification-code',
        data: {'email': email},
        fromJson: (json) => json,
      );
    } catch (e) {
      throw Exception(_parseErrorMessage(e));
    }
  }

  /// Send OTP to email (for registration or password reset)
  Future<void> sendOTP(String email, String type,
      {String? username, String? password, String? repassword}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await apiClient.post<Map<String, dynamic>>(
        '/auth/send-otp',
        data: {'email': email, 'type': type},
        fromJson: (json) => json,
      );

      // Store temporary registration data if provided
      if (type == 'registration' && password != null && repassword != null) {
        state = state.copyWith(
          tempEmail: email,
          tempUsername: username,
          tempPassword: password,
          tempRepassword: repassword,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      final errorMessage = _parseErrorMessage(e);
      state = state.copyWith(
        error: errorMessage,
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOTP(String email, String code, String type) async {
    try {
      await apiClient.post<Map<String, dynamic>>(
        '/auth/verify-otp',
        data: {'email': email, 'code': code, 'type': type},
        fromJson: (json) => json,
      );
      return true;
    } catch (e) {
      throw Exception(_parseErrorMessage(e));
    }
  }

  /// Verify email with code
  Future<void> verifyEmail(String email, String code) async {
    try {
      final response = await apiClient.post<AuthResponse>(
        '/auth/verify-email',
        data: {'email': email, 'code': code},
        fromJson: (json) => AuthResponse.fromJson(json),
      );

      // Save credentials to secure storage
      await storageService.write(key: 'jwt_token', value: response.token);
      await storageService.write(key: 'user_id', value: response.userId);
      await storageService.write(key: 'user_email', value: email);

      state = AuthState(
        isAuthenticated: true,
        userId: response.userId,
        email: email,
      );
    } catch (e) {
      throw Exception(_parseErrorMessage(e));
    }
  }

  /// Forgot password request
  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: {'email': email},
        fromJson: (json) => json,
      );
    } catch (e) {
      throw Exception(_parseErrorMessage(e));
    }
  }

  /// Verify password reset OTP
  Future<bool> verifyForgotOTP(String email, String code) async {
    try {
      await apiClient.post<Map<String, dynamic>>(
        '/auth/verify-forgot-otp',
        data: {'email': email, 'code': code},
        fromJson: (json) => json,
      );
      return true;
    } catch (e) {
      throw Exception(_parseErrorMessage(e));
    }
  }

  /// Reset password with OTP verification
  Future<bool> resetPassword(
      String email, String password, String repassword) async {
    try {
      await apiClient.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: {
          'email': email,
          'password': password,
          'repassword': repassword,
        },
        fromJson: (json) => json,
      );
      return true;
    } catch (e) {
      throw Exception(_parseErrorMessage(e));
    }
  }

  /// Clear temporary registration data
  void clearTempRegistrationData() {
    state = state.copyWith(
      tempEmail: null,
      tempUsername: null,
      tempPassword: null,
      tempRepassword: null,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);

  return AuthNotifier(
    apiClient: apiClient,
    storageService: storageService,
  );
});

/// Provider to check auth status on app initialization
final initAuthProvider = FutureProvider<void>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  await authNotifier.checkAuthStatus();
});
