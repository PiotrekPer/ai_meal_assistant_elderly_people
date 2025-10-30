import 'package:flutter/material.dart';
import 'onboarding_page_wrapper.dart';

class ShopPreferencePage extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onChanged;
  const ShopPreferencePage({required this.options, required this.selected, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      title: "Where do you shop for groceries?",
      subtitle: "Pick your favorite shop.",
      child: DropdownButtonFormField<String>(
        value: selected,
        items: options.map((shop) => DropdownMenuItem(
          value: shop,
          child: Text(shop),
        )).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: 'Shop',
          prefixIcon: Icon(Icons.storefront_outlined),
        ),
      ),
    );
  }
}
