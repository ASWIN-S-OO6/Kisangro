import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/services/product_service.dart'; // Ensure this import is correct
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/menu/wishlist.dart'; // Assuming this is correct
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/home/product.dart'; // ProductDetailPage

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName; // Renamed from categoryTitle
  final String categoryId;

  const CategoryProductsScreen({
    Key? key,
    required this.categoryName, // Now 'categoryName'
    required this.categoryId,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  // _allProducts (local to this screen) will store all products fetched so far for THIS category
  List<Product> _allProducts = [];
  // _displayedProducts are the ones actually shown in the GridView
  List<Product> _displayedProducts = [];

  bool _isLoading = true; // Initial loading state for the first batch
  bool _isLoadingMore = false; // Loading state for subsequent batches
  String? _errorMessage;

  int _offset = 0; // Current offset for pagination
  final int _limit = 10; // Number of products to load per batch
  bool _hasMore = true; // Flag to indicate if there are more products to load

  final ScrollController _scrollController = ScrollController();

  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png';
    }
    return rawImageUrl;
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialProducts(); // Initial load
    _scrollController.addListener(_onScroll); // Listen for scroll events
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Only load more if not already loading, if there's more data, and if scrolled near the bottom
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMoreProducts();
    }
  }

  // Fetches the first batch of products
  Future<void> _fetchInitialProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _offset = 0; // Reset offset for initial fetch
      _allProducts.clear(); // Clear previous data
      _displayedProducts.clear(); // Clear previous data
      _hasMore = true; // Assume there's more until proved otherwise
    });

    try {
      final newProducts = await ProductService.fetchProductsByCategory(
        widget.categoryId,
        offset: _offset,
        limit: _limit,
      );

      if (mounted) {
        setState(() {
          _allProducts.addAll(newProducts); // Add to local _allProducts for this category
          _displayedProducts = List.from(_allProducts); // Display all fetched so far
          _isLoading = false;
          _offset += newProducts.length; // Increment offset by actual number of products fetched
          _hasMore = newProducts.length == _limit; // If we got less than limit, no more
        });
      }
    } catch (e) {
      debugPrint('Error fetching initial products for category ${widget.categoryName} (ID: ${widget.categoryId}): $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load products. Please try again. ($e)';
          _isLoading = false;
        });
      }
    }
  }

  // Loads subsequent batches of products
  void _loadMoreProducts() async {
    if (!_hasMore || _isLoadingMore) return; // Prevent multiple simultaneous calls

    setState(() {
      _isLoadingMore = true; // Set loading state for "load more" indicator
    });

    try {
      final nextProducts = await ProductService.fetchProductsByCategory(
        widget.categoryId,
        offset: _offset,
        limit: _limit,
      );

      if (mounted) {
        setState(() {
          _displayedProducts.addAll(nextProducts); // Add new products to displayed list
          _allProducts.addAll(nextProducts); // Keep _allProducts updated with all fetched for this category
          _offset += nextProducts.length; // Increment offset by actual number of products fetched
          _hasMore = nextProducts.length == _limit; // Update hasMore flag
          _isLoadingMore = false; // Reset loading state
        });
      }
    } catch (e) {
      debugPrint('Error loading more products for category ${widget.categoryName} (ID: ${widget.categoryId}): $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load more products. ($e)'; // Display error
          _isLoadingMore = false; // Reset loading state
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final Color orange = const Color(0xffEB7720); // Your app's theme color

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        elevation: 0,
        title: Text(
          widget.categoryName, // Display the category name passed to the screen
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
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)], // Consistent theme gradient
          ),
        ),
        child: RefreshIndicator( // Allows pull-to-refresh
          onRefresh: _fetchInitialProducts, // Pull to refresh the first batch
          color: orange,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xffEB7720)))
              : _errorMessage != null && _errorMessage!.isNotEmpty // Check for error message
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchInitialProducts, // Retry button
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Retry', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ],
              ),
            ),
          )
              : _displayedProducts.isEmpty && !_isLoading // If no products and not loading
              ? Center(
            child: Text(
              'No products found for this category.',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            ),
          )
              : GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200, // Max width for items
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              mainAxisExtent: 320, // Explicitly set height for each tile to avoid overflow
            ),
            itemCount: _displayedProducts.length + (_hasMore ? 1 : 0), // Add 1 for loading indicator if hasMore
            itemBuilder: (context, index) {
              if (index == _displayedProducts.length) {
                // This is the loading indicator at the bottom
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Color(0xffEB7720)),
                  ),
                );
              }
              final product = _displayedProducts[index];
              return _buildProductTile(context, product);
            },
          ),
        ),
      ),
    );
  }

  // Reusing the _buildProductTile logic from homepage.dart for consistency
  Widget _buildProductTile(BuildContext context, Product product) {
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
                  builder: (context) => ProductDetailPage(product: product),
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
          // Unit Size and Price display with null check
          if (product.availableSizes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'No Price Available',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 5),
          SizedBox(
            height: 36,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: product.selectedUnit.isNotEmpty ? product.selectedUnit : null, // Set to null if empty
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xffEB7720)),
                isExpanded: true,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                items: product.availableSizes.map((ProductSize sizeOption) {
                  return DropdownMenuItem<String>(
                    value: sizeOption.size,
                    child: Text(sizeOption.size),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && mounted) {
                    setState(() {
                      product.selectedUnit = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Check if price is available before adding to cart
                    if (product.pricePerSelectedUnit != null && product.pricePerSelectedUnit! > 0) {
                      Provider.of<CartModel>(context, listen: false).addItem(product.copyWith());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.title} added to cart!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cannot add ${product.title} to cart: Price not available.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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
