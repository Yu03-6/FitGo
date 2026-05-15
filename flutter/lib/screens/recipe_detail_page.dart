import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class RecipeDetailPage extends StatefulWidget {
  final dynamic recipe;
  final String? mealType; // 'Breakfast', 'Lunch', 'Dinner'

  const RecipeDetailPage({
    Key? key,
    required this.recipe,
    this.mealType,
  }) : super(key: key);

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  Widget build(BuildContext context) {
    final title =
        (widget.recipe as dynamic)['title'] as String? ?? 'Unknown Recipe';
    final image = (widget.recipe)['imageProxy'] as String? ??
        (widget.recipe)['image'] as String?;
    final readyInMinutes = (widget.recipe)['readyInMinutes'] as int? ?? 0;
    final nutrition = (widget.recipe)['nutrition'] as dynamic;
    final instructions = (widget.recipe)['instructions'] as String?;
    final extendedIngredients =
        (widget.recipe)['extendedIngredients'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal image
            if (image != null)
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[300],
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
              ),

            // Meal name and basic information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and meal time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.mealType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getMealtypeColor(widget.mealType!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.mealType!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Basic information row
                  _buildInfoItem(
                    icon: Icons.schedule,
                    label: 'Cooking Time',
                    value: '$readyInMinutes minutes',
                  ),
                ],
              ),
            ),

            // Nutrition information card
            if (nutrition != null) _buildNutritionCard(nutrition),

            const SizedBox(height: 24),

            // Ingredients list
            if (extendedIngredients != null && extendedIngredients.isNotEmpty)
              _buildIngredientsSection(extendedIngredients),

            const SizedBox(height: 24),

            // Cooking instructions
            if (instructions != null && instructions.isNotEmpty)
              _buildInstructionsSection(instructions),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build basic information item
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build nutrition information card
  Widget _buildNutritionCard(dynamic nutrition) {
    final calories = nutrition?['calories'] as num? ?? 0;
    final carbs = nutrition?['carbohydrates'] as num? ?? 0;
    final protein = nutrition?['protein'] as num? ?? 0;
    final fat = nutrition?['fat'] as num? ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Facts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem(
                label: 'Calories',
                value: '${calories.toInt()}',
                unit: 'kcal',
                color: Colors.orange,
              ),
              _buildNutritionItem(
                label: 'Carbs',
                value: '${carbs.toInt()}',
                unit: 'g',
                color: Colors.orange,
              ),
              _buildNutritionItem(
                label: 'Protein',
                value: '${protein.toInt()}',
                unit: 'g',
                color: Colors.red,
              ),
              _buildNutritionItem(
                label: 'Fat',
                value: '${fat.toInt()}',
                unit: 'g',
                color: Colors.yellow[700]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build single nutrition item
  Widget _buildNutritionItem({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  /// Build ingredients list section
  Widget _buildIngredientsSection(List<dynamic> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ingredients (${ingredients.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ingredients.length,
          itemBuilder: (context, index) {
            final ingredient = ingredients[index] as dynamic;
            final name = ingredient['name'] as String? ?? 'Unknown Ingredient';
            final amount = ingredient['amount'] as num? ?? 0;
            final unit = ingredient['unit'] as String? ?? '';
            final original = ingredient['original'] as String?;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Ingredient icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shopping_basket,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Ingredient information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          original ?? '$amount $unit',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build cooking instructions section
  Widget _buildInstructionsSection(String instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Disclaimer notice
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            border: Border.all(color: Colors.red[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'This recipe is for reference only and cannot replace professional medical or clinical diagnosis and treatment advice. Please follow the doctor\'s instructions for your specific dietary plan.',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Cooking Instructions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // HTML content display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildInstructionsContent(instructions),
        ),
      ],
    );
  }

  /// Build cooking instructions content (handle HTML)
  Widget _buildInstructionsContent(String instructions) {
    // Check if HTML format (contains <)
    if (instructions.contains('<')) {
      // Use Html widget to render HTML
      return Html(
        data: instructions,
        style: {
          'body': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(14),
            color: Colors.black87,
            lineHeight: const LineHeight(1.6),
          ),
          'p': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.only(bottom: 8),
            fontSize: FontSize(14),
          ),
          'li': Style(
            fontSize: FontSize(14),
            margin: Margins(left: Margin(16)),
            padding: HtmlPaddings.only(bottom: 8),
          ),
          'ol': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'ul': Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          'strong': Style(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          'em': Style(
            fontStyle: FontStyle.italic,
          ),
        },
      );
    } else {
      // Plain text format
      return Text(
        instructions,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.6,
        ),
      );
    }
  }

  /// Get meal time color
  Color _getMealtypeColor(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return Colors.orange;
      case 'Lunch':
        return Colors.blue;
      case 'Dinner':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
