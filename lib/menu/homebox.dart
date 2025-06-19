import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const RewardApp());
}

class RewardApp extends StatelessWidget {
  const RewardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reward Popup Demo',
      home: const RewardHomePage(),
    );
  }
}

class RewardHomePage extends StatelessWidget {
  const RewardHomePage({super.key});

  void _showRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reward Image
                  Image.asset(
                    'assets/wings.gif',
                    height: 120,
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(
                    "Congratulations!",
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtext
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        const TextSpan(text: "You earned "),
                        TextSpan(
                          text: "100 coins",
                          style:  GoogleFonts.poppins(
                            color: Color(0xffEB7720),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         TextSpan(text: " through this purchase",style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff52B157),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "View Reward Coins",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Close Icon
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xffEB7720), width: 1),
                  ),
                  child:  Icon(
                    Icons.close,
                    size: 14,
                    color: Color(0xffEB7720),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Popup Demo'),
        backgroundColor: const Color(0xff38B000),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showRewardDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffEB7720),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text("Show Reward Dialog"),
        ),
      ),
    );
  }
}
