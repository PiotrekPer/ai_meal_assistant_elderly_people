import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/onboarding/onboarding_page_wrapper.dart';

class NamePage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const NamePage({required this.controller, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      title: "What's your name?",
      subtitle: "We’ll personalize your experience.",
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.next,
        autofillHints: [AutofillHints.name],
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          labelText: 'Name',
          hintText: 'e.g. Piotrek',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
    );
  }
}
