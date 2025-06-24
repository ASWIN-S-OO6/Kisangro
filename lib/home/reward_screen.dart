import 'dart:async'; // Still might be useful for general screen logic, or remove if not used elsewhere
import 'dart:typed_data'; // Needed for Uint8List to display image bytes (for profile image in main body)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart'; // For dotted borders around profile image (in main body)
import 'package:provider/provider.dart'; // For state management (accessing KycImageProvider in main body)
// Removed flutter_rating_bar and shared_preferences imports as their usage is now solely within CustomDrawer

// Imports for app navigation (these are for AppBar actions or general screen navigation, NOT drawer specific)
import 'package:kisangro/home/membership.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:kisangro/home/categories.dart'; // Assuming Categories screen is your main home tab
import 'package:kisangro/home/cart.dart'; // Assuming CartScreen exists

// NEW: Import the CustomDrawer
import 'package:kisangro/home/custom_drawer.dart';

import '../models/kyc_image_provider.dart'; // This is the shared drawer

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for Scaffold to open drawer

  // Removed: _rating, _reviewController, maxChars as they are now handled by CustomDrawer
  // Removed: _showLogoutDialog and showComplaintDialog as they are now in CustomDrawer

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Removed: _reviewController.dispose() as it's no longer here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign scaffold key to control drawer
      backgroundColor: const Color(0xFFFFF3E9),
      // *** LINKING THE CUSTOM DRAWER HERE ***
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7A00),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); // Open drawer on menu icon tap
          },
        ),
        title: Text(
          "Reward Points",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrder()));
            },
            icon: Image.asset('assets/box.png', height: 24, width: 24, color: Colors.white),
          ),
          const SizedBox(width: 5),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage()));
            },
            icon: Image.asset('assets/heart.png', height: 24, width: 24, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const noti()));
              },
              icon: Image.asset(
                'assets/noti.png',
                height: 24,
                width: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Profile Card (This part uses KycImageProvider, so it remains)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Profile Image (from KYC)
                  DottedBorder(
                    borderType: BorderType.Circle,
                    color: Colors.red,
                    strokeWidth: 2,
                    dashPattern: const [6, 3],
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30), // Match CircleAvatar radius
                        child: Consumer<KycImageProvider>(
                          builder: (context, kycImageProvider, child) {
                            final Uint8List? kycImageBytes = kycImageProvider.kycImageBytes;
                            return kycImageBytes != null
                                ? Image.memory(
                              kycImageBytes,
                              width: 60, // Match CircleAvatar radius * 2
                              height: 60, // Match CircleAvatar radius * 2
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              'assets/profile.png', // Fallback
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi Smart!",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "98765 43210",
                        style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xffEB7720)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/logo.png', // Updated asset path
                    height: 40,
                    width: 40,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Wings GIF
            Image.asset(
              'assets/wings.gif',
              height: 100,
            ),

            const SizedBox(height: 10),
            Text(
              "Your Reward Points",
              style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xffEB7720)),
            ),
            const SizedBox(height: 10),
            Text(
              "500", // Hardcoded as per reference
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xffEB7720),
              ),
            ),

            const SizedBox(height: 20),

            // Conversion Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffEB7720),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "100 Points = 100 ₹",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            // Reward Points Text + Verified GIF
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "Get Reward Points\nFor Every\nPurchase You Make",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xffEB7720),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  'assets/verified.gif',
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              "Reward Conversion Ratio",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xffEB7720),
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "1% Of Total Amount\nBefore Adding GST",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xffEB7720),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
