import 'package:flutter/cupertino.dart'; // For CupertinoIcons, if used
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:dotted_border/dotted_border.dart'; // For dotted borders
import 'package:kisangro/home/myorder.dart'; // Assuming this page exists
import 'package:kisangro/home/noti.dart'; // Assuming this page exists
import 'package:kisangro/menu/wishlist.dart'; // Assuming this page exists
import 'package:provider/provider.dart'; // For state management
import 'package:kisangro/models/kyc_image_provider.dart'; // Your custom KYC image provider
import 'dart:typed_data'; // Essential for Uint8List, which holds raw image data

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFEB7720); // Your app's orange theme color
    final backgroundColor = const Color(0xFFFFF3E0); // Your app's background color

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: orange,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Transform.translate(
          offset: Offset(-15, 0),
          child: Text(
            "My Account",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyOrder()));
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
                  MaterialPageRoute(builder: (context) => WishlistPage()));
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
                  context, MaterialPageRoute(builder: (context) => noti()));
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Stack(
                  children: [
                    DottedBorder(
                      borderType: BorderType.Circle,
                      color: Colors.red,
                      strokeWidth: 2,
                      dashPattern: const [6, 3],
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          // Use Consumer to listen for changes in KycImageProvider
                          // and display the image dynamically.
                          child: Consumer<KycImageProvider>(
                            builder: (context, kycImageProvider, child) {
                              final Uint8List? kycImageBytes = kycImageProvider.kycImageBytes; // Get the image bytes from the provider
                              return kycImageBytes != null
                                  ? Image.memory( // Use Image.memory for Uint8List display
                                      kycImageBytes,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/profile.png', // Fallback to default profile image if no image is uploaded
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      bottom: 0,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Action for editing details (e.g., navigate to edit profile page)
                        },
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 16),
                        label: Text(
                          "Edit Details",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Primary Details",
                      style: GoogleFonts.poppins(
                          color: orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildIconTextRow(
                      Icons.person_outline, "Full Name", "Smart Global"),
                  _buildIconTextRow(Icons.email_outlined, "Mail Id",
                      "smartg123@gmail.com"),
                  _buildIconTextRow(CupertinoIcons.phone_circle,
                      "WhatsApp Number", "+91 98765 43210"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Business Details",
                      style: GoogleFonts.poppins(
                          color: orange,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildBusinessDetail("Business Name", "Abc farms shop"),
                  _buildBusinessDetail("GSTIN", "8453CACA5A"),
                  _buildBusinessDetail(
                      "Aadhaar Number (Owner)", "9999 5555 4444"),
                  _buildBusinessDetail("PAN Number", "ABC1237B"),
                  _buildBusinessDetail(
                      "Nature Of Core Business", "Farm products selling"),
                  _buildBusinessDetail(
                      "Business Contact Number", "+91 98765 43210"),
                  _buildBusinessDetail("Business Address",
                      "102, Vellakar St, Ayyanbakkam, Chennai, Tamil Nadu 600-095"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "License Details",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: orange,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLicenseCard(context,
                index: 1,
                title: "Pesticide",
                imagePath: 'assets/sample_doc.png'),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildLicenseCard(context,
                index: 2,
                title: "Insecticide",
                imagePath: 'assets/sample_doc.png'),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a row with an icon, label, and value for primary details.
  Widget _buildIconTextRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(
                      color: Colors.black54, fontSize: 14)),
              Text(value,
                  style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper method to build a row for business details with a checkmark.
  Widget _buildBusinessDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        color: Colors.black54, fontSize: 14)),
                Text(value,
                    style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build a license card with an image and upload button.
  Widget _buildLicenseCard(BuildContext context,
      {required int index, required String title, required String imagePath}) {
    const orange = Color(0xFFEB7720);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$index. $title",
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Stack(
            children: [
              Center(
                child: Container(
                  width: 160,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Image.asset( // Display static license image
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Positioned(
                right: 35,
                top: 5,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: Icon(Icons.verified, color: Colors.blue, size: 24),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Action for uploading new license (e.g., navigate to upload screen)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                "Upload New",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
