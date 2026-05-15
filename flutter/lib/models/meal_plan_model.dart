import 'package:json_annotation/json_annotation.dart';

part 'meal_plan_model.g.dart';

/// Represents a single meal in the meal plan
@JsonSerializable()
class Recipe {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'servings')
  final int servings;

  @JsonKey(name: 'readyInMinutes')
  final int? readyInMinutes;

  @JsonKey(name: 'sourceUrl')
  final String? sourceUrl;

  @JsonKey(name: 'image')
  final String? image;

  @JsonKey(name: 'instructions')
  final String? instructions;

  @JsonKey(name: 'nutrition')
  final RecipeNutrition? nutrition;

  Recipe({
    required this.id,
    required this.title,
    required this.servings,
    this.readyInMinutes,
    this.sourceUrl,
    this.image,
    this.instructions,
    this.nutrition,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) =>
      _$RecipeFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

/// Nutrition data for a single recipe
@JsonSerializable()
class RecipeNutrition {
  @JsonKey(name: 'calories')
  final double? calories;

  @JsonKey(name: 'carbohydrates')
  final double? carbohydrates;

  @JsonKey(name: 'protein')
  final double? protein;

  @JsonKey(name: 'fat')
  final double? fat;

  RecipeNutrition({
    this.calories,
    this.carbohydrates,
    this.protein,
    this.fat,
  });

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) =>
      _$RecipeNutritionFromJson(json);

  Map<String, dynamic> toJson() => _$RecipeNutritionToJson(this);
}

/// Represents a meal in the daily meal plan
@JsonSerializable()
class Meal {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'readyInMinutes')
  final int? readyInMinutes;

  @JsonKey(name: 'servings')
  final int? servings;

  @JsonKey(name: 'sourceUrl')
  final String? sourceUrl;

  @JsonKey(name: 'image')
  final String? image;

  @JsonKey(name: 'instructions')
  final String? instructions;

  Meal({
    required this.id,
    required this.title,
    this.readyInMinutes,
    this.servings,
    this.sourceUrl,
    this.image,
    this.instructions,
  });

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);

  Map<String, dynamic> toJson() => _$MealToJson(this);
}

/// Daily nutrition summary
@JsonSerializable()
class Nutrients {
  @JsonKey(name: 'calories')
  final double calories;

  @JsonKey(name: 'carbohydrates')
  final double carbohydrates;

  @JsonKey(name: 'protein')
  final double protein;

  @JsonKey(name: 'fat')
  final double fat;

  @JsonKey(name: 'fiber')
  final double? fiber;

  @JsonKey(name: 'sugar')
  final double? sugar;

  Nutrients({
    required this.calories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    this.fiber,
    this.sugar,
  });

  factory Nutrients.fromJson(Map<String, dynamic> json) =>
      _$NutrientsFromJson(json);

  Map<String, dynamic> toJson() => _$NutrientsToJson(this);
}

/// Complete daily meal plan
@JsonSerializable()
class MealPlan {
  @JsonKey(name: 'meals')
  final List<Meal> meals;

  @JsonKey(name: 'nutrients')
  final Nutrients nutrients;

  MealPlan({
    required this.meals,
    required this.nutrients,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) =>
      _$MealPlanFromJson(json);

  Map<String, dynamic> toJson() => _$MealPlanToJson(this);
}

/// API response wrapper for meal plan generation
@JsonSerializable()
class GenerateMealPlanResponse {
  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'mealPlan')
  final MealPlan mealPlan;

  GenerateMealPlanResponse({
    required this.message,
    required this.mealPlan,
  });

  factory GenerateMealPlanResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateMealPlanResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateMealPlanResponseToJson(this);
}

/// Saved meal plan metadata
@JsonSerializable()
class SavedMealPlan {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'summary')
  final String? summary;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'plan_data')
  final MealPlan? planData;

  SavedMealPlan({
    required this.id,
    this.summary,
    required this.createdAt,
    this.planData,
  });

  factory SavedMealPlan.fromJson(Map<String, dynamic> json) =>
      _$SavedMealPlanFromJson(json);

  Map<String, dynamic> toJson() => _$SavedMealPlanToJson(this);
}
