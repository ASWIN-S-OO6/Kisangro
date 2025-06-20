import 'package:flutter/material.dart';
import 'package:kisangro/home/bottom.dart'; // Corrected import
import 'package:kisangro/home/myorder.dart'; // Corrected import
import 'package:kisangro/home/noti.dart'; // Corrected import
import 'package:kisangro/menu/wishlist.dart'; // Corrected import
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/payment/payment1.dart'; // Assuming 'delivery' is defined here
import 'package:kisangro/payment/payment3.dart'; // Corrected import (PaymentPage)
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Corrected import

// Import your custom models
import 'package:kisangro/models/cart_model.dart'; // Corrected import
import 'package:kisangro/models/product_model.dart'; // Corrected import
import 'package:kisangro/services/product_service.dart'; // Import ProductService to get products
// Import ProductDetailPage for similar products (if you need to navigate to it from here)
import 'package:kisangro/home/product.dart'; // Uncomment if you have this file and need to navigate

// Retaining original class name 'cart' as requested
class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _cartState();
}

class _cartState extends State<Cart> {
  // List of similar products, fetched from ProductService
  late List<Product> _similarProducts;

  // Helper to check if a URL is valid and absolute
  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    // Check if it's a valid absolute URL AND not just the base API path as a placeholder
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  @override
  void initState() {
    super.initState();
    // Fetch all products from ProductService to use as "similar products"
    // Taking a subset and shuffling for variety in "similar products"
    _similarProducts = ProductService.getAllProducts().take(5).toList(); // Limit to 5 for example
    // Shuffle the list to show different "similar" products each time
    _similarProducts.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        centerTitle: false,
        elevation: 0,
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            "Cart",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            // Navigator.pushReplacement is used to replace the current route
            // to go back to the bottom navigation root.
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Bot(initialIndex: 0))); // Pass initialIndex to go to Home tab
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const WishlistPage())); // WishlistPage should be const if possible
            },
            icon: Image.asset(
              'assets/heart.png',
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
        ],
      ),
      // Consumer listens for changes in CartModel and rebuilds relevant parts
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Container( // Wrap Center with Container for background
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your cart is empty!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Start adding some products from the home screen.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 1),
                  Row(
                    children: [
                      Text('Total Amount:',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      const Spacer(), // Use Spacer instead of SizedBox for dynamic spacing
                      Text('₹ ${cart.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold)), // Dynamic total amount
                    ],
                  ),
                  const Divider(thickness: 1),
                  Text(
                    'Step 1/3',
                    style: GoogleFonts.poppins(
                        color: const Color(0xffEB7720), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Item Summary (${cart.totalItemCount} items in your cart)', // Dynamic total item count
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Display dynamic cart items
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(), // To allow parent SingleChildScrollView to scroll
                    shrinkWrap: true,
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      // Consumer for individual CartItem to update quantity display
                      return ChangeNotifierProvider<CartItem>.value(
                        value: cartItem, // Provide the existing CartItem instance
                        builder: (context, child) { // Use builder for the Consumer context
                          final item = Provider.of<CartItem>(context); // Get the CartItem from Provider
                          return _itemCard(
                            cartItem: item, // Pass the individual CartItem to the card
                            onRemove: () => cart.removeItem(item.id, item.selectedUnit),
                            onIncrement: () => item.incrementQuantity(), // Call method on CartItem
                            onDecrement: () => item.decrementQuantity(), // Call method on CartItem
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    collapsedBackgroundColor: const Color(0xffEB7720),
                    backgroundColor: const Color(0xfff9c7a1),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        Text('₹ ${cart.totalAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    children: [
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // These calculations would need to be dynamic based on actual cart items
                            _buildRow(
                                '${cart.totalItemCount} Units Total',
                                '₹ ${cart.totalAmount.toStringAsFixed(2)}'),
                            _buildRow(
                                'GST - 18%',
                                '₹ ${((cart.totalAmount * 0.18)).toStringAsFixed(2)}'), // Example GST calculation
                            _buildRow('Shipping', '₹ 90.00'), // Fixed shipping for now
                            _buildRow(
                                'Membership Discount - 3%',
                                '- ₹ ${((cart.totalAmount * 0.03)).toStringAsFixed(2)}'), // Example discount
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text("Browse Similar Products",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 290,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _similarProducts.length,
                      itemBuilder: (context, index) {
                        final product = _similarProducts[index];
                        return _buildSimilarProductCard(context, product);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CartModel>(
        builder: (context, cart, child) {
          // Only show the button if there are items in the cart
          if (cart.items.isEmpty) {
            return const SizedBox.shrink(); // Hide the button
          }
          return Container(
            height: 70, // Increased height to accommodate padding
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withOpacity(0.2), // Adjust shadow opacity
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEB7720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0, // No extra shadow
                ),
                onPressed: () {
                  if (cart.items.isNotEmpty) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const delivery())); // Corrected to const
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Your cart is empty! Add items to proceed.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed To Payment',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_ios_outlined, color: Colors.white70),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Updated _itemCard to accept CartItem and callbacks for actions
  Widget _itemCard({
    required CartItem cartItem,
    required VoidCallback onRemove,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withOpacity(0.3), // Changed to match wishlist item card
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align top elements to start
            children: [
              Container(
                height: 128,
                width: 100, // Adjusted width for better layout
                color: Colors.white,
                child: _isValidUrl(cartItem.imageUrl)
                    ? Image.network(cartItem.imageUrl,
                    width: 100,
                    height: 128,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/placeholder.png', // Fallback
                      width: 100,
                      height: 128,
                      fit: BoxFit.contain,
                    ))
                    : Image.asset(cartItem.imageUrl, // Corrected access
                    width: 100, height: 128, fit: BoxFit.contain),
              ),
              const SizedBox(width: 15), // Reduced width for better spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cartItem.title, // Corrected access
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text(cartItem.subtitle, // Corrected access
                        style: GoogleFonts.poppins(fontSize: 12)),
                    // Display selected unit correctly
                    Text('Unit Size: ${cartItem.selectedUnit}', // Corrected access
                        style: GoogleFonts.poppins(fontSize: 12)),
                    // Display price per selected unit
                    Text(
                        '₹ ${cartItem.pricePerUnit.toStringAsFixed(2)}/piece', // Corrected access to pricePerUnit
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xffEB7720))),
                    const SizedBox(height: 10), // Added spacing
                    Row(
                      children: [
                        Text("Units: ", style: GoogleFonts.poppins(fontSize: 13)),
                        // Decrement button
                        InkWell(
                          onTap: onDecrement,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffEB7720),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.remove, size: 16, color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('${cartItem.quantity}',
                                style: GoogleFonts.poppins(fontSize: 14)),
                          ),
                        ),
                        // Increment button
                        InkWell(
                          onTap: onIncrement,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffEB7720),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delete icon
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                padding: EdgeInsets.zero, // Remove default padding
                constraints: const BoxConstraints(), // Remove default constraints
              ),
            ],
          ),
          const SizedBox(height: 10), // Spacing below the item row
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: ₹ ${(cartItem.pricePerUnit * cartItem.quantity).toStringAsFixed(2)}', // Corrected access to totalPrice calculation
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xffEB7720),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins()),
          Text(value, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  // Helper for similar product cards - adapted to Product model
  Widget _buildSimilarProductCard(BuildContext context, Product product) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white, // Kept white as per other product cards (e.g., homepage)
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // Navigate to ProductDetailPage for similar products (regular Product)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
            child: _isValidUrl(product.imageUrl)
                ? Image.network(
                product.imageUrl,
                height: 100,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/placeholder.png', // Fallback
                  height: 100,
                  fit: BoxFit.contain,
                ))
                : Image.asset(product.imageUrl, height: 100, fit: BoxFit.contain),
          ),
          const Divider(),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(right: 0), // Adjust padding as needed
            child: Text(
              product.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(product.subtitle,
            style: GoogleFonts.poppins(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1, // Prevent overflow
            overflow: TextOverflow.ellipsis,), // Clip if too long
          // Display current selected unit
          Text("Unit Size: ${product.selectedUnit}",
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xffEB7720))),
          // Display price for selected unit
          Text('₹ ${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}', // Use pricePerSelectedUnit
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.green)), // Green for price
          const SizedBox(height: 8), // Added SizedBox here to ensure proper spacing
          // Corrected the typo from 'Padd' to 'Padding'
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0), // Original padding was `horizontal: 5, vertical: 0` but then it's in a Row below. This padding seems misplaced given the original intention. Let's assume it was meant to wrap the entire dropdown/buttons block. If not, this might need re-evaluation.
            child: Container( // This entire block should be wrapped by Padding to ensure consistency with the user's provided code.
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xffEB7720)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: product.selectedUnit,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xffEB7720)),
                  underline: const SizedBox(),
                  isExpanded: true,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                  // Iterate over availableSizes from the Product model
                  items: product.availableSizes.map((ProductSize sizeOption) {
                    return DropdownMenuItem<String>(
                      value: sizeOption.size,
                      child: Text(sizeOption.size),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      // Update the selected unit for this specific product instance
                      product.selectedUnit = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, // Use double.infinity for full width
            height: 30, // Fixed height for consistency
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribute space
              children: [
                Expanded(
                  // Use Expanded to make button take available space
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 0), // Adjust padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text("Add",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Consumer<WishlistModel>(
                  builder: (context, wishlist, child) {
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
