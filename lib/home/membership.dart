import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/payment/payment3.dart'; // Import the PaymentPage from payment3.dart

class MembershipDetailsScreen extends StatelessWidget {
  const MembershipDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text('Membership Details', style: GoogleFonts.poppins(color: Colors.white)),
        actions: const [
          Icon(Icons.inventory_2_outlined, color: Colors.white),
          SizedBox(width: 10),
          Icon(Icons.favorite_border, color: Colors.white),
          SizedBox(width: 10),
          Icon(Icons.notifications_outlined, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/mem.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
              child: Column(
                children: [
                  Text(
                    '“Be A Part Of Something Bigger”',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Text(
                        'Join Our Membership',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.yellow,
                        ),
                      ),
                      Text(
                        'Today!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // Use double.infinity for full width
                    height: 120,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/logo.png', height: 90),
                          const SizedBox(width: 10), // Changed from height to width for horizontal spacing
                          Expanded( // Use Expanded to allow text to take available space
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center, // Center text vertically
                              children: [
                                Text(
                                  'Agri-Products Delivered\nTo Your Door Step',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
                                ),
                                const SizedBox(height: 10), // Adjusted spacing
                                Text(
                                  'Effortless Bulk Ordering With\nExclusive Membership Discounts.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to the PaymentPage to process membership fee
                      // Using a dummy orderId for membership. In a real app,
                      // you might generate a specific order ID for membership purchases.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(orderId: 'MEMBERSHIP_ORDER_ID_ABC'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock_open, color: Colors.white),
                    label: Text('Unlock', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Membership @ ₹ 500',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '2% Membership Discount For Every\nProduct You Purchase',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'For',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    '1 YEAR', // Changed to "1 YEAR" for clarity
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 70), // Maintain spacing at the bottom
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // This button seems to duplicate the "Unlock" button's function.
                        // I'm making it navigate to PaymentPage as well.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentPage(orderId: 'MEMBERSHIP_ORDER_ID_ABC'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Proceed to Payment', // Changed text for clarity
                        style: GoogleFonts.poppins(
                          color: Colors.indigo,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
