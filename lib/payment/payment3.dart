import 'package:flutter/material.dart';
import 'package:kisangro/home/bottom.dart';
import 'package:kisangro/home/cart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/models/address_model.dart'; // Import AddressModel
import 'package:intl/intl.dart';
import 'package:kisangro/home/rewards_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final bool isMembershipPayment; // Flag to distinguish payment type

  const PaymentPage({
    super.key,
    required this.orderId,
    this.isMembershipPayment = false, // Default to false
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMode = '';
  Map<String, dynamic>? selectedUpiApp;
  bool _applyRewardPoints = true;
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
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xffEB7720)),
            const SizedBox(height: 16),
            Text(
              'Processing Payment...',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            orderId: widget.orderId,
            isMembershipPayment: widget.isMembershipPayment, // Pass the flag
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final addressModel = Provider.of<AddressModel>(context); // Listen to AddressModel
    final totalAmount = cart.totalAmount + 90.0; // Assuming 90.0 is a fixed delivery fee for calculation here.

    // Use name from AddressModel, fallback if AddressModel's name is default
    final String displayedName = addressModel.currentName.isNotEmpty && addressModel.currentName != "Smart (name)"
        ? addressModel.currentName
        : 'No Name Provided';


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
              SizedBox(
                width: double.infinity,
                height: 1,
                child: CustomPaint(
                  painter: DottedLinePainter(),
                ),
              ),
              const SizedBox(height: 16),
              // Delivery Address Section - Now includes name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Address',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffEB7720),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // NEW: Display the name at the top of the address
                    Text(
                      displayedName, // Use the resolved name
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4), // Small spacing after name
                    Text(
                      addressModel.currentAddress.isNotEmpty
                          ? addressModel.currentAddress
                          : 'No address provided',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pincode: ${addressModel.currentPincode}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
              // NEW: Show unit value (total items) from cart
              Text(
                '${cart.totalItemCount} Items from your cart', // Displays the count of unique items
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 1,
                child: CustomPaint(
                  painter: DottedLinePainter(),
                ),
              ),
              const SizedBox(height: 20),
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
              Text(
                'Choose Payment Mode',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select UPI App',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
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
                          color: isSelected
                              ? const Color(0xffEB7720)
                              : Colors.grey.shade300,
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
                    borderSide:
                    const BorderSide(color: Color(0xffEB7720), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEB7720)),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Other Modes',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
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
                      color: selectedPaymentMode == 'CARD'
                          ? const Color(0xffEB7720)
                          : Colors.grey.shade300,
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
                      color: selectedPaymentMode == 'NETBANKING'
                          ? const Color(0xffEB7720)
                          : Colors.grey.shade300,
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
                            child:
                            const Icon(Icons.account_balance, color: Colors.grey),
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
              _handlePaymentSuccess();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pay Now',
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
}

class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;
  final bool isMembershipPayment; // Receive the flag

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    this.isMembershipPayment = false, // Default to false
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHomeWithDelay();
  }

  Future<void> _navigateToHomeWithDelay() async {
    // Simulate some post-payment processing
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // If it's a membership payment, set the flag and navigate to home without popup
    if (widget.isMembershipPayment) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isMembershipActive', true); // Set membership as active
      await prefs.setBool('showRewardsPopupOnNextHomeLoad', false); // Ensure no reward popup for membership
      debugPrint('Membership payment successful. Flag set to true. Navigating to home.');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Bot(initialIndex: 0, showRewardsPopup: false), // Explicitly set showRewardsPopup to false
        ),
            (Route<dynamic> route) => false,
      );
    } else {
      // For regular product purchases, clear the cart and then show the reward popup on the next home load
      final cart = Provider.of<CartModel>(context, listen: false); // Access CartModel
      await cart.clearCart(); // Clear the cart after successful payment
      debugPrint('Cart cleared after successful product payment for order ID: ${widget.orderId}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('showRewardsPopupOnNextHomeLoad', true);
      debugPrint('Product payment successful. Reward popup flag set to true. Navigating to home.');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Bot(initialIndex: 0, showRewardsPopup: true), // Explicitly set showRewardsPopup to true
        ),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Color(0xffEB7720), size: 60),
            const SizedBox(height: 20),
            Text("Payment Successful!",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Order ID: ${widget.orderId}",
                style: GoogleFonts.poppins(fontSize: 16)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Color(0xffEB7720)),
            const SizedBox(height: 20),
            Text(
              "Redirecting to home... ",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
