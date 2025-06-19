import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // For deep equality checks if needed
import 'product_model.dart'; // Import Product and ProductSize
import 'order_model.dart'; // Import OrderedProduct

// Represents an item in the shopping cart.
class CartItem extends ChangeNotifier {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String category; // Added category
  String _selectedUnit; // The specific unit (e.g., "500 ML", "1 L")
  double _pricePerUnit; // Price for the selected unit
  int _quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.category,
    required String selectedUnit,
    required double pricePerUnit,
    int quantity = 1, // Default quantity is 1
  })  : _selectedUnit = selectedUnit,
        _pricePerUnit = pricePerUnit,
        _quantity = quantity;

  // Getters
  String get selectedUnit => _selectedUnit;
  double get pricePerUnit => _pricePerUnit;
  int get quantity => _quantity;

  // Calculate total price for this item based on quantity and price per unit
  double get totalPrice => _pricePerUnit * _quantity;

  // Setters (with notifyListeners for UI updates)
  set selectedUnit(String newUnit) {
    if (_selectedUnit != newUnit) {
      _selectedUnit = newUnit;
      notifyListeners();
    }
  }

  set pricePerUnit(double newPrice) {
    if (_pricePerUnit != newPrice) {
      _pricePerUnit = newPrice;
      notifyListeners();
    }
  }

  set quantity(int newQuantity) {
    if (_quantity != newQuantity && newQuantity >= 0) {
      _quantity = newQuantity;
      notifyListeners();
    }
  }

  // Convenience methods for quantity
  void incrementQuantity() {
    quantity++; // Uses the setter
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--; // Uses the setter
    }
  }

  // Converts CartItem to OrderedProduct for order placement
  OrderedProduct toOrderedProduct() {
    return OrderedProduct(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      category: category,
      selectedUnit: selectedUnit,
      pricePerUnit: pricePerUnit,
      quantity: quantity,
    );
  }
}

// Manages the list of CartItem objects in the shopping cart.
class CartModel extends ChangeNotifier {
  final List<CartItem> _items = []; // Private list of cart items

  List<CartItem> get items => List.unmodifiable(_items); // Public getter for immutable list

  // Calculates the total amount of all items in the cart
  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  // Gets the total count of unique items (not total quantity)
  int get totalItemCount => _items.length;

  // Adds a product to the cart or increments its quantity if it already exists.
  void addItem(Product product) {
    // Check if an item with the same ID and selected unit already exists
    final existingItemIndex = _items.indexWhere(
      (item) => item.id == product.id && item.selectedUnit == product.selectedUnit,
    );

    if (existingItemIndex != -1) {
      // If item exists, increment its quantity
      _items[existingItemIndex].incrementQuantity();
      debugPrint('Incremented quantity for existing item: ${product.title}');
    } else {
      // If item does not exist, add a new CartItem
      // Ensure pricePerSelectedUnit is not null, default to 0.0 if it is
      final double price = product.pricePerSelectedUnit ?? 0.0;

      if (price >= 0) { // Only add if price is non-negative
        _items.add(CartItem(
          id: product.id,
          title: product.title,
          subtitle: product.subtitle,
          imageUrl: product.imageUrl,
          category: product.category,
          selectedUnit: product.selectedUnit,
          pricePerUnit: price, // Use the safely obtained price
        ));
        debugPrint('Added new item to cart: ${product.title} with price $price');
      } else {
        debugPrint('Error: Product ${product.title} has no valid price for selected unit ${product.selectedUnit}. Not adding to cart.');
      }
    }
    notifyListeners(); // Notify UI about changes
  }


  // Removes an item from the cart
  void removeItem(String productId, String selectedUnit) {
    _items.removeWhere(
      (item) => item.id == productId && item.selectedUnit == selectedUnit,
    );
    notifyListeners();
  }

  // Clears the entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Populate cart from an Order's products (for "Modify Order" functionality)
  void populateCartFromOrder(List<OrderedProduct> orderedProducts) {
    _items.clear(); // Clear existing cart
    for (var orderedProduct in orderedProducts) {
      _items.add(
        CartItem(
          id: orderedProduct.id,
          title: orderedProduct.title,
          subtitle: orderedProduct.subtitle,
          imageUrl: orderedProduct.imageUrl,
          category: orderedProduct.category,
          selectedUnit: orderedProduct.selectedUnit,
          pricePerUnit: orderedProduct.pricePerUnit, // Directly use pricePerUnit from OrderedProduct
          quantity: orderedProduct.quantity,
        ),
      );
    }
    notifyListeners();
  }
}
