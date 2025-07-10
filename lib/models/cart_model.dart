import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'product_model.dart';
import 'order_model.dart';
import 'database_helper.dart'; // NEW: Import DatabaseHelper

class CartItem extends ChangeNotifier {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String category;
  String _selectedUnit;
  double _pricePerUnit;
  int _quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.category,
    required String selectedUnit,
    required double pricePerUnit,
    int quantity = 1,
  })  : _selectedUnit = selectedUnit,
        _pricePerUnit = pricePerUnit,
        _quantity = quantity;

  String get selectedUnit => _selectedUnit;
  double get pricePerUnit => _pricePerUnit;
  int get quantity => _quantity;

  double get totalPrice => _pricePerUnit * _quantity;

  set selectedUnit(String newUnit) {
    if (_selectedUnit != newUnit) {
      _selectedUnit = newUnit;
      notifyListeners(); // Notify listeners (including CartModel)
    }
  }

  set pricePerUnit(double newPrice) {
    if (_pricePerUnit != newPrice) {
      _pricePerUnit = newPrice;
      notifyListeners(); // Notify listeners (including CartModel)
    }
  }

  set quantity(int newQuantity) {
    if (_quantity != newQuantity && newQuantity >= 0) {
      _quantity = newQuantity;
      notifyListeners(); // Notify listeners (including CartModel)
    }
  }

  void incrementQuantity() {
    quantity++;
  }

  void decrementQuantity() {
    if (quantity > 1) { // Prevent quantity from going below 1
      quantity--;
    }
  }

  OrderedProduct toOrderedProduct({required String orderId}) {
    return OrderedProduct(
      id: id,
      title: title,
      description: subtitle,
      imageUrl: imageUrl,
      category: category,
      unit: selectedUnit,
      price: pricePerUnit,
      quantity: quantity,
      orderId: orderId,
    );
  }
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance; // NEW: DatabaseHelper instance

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get totalItemCount => _items.length;

  CartModel() {
    _loadCartItems(); // NEW: Load cart items when CartModel is instantiated
  }

  // NEW: Loads cart items from the database
  Future<void> _loadCartItems() async {
    try {
      _items.clear();
      final loadedItems = await _dbHelper.getCartItems();
      for (var item in loadedItems) {
        _items.add(item);
        item.addListener(() => _updateItemInDb(item)); // Attach listener to loaded items
      }
      notifyListeners();
      debugPrint('Cart loaded from DB: ${_items.length} items');
    } catch (e) {
      debugPrint('Error loading cart items from DB: $e');
    }
  }

  // NEW: Helper method to update a single item in the database
  Future<void> _updateItemInDb(CartItem item) async {
    try {
      await _dbHelper.insertCartItem(item); // insertCartItem uses REPLACE, so it works for updates too
      debugPrint('Cart item updated in DB: ${item.title}, Qty: ${item.quantity}, Unit: ${item.selectedUnit}');
    } catch (e) {
      debugPrint('Error updating cart item in DB: $e');
    }
  }

  @override
  void addItem(Product product) {
    final existingItem = _items.firstWhereOrNull(
          (item) => item.id == product.id && item.selectedUnit == product.selectedUnit,
    );

    if (existingItem != null) {
      existingItem.incrementQuantity();
      _updateItemInDb(existingItem); // NEW: Persist quantity change
      debugPrint('Incremented quantity for existing item: ${product.title}');
    } else {
      final double price = product.pricePerSelectedUnit ?? 0.0;
      if (price >= 0) {
        final newCartItem = CartItem(
          id: product.id,
          title: product.title,
          subtitle: product.subtitle,
          imageUrl: product.imageUrl,
          category: product.category,
          selectedUnit: product.selectedUnit,
          pricePerUnit: price,
        );
        _items.add(newCartItem);
        newCartItem.addListener(() => _updateItemInDb(newCartItem)); // NEW: Attach listener to new item
        _dbHelper.insertCartItem(newCartItem); // NEW: Save new item to DB
        debugPrint('Added new item to cart: ${product.title} with price $price');
      } else {
        debugPrint(
            'Error: Product ${product.title} has no valid price for selected unit ${product.selectedUnit}. Not adding to cart.');
      }
    }
    notifyListeners(); // Notify UI listeners
  }

  @override
  void removeItem(String productId, String selectedUnit) {
    final removedItemIndex = _items.indexWhere(
          (item) => item.id == productId && item.selectedUnit == selectedUnit,
    );

    if (removedItemIndex != -1) {
      final itemToRemove = _items[removedItemIndex];
      itemToRemove.removeListener(() => _updateItemInDb(itemToRemove)); // NEW: Remove listener
      _items.removeAt(removedItemIndex);
      _dbHelper.removeCartItem(productId, selectedUnit); // NEW: Remove from DB
      debugPrint('Removed item from cart: $productId, Unit: $selectedUnit');
      notifyListeners(); // Notify UI listeners
    }
  }

  @override
  void clearCart() {
    for (var item in _items) {
      item.removeListener(() => _updateItemInDb(item)); // NEW: Remove listeners from all items
    }
    _items.clear();
    _dbHelper.clearCartItems(); // NEW: Clear items from DB
    notifyListeners(); // Notify UI listeners
  }

  // MODIFIED: This method now ADDS items to the cart, instead of clearing and replacing.
  void addProductsToCartFromOrder(List<OrderedProduct> orderedProducts) {
    // No clearing of _items here. We add to existing items.
    for (var orderedProduct in orderedProducts) {
      // Check if product already exists in cart with the same unit, if so, increment quantity
      final existingCartItem = _items.firstWhereOrNull(
            (item) => item.id == orderedProduct.id && item.selectedUnit == orderedProduct.unit,
      );

      if (existingCartItem != null) {
        existingCartItem.quantity += orderedProduct.quantity; // Increment quantity
        _updateItemInDb(existingCartItem); // Update in DB
      } else {
        final newCartItem = CartItem(
          id: orderedProduct.id,
          title: orderedProduct.title,
          subtitle: orderedProduct.description,
          imageUrl: orderedProduct.imageUrl,
          category: orderedProduct.category,
          selectedUnit: orderedProduct.unit,
          pricePerUnit: orderedProduct.price,
          quantity: orderedProduct.quantity,
        );
        _items.add(newCartItem);
        newCartItem.addListener(() => _updateItemInDb(newCartItem)); // Attach listener
        _dbHelper.insertCartItem(newCartItem); // Add to DB
      }
    }
    notifyListeners();
    debugPrint('Cart populated from order: Added ${orderedProducts.length} items. Current cart size: ${_items.length}');
  }
}
