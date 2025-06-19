import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/home/product.dart';
import 'package:provider/provider.dart'; // For accessing CartModel and WishlistModel

import 'package:kisangro/services/product_service.dart'; // Import the new ProductService
import 'package:kisangro/models/product_model.dart'; // Import Product and ProductSize model
import 'package:kisangro/models/cart_model.dart'; // Import CartModel
import 'package:kisangro/models/wishlist_model.dart'; // Import WishlistModel
 // Import ProductDetailPage

// This screen will display products for a specific category.
class CategoryProductsScreen extends StatefulWidget {
  final String categoryTitle;

  const CategoryProductsScreen({Key? key, required this.categoryTitle}) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late List<Product> _products;

  @override
  void initState() {
    super.initState();
    // Load products based on the category title
    _products = ProductService.getProductsByCategory(widget.categoryTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Text(
          widget.categoryTitle, // Display the tapped category's title
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
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
        child: _products.isEmpty
            ? Center(
                child: Text(
                  'No products found for "${widget.categoryTitle}" yet.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              )
            : GridView.builder( // Changed to GridView.builder
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 10, // Spacing between columns
                  mainAxisSpacing: 12, // Spacing between rows
                  childAspectRatio: 140 / 290, // Aspect ratio similar to homepage grid items
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  // Pass the product directly to the new grid item builder
                  return _buildProductGridItem(context, product);
                },
              ),
      ),
    );
  }

  /// Helper method to build a single product grid item (card), mirroring homepage style.
  Widget _buildProductGridItem(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to ProductDetailPage for individual product
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
            // Product image, ensure imageUrl is a valid asset path or network URL
            child: Center(child: Image.asset(product.imageUrl, height: 120)),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            product.title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(product.subtitle, style: GoogleFonts.poppins(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          // Display price per unit, safely handling null pricePerSelectedUnit
          Text('₹ ${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}/piece',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.green)),
          // Display selected unit
          Text('Unit: ${product.selectedUnit}',
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xffEB7720))),
          const SizedBox(height: 8),
          SizedBox( // Use SizedBox to give fixed height to dropdown
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
                onChanged: (newValue) {
                  // Call setState to re-render the specific product card
                  // when a new unit is selected, as Product is a ChangeNotifier
                  setState(() {
                    product.selectedUnit = newValue!;
                    // product.notifyListeners(); // Could also notify listeners if Product was observed directly
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add to Cart Logic using Provider
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8)
                  ),
                  child: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Consumer<WishlistModel>(
                builder: (context, wishlist, child) {
                  // FIX: Changed 'item.product.selectedUnit' to 'item.selectedUnit'
                  final bool isFavorite = wishlist.items.any(
                    (item) => item.id == product.id && item.selectedUnit == product.selectedUnit,
                  );
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
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
