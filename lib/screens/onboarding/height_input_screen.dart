import 'package:flutter/material.dart';
import '../../services/user_profile_service.dart';
import 'onboarding_page_wrapper.dart';

class HeightInputScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final Function(double)? onHeightChanged;
  
  const HeightInputScreen({Key? key, this.onNext, this.onHeightChanged}) : super(key: key);

  @override
  State<HeightInputScreen> createState() => _HeightInputScreenState();
}

class _HeightInputScreenState extends State<HeightInputScreen> {
  final UserProfileService _userProfileService = UserProfileService();
  double _height = 170.0; // Default height in cm

  @override
  void initState() {
    super.initState();
    // Initialize height in parent widget
    widget.onHeightChanged?.call(_height);
  }

  void _incrementHeight() {
    setState(() {
      _height += 1;
    });
    widget.onHeightChanged?.call(_height);
  }

  void _decrementHeight() {
    setState(() {
      if (_height > 100) {
        _height -= 1;
      }
    });
    widget.onHeightChanged?.call(_height);
  }

  void saveHeight() {
    _userProfileService.updateHeight(_height);
    widget.onHeightChanged?.call(_height);
  }

  double get currentHeight => _height;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      title: 'What\'s your height?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _decrementHeight,
                icon: const Icon(Icons.remove_circle_outline),
                color: Theme.of(context).colorScheme.primary,
                iconSize: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '$_height cm',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: _incrementHeight,
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
