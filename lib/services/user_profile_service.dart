import 'package:flutter/foundation.dart';

class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  String? _name;
  double? _weight;
  double? _height;

  String? get name => _name;
  double? get weight => _weight;
  double? get height => _height;

  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void updateWeight(double weight) {
    _weight = weight;
    notifyListeners();
  }

  void updateHeight(double height) {
    _height = height;
    notifyListeners();
  }
}
