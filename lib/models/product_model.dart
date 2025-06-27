import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'product_model.g.dart';

// Represents a single available size/unit option for a product.
@JsonSerializable()

class ProductSize {
  final String size;
  final double price; // This must be 'price'

  ProductSize({required this.size, required this.price});

  // Factory constructor to create a ProductSize from JSON
  factory ProductSize.fromJson(Map<String, dynamic> json) {
    // Handle cases where 'mrp' might be null or not a double, defaulting to 0.0
    // The API response uses "mrp", so we map it to "price" in our model.
    final double parsedPrice = (json['mrp'] as num?)?.toDouble() ?? 0.0;
    return ProductSize(
      size: json['size'] as String,
      price: parsedPrice,
    );
  }
}

 @JsonSerializable()

// Represents a single product in the application.
class Product extends ChangeNotifier {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String category; // Added category
  final List<ProductSize> availableSizes; // List of available sizes with their prices
  String _selectedUnit; // Private variable for selected unit

  Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.category,
    required this.availableSizes,
    String? selectedUnit, // Optional initial selected unit
  }) : _selectedUnit = selectedUnit ?? (availableSizes.isNotEmpty ? availableSizes.first.size : ''); // Default to first available size

  // Factory constructor to create a Product from API JSON response
  factory Product.fromJson(Map<String, dynamic> json, String id, String category) {
    final List<ProductSize> sizes = json.containsKey('sizes') && json['sizes'] is List
        ? (json['sizes'] as List).map((sizeJson) => ProductSize.fromJson(sizeJson as Map<String, dynamic>)).toList()
        : [ProductSize(size: 'Unit', price: 0.0)];

    return Product(
      id: id,
      title: json['pro_name'] as String? ?? 'No Title',
      subtitle: json['technical_name'] as String? ?? 'No Description',
      imageUrl: json['image'] as String? ?? 'assets/placeholder.png',
      category: category,
      availableSizes: sizes,
      selectedUnit: sizes.isNotEmpty ? sizes.first.size : 'Unit',
    );
  }

    Map<String, dynamic> toJson() => _$ProductToJson(this);
  //
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'pro_name': title,
  //     'technical_name': subtitle,
  //     'image': imageUrl,
  //     'category': category,
  //     'sizes': availableSizes.map((size) => size.toJson()).toList(),
  //     'selectedUnit': selectedUnit,
  //     'pricePerSelectedUnit': pricePerSelectedUnit,
  //   };
  // }

  // Getters
  String get selectedUnit => _selectedUnit;

  // Setter for selected unit (updates the state and notifies listeners)
  set selectedUnit(String newUnit) {
    if (_selectedUnit != newUnit && availableSizes.any((s) => s.size == newUnit)) {
      _selectedUnit = newUnit;
      notifyListeners(); // Notify consumers when selectedUnit changes
    }
  }

  // Getter to dynamically get the price based on the selected unit
  double? get pricePerSelectedUnit {
    try {
      return availableSizes.firstWhere((size) => size.size == _selectedUnit).price;
    } catch (e) {
      debugPrint('Error: Selected unit $_selectedUnit not found for product $title. Error: $e');
      return null; // Or throw an error, or return a default price
    }
  }

  // Method to create a copy of the product, potentially with new values.
  // Useful for adding to cart without modifying the original product in lists.
  Product copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? category,
    List<ProductSize>? availableSizes,
    String? selectedUnit,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      availableSizes: availableSizes ?? List.from(this.availableSizes), // Deep copy list
      selectedUnit: selectedUnit ?? this.selectedUnit,
    );
  }
}
