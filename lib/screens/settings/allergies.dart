import 'package:flutter/material.dart';
import '../../main.dart';

class Allergies extends StatefulWidget {
  final TextEditingController controller;

  const Allergies({Key? key, required this.controller}) : super(key: key);

  @override
  _AllergiesState createState() => _AllergiesState();
}

class _AllergiesState extends State<Allergies> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Allergies',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: allergenOptions.map((allergy) {
            final isSelected = widget.controller.text.split(',').contains(allergy);
            return FilterChip(
              label: Text(allergy),
              selected: isSelected,
              onSelected: (val) {
                final selectedAllergies = widget.controller.text.split(',');
                if (val) {
                  selectedAllergies.add(allergy);
                } else {
                  selectedAllergies.remove(allergy);
                }
                setState(() {
                  widget.controller.text = selectedAllergies.join(',');
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
