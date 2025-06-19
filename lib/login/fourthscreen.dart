import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/login/login.dart';

class fourthscreen extends StatefulWidget {
  const fourthscreen({super.key});

  @override
  State<fourthscreen> createState() => _fourthscreenState();
}

class _fourthscreenState extends State<fourthscreen> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final scale = isTablet ? 1.5 : 1.0;

    return Scaffold(
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
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/welcome4.svg",
                    height: screenHeight * 0.32,
                    width: screenWidth * 0.8,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gpp_good, size: 22 * scale),
                      const SizedBox(width: 10),
                      Text(
                        "Safe & Secure Payments",
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.042,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.headset_mic_outlined, size: 22 * scale),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          "24/7 Customer Support - Reach Out Us Anytime",
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.042,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/cart.gif',
                        height: 58 * scale,
                        width: 99 * scale,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Ready To Shop!",
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1.5,
                    width: screenWidth * 0.55,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    height: 50 * scale,
                    width: 300 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xffEB7720),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginApp(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Dive In ",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.045,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: Colors.white,
                            size: 14,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
