import 'package:flutter/material.dart';
import 'package:kisangro/home/myorder.dart'; // Ensure MyOrder is imported for navigation
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import Provider to access OrderModel
import 'package:kisangro/models/order_model.dart'; // Import your OrderModel (which now contains OrderStatus and OrderModel)

// IMPORTANT: Removed void main() and MyApp as this screen is part of a larger app.
// It should be navigated to from MyOrder, which passes the orderId.

class CancellationStep1Page extends StatefulWidget {
  final String orderId; // New: Accept orderId

  const CancellationStep1Page({super.key, required this.orderId}); // Require orderId

  @override
  State<CancellationStep1Page> createState() => _CancellationStep1PageState();
}

class _CancellationStep1PageState extends State<CancellationStep1Page> {
  String selectedReason = 'Wrong Product Ordered';
  final TextEditingController otherController = TextEditingController();

  List<String> reasons = [
    'Wrong Product Ordered',
    'Wrong Quantity Of Product Ordered',
    'Changed Delivery Address',
    'Price Too High',
    'Changed My Mind',
    'Prefer to Buy In-Store',
    'Other Reasons'
  ];

  @override
  void dispose() {
    otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 'widget' is correctly available here within the build method.
    // The orderId is accessed via widget.orderId.
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    "Order Cancellation",
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 270),
                child: Text(
                  "step 1/2",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Cancellation Reason',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20), // Adjusted to symmetric
                child: Container(
                  width: double.infinity, // Made responsive
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...reasons.map((reason) {
                        return RadioListTile<String>(
                          title: Text(
                            reason,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          value: reason,
                          groupValue: selectedReason,
                          onChanged: (value) {
                            setState(() {
                              selectedReason = value!;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          activeColor: const Color(0xffEB7720), // Added active color for radio button
                        );
                      }).toList(),
                      if (selectedReason == "Other Reasons")
                        Padding(
                          padding: const EdgeInsets.only(left: 50, right: 30, bottom: 30),
                          child: TextField(
                            controller: otherController,
                            decoration: const InputDecoration(
                              hintText: "Type Here...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 50, bottom: 50),
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      print('DEBUG: CancellationStep1Page: Navigating to Step2 with orderId: ${widget.orderId}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CancellationStep2Page(orderId: widget.orderId), // Pass orderId using widget.orderId
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      backgroundColor: const Color(0xffEB7720),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Proceed', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CancellationStep2Page extends StatefulWidget { // Changed to StatefulWidget
  final String orderId; // New: Accept orderId

  const CancellationStep2Page({super.key, required this.orderId}); // Require orderId

  @override
  State<CancellationStep2Page> createState() => _CancellationStep2PageState();
}

class _CancellationStep2PageState extends State<CancellationStep2Page> { // State class for CancellationStep2Page
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController holderNameController = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers when the widget is removed from the widget tree
    bankNameController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    holderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  "Order Cancellation",
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 270),
              child: Text(
                "step 2/2", // Corrected step number
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Enter Bank Details',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '(Note: The cancellation amount will be refunded to your bank account shortly. So enter bank details carefully)',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: bankNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Bank name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xffEB7720)), borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: accountNumberController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Bank Account number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xffEB7720)), borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: ifscController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'IFSC code',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xffEB7720)), borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: holderNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Account holder name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xffEB7720)), borderRadius: BorderRadius.circular(8)),
                ),
                style: GoogleFonts.poppins(),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 50, bottom: 50),
              child: SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Basic validation
                    if (bankNameController.text.isEmpty ||
                        accountNumberController.text.isEmpty ||
                        ifscController.text.isEmpty ||
                        holderNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all bank details.', style: GoogleFonts.poppins())),
                      );
                      return;
                    }

                    // Get OrderModel and update the status
                    final orderModel = Provider.of<OrderModel>(context, listen: false);
                    print('DEBUG: CancellationStep2Page: Calling updateOrderStatus for orderId: ${widget.orderId} with status: cancelled');
                    orderModel.updateOrderStatus(widget.orderId, OrderStatus.cancelled); // Use widget.orderId passed to this widget

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order ${widget.orderId} cancelled successfully!', style: GoogleFonts.poppins())),
                    );

                    // Navigate back to MyOrder and clear the cancellation pages from stack
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrder()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    backgroundColor: const Color(0xffEB7720),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Verify & Submit', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
