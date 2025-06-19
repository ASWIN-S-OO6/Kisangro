import 'package:flutter/material.dart';
import 'package:kisangro/home/bottom.dart'; // Assuming this is your main navigation screen
import 'package:kisangro/home/cart.dart'; // Import if you navigate to cart from here (though not directly used in this snippet)
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/order_model.dart'; // Import OrderModel and OrderStatus
import 'package:kisangro/models/address_model.dart'; // NEW: Import AddressModel
import 'package:intl/intl.dart'; // For date formatting if needed (though not directly used in this snippet, good practice to keep)

class PaymentPage extends StatefulWidget {
  final String orderId; // Receive the orderId from previous screen

  const PaymentPage({super.key, required this.orderId});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedOtherMode = '';
  Map<String, dynamic>? selectedUpiApp;
  bool _applyRewardPoints = true; // State for reward points checkbox

  List<Map<String, dynamic>> upiApps = [
    {'name': 'Google Pay', 'image': 'assets/gpay.png'},
    {'name': 'Phone Pe', 'image': 'assets/phonepay.png'},
    {'name': 'Paytm', 'image': 'assets/paytm.png'},
    {'name': 'Amazon Pay', 'image': 'assets/amazonpay.png'},
  ];

  @override
  void initState() {
    super.initState();
    _handlePaymentSuccess();
  }

  void _handlePaymentSuccess() {
    // We use a Future.delayed to simulate a network call/processing time
    // and then update the order status and navigate.
    Future.delayed(const Duration(seconds: 3), () {
      final orderModel = Provider.of<OrderModel>(context, listen: false);

      // IMPORTANT: Update the order status to confirmed after successful payment
      orderModel.updateOrderStatus(widget.orderId, OrderStatus.confirmed); // Using the now existing 'confirmed' status
      debugPrint('Order ${widget.orderId} status updated to CONFIRMED after payment.');

      final cartModel = Provider.of<CartModel>(context, listen: false);
      cartModel.clearCart(); // Clear the cart after the payment is successful

      // Navigate to the main home screen (Bot) and clear the entire stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Bot(initialIndex: 0)), // Go to the first tab (Home)
        (Route<dynamic> route) => false, // Clears all previous routes
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xffEB7720), size: 60),
            const SizedBox(height: 20),
            Text("Payment Successful!", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Order ID: ${widget.orderId}", style: GoogleFonts.poppins(fontSize: 16)),
            const SizedBox(height: 20),
            // You can add more details or a loading indicator if the delay is longer
            CircularProgressIndicator(color: Color(0xffEB7720)),
            const SizedBox(height: 20),
            Text(
              "Redirecting to home...",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
