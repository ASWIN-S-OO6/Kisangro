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
import 'package:kisangro/models/license_provider.dart'; // NEW: Import LicenseProvider
import 'package:kisangro/login/licence.dart'; // Import licence1 for "Upload New" button
import 'package:kisangro/common/document_viewer_screen.dart'; // NEW: Import DocumentViewerScreen

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFEB7720); // Your app's orange theme color
    // Removed backgroundColor, as we will use a gradient for the body
    final licenseProvider = Provider.of<LicenseProvider>(context); // Access LicenseProvider

    return Scaffold(
      // Removed direct backgroundColor from Scaffold to allow gradient in body
      appBar: AppBar(
        backgroundColor: orange,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Transform.translate(
          offset: const Offset(-15, 0), // Added const
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
                  context, MaterialPageRoute(builder: (context) => const MyOrder())); // Added const
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
                  MaterialPageRoute(builder: (context) => const WishlistPage())); // Added const
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
                  context, MaterialPageRoute(builder: (context) => const noti())); // Added const
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
      body: Container( // Added Container for the gradient background
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)], // Consistent theme
          ),
        ),
        child: SingleChildScrollView(
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
              // Display Pesticide License
              _buildLicenseCard(
                context,
                index: 1,
                title: "Pesticide",
                licenseData: licenseProvider.pesticideLicense, // Pass pesticide data
                onUploadNew: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => licence1()), // Go to licence1 to select type
                  );
                },
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              // Display Fertilizer License
              _buildLicenseCard(
                context,
                index: 2,
                title: "Fertilizer", // Changed from "Insecticide" to "Fertilizer" as per context
                licenseData: licenseProvider.fertilizerLicense, // Pass fertilizer data
                onUploadNew: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => licence1()), // Go to licence1 to select type
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
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

  /// Helper method to build a license card with dynamic data.
  Widget _buildLicenseCard(BuildContext context,
      {required int index,
        required String title,
        LicenseData? licenseData, // Make licenseData nullable
        required VoidCallback onUploadNew}) {
    const orange = Color(0xFFEB7720);
    bool isUploaded = licenseData?.imageBytes != null;
    String licenseNumber = licenseData?.licenseNumber ?? 'N/A';
    String expiryDisplay = licenseData?.displayDate ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$index. $title License", // Updated title for clarity
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          GestureDetector( // Added GestureDetector to make the container tappable
            onTap: isUploaded
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentViewerScreen(
                    documentBytes: licenseData!.imageBytes,
                    isImage: licenseData.isImage,
                    title: '$title License Document',
                  ),
                ),
              );
            }
                : null, // Disable tap if no document is uploaded
            child: Center(
              child: Container(
                width: 160,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, // Background for image container
                  border: Border.all(color: isUploaded ? Colors.green : Colors.black26), // Green border if uploaded
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isUploaded
                    ? (licenseData!.isImage
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(
                    licenseData.imageBytes!,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Center(
                    child: Icon(Icons.picture_as_pdf, color: orange, size: 60)))
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.grey[400], size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'No document uploaded',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Display License Number and Expiry Date
          if (isUploaded) ...[
            Text('License Number: $licenseNumber', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Expiry Date: ${licenseData!.noExpiry ? 'Permanent' : expiryDisplay}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
          ],
          Center(
            child: ElevatedButton(
              onPressed: onUploadNew, // Use the provided callback for "Upload New"
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                isUploaded ? "Re-upload" : "Upload Now", // Change button text based on upload status
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
