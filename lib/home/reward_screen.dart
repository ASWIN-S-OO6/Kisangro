import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/home/membership.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:kisangro/home/categories.dart';
import 'package:kisangro/home/cart.dart';
// Import your CustomDrawer and CustomAppBar

import 'package:kisangro/models/kyc_business_model.dart';
import 'package:kisangro/models/kyc_image_provider.dart';
import 'package:kisangro/home/bottom.dart';

import '../common/common_app_bar.dart';
import 'custom_drawer.dart'; // NEW: Import Bot for navigation


class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the KycBusinessDataProvider
    final kycBusinessProvider = Provider.of<KycBusinessDataProvider>(context);
    final kycData = kycBusinessProvider.kycBusinessData;

    // Use KYC data for name and WhatsApp number, with "N/A" fallback
    final String displayName = kycData?.fullName?.isNotEmpty == true
        ? "Hi ${kycData!.fullName!.split(' ').first}!"
        : "N/A";
    final String displayWhatsAppNumber = kycData?.whatsAppNumber?.isNotEmpty == true
        ? kycData!.whatsAppNumber!
        : "N/A";

    return PopScope( // <--- PopScope remains for back gesture control
      canPop: false, // Prevent default back behavior
      onPopInvoked: (didPop) {
        if (didPop) return; // If the pop was successful, do nothing.
        // If pop was not successful (e.g., canPop was false),
        // explicitly navigate back to the home screen.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Bot(initialIndex: 0)),
              (Route<dynamic> route) => false, // Remove all previous routes
        );
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFFFF3E9),
        drawer: const CustomDrawer(), // Integrate CustomDrawer
        appBar: CustomAppBar( // Integrate CustomAppBar
          title: "Reward Points", // Set the title
          showBackButton: false, // Do NOT show back button
          showMenuButton: true, // Show menu button to open the drawer
          scaffoldKey: _scaffoldKey, // Pass the scaffold key
          isMyOrderActive: false, // Not active
          isWishlistActive: false, // Not active
          isNotiActive: false, // Not active
          // showWhatsAppIcon is false by default, matching original behavior
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Profile Card
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
                          borderRadius: BorderRadius.circular(30),
                          child: kycData?.shopImageBytes != null
                              ? Image.memory(
                            kycData!.shopImageBytes!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            'assets/profile.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayWhatsAppNumber,
                          style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xffEB7720)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Image.asset(
                      'assets/logo.png',
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
                "500",
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
      ),
    );
  }
}
