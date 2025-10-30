import 'package:flutter/material.dart';

class OnboardingPageWrapper extends StatelessWidget {
  final String title;
  final String? subtitle; // Made subtitle optional
  final Widget child;
  final VoidCallback? onNext; // Added onNext callback

  const OnboardingPageWrapper({
    required this.title,
    this.subtitle, // Updated constructor
    required this.child,
    this.onNext, // Added constructor parameter
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo_apka.png', height: 140),
                  SizedBox(height: 12),
                  Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                  if (subtitle != null) ...[
                    SizedBox(height: 6),
                    Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                  SizedBox(height: 20),
                  child,
                ],
              ),
            ),
          ),
        ),
        if (onNext != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: onNext,
              child: const Icon(Icons.arrow_forward),
            ),
          ),
      ],
    );
  }
}
