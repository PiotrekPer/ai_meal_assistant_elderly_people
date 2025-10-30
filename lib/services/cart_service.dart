import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final String quantity;
  final String mealType;
  final String mealName;
  bool checked; 

  CartItem({
    required this.name,
    required this.quantity,
    required this.mealType,
    required this.mealName,
    this.checked = false, 
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          quantity == other.quantity &&
          mealType == other.mealType &&
          mealName == other.mealName;

  @override
  int get hashCode => Object.hash(name, quantity, mealType, mealName);

  @override
  String toString() => '$name ($quantity) - $mealName';
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  void addItem(CartItem item) {
    if (!_items.contains(item)) {
      _items.add(item);
      notifyListeners();
    }
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void addAllIngredientsFromMealPlan(Map<String, dynamic> mealPlan) {
    mealPlan.forEach((mealType, mealData) {
      if (mealData is Map<String, dynamic>) {
        final mealName = mealData['name'] ?? mealType;
        final ingredients = mealData['ingredients'] as List?;
        
        if (ingredients != null) {
          for (final ingredient in ingredients) {
            if (ingredient is Map<String, dynamic>) {
              final item = CartItem(
                name: ingredient['item'] ?? ingredient['name'] ?? 'Unknown ingredient',
                quantity: ingredient['quantity'] ?? 'N/A',
                mealType: mealType,
                mealName: mealName,
              );
              addItem(item);
            }
          }
        }
      }
    });
  }

  void addIngredientsFromMeal(String mealType, Map<String, dynamic> mealData) {
    final mealName = mealData['name'] ?? mealType;
    final ingredients = mealData['ingredients'] as List?;
    
    if (ingredients != null) {
      for (final ingredient in ingredients) {
        if (ingredient is Map<String, dynamic>) {
          final item = CartItem(
            name: ingredient['item'] ?? ingredient['name'] ?? 'Unknown ingredient',
            quantity: ingredient['quantity'] ?? 'N/A',
            mealType: mealType,
            mealName: mealName,
          );
          addItem(item);
        }
      }
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Map<String, List<CartItem>> get itemsByMeal {
    final Map<String, List<CartItem>> grouped = {};
    for (final item in _items) {
      final key = '${item.mealType} - ${item.mealName}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }
    return grouped;
  }

  void toggleItemChecked(CartItem item) {
    final index = _items.indexOf(item);
    if (index != -1) {
      _items[index].checked = !_items[index].checked;
      notifyListeners();
    }
  }

  void toggleMealChecked(String mealKey) {
    final itemsInMeal = itemsByMeal[mealKey];
    if (itemsInMeal != null) {
      final allChecked = itemsInMeal.every((item) => item.checked);
      for (final item in itemsInMeal) {
        item.checked = !allChecked;
      }
      notifyListeners();
    }
  }
}
