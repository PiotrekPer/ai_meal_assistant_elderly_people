import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'settings/food_preferences.dart';
import 'settings/allergies.dart';
import 'settings/shop_preferences.dart';
import 'meal_plan_renderer.dart';
import '../api/openai_service.dart';
import '../services/cart_service.dart';
import '../services/elevenlabs_service.dart';
import 'cart_screen.dart';
import 'voice_assistant_screen.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> user;

  const Dashboard({required this.user, super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late final OpenAIService _openAIService;
  late final CartService _cartService;
  late final ElevenLabsService? _elevenLabsService;
  Map<String, dynamic>? _mealPlan;
  final TextEditingController _detailsController = TextEditingController();
  bool _isLoading = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _openAIService = OpenAIService(dotenv.env['OPENAI_API_KEY']!);
    _cartService = CartService();
    _cartService.addListener(_onCartChanged);
    
    final elevenLabsKey = dotenv.env['ELEVENLABS_API_KEY'];
    if (elevenLabsKey != null && elevenLabsKey.isNotEmpty && elevenLabsKey != 'your_elevenlabs_api_key_here') {
      _elevenLabsService = ElevenLabsService(elevenLabsKey);
    } else {
      _elevenLabsService = null;
    }
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    _elevenLabsService?.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchMealPlan(String details) async {
    setState(() {
      _isLoading = true; 
    });
    try {
      final response = await _openAIService.generateText(
        '''Generate a one-day meal plan in JSON format for a person with the following preferences: ${widget.user['food_preferences']} and allergies: ${widget.user['allergies']}. Additional details: $details.  

Include breakfast, lunch, dinner, and a snack.  
Each meal must include:  
- name  
- list of ingredients with item + quantity  
- nutrition info (calories, proteins, fiber, fat, carbs)  
- recipe with ordered steps (step_number, instruction) and total_time_minutes '''
      );
      print('Raw response: $response'); 
      try {
        final parsedResponse = jsonDecode(response);
        if (parsedResponse is! Map<String, dynamic>) {
          throw const FormatException('Response is not a valid JSON object');
        }
        if (mounted) {
          setState(() {
            _mealPlan = parsedResponse; // Store the full response, including recipes
          });
        }
      } catch (jsonError) {
        print('Failed to parse meal plan: $jsonError');
        if (mounted) {
          setState(() {
            _mealPlan = {
              'error': 'Failed to parse meal plan. Please check the response format.',
              'raw_response': response,
            };
          });
        }
      }
    } catch (e) {
      print('Failed to fetch meal plan: $e'); // Log the error
      if (mounted) {
        setState(() {
          _mealPlan = {'error': 'Failed to fetch meal plan: $e'};
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  Map<String, dynamic> _getMealPlanAsMap() {
    if (_mealPlan == null || !_mealPlan!.containsKey('meal_plan')) {
      return {};
    }

    final mealPlanData = _mealPlan!['meal_plan'];
    
    if (mealPlanData is Map<String, dynamic>) {
      return mealPlanData;
    } else if (mealPlanData is List<dynamic>) {
      Map<String, dynamic> result = {};
      for (int i = 0; i < mealPlanData.length; i++) {
        if (mealPlanData[i] is Map<String, dynamic>) {
          final meal = mealPlanData[i] as Map<String, dynamic>;
          final mealName = meal['name'] ?? 'Meal ${i + 1}';
          result[mealName] = meal;
        }
      }
      return result;
    }
    
    return {};
  }

  Widget _buildDailyStats() {
    final mealPlan = _getMealPlanAsMap();
    if (mealPlan.isEmpty) return Container();

    double totalCalories = 0;
    double totalProteins = 0, totalFiber = 0, totalFat = 0, totalCarbs = 0;

    for (final meal in mealPlan.values) {
      if (meal is Map<String, dynamic>) {
        final nutrition = meal['nutrition'] as Map<String, dynamic>?;
        if (nutrition != null) {
          totalCalories += (nutrition['calories'] ?? 0).toDouble();
          totalProteins += (nutrition['proteins'] ?? 0).toDouble();
          totalFiber += (nutrition['fiber'] ?? 0).toDouble();
          totalFat += (nutrition['fat'] ?? 0).toDouble();
          totalCarbs += (nutrition['carbs'] ?? 0).toDouble();
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Nutrition Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Calories', '${totalCalories.toStringAsFixed(0)}kcal', Icons.local_fire_department),
              _buildStatItem('Protein', '${totalProteins.toStringAsFixed(1)}g', Icons.fitness_center),
              _buildStatItem('Fiber', '${totalFiber.toStringAsFixed(1)}g', Icons.grass),
              _buildStatItem('Fat', '${totalFat.toStringAsFixed(1)}g', Icons.opacity),
              _buildStatItem('Carbs', '${totalCarbs.toStringAsFixed(1)}g', Icons.bakery_dining),
              _buildStatItem('Meals', '${mealPlan.length}', Icons.restaurant),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _generateMealPlanSpeechText() {
    final mealPlan = _getMealPlanAsMap();
    if (mealPlan.isEmpty) return '';

    double totalCalories = 0;
    double totalProteins = 0, totalCarbs = 0, totalFat = 0;
    
    for (final meal in mealPlan.values) {
      if (meal is Map<String, dynamic>) {
        final nutrition = meal['nutrition'] as Map<String, dynamic>?;
        if (nutrition != null) {
          totalCalories += (nutrition['calories'] ?? 0).toDouble();
          totalProteins += (nutrition['proteins'] ?? 0).toDouble();
          totalCarbs += (nutrition['carbs'] ?? 0).toDouble();
          totalFat += (nutrition['fat'] ?? 0).toDouble();
        }
      }
    }

    String text = 'Here is your meal plan for today. ';
    text += 'You have ${mealPlan.length} meals planned. ';
    text += 'Total nutrition: ${totalCalories.toStringAsFixed(0)} calories, ';
    text += '${totalProteins.toStringAsFixed(0)} grams of protein, ';
    text += '${totalCarbs.toStringAsFixed(0)} grams of carbs, ';
    text += 'and ${totalFat.toStringAsFixed(0)} grams of fat. ';
    
    for (final entry in mealPlan.entries) {
      final mealType = entry.key;
      final meal = entry.value;
      
      if (meal is Map<String, dynamic>) {
        final mealName = meal['name'] ?? 'Unknown';
        text += 'For $mealType, you will have $mealName. ';
        
        final nutrition = meal['nutrition'] as Map<String, dynamic>?;
        if (nutrition != null) {
          text += 'This meal contains ${nutrition['calories']} calories. ';
        }
      }
    }
    
    return text;
  }

  Future<void> _readMealPlan() async {
    if (_elevenLabsService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ElevenLabs API key not configured'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSpeaking = true);
    
    try {
      final text = _generateMealPlanSpeechText();
      await _elevenLabsService.speakText(text: text);
      
      if (mounted) {
        setState(() => _isSpeaking = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSpeaking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading plan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopReading() async {
    await _elevenLabsService?.stopSpeaking();
    setState(() => _isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mealPlan != null && !_mealPlan!.containsKey('error') ? 'Suggested Plan' : 'Your Dashboard',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          // Cart icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
              ),
              if (_cartService.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartService.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Voice Assistant',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VoiceAssistantScreen(
                    userContext: widget.user,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final updatedUser = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(user: widget.user),
                ),
              );
              if (updatedUser != null) {
                setState(() {
                  widget.user.addAll(updatedUser);
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Image.asset(
                'assets/logo_apka.png',
                height: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_mealPlan == null)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 300), // Space for the logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: TextField(
                          controller: _detailsController,
                          decoration: const InputDecoration(
                            labelText: 'More details for todays meal plan!',
                            border: InputBorder.none,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () => _fetchMealPlan(_detailsController.text),
                        child: Text(
                          "Let's plan it!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else if (_mealPlan!.containsKey('error'))
            Center(
              child: Text(
                _mealPlan!['error'],
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          else
            Column(
              children: [
                _buildDailyStats(),
                Expanded(
                  child: MealPlanRenderer(mealPlan: _getMealPlanAsMap()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      // Add to Cart Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            _cartService.addAllIngredientsFromMealPlan(_getMealPlanAsMap());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${_getMealPlanAsMap().length} meals to cart!'),
                                backgroundColor: Colors.green,
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const CartScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                          label: const Text(
                            'Add All Ingredients to Cart',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_elevenLabsService != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSpeaking ? Colors.red : Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSpeaking ? _stopReading : _readMealPlan,
                            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up, color: Colors.white),
                            label: Text(
                              _isSpeaking ? 'Stop Reading' : 'Read Meal Plan Aloud',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      if (_elevenLabsService != null) const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _fetchMealPlan(_detailsController.text),
                            child: const Text(
                              'Reprompt Plan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              // Save the meal plan logic here
                              print('Meal plan saved!');
                            },
                            child: const Text(
                              'Save Plan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _mealPlan = null;
                    });
                  },
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const SettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foodPrefsCtrl = TextEditingController(text: user['food_preferences'] ?? '');
    final allergiesCtrl = TextEditingController(text: user['allergies'] ?? '');
    final shopPrefCtrl = TextEditingController(text: user['shop_preference'] ?? '');

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FoodPreferences(controller: foodPrefsCtrl),
              const SizedBox(height: 16),
              Allergies(controller: allergiesCtrl),
              const SizedBox(height: 16),
              ShopPreferences(controller: shopPrefCtrl),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'food_preferences': foodPrefsCtrl.text,
                    'allergies': allergiesCtrl.text,
                    'shop_preference': shopPrefCtrl.text,
                  });
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
