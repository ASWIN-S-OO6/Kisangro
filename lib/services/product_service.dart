import 'package:kisangro/models/product_model.dart'; // Import Product and ProductSize
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For json.decode
import 'dart:async'; // REQUIRED for TimeoutException

// This service handles fetching and managing product and category data.
// In a real application, this would interact with a backend API.
class ProductService {
  static List<Product> _allProducts = []; // Stores the general product catalog
  static List<Map<String, String>> _allCategories = [];

  // API endpoint for products
  static const String _productApiUrl = 'https://sgserp.in/erp/api/m_api/';

  // Static parameters for the POST request body as per your demo code
  static const String _cid = '23262954';
  static const String _type = '1041'; // The specific type for the main product fetch
  static const String _ln = '123';
  static const String _lt = '123';
  static const String _deviceId = '12';

  // --- MODIFIED METHOD (for general product loading at app startup using POST) ---
  // Fetches product data from the API using a POST request with specific parameters.
  // This method populates the static _allProducts list which is then used throughout the app.
  static Future<void> loadProductsFromApi() async {
    debugPrint('Attempting to load ALL product data from API via POST: $_productApiUrl');

    try {
      final requestBody = {
        'cid': _cid,
        'type': _type, // Using the static '1041' type for the main load
        'ln': _ln,
        'lt': _lt,
        'device_id': _deviceId,
      };

      final response = await http.post(
        Uri.parse(_productApiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody, // Sending parameters as form-urlencoded body
      ).timeout(const Duration(seconds: 30)); // Added timeout for robustness

      debugPrint('Response Status Code: ${response.statusCode}');
      // Print limited response body for debugging to avoid console clutter
      debugPrint('Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success' && responseData['data'] is List) {
          final List<dynamic> rawApiProductsData = responseData['data'];
          _allProducts.clear(); // Clear existing products before loading new ones

          // Set to track unique products by pro_name and technical_name, as per your demo
          final seenProductKeys = <String>{};
          final List<Product> productsToProcess = [];

          for (var item in rawApiProductsData) {
            String category;
            final String proNameLower = item['pro_name'].toString().toLowerCase().trim();

            // Your existing logic to determine category
            if (proNameLower.contains('insecticide') || proNameLower.contains('buggone') || proNameLower.contains('pestguard')) {
              category = 'INSECTICIDE';
            } else if (proNameLower.contains('fungicide') || proNameLower.contains('aurastar') || proNameLower.contains('azeem') || proNameLower.contains('valax')) {
              category = 'FUNGICIDE';
            } else if (proNameLower.contains('herbicide') || proNameLower.contains('weed killer')) {
              category = 'HERBICIDE';
            } else if (proNameLower.contains('plant growth regulator') || proNameLower.contains('new super growth') || proNameLower.contains('growth') || proNameLower.contains('promoter') || proNameLower.contains('flourish')) {
              category = 'PLANT GROWTH REGULATOR';
            } else if (proNameLower.contains('organic biostimulant') || proNameLower.contains('bio-growth')) {
              category = 'ORGANIC BIOSTIMULANT';
            } else if (proNameLower.contains('liquid fertilizer') || proNameLower.contains('ferra')) {
              category = 'LIQUID FERTILIZER';
            } else if (proNameLower.contains('micronutrient') || proNameLower.contains('zinc') || proNameLower.contains('bora')) {
              category = 'MICRONUTRIENTS';
            } else if (proNameLower.contains('bio fertiliser') || proNameLower.contains('aura vam') || proNameLower.contains('soil rich')) {
              category = 'BIO FERTILISER';
            } else {
              category = 'Uncategorized';
            }

            // Generate a unique ID (Product model expects an ID)
            String id = 'api_product_${proNameLower.replaceAll(' ', '_').replaceAll('%', '').replaceAll('.', '').replaceAll('-', '_')}_${DateTime.now().microsecondsSinceEpoch}';

            // Handle image URL fallback logic
            String imageUrl = item['image'] as String? ?? '';
            if (imageUrl.isEmpty || imageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(imageUrl)?.isAbsolute != true && !imageUrl.startsWith('assets/'))) {
              imageUrl = 'assets/placeholder.png';
            }

            // Create a Product instance using your app's Product model's fromJson.
            final product = Product.fromJson(item as Map<String, dynamic>, id, category);

            // Apply uniqueness filter from your demo code
            final key = '${product.title}_${product.subtitle}'; // Use app's model properties for uniqueness
            if (!seenProductKeys.contains(key)) {
              seenProductKeys.add(key);
              productsToProcess.add(product);
            }
          }
          _allProducts = productsToProcess; // Update the static list

          debugPrint('ProductService: Successfully parsed ${_allProducts.length} unique products from API for general load (POST).');
        } else {
          debugPrint('ProductService: API response format invalid or status not success for general load (POST). Falling back to dummy products.');
          _loadDummyProductsFallback();
        }
      } else {
        debugPrint('ProductService: Failed to load products from API (POST). Status code: ${response.statusCode}. Falling back to dummy products.');
        _loadDummyProductsFallback();
      }
    } on TimeoutException catch (_) { // Correct use of TimeoutException
      debugPrint('ProductService: Request timed out for type $_type.');
      throw Exception('Request timed out. Check your internet connection.');
    } on http.ClientException catch (e) {
      debugPrint('ProductService: Network error for type $_type: $e');
      throw Exception('Network error. Check your internet connection.');
    } catch (e) {
      debugPrint('ProductService: Unexpected error fetching products for type $_type: $e');
      throw Exception('Unexpected error fetching products.');
    }
  }

  // Fallback method (reverted to void return type and processes with uniqueness)
  static void _loadDummyProductsFallback() {
    debugPrint('ProductService: Loading static dummy product data for fallback.');
    _allProducts.clear();
    final List<Map<String, dynamic>> dummyProductsData = [
      {
        "image": "assets/Valaxa.png",
        "pro_name": "AURA VAM (Dummy)",
        "technical_name": "Vermiculate Based Granular (Dummy)",
        "sizes": [
          {"size": "500 GRM", "mrp": 500.0},
          {"size": "1 KG", "mrp": 900.0},
          {"size": "5 KG", "mrp": 4000.0}
        ]
      },
      {
        "image": "assets/hyfen.png",
        "pro_name": "RAPI FERRA (Dummy)",
        "technical_name": "EDTA Chelated Ferrous 12 % (Dummy)",
        "sizes": [
          {"size": "500 GRM", "mrp": 600.0},
          {"size": "1 KG", "mrp": 1100.0},
          {"size": "5 KG", "mrp": 5000.0}
        ]
      },
      {
        "image": "assets/Oxyfen.png",
        "pro_name": "BUGGONE (Dummy)",
        "technical_name": "Powerful Insecticide (Dummy)",
        "sizes": [
          {"size": "100 ML", "mrp": 900.0},
          {"size": "250 ML", "mrp": 1500.0}
        ]
      },
      {
        "image": "assets/Valaxa.png",
        "pro_name": "AURASTAR Fungicide (Dummy)",
        "technical_name": "Systemic fungicide (Dummy)",
        "sizes": [
          {"size": "250 ML", "mrp": 950.0},
          {"size": "500 ML", "mrp": 1550.0},
        ]
      },
      {
        "image": "assets/hyfen.png",
        "pro_name": "FLOURISH Promoter (Dummy)",
        "technical_name": "Promotes flowering (Dummy)",
        "sizes": [
          {"size": "500 ML", "mrp": 1100.0},
          {"size": "1 L", "mrp": 2000.0},
        ]
      },
    ];

    final seenProductKeys = <String>{};
    final List<Product> productsToProcess = [];

    for (var item in dummyProductsData) {
      String category;
      final String proNameLower = item['pro_name'].toString().toLowerCase().trim();

      if (proNameLower.contains('insecticide') || proNameLower.contains('buggone')) {
        category = 'INSECTICIDE';
      } else if (proNameLower.contains('fungicide') || proNameLower.contains('aurastar')) {
        category = 'FUNGICIDE';
      } else if (proNameLower.contains('ferra')) {
        category = 'LIQUID FERTILIZER';
      } else if (proNameLower.contains('vam')) {
        category = 'BIO FERTILISER';
      } else if (proNameLower.contains('promoter') || proNameLower.contains('flourish')) {
        category = 'PLANT GROWTH REGULATOR';
      }
      else {
        category = 'Uncategorized';
      }
      String id = 'dummy_product_${proNameLower.replaceAll(' ', '_')}_${DateTime.now().microsecondsSinceEpoch}';
      final product = Product.fromJson(item as Map<String, dynamic>, id, category);
      final key = '${product.title}_${product.subtitle}';
      if (!seenProductKeys.contains(key)) {
        seenProductKeys.add(key);
        productsToProcess.add(product);
      }
    }
    _allProducts = productsToProcess;
    debugPrint('ProductService: Successfully loaded ${_allProducts.length} unique dummy products.');
  }

  // Method to (simulate) fetch categories from your API.
  static Future<void> loadCategoriesFromApi() async {
    debugPrint('Loading categories data...');
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay

    final Map<String, dynamic> apiResponse = {
      "status": "success",
      "data": [
        {"category": "INSECTICIDE"},
        {"category": "FUNGICIDE"},
        {"category": "HERBICIDE"},
        {"category": "PLANT GROWTH REGULATOR"},
        {"category": "ORGANIC BIOSTIMULANT"},
        {"category": "LIQUID FERTILIZER"},
        {"category": "MICRONUTRIENTS "}, // Note the trailing space
        {"category": "BIO FERTILISER"}
      ]
    };

    _allCategories.clear(); // Clear existing categories

    if (apiResponse['status'] == 'success' && apiResponse['data'] is List) {
      Map<String, String> categoryIconMap = {
        'INSECTICIDE': 'assets/grid1.png',
        'FUNGICIDE': 'assets/grid2.png',
        'HERBICIDE': 'assets/grid3.png',
        'PLANT GROWTH REGULATOR': 'assets/grid4.png',
        'ORGANIC BIOSTIMULANT': 'assets/grid5.png',
        'LIQUID FERTILIZER': 'assets/grid6.png',
        'MICRONUTRIENTS': 'assets/grid7.png',
        'BIO FERTILISER': 'assets/grid8.png',
      };

      for (var item in apiResponse['data'] as List) {
        String categoryName = (item['category'] as String).trim();
        _allCategories.add({
          'icon': categoryIconMap[categoryName] ?? 'assets/placeholder_category.png',
          'label': categoryName,
        });
      }
      debugPrint('ProductService: Successfully parsed ${_allCategories.length} categories.');
    } else {
      debugPrint('ProductService: Failed to load categories from API: Invalid data format.');
      throw Exception('Failed to load categories from API: Invalid data format.');
    }
  }

  // --- Methods to retrieve data from the loaded lists ---

  static List<Product> getAllProducts() {
    return List.from(_allProducts); // Return a copy to prevent external modification
  }

  static List<Product> getProductsByCategory(String category) {
    return _allProducts.where((product) => product.category == category).toList();
  }

  static Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      debugPrint('ProductService: Product with ID $id not found.');
      return null;
    }
  }

  static List<Map<String, String>> getAllCategories() {
    return List.from(_allCategories); // Return a copy
  }
}
