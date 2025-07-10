import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/services/product_service.dart'; // Import ProductService
import 'package:kisangro/models/product_model.dart'; // Import Product model
import 'package:kisangro/home/product.dart'; // Import ProductDetailPage
import 'package:provider/provider.dart'; // Import Provider for CartModel and WishlistModel
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'dart:async'; // For Timer for debouncing


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Product> _recentSearches = [];
  List<Product> _trendingSearches = [];
  List<Product> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounce;

  // Filter and Sort States
  String? _selectedCategory;
  String? _selectedSortBy; // 'weight_asc', 'weight_desc', 'price_asc', 'price_desc'
  List<Map<String, String>> _categories = []; // To hold fetched categories

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadInitialData(); // Load products and categories
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _loadInitialData() async {
    await ProductService.loadCategoriesFromApi(); // Ensure categories are loaded
    if (mounted) {
      setState(() {
        _categories = ProductService.getAllCategories();
        final allProducts = ProductService.getAllProducts();
        if (allProducts.isNotEmpty) {
          _recentSearches = allProducts.reversed.take(5).toList();
          _trendingSearches = allProducts.take(5).toList();
        }
      });
    }
  }

  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png';
    }
    return rawImageUrl;
  }

  void _performSearch(String query) {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    if (query.isEmpty && _selectedCategory == null) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    try {
      List<Product> results = ProductService.searchProductsLocally(query);

      // Apply category filter
      if (_selectedCategory != null && _selectedCategory != 'All') {
        results = results.where((product) => product.category == _selectedCategory).toList();
      }

      // Apply sorting
      if (_selectedSortBy != null) {
        switch (_selectedSortBy) {
          case 'weight_asc':
            results.sort((a, b) {
              // Assuming 'kg' is a common unit for weight and its price represents weight value
              final double weightA = a.availableSizes.firstWhere((s) => s.size.toLowerCase().contains('kg'), orElse: () => ProductSize(size: 'kg', price: 0.0)).price;
              final double weightB = b.availableSizes.firstWhere((s) => s.size.toLowerCase().contains('kg'), orElse: () => ProductSize(size: 'kg', price: 0.0)).price;
              return weightA.compareTo(weightB);
            });
            break;
          case 'weight_desc':
            results.sort((a, b) {
              final double weightA = a.availableSizes.firstWhere((s) => s.size.toLowerCase().contains('kg'), orElse: () => ProductSize(size: 'kg', price: 0.0)).price;
              final double weightB = b.availableSizes.firstWhere((s) => s.size.toLowerCase().contains('kg'), orElse: () => ProductSize(size: 'kg', price: 0.0)).price;
              return weightB.compareTo(weightA);
            });
            break;
          case 'price_asc':
            results.sort((a, b) => (a.pricePerSelectedUnit ?? 0.0).compareTo(b.pricePerSelectedUnit ?? 0.0));
            break;
          case 'price_desc':
            results.sort((a, b) => (b.pricePerSelectedUnit ?? 0.0).compareTo(a.pricePerSelectedUnit ?? 0.0));
            break;
        }
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Error searching products: ${e.toString()}';
        _searchResults = [];
        _isSearching = false;
      });
      debugPrint('Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;
    final double horizontalPadding = isTablet ? 24.0 : 12.0;
    final double verticalSpacing = isTablet ? 20.0 : 10.0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding), // Responsive padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: isTablet ? 12 : 8), // Responsive spacing
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 15, vertical: isTablet ? 12 : 8), // Responsive padding
                        hintText: 'Search by item/crop/chemical name',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: isTablet ? 16 : 14), // Responsive font size
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey, size: isTablet ? 24 : 20), // Responsive icon size
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                            : Icon(Icons.search, color: Colors.orange, size: isTablet ? 24 : 20), // Responsive icon size
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xffEB7720), width: 2),
                        ),
                      ),
                      style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14), // Responsive font size
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) {
                        _performSearch(query);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing), // Responsive spacing

              // Category Filter and Sort By
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: isTablet ? 50 : 40, // Responsive height
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8), // Responsive padding
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          hint: Text('Category', style: GoogleFonts.poppins(color: Colors.grey, fontSize: isTablet ? 16 : 14)), // Responsive font size
                          icon: Icon(Icons.arrow_drop_down, color: Color(0xffEB7720), size: isTablet ? 24 : 20), // Responsive icon size
                          isExpanded: true,
                          style: GoogleFonts.poppins(color: Colors.black, fontSize: isTablet ? 16 : 14), // Responsive font size
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                              _performSearch(_searchController.text);
                            });
                          },
                          items: [
                            const DropdownMenuItem(value: 'All', child: Text('All Categories')),
                            ..._categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category['label'],
                                child: Text(category['label']!),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 15 : 10), // Responsive spacing
                  Expanded(
                    child: Container(
                      height: isTablet ? 50 : 40, // Responsive height
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 8), // Responsive padding
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSortBy,
                          hint: Text('Sort By', style: GoogleFonts.poppins(color: Colors.grey, fontSize: isTablet ? 16 : 14)), // Responsive font size
                          icon: Icon(Icons.sort, color: Color(0xffEB7720), size: isTablet ? 24 : 20), // Responsive icon size
                          isExpanded: true,
                          style: GoogleFonts.poppins(color: Colors.black, fontSize: isTablet ? 16 : 14), // Responsive font size
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSortBy = newValue;
                              _performSearch(_searchController.text);
                            });
                          },
                          items: const [
                            DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                            DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                            DropdownMenuItem(value: 'weight_asc', child: Text('Weight: Low to High')),
                            DropdownMenuItem(value: 'weight_desc', child: Text('Weight: High to Low')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing), // Responsive spacing

              // Search Results Display or Default Content
              if (_isSearching)
                const Center(child: CircularProgressIndicator(color: Color(0xffEB7720)))
              else if (_searchError != null)
                Center(
                  child: Text(
                    _searchError!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                )
              else if (_searchController.text.isNotEmpty && _searchResults.isEmpty && (_selectedCategory != null || _selectedSortBy != null))
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No products found matching your criteria.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: isTablet ? 18 : 16, color: Colors.grey), // Responsive font size
                      ),
                    ),
                  )
                else if (_searchResults.isNotEmpty)
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 3 : 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.55,
                        ),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final product = _searchResults[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: product),
                                ),
                              );
                            },
                            child: _buildProductTile(context, product, isTablet), // Pass isTablet
                          );
                        },
                      ),
                    )
                  else
                  // Default content when no search is active or query is empty
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Recent Searches", style: GoogleFonts.poppins(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold)), // Responsive font size
                            SizedBox(height: verticalSpacing), // Responsive spacing
                            Wrap(
                              spacing: isTablet ? 15 : 10, // Responsive spacing
                              runSpacing: isTablet ? 15 : 10, // Responsive spacing
                              children: _recentSearches.map((product) => _buildProductTag(product, isTablet)).toList(), // Pass isTablet
                            ),
                            SizedBox(height: verticalSpacing * 2), // Responsive spacing
                            const Divider(),
                            SizedBox(height: verticalSpacing), // Responsive spacing
                            Text("Trending Searches", style: GoogleFonts.poppins(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold)), // Responsive font size
                            SizedBox(height: verticalSpacing), // Responsive spacing
                            Wrap(
                              spacing: isTablet ? 15 : 10, // Responsive spacing
                              runSpacing: isTablet ? 15 : 10, // Responsive spacing
                              children: _trendingSearches.map((product) => _buildProductTag(product, isTablet)).toList(), // Pass isTablet
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // MODIFIED: _buildProductTag to be responsive
  Widget _buildProductTag(Product product, bool isTablet) {
    return GestureDetector(
      onTap: () {
        _searchController.text = product.title;
        _performSearch(product.title);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 12, vertical: isTablet ? 8 : 6), // Responsive padding
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffEB7720)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: isTablet ? 30 : 24, // Responsive size
              height: isTablet ? 30 : 24, // Responsive size
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _getEffectiveImageUrl(product.imageUrl).startsWith('http')
                    ? Image.network(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/placeholder.png',
                    fit: BoxFit.contain,
                  ),
                )
                    : Image.asset(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: isTablet ? 10 : 8), // Responsive spacing
            Text(product.title, style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14)), // Responsive font size
            SizedBox(width: isTablet ? 8 : 5), // Responsive spacing
            Icon(Icons.trending_up, size: isTablet ? 18 : 14, color: Color(0xffEB7720)), // Responsive icon size
          ],
        ),
      ),
    );
  }

  // MODIFIED: _buildProductTile to be responsive
  Widget _buildProductTile(BuildContext context, Product product, bool isTablet) {
    final List<ProductSize> availableSizes = product.availableSizes.isNotEmpty
        ? product.availableSizes
        : [ProductSize(size: 'Unit', price: product.pricePerSelectedUnit ?? 0.0)];

    final String selectedUnit = availableSizes.any((size) => size.size == product.selectedUnit)
        ? product.selectedUnit
        : (availableSizes.isNotEmpty ? availableSizes.first.size : 'Unit');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: isTablet ? 120 : 100, // Responsive height for image area
            width: double.infinity,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 12 : 8), // Responsive padding
                child: _getEffectiveImageUrl(product.imageUrl).startsWith('http')
                    ? Image.network(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/placeholder.png',
                    fit: BoxFit.contain,
                  ),
                )
                    : Image.asset(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isTablet ? 10 : 8), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: isTablet ? 16 : 14), // Responsive font size
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.subtitle,
                  style: GoogleFonts.poppins(fontSize: isTablet ? 14 : 12), // Responsive font size
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₹ ${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.green, fontWeight: FontWeight.w600), // Responsive font size
                ),
                Text('Unit: $selectedUnit',
                    style: GoogleFonts.poppins(fontSize: isTablet ? 12 : 10, color: const Color(0xffEB7720))), // Responsive font size
                SizedBox(height: isTablet ? 10 : 8), // Responsive spacing
                Container(
                  height: isTablet ? 45 : 36, // Responsive height
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 8), // Responsive padding
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffEB7720)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedUnit,
                      icon: Icon(Icons.keyboard_arrow_down, color: Color(0xffEB7720), size: isTablet ? 24 : 20), // Responsive icon size
                      underline: const SizedBox(),
                      isExpanded: true,
                      style: GoogleFonts.poppins(fontSize: isTablet ? 14 : 12, color: Colors.black), // Responsive font size
                      items: availableSizes.map((sizeOption) => DropdownMenuItem<String>(
                        value: sizeOption.size,
                        child: Text(sizeOption.size),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          product.selectedUnit = val!;
                          debugPrint('Selected unit for ${product.title}: $val, Price: ₹${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}');
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 10 : 8), // Responsive spacing
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<CartModel>(context, listen: false).addItem(product.copyWith());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.title} added to cart!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffEB7720),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(vertical: isTablet ? 10 : 8)), // Responsive padding
                        child: Text(
                          "Add",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: isTablet ? 14 : 13), // Responsive font size
                        ),
                      ),
                    ),
                    Consumer<WishlistModel>(
                      builder: (context, wishlist, child) {
                        final bool isFavorite = wishlist.items.any(
                                (item) => item.id == product.id && item.selectedUnit == product.selectedUnit);
                        return IconButton(
                          onPressed: () {
                            if (isFavorite) {
                              wishlist.removeItem(product.id, product.selectedUnit);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.title} removed from wishlist!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              wishlist.addItem(product.copyWith());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.title} added to wishlist!'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: const Color(0xffEB7720),
                            size: isTablet ? 28 : 24, // Responsive icon size
                          ),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
