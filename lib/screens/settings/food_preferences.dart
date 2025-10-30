import 'package:flutter/material.dart';
import '../../main.dart';

class FoodPreferences extends StatefulWidget {
  final TextEditingController controller;

  const FoodPreferences({Key? key, required this.controller}) : super(key: key);

  @override
  _FoodPreferencesState createState() => _FoodPreferencesState();
}

class _FoodPreferencesState extends State<FoodPreferences> {
  @override
  Widget build(BuildContext context) {
    final selectedFoods = widget.controller.text.split(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Preferences',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: foodOptions.map((food) {
            final isSelected = selectedFoods.contains(food);
            return FilterChip(
              label: Text(food),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    selectedFoods.add(food);
                  } else {
                    selectedFoods.remove(food);
                  }
                  widget.controller.text = selectedFoods.join(',');
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
