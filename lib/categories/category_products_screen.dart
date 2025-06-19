import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // For state management
import 'package:kisangro/models/product_model.dart'; // Import Product model
import 'package:kisangro/services/product_service.dart'; // Import ProductService
import 'package:kisangro/models/cart_model.dart'; // For adding to cart
import 'package:kisangro/menu/wishlist.dart'; // For wishlist functionality
import 'package:kisangro/models/wishlist_model.dart'; // For wishlist model
import 'package:kisangro/home/product.dart'; // Import ProductDetailPage

class CategoryProductsScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryId; // New: Accept categoryId

  const CategoryProductsScreen({
    Key? key,
    required this.categoryTitle,
    required this.categoryId, // Make categoryId required
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _categoryProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Helper function to determine the effective image URL
  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png'; // Fallback to a local asset placeholder
    }
    return rawImageUrl; // Use the provided URL if it's valid
  }

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
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
          _categoryProducts = products;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Text(
          widget.categoryTitle, // Display the category title
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
            child: CircularProgressIndicator(color: Color(0xffEB7720)))
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
            : _categoryProducts.isEmpty
            ? Center(
          child: Text(
            'No products found for this category.',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
        )
            : GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, // Max width for items
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            mainAxisExtent: 320, // Adjusted height to match homepage tiles
          ),
          itemCount: _categoryProducts.length,
          itemBuilder: (context, index) {
            final product = _categoryProducts[index];
            return _buildProductTile(context, product);
          },
        ),
      ),
    );
  }

  // Reusing the product tile builder from homepage.dart for consistency
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
              // Navigate to ProductDetailPage. Ensure it's set up to receive a Product object.
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
          // Unit Size and Price (handled for missing 'sizes' in API response)
          // Displays "Unit: N/A" and "Price: ₹0.00" if sizes/mrp are not in API response.
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
              'Price: ₹${product.pricePerSelectedUnit!.toStringAsFixed(2)}',
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
                    Provider.of<CartModel>(context, listen: false)
                        .addItem(product.copyWith());
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
