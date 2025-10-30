import 'package:flutter/material.dart';
import '../../main.dart';

class ShopPreferences extends StatefulWidget {
  final TextEditingController controller;

  const ShopPreferences({Key? key, required this.controller}) : super(key: key);

  @override
  _ShopPreferencesState createState() => _ShopPreferencesState();
}

class _ShopPreferencesState extends State<ShopPreferences> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shop Preference',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: shopOptions.map((shop) {
            final isSelected = widget.controller.text == shop;
            return ChoiceChip(
              label: Text(shop),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  widget.controller.text = val ? shop : '';
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
