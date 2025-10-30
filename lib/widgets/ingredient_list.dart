import 'package:flutter/material.dart';

class IngredientList extends StatelessWidget {
  final List<Map<String, dynamic>> ingredients;

  const IngredientList({Key? key, required this.ingredients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8.0),
        ...ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ingredient['name'] ?? 'Unknown',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                Text(
                  'Quantity: ${ingredient['quantity'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
