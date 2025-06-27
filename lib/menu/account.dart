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
import 'package:kisangro/models/license_provider.dart'; // Import LicenseProvider
import 'package:kisangro/login/licence.dart'; // Import licence1 for "Upload New" button
import 'package:kisangro/common/document_viewer_screen.dart'; // Import DocumentViewerScreen
import 'package:kisangro/models/kyc_business_model.dart';
import 'package:kisangro/login/kyc.dart'; // Import kyc for navigating to KYC edit page

// NEW: Import the VerificationWarningPopup and Helper
import 'package:kisangro/common/verification_warning_popup.dart'; // Adjust path if different

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFEB7720); // Your app's orange theme color
    final licenseProvider = Provider.of<LicenseProvider>(context); // Access LicenseProvider
    final kycBusinessDataProvider = Provider.of<KycBusinessDataProvider>(context); // NEW: Access KycBusinessDataProvider
    final kycData = kycBusinessDataProvider.kycBusinessData; // Get the KYC data

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Transform.translate(
          offset: const Offset(-15, 0),
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
                  context, MaterialPageRoute(builder: (context) => const MyOrder()));
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
                  MaterialPageRoute(builder: (context) => const WishlistPage()));
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
                  context, MaterialPageRoute(builder: (context) => const noti()));
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
                            child: kycData?.shopImageBytes != null
                                ? Image.memory( // Use Image.memory for Uint8List display
                              kycData!.shopImageBytes!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              'assets/profile.png', // Fallback to default profile image if no image is uploaded
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 1,
                        bottom: 0,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Show the VerificationWarningPopup when the edit button is pressed
                            VerificationPopupHelper.show(
                              context,
                              onProceed: () {
                                Navigator.of(context).pop(); // Dismiss the popup
                                // Navigate to KYC edit page (kyc.dart)
                                Navigator.push(context, MaterialPageRoute(builder: (context) => kyc()));
                              },
                              onCancel: () {
                                Navigator.of(context).pop(); // Dismiss the popup
                                // Optional: Show a message if cancelled
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('KYC update cancelled.', style: GoogleFonts.poppins())),
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const SizedBox.shrink(), // Use SizedBox.shrink() to provide an empty widget
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange, // Ensure 'orange' is defined (e.g., const Color(0xffEB7720))
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    _buildIconTextRow(Icons.person_outline, "Full Name", kycData?.fullName ?? "N/A"),
                    _buildIconTextRow(Icons.email_outlined, "Mail Id", kycData?.mailId ?? "N/A"),
                    _buildIconTextRow(CupertinoIcons.phone_circle, "WhatsApp Number", kycData?.whatsAppNumber ?? "N/A"),
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
                    _buildBusinessDetail("Business Name", kycData?.businessName ?? "N/A"),
                    _buildBusinessDetail("GSTIN", kycData?.gstin ?? "N/A"),
                    _buildBusinessDetail("Aadhaar Number (Owner)", kycData?.aadhaarNumber ?? "N/A"),
                    _buildBusinessDetail("PAN Number", kycData?.panNumber ?? "N/A"),
                    _buildBusinessDetail("Nature Of Core Business", kycData?.natureOfBusiness ?? "N/A"),
                    _buildBusinessDetail("Business Contact Number", kycData?.businessContactNumber ?? "N/A"),
                    // Conditionally display Business Address
                    if (kycData?.isGstinVerified == true && (kycData?.businessAddress?.isNotEmpty ?? false))
                      _buildBusinessDetail("Business Address", kycData?.businessAddress ?? "N/A"),
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
                  // --- MODIFIED HERE: Show popup before navigating to licence1() ---
                  VerificationPopupHelper.show(
                    context,
                    onProceed: () {
                      Navigator.of(context).pop(); // Dismiss the popup
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => licence1()), // Go to licence1 to select type
                      );
                    },
                    onCancel: () {
                      Navigator.of(context).pop(); // Dismiss the popup
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('License update cancelled.', style: GoogleFonts.poppins())),
                      );
                    },
                  );
                  // --- END MODIFICATION ---
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
                  // --- MODIFIED HERE: Show popup before navigating to licence1() ---
                  VerificationPopupHelper.show(
                    context,
                    onProceed: () {
                      Navigator.of(context).pop(); // Dismiss the popup
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => licence1()), // Go to licence1 to select type
                      );
                    },
                    onCancel: () {
                      Navigator.of(context).pop(); // Dismiss the popup
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('License update cancelled.', style: GoogleFonts.poppins())),
                      );
                    },
                  );
                  // --- END MODIFICATION ---
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
            Text('License Number: ${licenseNumber}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
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
