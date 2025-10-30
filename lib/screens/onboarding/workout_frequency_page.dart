import 'package:flutter/material.dart';
import 'onboarding_page_wrapper.dart';

class WorkoutFrequencyPage extends StatefulWidget {
  final List<String> options;
  final String? selected;
  final Function(String?) onChanged;

  const WorkoutFrequencyPage({
    Key? key,
    required this.options,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<WorkoutFrequencyPage> createState() => _WorkoutFrequencyPageState();
}

class _WorkoutFrequencyPageState extends State<WorkoutFrequencyPage> {
  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      title: 'How often do you work out per week?',
      subtitle: 'This helps us tailor your meal plan to your activity level.',
      child: Column(
        children: widget.options.map((option) {
          final isSelected = widget.selected == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => widget.onChanged(option),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconForOption(option),
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForOption(String option) {
    switch (option.toLowerCase()) {
      case 'not work out':
        return Icons.weekend;
      case '1-3':
        return Icons.fitness_center;
      case '3-5':
        return Icons.sports_gymnastics;
      case 'everyday':
        return Icons.sports_kabaddi;
      default:
        return Icons.fitness_center;
    }
  }
}
