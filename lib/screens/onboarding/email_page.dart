import 'package:flutter/material.dart';
import 'onboarding_page_wrapper.dart';

class EmailPage extends StatelessWidget {
  final TextEditingController controller;
  final String name;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  const EmailPage({required this.controller, required this.name, required this.onChanged, required this.onSubmitted, super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      title: "Hi ${name.isNotEmpty ? name : ''}! What's your email?",
      subtitle: "We’ll use it for sign-in and updates.",
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: [AutofillHints.email],
        onChanged: (_) => onChanged(),
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'you@example.com',
          prefixIcon: Icon(Icons.email_outlined),
        ),
      ),
    );
  }
}
