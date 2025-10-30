import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsByMeal = _cartService.itemsByMeal;

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart (${_cartService.itemCount} items)'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_cartService.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _cartService.clearCart();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _cartService.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add ingredients from your meal plan to get started!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: itemsByMeal.length,
              itemBuilder: (context, index) {
                final mealKey = itemsByMeal.keys.elementAt(index);
                final items = itemsByMeal[mealKey]!;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            mealKey.contains('-') ? mealKey.split('-')[1].trim() : mealKey,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: null,
                          ),
                        ),
                        Checkbox(
                          value: items.every((item) => item.checked),
                          onChanged: (value) {
                            _cartService.toggleMealChecked(mealKey);
                          },
                        ),
                      ],
                    ),
                    subtitle: Text('${items.length} ingredient${items.length != 1 ? 's' : ''}'),
                    children: items.map((item) => ListTile(
                      leading: Checkbox(
                        value: item.checked,
                        onChanged: (value) {
                          _cartService.toggleItemChecked(item);
                        },
                      ),
                      title: Text(item.name),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          _cartService.removeItem(item);
                        },
                      ),
                    )).toList(),
                  ),
                );
              },
            ),
      bottomNavigationBar: _cartService.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total: ${_cartService.itemCount} ingredient${_cartService.itemCount != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _showExportOptions(context);
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text(
                          'Export Shopping List',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _showExportOptions(BuildContext context) {
    final items = _cartService.items;
    final shoppingList = items.map((item) => '• ${item.name} (${item.quantity})').join('\n');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shopping List'),
        content: SingleChildScrollView(
          child: Text(shoppingList),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Shopping list copied to clipboard would go here!'),
                ),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}
