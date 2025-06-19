import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/home/bottom.dart';

void main() => runApp(KisanProApp());

class KisanProApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KycSplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class KycSplashScreen extends StatefulWidget {
  @override
  _KycSplashScreenState createState() => _KycSplashScreenState();
}

class _KycSplashScreenState extends State<KycSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to HomePage after 4 seconds
    Future.delayed(Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Bot()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 50),
              SizedBox(
                height: 130,
                width: 150,
                child: Image.asset("assets/logo.png"),
              ),
              const SizedBox(height: 80),
              Image.asset(
                "assets/process.gif",
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  'Your KYC verification is in process.\n\nYou can purchase our products once it is completed.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy Home Page (replace with your real screen)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Welcome to HomePage!',
          style: GoogleFonts.poppins(fontSize: 24),
        ),
      ),
    );
  }
}
