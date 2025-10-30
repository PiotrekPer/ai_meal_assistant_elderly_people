import 'package:flutter/material.dart';
import 'dashboard/meal_card.dart';

class MealPlanRenderer extends StatelessWidget {
  final Map<String, dynamic> mealPlan;

  const MealPlanRenderer({Key? key, required this.mealPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: mealPlan.keys.length,
      itemBuilder: (context, index) {
        final mealType = mealPlan.keys.elementAt(index);
        final meal = mealPlan[mealType] ?? {};
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 6.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                mealType,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              subtitle: Text(
                meal['name'] ?? 'Unknown Meal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MealCard(
                        mealType: mealType,
                        meal: meal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
