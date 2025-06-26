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
import 'package:kisangro/services/product_service.dart';
import 'package:kisangro/home/product.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _cartState();
}

class _cartState extends State<Cart> {
  late List<Product> _similarProducts;

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  @override
  void initState() {
    super.initState();
    _similarProducts = ProductService.getAllProducts().take(5).toList();
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
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Bot(initialIndex: 0)));
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
                  MaterialPageRoute(builder: (context) => const WishlistPage()));
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
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
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
          // Calculate dynamic values
          final double subtotal = cart.totalAmount;
          final double gst = subtotal * 0.18;
          final double discount = subtotal * 0.03;
          final double shipping = 90.00;
          final double grandTotal = subtotal + gst + shipping - discount;

          debugPrint('Cart: Subtotal=₹$subtotal, GST=₹$gst, Discount=₹$discount, GrandTotal=₹$grandTotal');

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
                            cart: cart, // Pass CartModel for ExpansionTile
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
    required CartModel cart, // Added to access cart-wide totals
    required VoidCallback onRemove,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    // Calculate cart-wide totals for ExpansionTile
    final double subtotal = cart.totalAmount;
    final double gst = subtotal * 0.18;
    final double discount = subtotal * 0.03;
    final double shipping = 90.00;
    final double grandTotal = subtotal + gst + shipping - discount;

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
          Align(
            alignment: Alignment.centerRight,

          ),
          const SizedBox(height: 10),
          // Shrunk and right-aligned ExpansionTile
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12)
              ),
              width: 273,
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                collapsedBackgroundColor: const Color(0xffEB7720),
                backgroundColor: const Color(0xfff9c7a1),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text('₹ ${grandTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildRow('${cart.totalItemCount} Units Total',
                            '₹ ${subtotal.toStringAsFixed(2)}'),
                        _buildRow('GST - 18%', '₹ ${gst.toStringAsFixed(2)}'),
                        _buildRow('Shipping', '₹ ${shipping.toStringAsFixed(2)}'),
                        _buildRow('Membership Discount - 3%',
                            '- ₹ ${discount.toStringAsFixed(2)}'),
                        _buildRow('Grand Total', '₹ ${grandTotal.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildSimilarProductCard(BuildContext context, Product product) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
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
            child: _isValidUrl(product.imageUrl)
                ? Image.network(
                product.imageUrl,
                height: 100,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/placeholder.png',
                  height: 100,
                  fit: BoxFit.contain,
                ))
                : Image.asset(product.imageUrl, height: 100, fit: BoxFit.contain),
          ),
          const Divider(),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(right: 0),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text("Unit Size: ${product.selectedUnit}",
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xffEB7720))),
          Text('₹ ${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.green)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Container(
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
                  items: product.availableSizes.map((ProductSize sizeOption) {
                    return DropdownMenuItem<String>(
                      value: sizeOption.size,
                      child: Text(sizeOption.size),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      product.selectedUnit = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
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