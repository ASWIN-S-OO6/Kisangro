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
  List<Product> _allProducts = []; // Store all products fetched from API for the category
  List<Product> _displayedProducts = []; // Products currently displayed (filtered by search or paginated)
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _offset = 0;
  final int _initialLimit = 15; // Initial load of 15 products
  final int _loadMoreLimit = 10; // Subsequent loads of 10 products
  bool _hasMore = true; // Flag to check if more products are available
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // MODIFIED: Use ProductService.getRandomValidImageUrl() as fallback
  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty ||
        rawImageUrl == 'https://sgserp.in/erp/api/' ||
        (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return ProductService.getRandomValidImageUrl(); // Use a random valid API image
    }
    return rawImageUrl;
  }

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts(initialLoad: true); // Initial load
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading || _searchQuery.isNotEmpty) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMoreProducts();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterAndDisplayProducts(); // Filter based on search query
    });
  }

  // This method now filters from _allProducts (which holds all fetched for the category)
  // and also handles initial display vs. search results.
  void _filterAndDisplayProducts() {
    if (_searchQuery.isEmpty) {
      // If search query is empty, display all fetched products for the category
      _displayedProducts = List.from(_allProducts);
    } else {
      // If there's a search query, filter all products in the category
      _displayedProducts = _allProducts
          .where((product) =>
      product.title.toLowerCase().contains(_searchQuery) ||
          product.subtitle.toLowerCase().contains(_searchQuery) ||
          product.category.toLowerCase().contains(_searchQuery))
          .toList();
    }
    // When filtering, we assume all matching results are displayed, so no further loading
    _isLoadingMore = false;
  }

  Future<void> _fetchCategoryProducts({bool initialLoad = false}) async {
    if (initialLoad) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _offset = 0; // Reset offset for initial load
        _allProducts.clear(); // Clear previous products
        _displayedProducts.clear(); // Clear displayed products
        _hasMore = true; // Assume there's more initially
      });
    }

    try {
      final Map<String, dynamic> result = await ProductService.fetchProductsByCategory(
        widget.categoryId,
        offset: _offset,
        limit: initialLoad ? _initialLimit : _loadMoreLimit,
      );

      final List<Product> fetchedProducts = result['products'];
      final bool fetchedHasMore = result['hasMore'];

      if (mounted) {
        setState(() {
          _allProducts.addAll(fetchedProducts); // Add to the master list of all products for the category
          _offset += fetchedProducts.length;
          _hasMore = fetchedHasMore;
          _isLoading = false;
          _isLoadingMore = false;
          _filterAndDisplayProducts(); // Update displayed products based on search query
        });
      }
    } catch (e) {
      debugPrint('Error fetching products for category ${widget.categoryTitle} (ID: ${widget.categoryId}): $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load products. Please try again later. ($e)';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _loadMoreProducts() async {
    if (!_hasMore || _isLoadingMore || _searchQuery.isNotEmpty) return;

    setState(() {
      _isLoadingMore = true; // Show the loading indicator immediately
    });

    // Introduce a small delay to ensure the loading indicator is visible
    await Future.delayed(const Duration(milliseconds: 500)); // Increased delay for better visibility

    try {
      final Map<String, dynamic> result = await ProductService.fetchProductsByCategory(
        widget.categoryId,
        offset: _offset,
        limit: _loadMoreLimit,
      );

      final List<Product> fetchedProducts = result['products'];
      final bool fetchedHasMore = result['hasMore'];

      if (mounted) {
        setState(() {
          _allProducts.addAll(fetchedProducts); // Add to the master list
          _offset += fetchedProducts.length;
          _hasMore = fetchedHasMore;
          _isLoadingMore = false; // Hide the loading indicator
          _filterAndDisplayProducts(); // Update displayed products with new data
        });
      }
    } catch (e) {
      debugPrint('Error loading more products for category ${widget.categoryTitle} (ID: ${widget.categoryId}): $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load more products. Please try again later. ($e)';
          _isLoadingMore = false;
        });
      }
    }
  }

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
              // No need to call _filterProducts directly here, listener handles it
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
        onSubmitted: (value) {
          _filterAndDisplayProducts();
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
            : CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              sliver: SliverGrid(
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
            // Re-added the loading indicator for "load more"
            if (_isLoadingMore && _searchQuery.isEmpty) // Only show if loading more and not actively searching
              SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xffEB7720)),
                  ),
                ),
              ),
            if (_displayedProducts.isEmpty && _searchQuery.isEmpty && !_isLoading && _errorMessage == null)
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
                      'assets/placeholder.png', // Fallback to local placeholder if network image fails
                      fit: BoxFit.contain,
                    ),
                  )
                      : Image.asset(
                    _getEffectiveImageUrl(product.imageUrl), // This will now use the dynamic fallback if rawImageUrl is empty
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
              'Price: ₹${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}',
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
