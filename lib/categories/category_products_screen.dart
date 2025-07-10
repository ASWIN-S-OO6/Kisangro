import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/services/product_service.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/home/product.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryId;

  const CategoryProductsScreen({
    Key? key,
    required this.categoryTitle,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _allProducts = []; // Store all products fetched from API
  List<Product> _displayedProducts = []; // Products currently displayed (filtered by search or category)
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _offset = 0;
  final int _limit = 10; // Load 10 products at a time
  bool _hasMore = true; // Flag to check if more products are available
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController(); // Search controller
  String _searchQuery = ''; // Stores the current search query

  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty ||
        rawImageUrl == 'https://sgserp.in/erp/api/' ||
        (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png';
    }
    return rawImageUrl;
  }

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged); // Add listener for search input changes
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMoreProducts();
    }
  }

  // Method to handle search query changes
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterProducts(); // Filter products based on new search query
    });
  }

  // Method to filter products based on the search query
  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      // If search query is empty, show products from the current category, paginated
      _displayedProducts = _allProducts.take(_limit).toList();
      _offset = _limit;
      _hasMore = _allProducts.length > _limit;
    } else {
      // If there's a search query, filter all products in the category
      _displayedProducts = _allProducts
          .where((product) =>
      product.title.toLowerCase().contains(_searchQuery) ||
          product.subtitle.toLowerCase().contains(_searchQuery) ||
          product.category.toLowerCase().contains(_searchQuery))
          .toList();
      _offset = _displayedProducts.length; // When searching, display all matching items, no load more
      _hasMore = false; // No more items to load when a search is active
    }
    _isLoadingMore = false; // Reset loading more flag
  }

  Future<void> _fetchCategoryProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await ProductService.fetchProductsByCategory(widget.categoryId);
      if (mounted) {
        setState(() {
          _allProducts = products;
          _filterProducts(); // Filter immediately after fetching to populate _displayedProducts
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching products for category ${widget.categoryTitle} (ID: ${widget.categoryId}): $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load products. Please try again later. ($e)';
          _isLoading = false;
        });
      }
    }
  }

  void _loadMoreProducts() {
    if (!_hasMore || _isLoadingMore || _searchQuery.isNotEmpty) return; // Don't load more if searching
    setState(() {
      _isLoadingMore = true;
    });

    // Simulate a slight delay to mimic API call and prevent UI jank
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          final nextProducts = _allProducts.skip(_offset).take(_limit).toList();
          _displayedProducts.addAll(nextProducts);
          _offset += _limit;
          _hasMore = _offset < _allProducts.length;
          _isLoadingMore = false;
        });
      }
    });
  }

  // Method to build the search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products in ${widget.categoryTitle}...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.search, color: Color(0xffEB7720)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              _filterProducts(); // Clear search and show initial category products
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none, // No border for a cleaner look
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
        onSubmitted: (value) {
          _filterProducts(); // Trigger search on submit as well
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Text(
          widget.categoryTitle,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xffEB7720)),
        )
            : _errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
            ),
          ),
        )
            : _displayedProducts.isEmpty && _searchQuery.isNotEmpty
            ? Center(
          child: Text(
            'No products found matching "${_searchController.text}" in this category.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
        )
            : CustomScrollView( // NEW: Use CustomScrollView for scrollable search bar
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter( // NEW: Search bar as a sliver
              child: _buildSearchBar(),
            ),
            // ADDED: Padding around the SliverGrid for alignment
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0), // Adjust padding here
              sliver: SliverGrid( // NEW: Products grid as a sliver grid
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final product = _displayedProducts[index];
                    return _buildProductTile(context, product);
                  },
                  childCount: _displayedProducts.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  mainAxisExtent: 320,
                ),
              ),
            ),
            if (_isLoadingMore && _searchQuery.isEmpty)
              SliverToBoxAdapter( // NEW: Loading indicator as a sliver
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xffEB7720)),
                  ),
                ),
              ),
            if (_displayedProducts.isEmpty && _searchQuery.isEmpty) // Show 'No products' only if no search and genuinely empty
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No products found for this category.',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    final List<ProductSize> availableSizes = product.availableSizes.isNotEmpty
        ? product.availableSizes
        : [ProductSize(size: 'Default', price: 0.0)];
    final String selectedUnit = availableSizes.any((size) => size.size == product.selectedUnit)
        ? product.selectedUnit
        : (availableSizes.isNotEmpty ? availableSizes.first.size : 'Default');


    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider<Product>.value(
                    value: product,
                    child: ProductDetailPage(product: product),
                  ),
                ),
              );
            },
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Center(
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
            ),
          ),
          const Divider(),
          const SizedBox(height: 3),
          Text(
            product.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            product.subtitle,
            style: GoogleFonts.poppins(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Unit Size: ${product.selectedUnit}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xffEB7720),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Price: ₹${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}', // Safely access price
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 5),
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8)),
                  child: Text(
                    "Add",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 44,
                height: 44,
                child: Consumer<WishlistModel>(
                  builder: (context, wishlist, child) {
                    final bool isFavorite = wishlist.items.any(
                          (item) => item.id == product.id && item.selectedUnit == product.selectedUnit,
                    );
                    return IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (isFavorite) {
                          wishlist.removeItem(product.id, product.selectedUnit);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${product.title} removed from wishlist!'),
                                backgroundColor: Colors.red),
                          );
                        } else {
                          wishlist.addItem(product.copyWith());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${product.title} added to wishlist!'),
                                backgroundColor: Colors.blue),
                          );
                        }
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xffEB7720),
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
