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
import 'package:kisangro/models/kyc_business_model.dart';
// Removed geolocator and geocoding imports as they are no longer used here
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
import '../common/common_app_bar.dart';
import '../home/cart.dart';
import '../home/myorder.dart';
import '../menu/wishlist.dart';
import '../home/noti.dart';
// Import CustomAppBar



class delivery extends StatefulWidget {
  final Product? product; // Optional product for "Buy Now" flow

  const delivery({super.key, this.product});

  @override
  State<delivery> createState() => _deliveryState();
}

class _deliveryState extends State<delivery> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final addressModel = Provider.of<AddressModel>(context); // Listen to AddressModel
    final orderModel = Provider.of<OrderModel>(context, listen: false);
    final kycBusinessDataProvider = Provider.of<KycBusinessDataProvider>(context);

    final bool isBuyNow = widget.product != null;
    final double itemTotal = isBuyNow
        ? (widget.product!.pricePerSelectedUnit ?? 0.0)
        : cart.totalAmount;

    final String displayedName = kycBusinessDataProvider.kycBusinessData?.fullName ?? addressModel.currentName;

    return Scaffold(
      appBar: CustomAppBar( // Integrated CustomAppBar
        title: "Address Details", // Set the title
        showBackButton: true, // Show back button
        showMenuButton: false, // Do NOT show menu button (drawer icon)
        // scaffoldKey is not needed here as there's no drawer
        isMyOrderActive: false, // Not active
        isWishlistActive: false, // Not active
        isNotiActive: false, // Not active
        // showWhatsAppIcon is false by default, matching original behavior
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
                      displayedName,
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    // Display address from AddressModel
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
                    if (isBuyNow && widget.product != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${widget.product!.title} (${widget.product!.selectedUnit}) x 1',
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
              if (!isBuyNow && cart.items.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your cart is empty! Add items to proceed.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (isBuyNow && widget.product == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No product selected! Please try again.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final String newOrderId = DateTime.now().millisecondsSinceEpoch.toString();

              final List<OrderedProduct> orderedProducts = isBuyNow
                  ? [
                OrderedProduct(
                  id: widget.product!.id,
                  title: widget.product!.title,
                  description: widget.product!.subtitle,
                  imageUrl: widget.product!.imageUrl,
                  category: widget.product!.category,
                  unit: widget.product!.selectedUnit,
                  price: widget.product!.pricePerSelectedUnit ?? 0.0,
                  quantity: 1,
                  orderId: newOrderId,
                )
              ]
                  : cart.items
                  .map((item) => item.toOrderedProduct(orderId: newOrderId))
                  .toList();

              final newOrder = Order(
                id: newOrderId,
                products: orderedProducts,
                totalAmount: itemTotal + 90.0,
                orderDate: DateTime.now(),
                status: OrderStatus.pending, // Initial status
                paymentMethod: '', // Will be updated in PaymentPage
              );

              Provider.of<OrderModel>(context, listen: false).addOrder(newOrder);

              // MODIFIED LOGIC: Clear cart if it's a regular cart purchase
              // This ensures the cart is cleared ONLY for multi-item checkouts,
              // not for "Buy Now" single product purchases.
              if (!isBuyNow) {
                cart.clearCart(); // Clear the cart after creating the order
                debugPrint('Cart cleared after order creation for order ID: $newOrderId');
              }

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
