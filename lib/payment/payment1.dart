import 'package:flutter/material.dart';
import 'package:kisangro/home/bottom.dart';
import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/payment/payment2.dart';
import 'package:kisangro/payment/payment3.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/models/address_model.dart';
import '../home/cart.dart';
import '../home/myorder.dart';
import '../menu/wishlist.dart';
import '../home/noti.dart';

class delivery extends StatelessWidget {
  final Product? product; // Optional product for "Buy Now" flow

  const delivery({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final addressModel = Provider.of<AddressModel>(context);
    final orderModel = Provider.of<OrderModel>(context, listen: false);

    // Determine if we're in "Buy Now" mode (product is provided)
    final bool isBuyNow = product != null;
    // Calculate total amount based on mode
    final double itemTotal = isBuyNow
        ? (product!.pricePerSelectedUnit ?? 0.0)
        : cart.totalAmount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        centerTitle: false,
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            "Address Details",
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrder()));
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage()));
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const noti()));
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
      body: Container(
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(thickness: 1),
              Row(
                children: [
                  Text('Total Amount:',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('₹ ${itemTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(thickness: 1),
              Text(
                'Step 2/3',
                style: GoogleFonts.poppins(
                    color: const Color(0xffEB7720), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delivery Address',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const delivery2()),
                            );
                          },
                          child: Text('Change',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xffEB7720),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      addressModel.currentName,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      addressModel.currentAddress,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    Text(
                      'Pincode: ${addressModel.currentPincode}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Text('Deliverable By 11 Dec, 2024',
                        style: GoogleFonts.poppins(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Item Summary',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (isBuyNow && product != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${product!.title} (${product!.selectedUnit}) x 1',
                                style: GoogleFonts.poppins(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text('₹${itemTotal.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.title} (${item.selectedUnit}) x ${item.quantity}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text('₹${item.totalPrice.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(fontSize: 14)),
                              ],
                            ),
                          );
                        },
                      ),
                    const Divider(height: 20, thickness: 1),
                    _buildPriceRow(
                        'Item Total', '₹${itemTotal.toStringAsFixed(2)}'),
                    _buildPriceRow('Delivery Fee', '₹90.00'),
                    _buildPriceRow('Discount', '-₹0.00', isDiscount: true),
                    const Divider(height: 20, thickness: 1),
                    _buildPriceRow(
                        'Grand Total', '₹${(itemTotal + 90.0).toStringAsFixed(2)}',
                        isGrandTotal: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
              // Allow proceeding if either a product is provided (Buy Now) or cart has items
              if (!isBuyNow && cart.items.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your cart is empty! Add items to proceed.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (isBuyNow && product == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No product selected! Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Check if address details are set
              if (addressModel.currentAddress ==
                  "D/no: 123, abc street, rrr nagar, near ppp, Coimbatore." ||
                  addressModel.currentPincode == "641612") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Please update your delivery address before proceeding.',
                        style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Generate a unique order ID
              final String newOrderId =
              DateTime.now().millisecondsSinceEpoch.toString();

              // Create ordered products based on mode
              final List<OrderedProduct> orderedProducts = isBuyNow
                  ? [
                OrderedProduct(
                  id: product!.id,
                  title: product!.title,
                  description: product!.subtitle,
                  imageUrl: product!.imageUrl,
                  category: product!.category,
                  unit: product!.selectedUnit,
                  price: product!.pricePerSelectedUnit ?? 0.0,
                  quantity: 1, // Default quantity for Buy Now
                  orderId: newOrderId,
                )
              ]
                  : cart.items
                  .map((item) => item.toOrderedProduct(orderId: newOrderId))
                  .toList();

              final newOrder = Order(
                id: newOrderId,
                products: orderedProducts,
                totalAmount: itemTotal + 90.0, // Include delivery fee
                orderDate: DateTime.now(),
                status: OrderStatus.pending,
                paymentMethod: '',
              );

              orderModel.addOrder(newOrder);

              // Navigate to PaymentPage
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentPage(orderId: newOrderId)));
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
                const Icon(Icons.arrow_forward_ios_outlined,
                    color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isDiscount = false, bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isGrandTotal ? 16 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
              color: isGrandTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isGrandTotal ? 18 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount
                  ? Colors.red
                  : (isGrandTotal ? const Color(0xffEB7720) : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}