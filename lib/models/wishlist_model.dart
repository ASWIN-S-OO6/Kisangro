import 'package:flutter/foundation.dart';
import 'package:kisangro/models/product_model.dart'; // Import the Product model

/// A ChangeNotifier for managing the state of the user's wishlist.
class WishlistModel extends ChangeNotifier {
  final List<Product> _items = []; // Private list to store wishlist products

  List<Product> get items => List.unmodifiable(_items); // Public getter for an unmodifiable list of items

  /// Adds a product to the wishlist if it's not already present.
  void addItem(Product product) {
    // Check if the item is already in the wishlist (based on product ID and selected unit)
    if (!_items.any((item) => item.id == product.id && item.selectedUnit == product.selectedUnit)) {
      _items.add(product);
      notifyListeners(); // Notify listeners about the change
    }
  }

  /// Removes a product from the wishlist.
  void removeItem(String productId, String selectedUnit) {
    _items.removeWhere(
      (item) => item.id == productId && item.selectedUnit == selectedUnit,
    );
    notifyListeners(); // Notify listeners about the change
  }

  /// Checks if a product is already in the wishlist.
  bool containsItem(String productId, String selectedUnit) {
    return _items.any((item) => item.id == productId && item.selectedUnit == selectedUnit);
  }

  /// Clears all items from the wishlist.
  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }
}
