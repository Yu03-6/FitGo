import 'package:dio/dio.dart';
import 'storage_service.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? type;

  ApiException({
    required this.message,
    this.statusCode,
    this.type,
  });

  @override
  String toString() {
    if (type == 'server_error') {
      return 'Server error: $message';
    }
    return message;
  }
}

/// Interceptor for adding JWT token to requests
class AuthInterceptor extends Interceptor {
  final StorageService storageService;

  AuthInterceptor({required this.storageService});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await storageService.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('Error reading token: $e');
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Clear token on unauthorized
      await storageService.delete(key: 'jwt_token');
      await storageService.delete(key: 'user_id');
    }
    return handler.next(err);
  }
}

/// Error interceptor for handling API errors
class ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    String message = 'An unexpected error occurred. Please try again';
    String? type;

    if (err.response != null) {
      final statusCode = err.response?.statusCode;
      final data = err.response?.data;

      if (statusCode == 401) {
        // Check if error has specific message from backend
        if (data is Map && data.containsKey('error')) {
          message = data['error'];
        } else {
          message = 'Unauthorized: Please log in again';
        }
        type = 'unauthorized';
      } else if (statusCode == 400) {
        // Check if error has details about what went wrong
        if (data is Map && data.containsKey('error')) {
          message = data['error'];
        } else if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else {
          message = 'Bad request: Please check your input';
        }
      } else if (statusCode == 404) {
        message = 'Resource not found';
      } else if (statusCode == 409) {
        // Conflict error - likely email already exists
        if (data is Map && data.containsKey('error')) {
          message = data['error'];
        } else {
          message = 'Email already exists. Please use a different email';
        }
      } else if (statusCode == 500) {
        message = 'Server error: Please try again later';
        type = 'server_error';
      } else {
        if (data is Map && data.containsKey('error')) {
          message = data['error'];
        } else {
          message = 'Request failed with status $statusCode';
        }
      }
    } else if (err.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout: Check your internet connection';
    } else if (err.type == DioExceptionType.receiveTimeout) {
      message = 'Server timeout: Please try again';
    } else if (err.type == DioExceptionType.unknown) {
      // Check for network-related errors
      if (err.message?.contains('Connection refused') ?? false) {
        message = 'Server connection failed: Is the server running?';
      } else {
        message = 'Network error: ${err.message}';
      }
    }

    final apiException = ApiException(
      message: message,
      statusCode: err.response?.statusCode,
      type: type,
    );

    return handler.reject(DioException(
      requestOptions: err.requestOptions,
      message: apiException.toString(),
      error: apiException,
      stackTrace: err.stackTrace,
      type: err.type,
      response: err.response,
    ));
  }
}

/// API Client for handling HTTP requests
class ApiClient {
  late Dio _dio;
  final String baseUrl;
  final StorageService storageService;

  ApiClient({
    required this.baseUrl,
    required this.storageService,
  }) {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor(storageService: storageService));
    _dio.interceptors.add(ErrorInterceptor());

    // Optional: Add logging in debug mode
    if (true) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => print(obj),
        ),
      );
    }
  }

  /// GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      if (fromJson != null && response.data is Map<String, dynamic>) {
        return fromJson(response.data as Map<String, dynamic>);
      }
      return response.data as T;
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: e.toString());
    }
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (fromJson != null && response.data is Map<String, dynamic>) {
        return fromJson(response.data as Map<String, dynamic>);
      }
      return response.data as T;
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: e.toString());
    }
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (fromJson != null && response.data is Map<String, dynamic>) {
        return fromJson(response.data as Map<String, dynamic>);
      }
      return response.data as T;
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: e.toString());
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      if (fromJson != null && response.data is Map<String, dynamic>) {
        return fromJson(response.data as Map<String, dynamic>);
      }
      return response.data as T;
    } on DioException catch (e) {
      throw e.error ?? ApiException(message: e.toString());
    }
  }

  /// Update base URL
  void setBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Get current token
  Future<String?> getToken() async {
    return await storageService.read(key: 'jwt_token');
  }

  /// Save token
  Future<void> saveToken(String token) async {
    await storageService.write(key: 'jwt_token', value: token);
  }

  /// Clear token
  Future<void> clearToken() async {
    await storageService.delete(key: 'jwt_token');
  }
}
