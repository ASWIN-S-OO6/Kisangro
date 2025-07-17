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

  // This setter is crucial for incrementing/decrementing quantity and notifying
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
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Future<void>? _loadFuture; // To hold the future of the initial load

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get totalItemCount => _items.length;

  CartModel() {
    _loadFuture = _loadCartItems(); // Start loading when instantiated
  }

  // Loads cart items from the database
  Future<void> _loadCartItems() async {
    debugPrint('CartModel: Starting to load cart items from DB...');
    try {
      _items.clear(); // Clear existing items before loading from DB
      final loadedItems = await _dbHelper.getCartItems();
      for (var item in loadedItems) {
        _items.add(item);
        // Attach listener to loaded items so changes to quantity/unit are persisted
        item.addListener(() => _updateItemInDb(item));
      }
      notifyListeners();
      debugPrint('CartModel: Loaded ${_items.length} items from DB successfully.');
    } catch (e) {
      debugPrint('CartModel: Error loading cart items from DB: $e');
    }
  }

  // Helper method to ensure initial load is complete
  Future<void> _ensureLoaded() async {
    if (_loadFuture != null) {
      debugPrint('CartModel: Awaiting initial DB load...');
      await _loadFuture;
      _loadFuture = null; // Clear the future after it completes once
      debugPrint('CartModel: Initial DB load completed.');
    } else {
      debugPrint('CartModel: Initial DB load already completed or not needed.');
    }
  }

  // Helper method to update a single item in the database
  Future<void> _updateItemInDb(CartItem item) async {
    try {
      await _dbHelper.insertCartItem(item); // insertCartItem uses REPLACE, so it works for updates too
      debugPrint('CartModel: DB Updated: ${item.title}, Qty: ${item.quantity}, Unit: ${item.selectedUnit}');
    } catch (e) {
      debugPrint('CartModel: Error updating cart item in DB: $e');
    }
  }

  // Modified addItem to handle quantity increment for existing items
  Future<void> addItem(Product product) async { // Made async
    await _ensureLoaded(); // Ensure items are loaded from DB before adding

    debugPrint('CartModel: Attempting to add product: ${product.title}');
    debugPrint('  Incoming Product ID: "${product.id}", Unit: "${product.selectedUnit}"');

    CartItem? existingItem;
    for (var item in _items) {
      debugPrint('  Comparing with existing item: ID: "${item.id}", Unit: "${item.selectedUnit}"');
      if (item.id == product.id && item.selectedUnit == product.selectedUnit) {
        existingItem = item;
        debugPrint('  MATCH FOUND! Existing item: ${item.title}, Current Qty: ${item.quantity}');
        break;
      }
    }

    if (existingItem != null) {
      existingItem.incrementQuantity();
      await _updateItemInDb(existingItem); // Persist quantity change
      debugPrint('CartModel: Incremented quantity for existing item: ${product.title}, new quantity: ${existingItem.quantity}');
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
          quantity: 1, // Start with quantity 1 for new items
        );
        _items.add(newCartItem);
        newCartItem.addListener(() => _updateItemInDb(newCartItem)); // Attach listener to new item
        await _dbHelper.insertCartItem(newCartItem); // Save new item to DB
        debugPrint('CartModel: Added NEW item to cart: ${product.title} with price $price, Unit: ${product.selectedUnit}');
      } else {
        debugPrint(
            'CartModel: Error: Product ${product.title} has no valid price for selected unit ${product.selectedUnit}. Not adding to cart.');
      }
    }
    notifyListeners(); // Notify UI listeners
  }

  Future<void> removeItem(String productId, String selectedUnit) async { // Made async
    await _ensureLoaded(); // Ensure items are loaded from DB before removing

    debugPrint('CartModel: Attempting to remove product: ID: "$productId", Unit: "$selectedUnit"');
    final removedItemIndex = _items.indexWhere(
          (item) => item.id == productId && item.selectedUnit == selectedUnit,
    );

    if (removedItemIndex != -1) {
      final itemToRemove = _items[removedItemIndex];
      itemToRemove.removeListener(() => _updateItemInDb(itemToRemove)); // Remove listener
      _items.removeAt(removedItemIndex);
      await _dbHelper.removeCartItem(productId, selectedUnit); // Remove from DB
      debugPrint('CartModel: Removed item from cart: "$productId", Unit: "$selectedUnit"');
      notifyListeners(); // Notify UI listeners
    } else {
      debugPrint('CartModel: Item not found for removal: ID: "$productId", Unit: "$selectedUnit"');
    }
  }

  Future<void> clearCart() async { // Made async
    await _ensureLoaded(); // Ensure items are loaded from DB before clearing

    debugPrint('CartModel: Clearing all cart items.');
    for (var item in _items) {
      item.removeListener(() => _updateItemInDb(item)); // Remove listeners from all items
    }
    _items.clear();
    await _dbHelper.clearCartItems(); // Clear items from DB
    notifyListeners(); // Notify UI listeners
  }

  // MODIFIED: This method now ADDS items to the cart, instead of clearing and replacing.
  Future<void> addProductsToCartFromOrder(List<OrderedProduct> orderedProducts) async { // Made async
    await _ensureLoaded(); // Ensure items are loaded from DB before adding from order

    debugPrint('CartModel: Populating cart from order with ${orderedProducts.length} products.');
    // No clearing of _items here. We add to existing items.
    for (var orderedProduct in orderedProducts) {
      // Check if product already exists in cart with the same unit, if so, increment quantity
      final existingCartItem = _items.firstWhereOrNull(
            (item) => item.id == orderedProduct.id && item.selectedUnit == orderedProduct.unit,
      );

      if (existingCartItem != null) {
        existingCartItem.quantity += orderedProduct.quantity; // Increment quantity
        await _updateItemInDb(existingCartItem); // Update in DB
        debugPrint('CartModel: Incremented quantity for existing item from order: ${orderedProduct.title}, new quantity: ${existingCartItem.quantity}');
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
        await _dbHelper.insertCartItem(newCartItem); // Add to DB
        debugPrint('CartModel: Added new item from order to cart: ${orderedProduct.title}, Qty: ${orderedProduct.quantity}, Unit: ${orderedProduct.unit}');
      }
    }
    notifyListeners();
    debugPrint('CartModel: Cart populated from order. Current cart size: ${_items.length}');
  }
}
