import 'package:flutter/material.dart';
import 'onboarding_page_wrapper.dart';

class AllergiesPage extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  const AllergiesPage({required this.options, required this.selected, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      title: "Do you have any allergies?",
      subtitle: "Select all allergens that apply.",
      child: Wrap(
        spacing: 8,
        children: options.map((allergen) {
          final isSelected = selected.contains(allergen);
          return FilterChip(
            label: Text(allergen),
            selected: isSelected,
            onSelected: (val) {
              final newSelected = List<String>.from(selected);
              if (val) {
                newSelected.add(allergen);
              } else {
                newSelected.remove(allergen);
              }
              onChanged(newSelected);
            },
          );
        }).toList(),
      ),
    );
  }
}
