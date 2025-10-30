import 'package:flutter/material.dart';
import 'onboarding_page_wrapper.dart';

class FoodPreferencesPage extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  const FoodPreferencesPage({required this.options, required this.selected, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      title: "What are your food preferences?",
      subtitle: "Select all that apply.",
      child: Wrap(
        spacing: 8,
        children: options.map((food) {
          final isSelected = selected.contains(food);
          return FilterChip(
            label: Text(food),
            selected: isSelected,
            onSelected: (val) {
              final newSelected = List<String>.from(selected);
              if (val) {
                newSelected.add(food);
              } else {
                newSelected.remove(food);
              }
              onChanged(newSelected);
            },
          );
        }).toList(),
      ),
    );
  }
}
