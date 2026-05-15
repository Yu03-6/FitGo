// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      servings: (json['servings'] as num).toInt(),
      readyInMinutes: (json['readyInMinutes'] as num?)?.toInt(),
      sourceUrl: json['sourceUrl'] as String?,
      image: json['image'] as String?,
      instructions: json['instructions'] as String?,
      nutrition: json['nutrition'] == null
          ? null
          : RecipeNutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'servings': instance.servings,
      'readyInMinutes': instance.readyInMinutes,
      'sourceUrl': instance.sourceUrl,
      'image': instance.image,
      'instructions': instance.instructions,
      'nutrition': instance.nutrition,
    };

RecipeNutrition _$RecipeNutritionFromJson(Map<String, dynamic> json) =>
    RecipeNutrition(
      calories: (json['calories'] as num?)?.toDouble(),
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RecipeNutritionToJson(RecipeNutrition instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'carbohydrates': instance.carbohydrates,
      'protein': instance.protein,
      'fat': instance.fat,
    };

Meal _$MealFromJson(Map<String, dynamic> json) => Meal(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      readyInMinutes: (json['readyInMinutes'] as num?)?.toInt(),
      servings: (json['servings'] as num?)?.toInt(),
      sourceUrl: json['sourceUrl'] as String?,
      image: json['image'] as String?,
      instructions: json['instructions'] as String?,
    );

Map<String, dynamic> _$MealToJson(Meal instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'readyInMinutes': instance.readyInMinutes,
      'servings': instance.servings,
      'sourceUrl': instance.sourceUrl,
      'image': instance.image,
      'instructions': instance.instructions,
    };

Nutrients _$NutrientsFromJson(Map<String, dynamic> json) => Nutrients(
      calories: (json['calories'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NutrientsToJson(Nutrients instance) => <String, dynamic>{
      'calories': instance.calories,
      'carbohydrates': instance.carbohydrates,
      'protein': instance.protein,
      'fat': instance.fat,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
    };

MealPlan _$MealPlanFromJson(Map<String, dynamic> json) => MealPlan(
      meals: (json['meals'] as List<dynamic>)
          .map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList(),
      nutrients: Nutrients.fromJson(json['nutrients'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MealPlanToJson(MealPlan instance) => <String, dynamic>{
      'meals': instance.meals,
      'nutrients': instance.nutrients,
    };

GenerateMealPlanResponse _$GenerateMealPlanResponseFromJson(
        Map<String, dynamic> json) =>
    GenerateMealPlanResponse(
      message: json['message'] as String,
      mealPlan: MealPlan.fromJson(json['mealPlan'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GenerateMealPlanResponseToJson(
        GenerateMealPlanResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'mealPlan': instance.mealPlan,
    };

SavedMealPlan _$SavedMealPlanFromJson(Map<String, dynamic> json) =>
    SavedMealPlan(
      id: json['id'] as String,
      summary: json['summary'] as String?,
      createdAt: json['created_at'] as String,
      planData: json['plan_data'] == null
          ? null
          : MealPlan.fromJson(json['plan_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SavedMealPlanToJson(SavedMealPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'summary': instance.summary,
      'created_at': instance.createdAt,
      'plan_data': instance.planData,
    };
