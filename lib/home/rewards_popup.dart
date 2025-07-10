import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/home/reward_screen.dart';
import 'package:kisangro/home/bottom.dart'; // Import the Bot class

class RewardsPopup extends StatelessWidget {
  final int coinsEarned;

  const RewardsPopup({
    super.key,
    this.coinsEarned = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 12),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            // Coin animation area with stars
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Stars and coin icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Decorative stars
                      Positioned(
                        left: 20,
                        top: 10,
                        child: _buildStar(12, Colors.orange[300]!),
                      ),
                      Positioned(
                        right: 15,
                        top: 5,
                        child: _buildStar(8, Colors.orange[200]!),
                      ),
                      Positioned(
                        left: 60,
                        bottom: 5,
                        child: _buildStar(6, Colors.orange[100]!),
                      ),
                      Positioned(
                        right: 45,
                        bottom: 15,
                        child: _buildStar(10, Colors.orange[300]!),
                      ),

                      // Main coin icon
                      Image.asset('assets/wings.gif', scale: 1),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Congratulations text
                  Text(
                    "Congratulations!",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Coins earned text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: "You earned "),
                        TextSpan(
                          text: "$coinsEarned coins",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[600],
                          ),
                        ),
                        const TextSpan(text: " through this\npurchase"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),

            // View Reward Coins button - positioned at bottom with no padding
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Close the current dialog
                  Navigator.pop(context);
                  // Navigate to the Bot (BottomNavigationBar) and select the Rewards tab (index 2)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Bot(initialIndex: 2), // Set initialIndex to 2 for Rewards tab
                    ),
                        (Route<dynamic> route) => false, // Remove all previous routes
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  "View Reward Coins",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a decorative star
  Widget _buildStar(double size, Color color) {
    return Icon(
      Icons.star,
      size: size,
      color: color,
    );
  }
}
