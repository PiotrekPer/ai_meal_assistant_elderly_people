import 'package:flutter/material.dart';
import '../../services/user_profile_service.dart';
import 'onboarding_page_wrapper.dart';

class WeightInputScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final Function(double)? onWeightChanged;
  
  const WeightInputScreen({Key? key, this.onNext, this.onWeightChanged}) : super(key: key);

  @override
  State<WeightInputScreen> createState() => _WeightInputScreenState();
}

class _WeightInputScreenState extends State<WeightInputScreen> {
  final UserProfileService _userProfileService = UserProfileService();
  double _weight = 70.0; // Default weight

  @override
  void initState() {
    super.initState();
    // Initialize weight in parent widget
    widget.onWeightChanged?.call(_weight);
  }

  void _incrementWeight() {
    setState(() {
      _weight += 1;
    });
    widget.onWeightChanged?.call(_weight);
  }

  void _decrementWeight() {
    setState(() {
      if (_weight > 1) {
        _weight -= 1;
      }
    });
    widget.onWeightChanged?.call(_weight);
  }

  void saveWeight() {
    _userProfileService.updateWeight(_weight);
    widget.onWeightChanged?.call(_weight);
  }

  double get currentWeight => _weight;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      title: 'What\'s your weight?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _decrementWeight,
                icon: const Icon(Icons.remove_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                iconSize: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '$_weight kg',
                  style: const TextStyle(
                    fontSize: 25, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _incrementWeight,
                icon: const Icon(Icons.add_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                iconSize: 50,
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}
