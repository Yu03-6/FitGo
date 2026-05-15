import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';

import '../services/api_client.dart';
import 'auth_provider.dart';

/// User profile provider
class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final ApiClient apiClient;

  UserProfileNotifier({required this.apiClient}) : super(null);

  /// Clear user profile
  void clearProfile() {
    state = null;
  }

  /// Fetch user profile
  Future<void> fetchProfile() async {
    try {
      print('🔍 Fetching user profile...');
      final profile = await apiClient.get<UserProfile>(
        '/user/profile',
        fromJson: (json) => UserProfile.fromJson(json),
      );
      print('✅ Profile fetched successfully: ${"body data available"}');
      print('   - height: ${profile.height}');
      print('   - weight: ${profile.weight}');
      print('   - age: ${profile.age}');
      state = profile;
    } catch (e) {
      print('❌ Error fetching profile: $e');
      // If 404, the user simply has no profile yet — this is expected
      if (e.toString().contains('404') ||
          e.toString().contains('Profile not found')) {
        print('   User has not filled in body data yet (expected)');
      }
      state = null;
    }
  }

  /// Update user profile
  Future<NutritionResult> updateProfile({
    required int height,
    required double weight,
    required int age,
    required String gender,
    required double activityLevel,
    required String goal,
    required String dietPreference,
    String? dislikedIngredients,
  }) async {
    try {
      final response = await apiClient.post<UpdateProfileResponse>(
        '/user/profile',
        data: {
          'height': height,
          'weight': weight,
          'age': age,
          'gender': gender,
          'activity_level': activityLevel,
          'goal': goal,
          'diet_preference': dietPreference,
          'disliked_ingredients': dislikedIngredients,
        },
        fromJson: (json) => UpdateProfileResponse.fromJson(json),
      );

      // Update local state with userId preserved
      final updatedProfile = UserProfile(
        userId: state?.userId,
        id: state?.id,
        height: height,
        weight: weight,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
        goal: goal,
        dietPreference: dietPreference,
        dislikedIngredients: dislikedIngredients,
        calculatedCalories: response.nutrition.dailyCalories,
      );
      state = updatedProfile;

      return response.nutrition;
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception(
          'Failed to save profile: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }
}

/// User profile provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserProfileNotifier(apiClient: apiClient);
});

/// Meal plan state
class MealPlanState {
  final dynamic mealPlan;
  final bool isLoading;
  final String? error;

  MealPlanState({
    this.mealPlan,
    this.isLoading = false,
    this.error,
  });

  MealPlanState copyWith({
    dynamic mealPlan,
    bool? isLoading,
    String? error,
  }) {
    return MealPlanState(
      mealPlan: mealPlan ?? this.mealPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Meal plan provider
class MealPlanNotifier extends StateNotifier<MealPlanState> {
  final ApiClient apiClient;

  MealPlanNotifier({required this.apiClient}) : super(MealPlanState());

  /// Clear meal plan
  void clearMealPlan() {
    state = MealPlanState();
  }

  /// Generate meal plan with optional user profile data
  Future<void> generateMealPlan({dynamic userProfile}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Prepare request data with user profile information for better meal plan generation
      final requestData = {
        'dailyCalories': userProfile?.calculatedCalories ?? 2000,
        'dietPreference': userProfile?.dietPreference ?? 'standard',
        'dislikedIngredients': userProfile?.dislikedIngredients,
      };

      print('🔄 Generating meal plan, params: $requestData');

      final response = await apiClient.post<dynamic>(
        '/meal/generate',
        data: requestData,
      );

      // Extract mealPlan from response
      // Backend returns: { message: "...", mealPlan: {...} }
      dynamic mealPlanData;
      if (response is Map<String, dynamic> &&
          response.containsKey('mealPlan')) {
        mealPlanData = response['mealPlan'];
      } else {
        mealPlanData = response;
      }

      state = state.copyWith(
        mealPlan: mealPlanData,
        isLoading: false,
      );

      print('✅ Meal plan generated successfully');
      print('Meal plan data: $mealPlanData');
    } catch (e) {
      print('❌ Error generating meal plan: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Save meal plan
  Future<void> saveMealPlan(dynamic planData, String? summary) async {
    try {
      if (planData == null) {
        throw Exception('Meal plan data is null');
      }

      final response = await apiClient.post<dynamic>(
        '/meal/save',
        data: {
          'plan_data': planData,
          'summary': summary,
        },
      );

      print('✅ Meal plan saved successfully');
      print('Response: $response');
    } catch (e) {
      print('❌ Error saving meal plan: $e');
      rethrow;
    }
  }
}

/// Meal plan provider
final mealPlanProvider =
    StateNotifierProvider<MealPlanNotifier, MealPlanState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MealPlanNotifier(apiClient: apiClient);
});

/// Favorite meal plans provider
class FavoriteMealsNotifier extends StateNotifier<List<dynamic>> {
  final ApiClient apiClient;

  FavoriteMealsNotifier({required this.apiClient}) : super([]);

  /// Fetch favorite meal plans
  Future<void> fetchFavoritePlans() async {
    try {
      print('🔍 Fetching favorite meal plans...');
      final response = await apiClient.get<dynamic>(
        '/meal/favorites',
      );

      print('📦 Favorites response: $response');

      if (response is Map && response.containsKey('plans')) {
        final plans = List.from(response['plans'] ?? []);
        print('✅ Fetched ${plans.length} favorite(s)');
        for (var i = 0; i < plans.length; i++) {
          print('   Plan $i:');
          print('     - id: ${plans[i]['id']}');
          print('     - summary: ${plans[i]['summary']}');
          print(
              '     - plan_data keys: ${plans[i]['plan_data']?.keys?.toList()}');
        }
        state = plans;
      } else {
        print('⚠️ Unexpected response format: $response');
        state = [];
      }
    } catch (e) {
      print('❌ Error fetching favorites: $e');
      state = [];
    }
  }

  /// Get meal plan detail
  Future<dynamic> getMealPlanDetail(String planId) async {
    try {
      return await apiClient.get<dynamic>(
        '/meal/favorites/$planId',
      );
    } catch (e) {
      print('Error fetching meal plan detail: $e');
      rethrow;
    }
  }

  /// Delete meal plan
  Future<void> deleteMealPlan(String planId) async {
    try {
      await apiClient.delete<dynamic>(
        '/meal/favorites/$planId',
      );

      // Remove from local state
      state = state.where((p) => p['id'] != planId).toList();
    } catch (e) {
      print('Error deleting meal plan: $e');
    }
  }
}

/// Favorite meals provider
final favoriteMealsProvider =
    StateNotifierProvider<FavoriteMealsNotifier, List<dynamic>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FavoriteMealsNotifier(apiClient: apiClient);
});
