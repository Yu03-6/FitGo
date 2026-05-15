import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

/// Login request model
@JsonSerializable()
class LoginRequest {
  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'password')
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

/// Register request model
@JsonSerializable()
class RegisterRequest {
  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'password')
  final String password;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

/// Auth response model
@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'username')
  final String? username;

  @JsonKey(name: 'token')
  final String token;

  AuthResponse({
    required this.message,
    required this.userId,
    this.username,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

/// User model
@JsonSerializable()
class User {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'username')
  final String? username;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  User({
    required this.id,
    required this.email,
    this.username,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
