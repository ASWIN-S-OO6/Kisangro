import 'package:flutter/material.dart';
import 'package:kisangro/home/bottom.dart';
import 'package:kisangro/payment/payment2.dart'; // Assuming this is payment step 2
import 'package:kisangro/payment/payment3.dart'; // Import PaymentPage from payment3.dart
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/order_model.dart'; // Import Order and OrderModel
import 'package:kisangro/models/address_model.dart';

import '../home/cart.dart'; // NEW: Import AddressModel

class delivery extends StatelessWidget { // Changed back to StatelessWidget as AddressModel handles state
  const delivery({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context); // Listen to CartModel changes
    final addressModel = Provider.of<AddressModel>(context); // NEW: Listen to AddressModel

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
            Navigator.pop(context); // Go back to the previous screen (Cart)
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle notification icon tap
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
              // Handle wishlist icon tap
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
              // Handle cart icon tap - navigate to cart page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cart()), // CHANGED TO const cart()
              );
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
                  Text('₹ ${cart.totalAmount.toStringAsFixed(2)}',
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
                      addressModel.currentName, // Display name from model
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      addressModel.currentAddress, // Display address from model
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    Text(
                      'Pincode: ${addressModel.currentPincode}', // Display pincode from model
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
                        'Item Total', '₹${cart.totalAmount.toStringAsFixed(2)}'),
                    _buildPriceRow('Delivery Fee', '₹90.00'), // Fixed delivery fee
                    _buildPriceRow('Discount', '-₹0.00', isDiscount: true), // Example
                    const Divider(height: 20, thickness: 1),
                    _buildPriceRow(
                        'Grand Total', '₹${(cart.totalAmount + 90.0).toStringAsFixed(2)}', // Example calculation
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total:',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[600])),
                  Text('₹${(cart.totalAmount + 90.0).toStringAsFixed(2)}', // Example grand total
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffEB7720))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEB7720),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    if (cart.items.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your cart is empty! Add items to proceed.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Check if address details are set
                    if (addressModel.currentAddress == "D/no: 123, abc street, rrr nagar, near ppp, Coimbatore." ||
                        addressModel.currentPincode == "641612") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please update your delivery address before proceeding.', style: GoogleFonts.poppins()),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }


                    final orderModel = Provider.of<OrderModel>(context, listen: false);
                    // Generate a unique order ID for this order
                    final String newOrderId = DateTime.now().millisecondsSinceEpoch.toString();

                    final newOrder = Order(
                      id: newOrderId, // Assign the unique ID
                      products: cart.items.map((item) => item.toOrderedProduct()).toList(), // Correctly map CartItem to OrderedProduct
                      totalAmount: cart.totalAmount + 90.0, // Include shipping in total
                      orderDate: DateTime.now(),
                      status: OrderStatus.pending, // Use the now existing 'pending' status
                    );

                    orderModel.addOrder(newOrder); // Add to the OrderModel
                    // DO NOT clear cart here. Cart will be cleared upon successful payment (SplashScreen2)

                    // Navigate to PaymentPage (from payment3.dart) and pass the new order ID
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage(orderId: newOrderId)));
                  },
                  child: Text("Proceed",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                ),
              ),
            ),
          ],
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
