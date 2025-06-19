import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Keep if you use SVG for logo
import 'package:kisangro/login/secondscreen.dart'; // Path to your second screen
import 'package:kisangro/home/bottom.dart'; // Path to your home screen (Bot class)
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import "package:kisangro/home/homepage.dart";

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

  // Asynchronously checks the login status and navigates accordingly
  Future<void> _checkLoginStatusAndNavigate() async {
    // Simulate splash screen delay
    await Future.delayed(Duration(seconds: 3));

    // Ensure the widget is still mounted before attempting navigation
    if (!mounted) {
      return;
    }

    // Get an instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Check if the 'isLoggedIn' key exists and is true
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (mounted) {
      if (isLoggedIn) {
        // If logged in, navigate directly to the home screen (Bot)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Bot()), // Assuming Bot is your main home screen
        );
      } else {
        // If not logged in, proceed to the onboarding screens
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
      body: Center(
        child: Container(
          // Adjust size based on tablet or phone
          height: isTablet ? screenSize.height * 0.5 : 192,
          width: isTablet ? screenSize.width * 0.4 : 149,
          // Use Image.asset for local images
          child: Image.asset("assets/logo.png", fit: BoxFit.contain),
        ),
      ),
    );
  }
}
