import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kisangro/login/fourthscreen.dart';
import 'package:kisangro/login/login.dart';
import 'package:kisangro/login/thirdscreen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class secondscreen extends StatefulWidget {
  const secondscreen({super.key});

  @override
  State<secondscreen> createState() => _secondscreenState();
}

class _secondscreenState extends State<secondscreen> {
  PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              buildPage1(screenWidth, screenHeight, isTablet),
              thirdscreen(),
              fourthscreen(),
            ],
          ),
          Positioned(
            bottom: isTablet ? 30 : 20,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  dotColor: Color(0xffEB7720).withOpacity(0.3),
                  activeDotColor: Color(0xffEB7720),
                  dotHeight: isTablet ? 6.0 : 5.0,
                  dotWidth: isTablet ? 10.0 : 8.0,
                  spacing: 6.0,
                ),
                onDotClicked: (index) {
                  _controller.animateToPage(
                    index,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage1(double screenWidth, double screenHeight, bool isTablet) {
    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginApp()));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: EdgeInsets.only(top: screenHeight * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("Skip", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Center(
                    child: Text(
                      "Welcome To KISANGRO",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 32 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.035),
                  Center(
                    child: SvgPicture.asset(
                      'assets/welcome1.svg',
                      height: screenHeight * 0.18,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Center(
                    child: Text(
                      "Your “One-Stop Shop”",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: isTablet ? 20 : 16),
                    ),
                  ),
                  Center(
                    child: Text(
                      "For All Agricultural Needs!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: isTablet ? 20 : 16),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.045),
                  Center(
                    child: SvgPicture.asset(
                      'assets/welcome2.svg',
                      height: screenHeight * 0.23,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.045),
                  Center(
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 18 : 14,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: "Agri-Products ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: "Delivered"),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: isTablet ? 18 : 14,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(text: "To Your "),
                              TextSpan(
                                text: "Door Step",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
