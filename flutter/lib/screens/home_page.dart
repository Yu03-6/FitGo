import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Auto-generate meal plan when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateMealPlan();
    });
  }

  Future<void> _generateMealPlan() async {
    try {
      // Get user profile for passing to API
      final userProfile = ref.read(userProfileProvider);

      print('Generating meal plan...');
      print(
          '   User profile: calories=${userProfile?.calculatedCalories}, diet=${userProfile?.dietPreference}');

      await ref.read(mealPlanProvider.notifier).generateMealPlan(
            userProfile: userProfile,
          );
      print('Meal plan generated successfully');

      // Verify state
      final state = ref.read(mealPlanProvider);
      print('Current state:');
      print('   - isLoading: ${state.isLoading}');
      print('   - error: ${state.error}');
      print(
          '   - mealPlan: ${state.mealPlan != null ? "has data" : "no data"}');
      if (state.mealPlan != null) {
        print('   - mealPlan type: ${state.mealPlan.runtimeType}');
        print(
            '   - mealPlan fields: ${(state.mealPlan as dynamic).keys?.toList() ?? "N/A"}');

        // Print meals info
        final meals = (state.mealPlan as dynamic)['meals'];
        if (meals != null && meals is List) {
          print('   - meals count: ${meals.length}');
          for (var i = 0; i < meals.length; i++) {
            print('   - Meal ${i + 1}:');
            print('     * title: ${meals[i]['title']}');
            print('     * image: ${meals[i]['image']}');
            print('     * id: ${meals[i]['id']}');
          }
        }

        // Display generated calories
        final nutrients = (state.mealPlan as dynamic)['nutrients'];
        if (nutrients != null) {
          print('   - Total generated calories: ${nutrients["calories"]} kcal');
          print(
              '   - Target calories: ${userProfile?.calculatedCalories} kcal');
        }
      }
    } catch (e) {
      print('Meal plan generation failed: $e');
    }
  }

  Future<void> _saveMealPlan() async {
    final mealPlanState = ref.read(mealPlanProvider);
    if (mealPlanState.mealPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recipes available to save')),
      );
      return;
    }

    try {
      await ref.read(mealPlanProvider.notifier).saveMealPlan(
            mealPlanState.mealPlan,
            _generateSummary(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal plan saved to favorites!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generateSummary() {
    final mealPlanState = ref.read(mealPlanProvider);
    if (mealPlanState.mealPlan != null) {
      final calories =
          (mealPlanState.mealPlan as dynamic)['nutrients']?['calories'] ?? 0;
      return '${calories.toInt()} kcal • Daily Meal Plan';
    }
    return 'Daily Meal Plan';
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final mealPlanState = ref.watch(mealPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitGo'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Update Profile Button
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Update Body Data',
            onPressed: () {
              Navigator.pushNamed(context, '/onboarding');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              // Clear user profile data
              ref.read(userProfileProvider.notifier).clearProfile();
              // Clear meal plan data
              ref.read(mealPlanProvider.notifier).clearMealPlan();
              // Logout and navigate to login page
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                // Navigate to login page and remove all previous routes
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Daily Calorie Target Section
            if (userProfile != null) _buildCalorieTargetCard(userProfile),

            const SizedBox(height: 24),

            // Meal Plan Section
            if (mealPlanState.isLoading)
              _buildLoadingState()
            else if (mealPlanState.error != null)
              _buildErrorState(mealPlanState.error!)
            else if (mealPlanState.mealPlan != null)
              _buildMealPlanCards(mealPlanState.mealPlan)
            else
              _buildEmptyState(),

            const SizedBox(height: 24),

            // Action Buttons
            if (mealPlanState.mealPlan != null)
              _buildActionButtons()
            else if (!mealPlanState.isLoading && mealPlanState.error == null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _generateMealPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Generate Today\'s Meal Plan'),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build calorie target card
  Widget _buildCalorieTargetCard(dynamic userProfile) {
    final dailyCalories = userProfile.calculatedCalories ?? 0;
    final goal = _getGoalLabel(userProfile.goal);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Calorie Goal',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$dailyCalories',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'kcal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build meal plan cards
  Widget _buildMealPlanCards(dynamic mealPlan) {
    final meals = (mealPlan as dynamic)['meals'] as List<dynamic>?;
    if (meals == null || meals.isEmpty) {
      return _buildEmptyState();
    }

    final nutrients = (mealPlan)['nutrients'] as dynamic;
    final mealtimes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    // Show all meals, not just the first 3
    final displayMeals = meals;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Today\'s Meal Plans',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        // Show daily totals
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem('Calories',
                    '${(nutrients?['calories'] ?? 0).toInt()}', Colors.blue),
                _buildMacroItem('Protein',
                    '${(nutrients?['protein'] ?? 0).toInt()}g', Colors.red),
                _buildMacroItem(
                    'Carbs',
                    '${(nutrients?['carbohydrates'] ?? 0).toInt()}g',
                    Colors.orange),
                _buildMacroItem('Fat', '${(nutrients?['fat'] ?? 0).toInt()}g',
                    Colors.yellow.shade700),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          displayMeals.length,
          (index) => _buildMealCard(
            displayMeals[index],
            index < mealtimes.length ? mealtimes[index] : 'Meal ${index + 1}',
          ),
        ),
      ],
    );
  }

  /// Build individual meal card
  Widget _buildMealCard(dynamic meal, String mealtime) {
    final title = (meal as dynamic)['title'] as String? ?? 'Unknown Recipe';
    final image = (meal)['imageProxy'] as String? ?? (meal)['image'] as String?;
    final readyInMinutes = (meal)['readyInMinutes'] as num? ?? 0;
    final nutrition = (meal)['nutrition'] as Map<String, dynamic>?;
    final calories = nutrition?['calories'] as num?;
    final protein = nutrition?['protein'] as num?;
    final fat = nutrition?['fat'] as num?;
    final carbs = nutrition?['carbohydrates'] as num?;

    // Debug: print image info
    print('Meal card image info:');
    print('   - title: $title');
    print('   - image: $image');
    print('   - image is empty: ${image == null || image.isEmpty}');
    if (image != null && image.isNotEmpty) {
      print('   - image URL: $image');
    }

    return GestureDetector(
      onTap: () {
        // Open recipe detail page
        Navigator.pushNamed(
          context,
          '/recipe-detail',
          arguments: {
            'recipe': meal,
            'mealType': mealtime,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal time badge and image
            Stack(
              children: [
                // Image
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    color: Colors.grey,
                  ),
                  child: image != null && image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[400],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: Colors.grey[400],
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  title.length > 20
                                      ? '${title.substring(0, 20)}...'
                                      : title,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                // Meal time badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getMealtimeColor(mealtime),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      mealtime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Title and prep time
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prep time: ${readyInMinutes.toInt()} minutes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (nutrition != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildMacroChip(
                          label: 'Cal',
                          value: calories?.toInt(),
                          unit: 'kcal',
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildMacroChip(
                          label: 'P',
                          value: protein?.toInt(),
                          unit: 'g',
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        _buildMacroChip(
                          label: 'C',
                          value: carbs?.toInt(),
                          unit: 'g',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildMacroChip(
                          label: 'F',
                          value: fat?.toInt(),
                          unit: 'g',
                          color: Colors.brown,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Source link
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Icon(Icons.link, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'View Recipe',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build macro nutrient item
  Widget _buildMacroItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip({
    required String label,
    num? value,
    required String unit,
    required Color color,
  }) {
    final display = value != null ? value.toInt().toString() : '--';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$display$unit',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    final mealPlanState = ref.read(mealPlanProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: mealPlanState.isLoading ? null : _generateMealPlan,
              icon: mealPlanState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: const Text('Regenerate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveMealPlan,
              icon: const Icon(Icons.favorite_border),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/favorites');
              },
              icon: const Icon(Icons.favorite),
              label: const Text('Favorites'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Generating meal plan...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Generate Meal Plan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[400],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _generateMealPlan,
            child: const Text('Retry'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
            icon: const Icon(Icons.favorite, color: Colors.red),
            label: const Text(
              'View Saved Favorites',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Meal Plans Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Click the button below to generate today\'s meal plan',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Get goal label
  String _getGoalLabel(String goal) {
    switch (goal) {
      case 'build_muscle':
        return 'Build Muscle';
      case 'lose_weight':
        return 'Lose Weight';
      case 'keep_fit':
        return 'Keep Fit';
      default:
        return goal;
    }
  }

  /// Get mealtime color
  Color _getMealtimeColor(String mealtime) {
    switch (mealtime) {
      case 'Breakfast':
        return Colors.orange;
      case 'Lunch':
        return Colors.blue;
      case 'Dinner':
        return Colors.purple;
      case 'Snack':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
