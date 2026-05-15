import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';
import 'recipe_detail_page.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // Load favorite recipes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoriteMealsProvider.notifier).fetchFavoritePlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoriteMealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
        elevation: 0,
      ),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesList(favorites),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Save meal plans to view them here',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Return to home to generate recipes
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Generate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// Build favorites list
  Widget _buildFavoritesList(List<dynamic> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final plan = favorites[index] as dynamic;
        final planId = plan['id'] as String?;
        final summary = plan['summary'] as String? ?? 'Daily Meal Plan';
        final createdAt = plan['created_at'] as String?;
        final planData = plan['plan_data'] as dynamic;

        return _buildFavoritePlanCard(
          context,
          planId,
          summary,
          createdAt,
          planData,
          index,
        );
      },
    );
  }

  /// Build single favorite card (supports swipe to delete)
  Widget _buildFavoritePlanCard(
    BuildContext context,
    String? planId,
    String summary,
    String? createdAt,
    dynamic planData,
    int index,
  ) {
    return Dismissible(
      key: Key(planId ?? index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteFavoritePlan(planId);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          // Open recipe detail page
          _openMealPlanDetail(context, planData, planId);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and creation time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      summary,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.favorite,
                    color: Colors.red[400],
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Creation time and meal count
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatCreateTime(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quick preview: Show first 3 meals
              if (planData != null) _buildMealPreview(planData),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _openMealPlanDetail(context, planData, planId);
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showDeleteConfirmation(context, planId);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build meal quick preview
  Widget _buildMealPreview(dynamic planData) {
    final meals = (planData as dynamic)['meals'] as List<dynamic>?;
    if (meals == null || meals.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayMeals = meals.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Preview',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayMeals.map((meal) {
            final title =
                (meal as dynamic)['title'] as String? ?? 'Unknown Recipe';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.blue,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Open recipe detail page
  void _openMealPlanDetail(
    BuildContext context,
    dynamic planData,
    String? planId,
  ) async {
    print('View Details clicked');
    print('   - planId: $planId');

    if (planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan ID is missing')),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Fetch full meal plan data from server
      print('Fetching full meal plan data from server...');
      final fullPlan = await ref
          .read(favoriteMealsProvider.notifier)
          .getMealPlanDetail(planId);

      print('Fetched successfully: $fullPlan');

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      final planDataFull = fullPlan['plan_data'];
      print('   - planData type: ${planDataFull.runtimeType}');

      if (planDataFull == null) {
        print('planData is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe data is null')),
        );
        return;
      }

      final meals = (planDataFull as dynamic)['meals'] as List<dynamic>?;
      print('   - meals: ${meals?.length} items');

      if (meals == null || meals.isEmpty) {
        print('meals is empty');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe data is empty')),
        );
        return;
      }

      print('Showing meal selection dialog');
      // Show recipe selection dialog
      _showMealSelectionDialog(context, meals);
    } catch (e, stackTrace) {
      print('Error fetching meal plan details: $e');
      print('StackTrace: $stackTrace');

      if (!mounted) return;

      // Close loading dialog if still open
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load details: $e')),
      );
    }
  }

  /// Show recipe selection dialog
  void _showMealSelectionDialog(BuildContext context, List<dynamic> meals) {
    final mealtimes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: Colors.blue[700],
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Select Recipe to View',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Meal list
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        meals.length,
                        (index) {
                          final meal = meals[index];
                          final title = (meal as dynamic)['title'] as String? ??
                              'Unknown Recipe';
                          final mealtime = index < mealtimes.length
                              ? mealtimes[index]
                              : 'Meal ${index + 1}';
                          final nutrition =
                              (meal as dynamic)['nutrition'] as dynamic;
                          final calories = nutrition?['calories'] as num? ?? 0;

                          return ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getMealIcon(index),
                                color: Colors.blue[700],
                              ),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '$mealtime • ${calories.toInt()} kcal',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailPage(
                                    recipe: meal,
                                    mealType: mealtime,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get meal icon based on index
  IconData _getMealIcon(int index) {
    switch (index) {
      case 0:
        return Icons.free_breakfast;
      case 1:
        return Icons.lunch_dining;
      case 2:
        return Icons.dinner_dining;
      case 3:
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, String? planId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Favorite'),
          content: const Text('Are you sure you want to delete this recipe?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteFavoritePlan(planId);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Delete favorite recipe
  Future<void> _deleteFavoritePlan(String? planId) async {
    if (planId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed: Recipe ID is empty')),
      );
      return;
    }

    try {
      await ref.read(favoriteMealsProvider.notifier).deleteMealPlan(planId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleted from favorites'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Format creation time
  String _formatCreateTime(String? createdAt) {
    if (createdAt == null) return 'Unknown time';

    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}
