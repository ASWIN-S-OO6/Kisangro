import 'package:flutter/material.dart'; // For ChangeNotifier and debugPrint

// Represents a single available size/unit option for a product.
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

  // Convert ProductSize to JSON for potential serialization
  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'mrp': price, // Use 'mrp' to match API expectation if sending back
    };
  }
}

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
  }) : _selectedUnit = selectedUnit ?? (availableSizes.isNotEmpty ? availableSizes.first.size : '');

  // Factory constructor to create a Product from API JSON response
  factory Product.fromJson(Map<String, dynamic> json, String id, String category) {
    // Parse sizes list
    List<ProductSize> sizes = [];
    if (json['sizes'] is List) {
      sizes = (json['sizes'] as List)
          .map((sizeJson) => ProductSize.fromJson(sizeJson as Map<String, dynamic>))
          .toList();
    } else if (json.containsKey('mrp')) { // Fallback if 'sizes' array is missing but 'mrp' is direct
      final double price = (json['mrp'] as num?)?.toDouble() ?? 0.0;
      sizes.add(ProductSize(size: json['unit'] as String? ?? 'Unit', price: price));
    }


    // Default to the first size if available, otherwise empty string
    String initialSelectedUnit = sizes.isNotEmpty ? sizes.first.size : '';

    String imageUrl = json['image'] as String? ?? '';
    // Basic validation for image URL to ensure it's not an empty API path or malformed
    if (imageUrl.isEmpty || imageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(imageUrl)?.isAbsolute != true && !imageUrl.startsWith('assets/'))) {
      imageUrl = 'assets/placeholder.png'; // Use a local placeholder
    }

    return Product(
      id: id, // Use the provided ID
      title: json['pro_name'] as String? ?? 'No Title', // Map 'pro_name' to 'title'
      subtitle: json['technical_name'] as String? ?? 'No Description', // Map 'technical_name' to 'subtitle'
      imageUrl: imageUrl, // Use the validated imageUrl
      category: category, // Use the determined category
      availableSizes: sizes,
      selectedUnit: initialSelectedUnit,
    );
  }

  // Getters
  String get selectedUnit => _selectedUnit;

  // Setter for selected unit (updates the state and notifies listeners)
  set selectedUnit(String newUnit) {
    if (_selectedUnit != newUnit && availableSizes.any((s) => s.size == newUnit)) {
      _selectedUnit = newUnit;
      notifyListeners(); // Notify consumers when selectedUnit changes
    } else if (!availableSizes.any((s) => s.size == newUnit)) {
      debugPrint('Warning: Attempted to set selectedUnit to "$newUnit" which is not available for product "$title".');
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

  // Convert Product to JSON (for debugging or if you need to send product data back)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'category': category,
      'availableSizes': availableSizes.map((s) => s.toJson()).toList(),
      'selectedUnit': selectedUnit,
      'pricePerSelectedUnit': pricePerSelectedUnit, // Add current price for convenience
    };
  }
}
