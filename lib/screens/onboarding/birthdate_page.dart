import 'package:flutter/material.dart';
import 'onboarding_page_wrapper.dart';
import '../../database_helper.dart';

class BirthdatePage extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const BirthdatePage({required this.controller, required this.onChanged, super.key});

  @override
  State<BirthdatePage> createState() => _BirthdatePageState();
}

class _BirthdatePageState extends State<BirthdatePage> {
  String? _errorText;

  String? _validateDate(String value) {
    final regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    if (!regex.hasMatch(value)) {
      return 'Enter date as dd/mm/yyyy';
    }
    try {
      final parts = value.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (month < 1 || month > 12 || day < 1 || day > 31) {
        return 'Invalid day or month';
      }
      final date = DateTime(year, month, day);
      final now = DateTime.now();
      if (date.isAfter(now) || year < now.year - 120) {
        return 'Enter a valid birthdate';
      }
      if (month == 2 && day > 29) {
        return 'Invalid day for February';
      }
      if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) {
        return 'Invalid day for the month';
      }
    } catch (_) {
      return 'Invalid date';
    }
    return null;
  }

  void _saveAgeToDatabase(String birthdate) {
    final parts = birthdate.split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final birthDate = DateTime(year, month, day);
    final now = DateTime.now();
    final age = now.year - birthDate.year - (now.isBefore(DateTime(now.year, birthDate.month, birthDate.day)) ? 1 : 0);

    final dbHelper = DatabaseHelper();
    dbHelper.insertUser(
      'example@example.com', // Replace with actual user email
      'password123', // Replace with actual user password
      'John Doe', // Replace with actual user name
      age: age,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final error = _validateDate(widget.controller.text);
      if (error != _errorText) {
        setState(() {
          _errorText = error;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageWrapper(
      title: "When were you born?",
      subtitle: "We’ll use this to tailor recommendations.",
      child: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          hintText: 'dd/mm/yyyy',
          prefixIcon: Icon(Icons.cake_outlined),
          errorText: _errorText,
        ),
        onChanged: (value) {
          setState(() {
            _errorText = _validateDate(value);
          });
          if (_errorText == null) {
            _saveAgeToDatabase(value);
          }
          widget.onChanged();
        },
        maxLength: 10,
      ),
    );
  }
}
