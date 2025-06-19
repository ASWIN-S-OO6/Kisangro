import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/home/myorder.dart'; // Import for MyOrder
import 'package:kisangro/home/noti.dart'; // Import for Noti
import 'package:kisangro/home/cart.dart'; // Import for CartScreen navigation

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key}); // Added Key and fixed super.key

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  // Helper to check if a URL is valid and absolute
  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    // Check if it's a valid absolute URL AND not just the base API path as a placeholder
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        title: Padding(
          padding: const EdgeInsets.only(right: 50),
          child: Text(
            "Wishlist",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const MyOrder()));
            },
            icon: Image.asset(
              'assets/box.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const noti()));
            },
            icon: Image.asset(
              'assets/noti.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) =>  Cart())); // Corrected line
            },
            icon: Image.asset(
              'assets/bag.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Consumer<WishlistModel>(
        builder: (context, wishlist, child) {
          if (wishlist.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your wishlist is empty!',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add products you love to your wishlist.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: wishlist.items.length,
              itemBuilder: (context, index) {
                final product = wishlist.items[index];
                return WishlistItemCard(
                  product: product,
                  isValidUrl: _isValidUrl, // Pass the helper function
                  onMoveToCart: () {
                    // Find the current price for the selected unit
                    final double? price = product.pricePerSelectedUnit;
                    if (price != null) {
                      Provider.of<CartModel>(context, listen: false).addItem(product);
                      wishlist.removeItem(product.id, product.selectedUnit); // Remove from wishlist after moving
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${product.title} moved to cart!'),
                            backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Cannot move ${product.title}: price not found for selected unit.'),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  onRemove: () {
                    wishlist.removeItem(product.id, product.selectedUnit);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${product.title} removed from wishlist!'),
                          backgroundColor: Colors.red),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class WishlistItemCard extends StatefulWidget {
  final Product product;
  final Function(String?) isValidUrl; // Accept the helper function
  final VoidCallback onMoveToCart;
  final VoidCallback onRemove;

  const WishlistItemCard({
    super.key,
    required this.product,
    required this.isValidUrl,
    required this.onMoveToCart,
    required this.onRemove,
  });

  @override
  State<WishlistItemCard> createState() => _WishlistItemCardState();
}

class _WishlistItemCardState extends State<WishlistItemCard> {
  // Local state for dropdown to update immediately
  late String _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.product.selectedUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withOpacity(0.3),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: 100,
                color: Colors.white, // Placeholder background
                child: widget.isValidUrl(widget.product.imageUrl)
                    ? Image.network(widget.product.imageUrl,
                        width: 100,
                        height: 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/placeholder.png',
                              width: 100,
                              height: 120,
                              fit: BoxFit.contain,
                            ))
                    : Image.asset(widget.product.imageUrl,
                        width: 100, height: 120, fit: BoxFit.contain),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text(widget.product.subtitle,
                        style: GoogleFonts.poppins(fontSize: 12)),
                    Text('Unit Size: $_selectedUnit', // Use local state for unit
                        style: GoogleFonts.poppins(fontSize: 12)),
                    Text(
                      '₹ ${widget.product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}/piece',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: const Color(0xffEB7720)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 40, // Height for the dropdown
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffEB7720)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Color(0xffEB7720)),
                          isExpanded: true,
                          underline: const SizedBox(), // ADDED: Required for isExpanded: true
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.black),
                          items: widget.product.availableSizes
                              .map((ProductSize sizeOption) {
                            return DropdownMenuItem<String>(
                              value: sizeOption.size,
                              child: Text(sizeOption.size),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedUnit = newValue!;
                              widget.product.selectedUnit = newValue; // Update the product model directly
                            });
                          },
                          iconEnabledColor: const Color(0xffEB7720),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onMoveToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffEB7720),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Move to cart',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: widget.onRemove,
              child: const Icon(
                Icons.close,
                size: 18,
                color: Color(0xffEB7720),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
