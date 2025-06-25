import 'package:kisangro/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ProductService {
  // _allProducts stores a comprehensive list of products for search functionality
  static List<Product> _allProducts = [];
  // _allCategories stores the list of categories fetched from the API
  static List<Map<String, String>> _allCategories = [];

  // Dummy map to simulate total product counts per category for pagination.
  // In a real API, this information would ideally come with the paginated response
  // or a separate endpoint for total counts.
  static final Map<String, int> _categoryTotalCounts = {};


  static const String _productApiUrl = 'https://sgserp.in/erp/api/m_api/';
  static const String _cid = '23262954';
  static const String _ln = '123';
  static const String _lt = '123';
  static const String _deviceId = '123';

  // Private helper to fetch and add products from type 1041 response (General Products)
  static Future<void> _fetchAndAddProductsFromType1041() async {
    debugPrint('Attempting to load general product data from API (type=1041): $_productApiUrl');

    try {
      final requestBody = {
        'cid': ProductService._cid,
        'type': '1041',
        'ln': ProductService._ln,
        'lt': ProductService._lt,
        'device_id': ProductService._deviceId,
      };

      final response = await http.post(
        Uri.parse(ProductService._productApiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response Status Code (type=1041): ${response.statusCode}');
      if (response.body.length > 500) {
        debugPrint('Response Body (type=1041, first 500 chars): ${response.body.substring(0, 500)}...');
      } else {
        debugPrint('Response Body (type=1041): ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success' && responseData['data'] is List) {
          final List<dynamic> rawApiProductsData = responseData['data'];

          for (var item in rawApiProductsData) {
            String category = ProductService._determineCategory(item['pro_name'].toString().toLowerCase().trim());
            // Generate unique ID based on a hash of product properties for better uniqueness
            final productHash = jsonEncode(item); // Simple hash for uniqueness
            String id = 'api_product_${productHash.hashCode.toString()}';

            final product = Product.fromJson(item as Map<String, dynamic>, id, category);

            // Add to _allProducts if not already present (using product ID for uniqueness)
            if (!ProductService._allProducts.any((p) => p.id == product.id)) {
              ProductService._allProducts.add(product);
            }
          }
          debugPrint('ProductService: Added/Updated ${ProductService._allProducts.length} unique products from API for general load (type=1041).');
        } else {
          debugPrint('ProductService: API response format invalid or status not success for type 1041.');
        }
      } else {
        debugPrint('ProductService: Failed to load products from API (type=1041). Status code: ${response.statusCode}.');
      }
    } on TimeoutException catch (_) {
      debugPrint('ProductService: Request (type=1041) timed out.');
    } on http.ClientException catch (e) {
      debugPrint('ProductService: Network error for type 1041: $e');
    } catch (e) {
      debugPrint('ProductService: Unexpected error fetching products for type 1041: $e');
    }
  }

  // --- MODIFIED: fetchProductsByCategory for paginated loading ---
  // This method fetches a specific batch of products for a given category.
  static Future<List<Product>> fetchProductsByCategory(String categoryId, {int offset = 0, int limit = 10}) async {
    debugPrint('Attempting to load products for category ID: $categoryId with offset=$offset, limit=$limit via POST (type=1044): $_productApiUrl');

    try {
      final requestBody = {
        'cid': ProductService._cid,
        'type': '1044',
        'ln': ProductService._ln,
        'lt': ProductService._lt,
        'device_id': ProductService._deviceId,
        'cat_id': categoryId,
        'offset': offset.toString(), // Pass offset for pagination
        'limit': limit.toString(),   // Pass limit for pagination
      };

      final response = await http.post(
        Uri.parse(ProductService._productApiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response Status Code (type=1044, cat_id=$categoryId): ${response.statusCode}');
      if (response.body.length > 500) {
        debugPrint('Response Body (type=1044, cat_id=$categoryId, first 500 chars): ${response.body.substring(0, 500)}...');
      } else {
        debugPrint('Response Body (type=1044, cat_id=$categoryId): ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success' && responseData['data'] is List) {
          final List<dynamic> rawApiProductsData = responseData['data'];
          final List<Product> categoryProducts = [];

          for (var item in rawApiProductsData) {
            String category = ProductService._determineCategory(item['pro_name'].toString().toLowerCase().trim());
            // Generate unique ID based on a hash of product properties for better uniqueness
            final productHash = jsonEncode(item); // Simple hash for uniqueness
            String id = 'api_product_${productHash.hashCode.toString()}';

            final product = Product.fromJson(item as Map<String, dynamic>, id, category);
            categoryProducts.add(product);
          }
          debugPrint('ProductService: Successfully parsed ${categoryProducts.length} products for category ID $categoryId (type=1044).');

          // If the API provides a total count for the category, update it here.
          // Example: if (responseData.containsKey('total_count')) { _categoryTotalCounts[categoryId] = responseData['total_count']; }

          return categoryProducts;
        } else {
          debugPrint('ProductService: API response format invalid or status not success for category ID $categoryId (type=1044). Returning empty list.');
          return [];
        }
      } else {
        debugPrint('ProductService: Failed to load products for category ID $categoryId (type=1044). Status code: ${response.statusCode}.');
        return [];
      }
    } on TimeoutException catch (_) {
      debugPrint('ProductService: Request (type=1044, cat_id=$categoryId) timed out.');
      return []; // Return empty list on timeout for category-specific search
    } on http.ClientException catch (e) {
      debugPrint('ProductService: Network error for type 1044, cat_id=$categoryId: $e');
      return [];
    } catch (e) {
      debugPrint('ProductService: Unexpected error fetching products for type 1044, cat_id=$categoryId: $e');
      return [];
    }
  }

  // Fetches and aggregates all products from all categories into _allProducts for global search.
  static Future<void> _fetchAllCategoryProductsForGlobalList() async {
    debugPrint('Attempting to load ALL products from ALL categories (type=1044) for global search list.');
    if (ProductService._allCategories.isEmpty) {
      await ProductService.loadCategoriesFromApi();
    }

    // Using a Set to track product IDs already added to _allProducts to avoid duplicates.
    final Set<String> _productIdsInAllProducts = ProductService._allProducts.map((p) => p.id).toSet();

    for (var categoryMap in ProductService._allCategories) {
      String categoryId = categoryMap['cat_id']!;
      // Fetch products for each category. Using a large limit assuming the API can handle it
      // for populating a global list used by search. This is a compromise.
      // We will add a safety break if total products exceed a reasonable limit to prevent OOM errors.
      final List<Product> products = await ProductService.fetchProductsByCategory(categoryId, offset: 0, limit: 5000); // Fetch a large number, limit to 5000 per category for global list

      for (var product in products) {
        if (!_productIdsInAllProducts.contains(product.id)) {
          ProductService._allProducts.add(product);
          _productIdsInAllProducts.add(product.id);
        }
      }
    }
    debugPrint('ProductService: Finished loading all category products for global list. Total products in _allProducts: ${ProductService._allProducts.length}');
  }


  // Main method to load all products and categories at app startup
  static Future<void> loadProductsFromApi() async {
    ProductService._allProducts.clear(); // Clear existing products before loading new

    await ProductService._fetchAndAddProductsFromType1041();
    await ProductService._fetchAllCategoryProductsForGlobalList(); // This populates _allProducts with category-specific products too.

    if (ProductService._allProducts.isEmpty) {
      debugPrint('ProductService: No products loaded from APIs. Falling back to dummy products.');
      ProductService._loadDummyProductsFallback();
    } else {
      debugPrint('ProductService: Successfully loaded total of ${ProductService._allProducts.length} products from all API sources.');
    }
  }

  // --- MODIFIED: loadCategoriesFromApi to reflect latest dummy data ---
  static Future<void> loadCategoriesFromApi() async {
    debugPrint('Attempting to load CATEGORIES data from API via POST (type=1043): ${ProductService._productApiUrl}');

    try {
      final requestBody = {
        'cid': ProductService._cid,
        'type': '1043',
        'ln': ProductService._ln,
        'lt': ProductService._lt,
        'device_id': ProductService._deviceId,
      };

      final response = await http.post(
        Uri.parse(ProductService._productApiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response from server for loadCategoriesFromApi: ${response.body}');
      debugPrint('Response Status Code (type=1043): ${response.statusCode}');
      if (response.body.length > 500) {
        debugPrint('Response Body (type=1043, first 500 chars): ${response.body.substring(0, 500)}...');
      } else {
        debugPrint('Response Body (type=1043): ${response.body}');
      }


      ProductService._allCategories.clear();

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = json.decode(response.body);

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
            'SPECIALTY PRODUCT': 'assets/grid9.png', // Ensure this is mapped if it comes from API
          };

          for (var item in apiResponse['data'] as List) {
            String categoryName = (item['category'] as String).trim();
            ProductService._allCategories.add({
              'cat_id': item['cat_id'].toString(),
              'icon': categoryIconMap[categoryName] ?? 'assets/placeholder_category.png',
              'label': categoryName,
            });
          }
          debugPrint('ProductService: Successfully parsed ${ProductService._allCategories.length} categories from API (type=1043).');
        } else {
          debugPrint('ProductService: Failed to load categories from API (type=1043): Invalid data format. Falling back to dummy categories.');
          ProductService._loadDummyCategoriesFallback();
        }
      } else {
        debugPrint('ProductService: Failed to load categories from API (type=1043). Status code: ${response.statusCode}. Falling back to dummy categories.');
        ProductService._loadDummyCategoriesFallback();
      }
    } on TimeoutException catch (_) {
      debugPrint('ProductService: Request (type=1043) timed out.');
      ProductService._loadDummyCategoriesFallback();
    } on http.ClientException catch (e) {
      debugPrint('ProductService: Network error for type 1043: $e');
      ProductService._loadDummyCategoriesFallback();
    } catch (e) {
      debugPrint('ProductService: Unexpected error fetching categories for type 1043: $e');
      ProductService._loadDummyCategoriesFallback();
    }
  }

  // Method to search products locally from the already loaded _allProducts list
  static List<Product> searchProductsLocally(String query) {
    if (query.isEmpty) {
      return [];
    }
    final lowerCaseQuery = query.toLowerCase();
    // Search across title, subtitle, and category
    return ProductService._allProducts.where((product) {
      return product.title.toLowerCase().contains(lowerCaseQuery) ||
          product.subtitle.toLowerCase().contains(lowerCaseQuery) ||
          product.category.toLowerCase().contains(lowerCaseQuery) ||
          product.availableSizes.any((size) => size.size.toLowerCase().contains(lowerCaseQuery));
    }).toList();
  }

  // This method is primarily for internal filtering if you still want it to filter from _allProducts.
  // For specific category product fetching, use fetchProductsByCategory directly.
  static List<Product> getProductsByCategoryName(String category) {
    return ProductService._allProducts.where((product) => product.category == category).toList();
  }

  static Product? getProductById(String id) {
    try {
      return ProductService._allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      debugPrint('ProductService: Product with ID $id not found.');
      return null;
    }
  }

  // --- Verified static method ---
  static List<Map<String, String>> getAllCategories() {
    return List.from(ProductService._allCategories);
  }

  static List<Product> getAllProducts() {
    return List.from(ProductService._allProducts); // Return a copy to prevent external modification
  }

  static String _determineCategory(String proNameLower) {
    if (proNameLower.contains('insecticide') || proNameLower.contains('buggone') || proNameLower.contains('pestguard')) {
      return 'INSECTICIDE';
    } else if (proNameLower.contains('fungicide') || proNameLower.contains('aurastar') || proNameLower.contains('azeem') || proNameLower.contains('valax') || proNameLower.contains('stabinil') || proNameLower.contains('orbiter') || proNameLower.contains('aurastin') || proNameLower.contains('benura') || proNameLower.contains('hello') || proNameLower.contains('capzola') || proNameLower.contains('runner') || proNameLower.contains('panonil') || proNameLower.contains('kurazet') || proNameLower.contains('aurobat') || proNameLower.contains('scara') || proNameLower.contains('hexaura') || proNameLower.contains('auralaxil') || proNameLower.contains('rio gold') || proNameLower.contains('aura m 45') || proNameLower.contains('intac') || proNameLower.contains('whita') || proNameLower.contains('proconzo') || proNameLower.contains('aura sulfa') || proNameLower.contains('cembra') || proNameLower.contains('tridot') || proNameLower.contains('alastor') || proNameLower.contains('tebuconz') || proNameLower.contains('valimin')) {
      return 'FUNGICIDE';
    } else if (proNameLower.contains('herbicide') || proNameLower.contains('weed killer')) {
      return 'HERBICIDE';
    } else if (proNameLower.contains('plant growth regulator') || proNameLower.contains('new super growth') || proNameLower.contains('growth') || proNameLower.contains('promoter') || proNameLower.contains('flourish')) {
      return 'PLANT GROWTH REGULATOR';
    } else if (proNameLower.contains('organic biostimulant') || proNameLower.contains('bio-growth')) {
      return 'ORGANIC BIOSTIMULANT';
    } else if (proNameLower.contains('liquid fertilizer') || proNameLower.contains('ferra')) {
      return 'LIQUID FERTILIZER';
    } else if (proNameLower.contains('micronutrient') || proNameLower.contains('zinc') || proNameLower.contains('bora')) {
      return 'MICRONUTRIENTS';
    } else if (proNameLower.contains('bio fertiliser') || proNameLower.contains('aura vam') || proNameLower.contains('soil rich')) {
      return 'BIO FERTILISER';
    } else {
      return 'Uncategorized';
    }
  }

  static void _loadDummyProductsFallback() {
    debugPrint('ProductService: Loading static dummy product data for fallback.');
    ProductService._allProducts.clear();
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
      String category = ProductService._determineCategory(item['pro_name'].toString().toLowerCase().trim());
      String id = 'dummy_product_${item['pro_name'].toString().replaceAll(' ', '_')}_${DateTime.now().microsecondsSinceEpoch}';
      final product = Product.fromJson(item as Map<String, dynamic>, id, category);
      final key = '${product.title}_${product.subtitle}';
      if (!seenProductKeys.contains(key)) {
        seenProductKeys.add(key);
        productsToProcess.add(product);
      }
    }
    ProductService._allProducts = productsToProcess;
    debugPrint('ProductService: Successfully loaded ${ProductService._allProducts.length} unique dummy products.');
  }

  static void _loadDummyCategoriesFallback() {
    debugPrint('ProductService: Loading static dummy category data for fallback.');
    ProductService._allCategories.clear();
    ProductService._allCategories = [
      {'cat_id': '14', 'icon': 'assets/grid1.png', 'label': 'INSECTICIDE'},
      {'cat_id': '15', 'icon': 'assets/grid2.png', 'label': 'FUNGICIDE'},
      {'cat_id': '16', 'icon': 'assets/grid3.png', 'label': 'HERBICIDE'},
      {'cat_id': '17', 'icon': 'assets/grid4.png', 'label': 'PLANT GROWTH REGULATOR'},
      {'cat_id': '18', 'icon': 'assets/grid5.png', 'label': 'ORGANIC BIOSTIMULANT'},
      {'cat_id': '19', 'icon': 'assets/grid6.png', 'label': 'LIQUID FERTILIZER'},
      {'cat_id': '20', 'icon': 'assets/grid7.png', 'label': 'MICRONUTRIENTS'},
      {'cat_id': '22', 'icon': 'assets/grid8.png', 'label': 'BIO FERTILISER'},
      {'cat_id': '99', 'icon': 'assets/grid9.png', 'label': 'SPECIALTY PRODUCT'},
    ];
    debugPrint('ProductService: Successfully loaded ${ProductService._allCategories.length} dummy categories.');
  }

  static String? getCategoryIdByName(String categoryName) {
    try {
      final category = ProductService._allCategories.firstWhere(
            (cat) => cat['label'] == categoryName,
      );
      return category['cat_id'];
    } catch (e) {
      debugPrint('ProductService: Category ID not found for name: $categoryName. Error: $e');
      return null;
    }
  }
}
