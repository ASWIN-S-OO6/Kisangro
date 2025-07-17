import 'package:flutter/material.dart';
import 'package:kisangro/home/bottom.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/payment/payment1.dart';
import 'package:kisangro/payment/payment3.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/services/product_service.dart'; // Import ProductService
import 'package:kisangro/home/product.dart';

// Import the common_app_bar file


import '../common/common_app_bar.dart';


class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _cartState();
}

class _cartState extends State<Cart> {
  List<Product> _similarProducts = []; // Changed to non-late and initialized empty

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  @override
  void initState() {
    super.initState();
    _loadSimilarProducts(); // Call a new method to load products
  }

  // NEW: Method to load similar products from ProductService
  void _loadSimilarProducts() {
    // We want to get products from the service.
    // ProductService.getAllProducts() will return either API data, cached data, or dummy data.
    final allAvailableProducts = ProductService.getAllProducts();

    // Shuffle and take a subset, similar to how "New On Kisangro" might pick items.
    // Ensure we don't try to shuffle an empty list.
    if (allAvailableProducts.isNotEmpty) {
      allAvailableProducts.shuffle();
      setState(() {
        _similarProducts = allAvailableProducts.take(10).toList(); // Take 10 items for display
        debugPrint('Cart: Loaded ${_similarProducts.length} similar products from ProductService.');
      });
    } else {
      // Fallback if no products are available from ProductService (e.g., still loading or error)
      debugPrint('Cart: ProductService returned no products for similar items. Using dummy fallback.');
      setState(() {
        _similarProducts = List.generate(
          5, // Generate 5 dummy items if no real products are available
              (index) => Product(
            id: 'similar_dummy_$index',
            title: 'Dummy Similar $index',
            subtitle: 'Placeholder Item',
            imageUrl: 'assets/placeholder.png',
            category: 'Dummy',
            availableSizes: [ProductSize(size: 'kg', price: 75.0 + index * 5)],
            selectedUnit: 'kg',
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define isTablet here to be accessible within build method
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    return Scaffold(
      // Removed the GlobalKey<ScaffoldState> as there's no drawer
      appBar: CustomAppBar( // Replaced AppBar with CustomAppBar
        title: "Cart", // Set the title
        showBackButton: true, // Show back button
        showMenuButton: false, // Do NOT show menu button (drawer icon)
        // scaffoldKey is not needed here as there's no drawer
        isMyOrderActive: false, // Not active
        isWishlistActive: false, // Not active
        isNotiActive: false, // Not active
        // showWhatsAppIcon is false by default, matching original behavior
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          // Calculate dynamic values
          final double subtotal = cart.totalAmount;
          final double gst = subtotal * 0.18;
          final double discount = subtotal * 0.03;
          final double shipping = 90.00;
          final double grandTotal = subtotal + gst + shipping - discount;

          debugPrint('Cart: Subtotal=₹$subtotal, GST=₹$gst, Discount=₹$discount, GrandTotal=₹$grandTotal');

          if (cart.items.isEmpty) {
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
                  // NEW: Total Amount Display at the top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Amount:',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      Text('₹ ${grandTotal.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                              fontSize: 22, fontWeight: FontWeight.bold)),
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
                    'Item Summary (${cart.totalItemCount} items in your cart)',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      return ChangeNotifierProvider<CartItem>.value(
                        value: cartItem,
                        builder: (context, child) {
                          final item = Provider.of<CartItem>(context);
                          return _itemCard(
                            cartItem: item,
                            // Removed `cart` parameter from _itemCard as ExpansionTile is removed
                            onRemove: () {
                              cart.removeItem(item.id, item.selectedUnit);
                              debugPrint('Cart: Removed item ${item.id}, Unit: ${item.selectedUnit}, New Total: ₹${cart.totalAmount}');
                            },
                            onIncrement: () {
                              item.incrementQuantity();
                              debugPrint('Cart: Incremented ${item.id}, Quantity: ${item.quantity}, New Total: ₹${cart.totalAmount}');
                            },
                            onDecrement: () {
                              item.decrementQuantity();
                              debugPrint('Cart: Decremented ${item.id}, Quantity: ${item.quantity}, New Total: ₹${cart.totalAmount}');
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text("Browse Similar Products",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double screenWidth = constraints.maxWidth;
                      int crossAxisCount;
                      double childAspectRatio;

                      // Adjusted crossAxisCount to 5 for large tablets/desktops
                      // and adjusted childAspectRatio for compactness and vertical fit.
                      if (screenWidth > 900) { // Large tablets / desktops
                        crossAxisCount = 5; // Changed to 5 as requested
                        childAspectRatio = 0.6; // Adjusted to make tiles horizontally compact and vertically fit
                      } else if (screenWidth > 600) { // Standard tablets (medium size)
                        crossAxisCount = 3; // Remains 3
                        childAspectRatio = 0.65; // Adjusted for vertical fit
                      } else { // Mobile phones
                        crossAxisCount = 2;
                        childAspectRatio = 0.52; // No change for mobile
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: _similarProducts.length,
                        itemBuilder: (context, index) {
                          final product = _similarProducts[index];
                          return _buildSimilarProductCard(context, product);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<CartModel>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const SizedBox.shrink();
          }
          return Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEB7720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (cart.items.isNotEmpty) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const delivery()));
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

  Widget _itemCard({
    required CartItem cartItem,
    // Removed `cart` parameter as ExpansionTile is removed
    required VoidCallback onRemove,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50.withOpacity(0.3),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 128,
                width: 100,
                color: Colors.white,
                child: _isValidUrl(cartItem.imageUrl)
                    ? Image.network(cartItem.imageUrl,
                    width: 100,
                    height: 128,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/placeholder.png',
                      width: 100,
                      height: 128,
                      fit: BoxFit.contain,
                    ))
                    : Image.asset(cartItem.imageUrl,
                    width: 100, height: 128, fit: BoxFit.contain),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cartItem.title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text(cartItem.subtitle,
                        style: GoogleFonts.poppins(fontSize: 12)),
                    Text('Unit Size: ${cartItem.selectedUnit}',
                        style: GoogleFonts.poppins(fontSize: 12)),
                    Text(
                        '₹ ${cartItem.pricePerUnit.toStringAsFixed(2)}/piece',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xffEB7720))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Units: ", style: GoogleFonts.poppins(fontSize: 13)),
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
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Removed the ExpansionTile from here
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

  Widget _buildSimilarProductCard(BuildContext context, Product product) {
    // Local state for the selected unit within this card
    String _localSelectedUnit = product.selectedUnit;

    // Ensure availableSizes is never empty to prevent errors in DropdownButton.
    final List<ProductSize> availableSizes = product.availableSizes.isNotEmpty
        ? product.availableSizes
        : [ProductSize(size: 'Unit', price: product.pricePerSelectedUnit ?? 0.0)];

    // Ensure _localSelectedUnit is one of the available sizes, or default to the first available.
    if (!availableSizes.any((size) => size.size == _localSelectedUnit)) {
      _localSelectedUnit = availableSizes.first.size;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              height: 100,
              width: double.infinity,
              child: Center(
                child: _isValidUrl(product.imageUrl)
                    ? Image.network(
                    product.imageUrl,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/placeholder.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ))
                    : Image.asset(product.imageUrl, height: 100, fit: BoxFit.contain),
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              product.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(product.subtitle,
                style: GoogleFonts.poppins(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Text('₹ ${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.green)),
          const SizedBox(height: 8), // Spacing before the unit/buttons section
          Expanded( // Allows the bottom section to take available space
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Align contents to the bottom
                crossAxisAlignment: CrossAxisAlignment.start, // Align "Unit" to start
                children: [
                  // Unit text and dropdown
                  Align(
                    alignment: Alignment.centerLeft, // Align "Unit" text to the left
                    child: Text("Unit Size: ${_localSelectedUnit}", // Use local state
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xffEB7720))),
                  ),
                  const SizedBox(height: 4), // Reduced spacing
                  Container(
                    height: 30, // Reduced height for dropdown
                    padding: const EdgeInsets.symmetric(horizontal: 5), // Reduced padding
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffEB7720)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _localSelectedUnit, // Use local state for dropdown value
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xffEB7720), size: 18), // Smaller icon
                        underline: const SizedBox(),
                        isExpanded: true,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.black), // Smaller font
                        items: availableSizes.map((ProductSize sizeOption) {
                          return DropdownMenuItem<String>(
                            value: sizeOption.size,
                            child: Text(sizeOption.size),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _localSelectedUnit = newValue!; // Update local state
                            // No need to update product.selectedUnit directly here,
                            // as we will pass the _localSelectedUnit to copyWith
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // Spacing before buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                    children: [
                      SizedBox(
                        width: 70, // Reduced width for Add button
                        height: 30, // Reduced height for Add button
                        child: ElevatedButton(
                          onPressed: () {
                            // Pass the locally selected unit when adding to cart
                            Provider.of<CartModel>(context, listen: false)
                                .addItem(product.copyWith(selectedUnit: _localSelectedUnit));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.title} added to cart!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffEB7720),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text("Add",
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)), // Smaller font
                        ),
                      ),
                      Consumer<WishlistModel>(
                        builder: (context, wishlist, child) {
                          // Check if the product with the *currently selected local unit* is in the wishlist
                          final bool isFavorite = wishlist.items.any(
                                  (item) => item.id == product.id && item.selectedUnit == _localSelectedUnit);
                          return IconButton(
                            onPressed: () {
                              if (isFavorite) {
                                wishlist.removeItem(product.id, _localSelectedUnit); // Remove using local unit
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.title} removed from wishlist!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                wishlist.addItem(product.copyWith(selectedUnit: _localSelectedUnit)); // Add using local unit
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
                              size: 20, // Smaller icon size
                            ),
                            padding: EdgeInsets.zero, // Remove default padding
                            constraints: const BoxConstraints(), // Remove default constraints
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
