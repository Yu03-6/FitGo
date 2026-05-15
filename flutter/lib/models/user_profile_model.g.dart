// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      height: (json['height'] as num).toInt(),
      weight: const WeightConverter().fromJson(json['weight']),
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      activityLevel: (json['activity_level'] as num).toDouble(),
      goal: json['goal'] as String,
      dietPreference: json['diet_preference'] as String,
      dislikedIngredients: json['disliked_ingredients'] as String?,
      calculatedCalories: (json['calculated_calories'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'height': instance.height,
      'weight': const WeightConverter().toJson(instance.weight),
      'age': instance.age,
      'gender': instance.gender,
      'activity_level': instance.activityLevel,
      'goal': instance.goal,
      'diet_preference': instance.dietPreference,
      'disliked_ingredients': instance.dislikedIngredients,
      'calculated_calories': instance.calculatedCalories,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

NutritionResult _$NutritionResultFromJson(Map<String, dynamic> json) =>
    NutritionResult(
      dailyCalories: (json['dailyCalories'] as num).toInt(),
      carbGrams: (json['carbGrams'] as num).toInt(),
      proteinGrams: (json['proteinGrams'] as num).toInt(),
      fatGrams: (json['fatGrams'] as num).toInt(),
    );

Map<String, dynamic> _$NutritionResultToJson(NutritionResult instance) =>
    <String, dynamic>{
      'dailyCalories': instance.dailyCalories,
      'carbGrams': instance.carbGrams,
      'proteinGrams': instance.proteinGrams,
      'fatGrams': instance.fatGrams,
    };

UpdateProfileResponse _$UpdateProfileResponseFromJson(
        Map<String, dynamic> json) =>
    UpdateProfileResponse(
      message: json['message'] as String,
      nutrition:
          NutritionResult.fromJson(json['nutrition'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateProfileResponseToJson(
        UpdateProfileResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'nutrition': instance.nutrition,
    };
