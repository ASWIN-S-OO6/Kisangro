import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'product_model.dart';
import 'order_model.dart';

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

  void incrementQuantity() {
    quantity++;
  }

  void decrementQuantity() {
    if (quantity > 1) {
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

  List<CartItem> get items => List.unmodifiable(_items);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get totalItemCount => _items.length;

  void addItem(Product product) {
    final existingItemIndex = _items.indexWhere(
          (item) => item.id == product.id && item.selectedUnit == product.selectedUnit,
    );

    if (existingItemIndex != -1) {
      _items[existingItemIndex].incrementQuantity();
      debugPrint('Incremented quantity for existing item: ${product.title}');
    } else {
      final double price = product.pricePerSelectedUnit ?? 0.0;
      if (price >= 0) {
        _items.add(CartItem(
          id: product.id,
          title: product.title,
          subtitle: product.subtitle,
          imageUrl: product.imageUrl,
          category: product.category,
          selectedUnit: product.selectedUnit,
          pricePerUnit: price,
        ));
        debugPrint('Added new item to cart: ${product.title} with price $price');
      } else {
        debugPrint(
            'Error: Product ${product.title} has no valid price for selected unit ${product.selectedUnit}. Not adding to cart.');
      }
    }
    notifyListeners();
  }

  void removeItem(String productId, String selectedUnit) {
    _items.removeWhere(
          (item) => item.id == productId && item.selectedUnit == selectedUnit,
    );
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void populateCartFromOrder(List<OrderedProduct> orderedProducts) {
    _items.clear();
    for (var orderedProduct in orderedProducts) {
      _items.add(
        CartItem(
          id: orderedProduct.id,
          title: orderedProduct.title,
          subtitle: orderedProduct.description,
          imageUrl: orderedProduct.imageUrl,
          category: orderedProduct.category,
          selectedUnit: orderedProduct.unit,
          pricePerUnit: orderedProduct.price,
          quantity: orderedProduct.quantity,
        ),
      );
    }
    notifyListeners();
  }
}