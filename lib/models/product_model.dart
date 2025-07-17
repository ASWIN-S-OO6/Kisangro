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

  // Convert ProductSize to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'price': price,
    };
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
    String? selectedUnit, // Make selectedUnit optional in constructor
  }) : _selectedUnit = selectedUnit ?? (availableSizes.isNotEmpty ? availableSizes.first.size : 'Unit');


  // Factory constructor to create a Product from JSON
  // IMPORTANT: When using json_annotation, the actual `fromJson` implementation
  // is generated in `product_model.g.dart`. We define the *signature* here
  // and then the build_runner creates the implementation.
  // The named parameters `idOverride`, `categoryOverride`, `imageUrlOverride`
  // are passed to the Product constructor *after* the raw JSON is parsed.
  factory Product.fromJson(Map<String, dynamic> json) {
    // The generated fromJson will handle the direct JSON parsing.
    // We will handle the overrides in the ProductService when calling this.
    // The actual implementation of Product.fromJson will be in product_model.g.dart
    // and will look something like:
    // Product _$ProductFromJson(Map<String, dynamic> json) => Product(...)
    // So, we need to ensure the ProductService passes these values to the Product constructor.

    // This part of the factory is usually handled by the generator.
    // However, if you need custom logic *before* calling the generated constructor,
    // you might do it here or in a separate helper.
    // For json_annotation, the factory *signature* should match what the generator expects.
    // The generator typically creates a factory like:
    // factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
    // And _$ProductFromJson then calls the Product constructor with named parameters.

    // Let's ensure the Product constructor itself can take these overrides.
    // The `id`, `category`, `imageUrl` fields are `final` so they must be set in the constructor.
    // The `ProductService` will pass these values to the `Product` constructor directly.

    // This factory should just call the generated one.
    // The overrides are handled by passing them directly to the Product constructor in ProductService.
    return _$ProductFromJson(json); // This calls the generated part
  }


  // Convert Product to JSON for caching
  Map<String, dynamic> toJson() {
    return _$ProductToJson(this); // This calls the generated part
  }

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
      availableSizes: availableSizes ?? this.availableSizes,
      selectedUnit: selectedUnit ?? this.selectedUnit,
    );
  }
}
