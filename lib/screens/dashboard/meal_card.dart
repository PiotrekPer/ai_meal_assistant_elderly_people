import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/cart_service.dart';
import '../../services/elevenlabs_service.dart';

class MealCard extends StatefulWidget {
  final String mealType;
  final Map<String, dynamic> meal;

  const MealCard({
    Key? key,
    required this.mealType,
    required this.meal,
  }) : super(key: key);

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  late final ElevenLabsService? _elevenLabsService;
  bool _isReadingRecipe = false;

  @override
  void initState() {
    super.initState();
    final elevenLabsKey = dotenv.env['ELEVENLABS_API_KEY'];
    if (elevenLabsKey != null && elevenLabsKey.isNotEmpty && elevenLabsKey != 'your_elevenlabs_api_key_here') {
      _elevenLabsService = ElevenLabsService(elevenLabsKey);
    } else {
      _elevenLabsService = null;
    }
  }

  @override
  void dispose() {
    _elevenLabsService?.dispose();
    super.dispose();
  }

  String _generateRecipeSpeechText() {
    final recipe = widget.meal['recipe'] as Map<String, dynamic>?;
    final steps = recipe?['steps'] as List?;
    
    if (steps == null || steps.isEmpty) {
      return 'No recipe steps available.';
    }

    String text = 'Recipe for ${widget.meal['name']}. ';
    
    if (recipe?['total_time_minutes'] != null) {
      text += 'Total cooking time: ${recipe!['total_time_minutes']} minutes. ';
    }
    
    text += 'Here are the cooking steps: ';
    
    for (int i = 0; i < steps.length; i++) {
      if (steps[i] is Map<String, dynamic>) {
        final step = steps[i] as Map<String, dynamic>;
        final instruction = step['instruction'] ?? '';
        text += 'Step ${i + 1}: $instruction. ';
      }
    }
    
    return text;
  }

  Future<void> _toggleRecipeReading() async {
    if (_elevenLabsService == null) return;

    if (_isReadingRecipe) {
      await _elevenLabsService.stopSpeaking();
      setState(() => _isReadingRecipe = false);
    } else {
      setState(() => _isReadingRecipe = true);
      
      try {
        final text = _generateRecipeSpeechText();
        await _elevenLabsService.speakText(text: text);
        
        if (mounted) {
          setState(() => _isReadingRecipe = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isReadingRecipe = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error reading recipe: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = (widget.meal['ingredients'] as List?)
        ?.where((item) => item is Map<String, dynamic>)
        .cast<Map<String, dynamic>>()
        .toList();

    final nutrition = widget.meal['nutrition'] as Map<String, dynamic>?;
    final recipe = widget.meal['recipe'] as Map<String, dynamic>?;
    final steps = recipe?['steps'] as List?;
    final cartService = CartService();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealType),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (ingredients != null && ingredients.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                cartService.addIngredientsFromMeal(widget.mealType, widget.meal);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${ingredients.length} ingredients to cart!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          if (_elevenLabsService != null && recipe != null)
            IconButton(
              icon: Icon(_isReadingRecipe ? Icons.stop : Icons.record_voice_over),
              tooltip: _isReadingRecipe ? 'Stop Reading' : 'Read Recipe',
              onPressed: _toggleRecipeReading,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.meal['name'] ?? 'Unknown Meal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nutrition Information
                    if (nutrition != null) ...[
                      Text(
                        'Nutrition Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildNutritionItem('Calories', '${nutrition['calories'] ?? 0}', 'kcal'),
                          const SizedBox(width: 20),
                          _buildNutritionItem('Protein', '${nutrition['proteins'] ?? 0}', 'g'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildNutritionItem('Carbs', '${nutrition['carbs'] ?? 0}', 'g'),
                          const SizedBox(width: 20),
                          _buildNutritionItem('Fat', '${nutrition['fat'] ?? 0}', 'g'),
                          const SizedBox(width: 20),
                          _buildNutritionItem('Fiber', '${nutrition['fiber'] ?? 0}', 'g'),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Ingredients
                    if (ingredients != null && ingredients.isNotEmpty) ...[
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...ingredients.map((ingredient) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 6),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${ingredient['item'] ?? ingredient['name'] ?? 'Unknown'} - ${ingredient['quantity'] ?? 'N/A'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                      const SizedBox(height: 16),
                    ],

                    // Recipe
                    if (recipe != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recipe Instructions',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                                if (recipe['total_time_minutes'] != null) ...[
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${recipe['total_time_minutes']} min',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (steps != null && steps.isNotEmpty)
                              ...steps.asMap().entries.map((entry) {
                                final index = entry.key;
                                final step = entry.value;
                                
                                if (step is Map<String, dynamic>) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                      bottom: index < steps.length - 1 ? 16 : 0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context).colorScheme.primary,
                                                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${step['step_number'] ?? index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              step['instruction'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                height: 1.5,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }).toList()
                            else
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'No recipe steps available.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_outlined, color: Colors.red[600], size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'No recipe available.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          '$value$unit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
