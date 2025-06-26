import 'package:kisangro/models/product_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ProductService {
  static List<Product> _allProducts = [];
  static List<Map<String, String>> _allCategories = [];

  static const String _productApiUrl = 'https://sgserp.in/erp/api/m_api/';
  static const String _cid = '23262954';
  static const String _ln = '123';
  static const String _lt = '123';
  static const String _deviceId = '123';

  static Future<void> loadProductsFromApi() async {
    debugPrint('Attempting to load ALL product data from API (type=1041 and type=1044 for all categories): $_productApiUrl');

    try {
      // Step 1: Ensure categories are loaded
      await loadCategoriesFromApi();
      if (_allCategories.isEmpty) {
        debugPrint('ProductService: No categories available. Falling back to dummy products.');
        _loadDummyProductsFallback();
        return;
      }

      // Step 2: Clear existing products
      _allProducts.clear();
      final seenProductKeys = <String>{}; // Track unique products by title and subtitle
      final List<Product> productsToProcess = [];

      // Step 3: Fetch general products (type=1041)
      final requestBody1041 = {
        'cid': _cid,
        'type': '1041',
        'ln': _ln,
        'lt': _lt,
        'device_id': _deviceId,
      };

      final response1041 = await http.post(
        Uri.parse(_productApiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody1041,
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response Status Code (type=1041): ${response1041.statusCode}');
      debugPrint('Response Body (type=1041, first 500 chars): ${response1041.body.substring(0, response1041.body.length > 500 ? 500 : response1041.body.length)}...');

      if (response1041.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response1041.body);
        if (responseData['status'] == 'success' && responseData['data'] is List) {
          final List<dynamic> rawApiProductsData = responseData['data'];
          for (var item in rawApiProductsData) {
            String category = _determineCategory(item['pro_name'].toString().toLowerCase().trim());
            String id = 'api_product_1041_${item['pro_name'].toString().replaceAll(' ', '_').replaceAll('%', '').replaceAll('.', '').replaceAll('-', '_')}_${DateTime.now().microsecondsSinceEpoch}';
            String imageUrl = item['image'] as String? ?? '';
            if (imageUrl.isEmpty || imageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(imageUrl)?.isAbsolute != true && !imageUrl.startsWith('assets/'))) {
              imageUrl = 'assets/placeholder.png';
            }

            final product = Product.fromJson(item as Map<String, dynamic>, id, category);
            final key = '${product.title}_${product.subtitle}';
            if (!seenProductKeys.contains(key)) {
              seenProductKeys.add(key);
              productsToProcess.add(product);
            }
          }
        } else {
          debugPrint('ProductService: API response format invalid or status not success for type=1041.');
        }
      } else {
        debugPrint('ProductService: Failed to load products for type=1041. Status code: ${response1041.statusCode}.');
      }

      // Step 4: Fetch products for all categories (type=1044)
      await _fetchAllCategoryProductsForGlobalList(productsToProcess, seenProductKeys);

      // Step 5: Update _allProducts
      _allProducts = productsToProcess;
      debugPrint('ProductService: Successfully loaded ${_allProducts.length} unique products from all categories.');

      if (_allProducts.isEmpty) {
        debugPrint('ProductService: No products loaded from API. Falling back to dummy products.');
        _loadDummyProductsFallback();
      }
    } on TimeoutException catch (_) {
      debugPrint('ProductService: Request timed out while loading products.');
      _loadDummyProductsFallback();
      throw Exception('Request timed out. Check your internet connection.');
    } on http.ClientException catch (e) {
      debugPrint('ProductService: Network error: $e');
      _loadDummyProductsFallback();
      throw Exception('Network error. Check your internet connection.');
    } catch (e) {
      debugPrint('ProductService: Unexpected error fetching products: $e');
      _loadDummyProductsFallback();
      throw Exception('Unexpected error fetching products.');
    }
  }

  // New helper method to fetch products for all categories
  static Future<void> _fetchAllCategoryProductsForGlobalList(List<Product> productsToProcess, Set<String> seenProductKeys) async {
    debugPrint('Attempting to load ALL products from ALL categories (type=1044) for global search list.');
    const int maxTotalProducts = 10000; // Safety limit to prevent OOM

    for (var categoryMap in _allCategories) {
      if (productsToProcess.length >= maxTotalProducts) {
        debugPrint('ProductService: Reached maximum product limit ($maxTotalProducts). Stopping further fetches.');
        break;
      }

      String categoryId = categoryMap['cat_id']!;
      debugPrint('Fetching products for category ID: $categoryId (type=1044)');
      final List<Product> categoryProducts = await fetchProductsByCategory(categoryId);

      for (var product in categoryProducts) {
        final key = '${product.title}_${product.subtitle}';
        if (!seenProductKeys.contains(key)) {
          seenProductKeys.add(key);
          productsToProcess.add(product);
        }
      }
    }
    debugPrint('ProductService: Finished loading all category products for global list. Total products: ${productsToProcess.length}');
  }

  static List<Product> searchProductsLocally(String query) {
    if (query.isEmpty) {
      return [];
    }

    final queryLower = query.toLowerCase().trim();
    return _allProducts.where((product) {
      final titleLower = product.title.toLowerCase();
      final subtitleLower = product.subtitle.toLowerCase();
      final categoryLower = product.category.toLowerCase();

      return titleLower.contains(queryLower) ||
          subtitleLower.contains(queryLower) ||
          categoryLower.contains(queryLower);
    }).toList();
  }

  static Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    debugPrint('Attempting to load products for category ID: $categoryId via POST (type=1044): $_productApiUrl');

    try {
      final requestBody = {
        'cid': _cid,
        'type': '1044',
        'ln': _ln,
        'lt': _lt,
        'device_id': _deviceId,
        'cat_id': categoryId,
      };

      final response = await http.post(
        Uri.parse(_productApiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response Status Code (type=1044, cat_id=$categoryId): ${response.statusCode}');
      debugPrint('Response Body (type=1044, cat_id=$categoryId, first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success' && responseData['data'] is List) {
          final List<dynamic> rawApiProductsData = responseData['data'];
          final List<Product> categoryProducts = [];
          final seenProductKeys = <String>{};

          for (var item in rawApiProductsData) {
            String category = _determineCategory(item['pro_name'].toString().toLowerCase().trim());
            String id = 'api_product_1044_${categoryId}_${item['pro_name'].toString().replaceAll(' ', '_').replaceAll('%', '').replaceAll('.', '').replaceAll('-', '_')}_${DateTime.now().microsecondsSinceEpoch}';

            String imageUrl = item['image'] as String? ?? '';
            if (imageUrl.isEmpty || imageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(imageUrl)?.isAbsolute != true && !imageUrl.startsWith('assets/'))) {
              imageUrl = 'assets/placeholder.png';
            }

            List<ProductSize> availableSizes = [];
            if (item.containsKey('sizes') && item['sizes'] is List && (item['sizes'] as List).isNotEmpty) {
              availableSizes = (item['sizes'] as List)
                  .map((sizeJson) => ProductSize.fromJson(sizeJson as Map<String, dynamic>))
                  .toList();
            } else {
              debugPrint('Warning: No "sizes" or "mrp" found for product "${item['pro_name']}" (cat_id: $categoryId). Using default "Unit" with price 0.0.');
              availableSizes.add(ProductSize(size: 'Unit', price: 0.0));
            }

            final product = Product(
              id: id,
              title: item['pro_name'] as String? ?? 'No Title',
              subtitle: item['technical_name'] as String? ?? 'No Description',
              imageUrl: imageUrl,
              category: category,
              availableSizes: availableSizes,
              selectedUnit: availableSizes.isNotEmpty ? availableSizes.first.size : 'Unit',
            );

            final key = '${product.title}_${product.subtitle}';
            if (!seenProductKeys.contains(key)) {
              seenProductKeys.add(key);
              categoryProducts.add(product);
            }
          }
          debugPrint('ProductService: Successfully parsed ${categoryProducts.length} unique products for category ID $categoryId (type=1044).');
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
      throw Exception('Request timed out. Check your internet connection.');
    } on http.ClientException catch (e) {
      debugPrint('ProductService: Network error for type 1044, cat_id=$categoryId: $e');
      throw Exception('Network error. Check your internet connection.');
    } catch (e) {
      debugPrint('ProductService: Unexpected error fetching products for type 1044, cat_id=$categoryId: $e');
      throw Exception('Unexpected error fetching products.');
    }
  }

  static Future<void> loadCategoriesFromApi() async {
    debugPrint('Attempting to load CATEGORIES data from API via POST (type=1043): $_productApiUrl');

    try {
      final requestBody = {
        'cid': _cid,
        'type': '1043',
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
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      debugPrint('Response from server for loadCategoriesFromApi: ${response.body}');
      debugPrint('Response Status Code (type=1043): ${response.statusCode}');
      debugPrint('Response Body (type=1043, first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      _allCategories.clear();

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
          };

          for (var item in apiResponse['data'] as List) {
            String categoryName = (item['category'] as String).trim();
            _allCategories.add({
              'cat_id': item['cat_id'].toString(),
              'icon': categoryIconMap[categoryName] ?? 'assets/placeholder_category.png',
              'label': categoryName,
            });
          }
          debugPrint('ProductService: Successfully parsed ${_allCategories.length} categories from API (type=1043).');
        } else {
          debugPrint('ProductService: Failed to load categories from API (type=1043): Invalid data format. Falling back to dummy categories.');
          _loadDummyCategoriesFallback();
        }
      } else {
        debugPrint('ProductService: Failed to load categories from API (type=1043). Status code: ${response.statusCode}. Falling back to dummy categories.');
        _loadDummyCategoriesFallback();
      }
    } on TimeoutException catch (_) {
      debugPrint('ProductService: Request (type=1043) timed out.');
      throw Exception('Request timed out. Check your internet connection.');
    } on http.ClientException catch (e) {
      debugPrint('ProductService: Network error for type 1043: $e');
      throw Exception('Network error. Check your internet connection.');
    } catch (e) {
      debugPrint('ProductService: Unexpected error fetching categories for type 1043: $e');
      throw Exception('Unexpected error fetching categories.');
    }
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
      String category = _determineCategory(item['pro_name'].toString().toLowerCase().trim());
      String id = 'dummy_product_${item['pro_name'].toString().replaceAll(' ', '_')}_${DateTime.now().microsecondsSinceEpoch}';
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

  static void _loadDummyCategoriesFallback() {
    debugPrint('ProductService: Loading static dummy category data for fallback.');
    _allCategories.clear();
    _allCategories = [
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
    debugPrint('ProductService: Successfully loaded ${_allCategories.length} dummy categories.');
  }

  static List<Product> getAllProducts() {
    return List.from(_allProducts);
  }

  static List<Product> getProductsByCategoryName(String category) {
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
    return List.from(_allCategories);
  }

  static String? getCategoryIdByName(String categoryName) {
    try {
      final category = _allCategories.firstWhere(
            (cat) => cat['label'] == categoryName,
      );
      return category['cat_id'];
    } catch (e) {
      debugPrint('ProductService: Category ID not found for name: $categoryName. Error: $e');
      return null;
    }
  }
}