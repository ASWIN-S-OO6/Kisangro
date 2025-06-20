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
  String selectedPaymentMode = '';
  Map<String, dynamic>? selectedUpiApp;
  bool _applyRewardPoints = true; // State for reward points checkbox
  final TextEditingController _upiController = TextEditingController();

  List<Map<String, dynamic>> upiApps = [
    {'name': 'Google Pay', 'image': 'assets/gpay.png'},
    {'name': 'Phone Pe', 'image': 'assets/phonepay.png'},
    {'name': 'Paytm', 'image': 'assets/paytm.png'},
    {'name': 'Amazon Pay', 'image': 'assets/amzpay.png'},
    {'name': 'Apple Pay', 'image': 'assets/applepay.png'},
  ];

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess() {
    // Navigate to payment success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(orderId: widget.orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final totalAmount = cart.totalAmount + 90.0; // Including delivery fee

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        centerTitle: false,
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            "Payment Method",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
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
              // Dotted line
              Container(
                width: double.infinity,
                height: 1,
                child: CustomPaint(
                  painter: DottedLinePainter(),
                ),
              ),
              const SizedBox(height: 16),

              // Total Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '₹ ${totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Items count
              Text(
                '${cart.totalItemCount} Items from your cart',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              // Dotted line
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 1,
                child: CustomPaint(
                  painter: DottedLinePainter(),
                ),
              ),
              const SizedBox(height: 20),

              // Reward Points Section
              Row(
                children: [
                  Text(
                    'Your Reward Points',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xffEB7720),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '500',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: const Color(0xffEB7720),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/coin.gif',
                    width: 30,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 30,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reward Points Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _applyRewardPoints,
                    onChanged: (value) {
                      setState(() {
                        _applyRewardPoints = value ?? false;
                      });
                    },
                    activeColor: const Color(0xffEB7720),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Add Reward Points To Your Purchase',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xffEB7720),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Choose Payment Mode
              Text(
                'Choose Payment Mode',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Select UPI App
              Text(
                'Select UPI App',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // UPI Apps Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: upiApps.length,
                itemBuilder: (context, index) {
                  final app = upiApps[index];
                  final isSelected = selectedUpiApp == app;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedUpiApp = app;
                        selectedPaymentMode = 'UPI';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xffEB7720) : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            app['image'],
                            height: 40,
                            width: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.payment, color: Colors.grey),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            app['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // UPI ID Input
              TextField(
                controller: _upiController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  hintText: 'Type or paste UPI Id here',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEB7720)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEB7720), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEB7720)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 30),

              // Other Modes
              Text(
                'Other Modes',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Debit/Credit Card Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPaymentMode = 'CARD';
                    selectedUpiApp = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedPaymentMode == 'CARD' ? const Color(0xffEB7720) : Colors.grey.shade300,
                      width: selectedPaymentMode == 'CARD' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'CARD',
                        groupValue: selectedPaymentMode,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMode = value!;
                            selectedUpiApp = null;
                          });
                        },
                        activeColor: const Color(0xffEB7720),
                      ),
                      Image.asset(
                        'assets/debit.png',
                        height: 30,
                        width: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 30,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.credit_card, color: Colors.grey),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Debit/Credit Card',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Net Banking Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPaymentMode = 'NETBANKING';
                    selectedUpiApp = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedPaymentMode == 'NETBANKING' ? const Color(0xffEB7720) : Colors.grey.shade300,
                      width: selectedPaymentMode == 'NETBANKING' ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'NETBANKING',
                        groupValue: selectedPaymentMode,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMode = value!;
                            selectedUpiApp = null;
                          });
                        },
                        activeColor: const Color(0xffEB7720),
                      ),
                      Image.asset(
                        'assets/netbanking.png',
                        height: 30,
                        width: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 30,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.account_balance, color: Colors.grey),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Net Banking',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
              // Validate payment selection
              if (selectedPaymentMode.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select a payment method', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (selectedPaymentMode == 'UPI' && selectedUpiApp == null && _upiController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select a UPI app or enter UPI ID', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Process payment
              _handlePaymentSuccess();
            },
            child: Text(
              'Proceed',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Payment Success Screen
class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;

  const PaymentSuccessScreen({super.key, required this.orderId});

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
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
      orderModel.updateOrderStatus(widget.orderId, OrderStatus.confirmed);
      debugPrint('Order ${widget.orderId} status updated to CONFIRMED after payment.');

      final cartModel = Provider.of<CartModel>(context, listen: false);
      cartModel.clearCart(); // Clear the cart after the payment is successful

      // Navigate to the main home screen (Bot) and clear the entire stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Bot(initialIndex: 0)),
            (Route<dynamic> route) => false,
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
            const CircularProgressIndicator(color: Color(0xffEB7720)),
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

// Custom painter for dotted lines
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double currentX = 0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dashWidth, 0),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}