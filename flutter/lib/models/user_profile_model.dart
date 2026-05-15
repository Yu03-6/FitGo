import 'package:json_annotation/json_annotation.dart';

part 'user_profile_model.g.dart';

/// Custom converter for weight field (handles string or number)
class WeightConverter implements JsonConverter<double, dynamic> {
  const WeightConverter();

  @override
  double fromJson(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    }
    throw ArgumentError('Invalid weight value: $value');
  }

  @override
  dynamic toJson(double value) => value;
}

/// User profile model with biometric data
@JsonSerializable()
class UserProfile {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'user_id')
  final String? userId;

  @JsonKey(name: 'height')
  final int height; // cm

  @JsonKey(name: 'weight')
  @WeightConverter()
  final double weight; // kg

  @JsonKey(name: 'age')
  final int age;

  @JsonKey(name: 'gender')
  final String gender; // 'male' or 'female'

  @JsonKey(name: 'activity_level')
  final double activityLevel; // 1.2 - 1.9

  @JsonKey(name: 'goal')
  final String goal; // 'lose_weight', 'build_muscle', 'keep_fit'

  @JsonKey(name: 'diet_preference')
  final String dietPreference; // 'standard', 'vegetarian', 'keto', 'vegan'

  @JsonKey(name: 'disliked_ingredients')
  final String? dislikedIngredients;

  @JsonKey(name: 'calculated_calories')
  final int? calculatedCalories;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  UserProfile({
    this.id,
    this.userId,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.dietPreference,
    this.dislikedIngredients,
    this.calculatedCalories,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

/// Nutrition calculation result
@JsonSerializable()
class NutritionResult {
  @JsonKey(name: 'dailyCalories')
  final int dailyCalories;

  @JsonKey(name: 'carbGrams')
  final int carbGrams;

  @JsonKey(name: 'proteinGrams')
  final int proteinGrams;

  @JsonKey(name: 'fatGrams')
  final int fatGrams;

  NutritionResult({
    required this.dailyCalories,
    required this.carbGrams,
    required this.proteinGrams,
    required this.fatGrams,
  });

  factory NutritionResult.fromJson(Map<String, dynamic> json) =>
      _$NutritionResultFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionResultToJson(this);
}

/// Profile update response
@JsonSerializable()
class UpdateProfileResponse {
  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'nutrition')
  final NutritionResult nutrition;

  UpdateProfileResponse({
    required this.message,
    required this.nutrition,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileResponseToJson(this);
}
