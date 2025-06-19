import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import "cancel1.dart";

class BookedOrdersScreen extends StatelessWidget {
  const BookedOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF1E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF37021),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booked',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFCD8BD),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: 'Note: You can cancel or modify your order within ',
                            style: GoogleFonts.poppins()),
                        TextSpan(
                            text: '2 hour ',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: 'from the time you booked.',
                            style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Delivery Address:', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('Smart (name)', style: GoogleFonts.poppins()),
                  Text('D/no: 123, abc street, rrr nagar, near ppp, Coimbatore.', style: GoogleFonts.poppins()),
                  Text('Pin-code: 641612', style: GoogleFonts.poppins()),
                  const SizedBox(height: 10),
                  Text('Expected Delivery: 20 Apr 2024', style: GoogleFonts.poppins()),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('2 Items', style: GoogleFonts.poppins()),
                  ),
                  const Spacer(),
                  Text('Ordered On: 03/11/2024  2:40 pm', style: GoogleFonts.poppins(fontSize: 13)),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 120,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/oxyfen.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('OXYFEN', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Oxyflourfen 23.5 % EC', style: GoogleFonts.poppins()),
                                  const SizedBox(height: 4),
                                  Text('Unit Size: 12 pieces', style: GoogleFonts.poppins(fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text('₹ 1550/piece', style: GoogleFonts.poppins(color: Colors.orange, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('Ordered Units: 02', style: GoogleFonts.poppins(fontSize: 13)),
                                  Text('Total Cost: ₹ 37,200', style: GoogleFonts.poppins(fontSize: 13, color: Colors.orange)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Column(
                            children: [
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF37021),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('1 L', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Order ID: 1234567', style: GoogleFonts.poppins(fontSize: 12)),
                    ),
                    const Divider(thickness: 1),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CancellationStep1Page(orderId: '',)),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Cancel Order', style: GoogleFonts.poppins(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFFF8C2F)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Modify Order', style: GoogleFonts.poppins(color: Color(0xFFFF8C2F))),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
