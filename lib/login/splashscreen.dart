import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Keep if you use SVG for logo, though your snippet uses Image.asset
import 'package:kisangro/login/secondscreen.dart'; // Path to your second screen
import 'package:kisangro/home/bottom.dart'; // Path to your home screen (Bot class)
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:kisangro/login/onprocess.dart'; // Import KycSplashScreen
import 'package:kisangro/services/product_service.dart'; // NEW: Import ProductService for data loading
import 'dart:async'; // For Future.delayed

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  // Asynchronously checks the login and KYC/license status, loads product data, and navigates accordingly
  Future<void> _checkLoginStatusAndNavigate() async {
    // Simulate splash screen delay
    await Future.delayed(const Duration(seconds: 3));

    // Ensure the widget is still mounted before attempting navigation or data loading
    if (!mounted) {
      return;
    }

    // NEW: Load product data from the API service
    try {
      debugPrint('SplashScreen: Starting to load product data...');
      await ProductService.loadProductsFromApi(); // Load general products (type 1041)
      await ProductService.loadCategoriesFromApi(); // Load categories (type 1043)
      debugPrint('SplashScreen: Product and Category data loaded successfully.');
    } catch (e) {
      debugPrint('SplashScreen: Failed to load product/category data: $e');
      if (mounted) {
        // Optionally, show a critical error and prevent navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load app data: $e. Please check your internet connection.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        // You might want to halt navigation here or go to an error screen.
        // For now, it will proceed, but subsequent screens might fail if data is truly missing.
      }
      return; // Exit if critical data load fails
    }

    // Get an instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Check if the 'isLoggedIn' key exists and is true
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    // Check for the license upload completion flag
    final hasUploadedLicenses = prefs.getBool('hasUploadedLicenses') ?? false;

    if (mounted) {
      if (isLoggedIn) {
        if (hasUploadedLicenses) {
          // If logged in AND licenses uploaded, go directly to home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Bot()), // Assuming Bot is your main home screen
          );
        } else {
          // If logged in BUT licenses NOT uploaded, go to KYC process screen
          // This covers cases where user logged in but didn't complete KYC/licenses or exited mid-way
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => KycSplashScreen()),
          );
        }
      } else {
        // If not logged in at all, proceed to the onboarding screens
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const secondscreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    return Scaffold(
      body: Container( // Wrapped the content in a Container for the gradient
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)], // Consistent gradient colors
          ),
        ),
        child: Center(
          child: Container(
            // Adjust size based on tablet or phone
            height: isTablet ? screenSize.height * 0.5 : 192,
            width: isTablet ? screenSize.width * 0.4 : 149,
            child: Image.asset(
              "assets/logo.png",
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
