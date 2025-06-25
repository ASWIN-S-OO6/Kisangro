import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/services/product_service.dart'; // Ensure this import is correct
import 'package:kisangro/home/product.dart'; // ProductDetailPage
import 'package:kisangro/models/cart_model.dart'; // CartModel
import 'package:kisangro/models/wishlist_model.dart'; // WishlistModel

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName; // This parameter is required

  const CategoryProductsScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName, // Make categoryName required
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Calling the static method directly on the class
      final products = await ProductService.fetchProductsByCategory(widget.categoryId);
      if (!mounted) return; // Check if widget is still in the tree after async operation

      setState(() {
        _products = products;
        _isLoading = false;
        if (products.isEmpty) {
          _errorMessage = 'No products found for this category.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load products: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Error loading category products: $e');
    }
  }

  // Helper function to determine the effective image URL
  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png'; // Fallback to a local asset placeholder
    }
    return rawImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final Color orange = const Color(0xffEB7720); // Your app's theme color

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        title: Text(
          widget.categoryName, // Display the category name here
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
          onRefresh: _loadProducts,
          color: orange,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xffEB7720)))
              : _errorMessage.isNotEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadProducts,
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
              : _products.isEmpty
              ? Center(
            child: Text(
              'No products available in this category.',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            ),
          )
              : GridView.builder(
            padding: const EdgeInsets.all(15.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200, // Max width for items
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              mainAxisExtent: 320, // Explicitly set height for each tile to avoid overflow
            ),
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
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
          if (product.pricePerSelectedUnit != null && product.pricePerSelectedUnit! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '₹${product.pricePerSelectedUnit!.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 5),
          SizedBox(
            height: 36,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: product.selectedUnit,
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
                  if (!mounted) return;
                  setState(() {
                    product.selectedUnit = newValue!;
                  });
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
                        if (!mounted) return;
                        if (isFavorite) {
                          wishlist.removeItem(product.id, product.selectedUnit);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.title} removed from wishlist!'), backgroundColor: Colors.red),
                          );
                        } else {
                          wishlist.addItem(product.copyWith());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.title} added to wishlist!'), backgroundColor: Colors.blue),
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
