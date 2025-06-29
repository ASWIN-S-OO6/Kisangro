import 'dart:async';
import 'dart:typed_data'; // Needed for Uint8List for image display
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // For star rating UI
import 'package:dotted_border/dotted_border.dart'; // For dotted borders around profile image
import 'package:provider/provider.dart'; // For state management (accessing KycImageProvider)

import 'package:flutter/material.dart';
import 'package:kisangro/home/membership.dart'; // Assuming this page exists
import 'package:kisangro/home/myorder.dart'; // Assuming this page exists
import 'package:kisangro/home/noti.dart'; // Assuming this page exists
import 'package:kisangro/menu/wishlist.dart'; // Assuming this page exists

import '../login/login.dart'; // For logout navigation
import '../menu/account.dart'; // For My Account navigation
import '../menu/ask.dart'; // For Ask Us! navigation
import '../menu/logout.dart'; // For LogoutConfirmationDialog
import '../menu/setting.dart'; // For Settings navigation
import '../menu/transaction.dart'; // For Transaction History navigation
import '../models/kyc_image_provider.dart'; // Import your custom KYC image provider

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  _RewardScreenState createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Key for Scaffold to open drawer

  // Variables related to rating dialog (consistent with other screens)
  double _rating = 4.0;
  final TextEditingController _reviewController = TextEditingController();
  static const int maxChars = 100;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  /// Shows a confirmation dialog for logging out, clears navigation stack.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (context) => LogoutConfirmationDialog(
        onCancel: () => Navigator.of(context).pop(), // Close dialog on cancel
        onLogout: () {
          // Perform logout actions and navigate to LoginApp, clearing navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginApp()),
            (Route<dynamic> route) => false, // Remove all routes below
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully!')),
          );
        },
      ),
    );
  }

  /// Shows a dialog for giving ratings and writing a review about the app.
  void showComplaintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          content: StatefulBuilder(
            // Use StatefulBuilder to manage dialog's internal state for _rating and _reviewController
            builder: (context, setState) {
              return SizedBox(
                width: 328, // Fixed width for dialog content
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Make column content fit
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context), // Close dialog
                        child: const Icon(
                          Icons.close,
                          color: Color(0xffEB7720), // Orange close icon
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Give ratings and write a review about your experience using this app.",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text("Rate:", style: GoogleFonts.lato(fontSize: 16)),
                        const SizedBox(width: 12),
                        RatingBar.builder(
                          // Star rating bar
                          initialRating: _rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 32,
                          unratedColor: Colors.grey[300],
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Color(0xffEB7720),
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _rating = rating; // Update rating state
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _reviewController,
                      maxLength: maxChars,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '', // Hide default counter text
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (_) => setState(
                          () {}), // Rebuild to update character count dynamically
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_reviewController.text.length}/$maxChars', // Character counter
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffEB7720),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close review dialog

                          // Show "Thank you" confirmation dialog
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.all(24),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xffEB7720),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Thank you!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thanks for rating us.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context), // Close thank you dialog
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xffEB7720),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'OK',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign scaffold key to control drawer
      drawer: Drawer(
        child: SafeArea(
          // Ensures content is not under status bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(), // Custom header for the drawer, now displaying KYC image
              _buildMenuItem(Icons.person_outline, "My Account"), // Drawer menu items
              _buildMenuItem(Icons.favorite_border, "Wishlist"),
              _buildMenuItem(Icons.history, "Transaction History"),
              _buildMenuItem(Icons.headset_mic, "Ask Us!"),
              _buildMenuItem(Icons.info_outline, "About Us"),
              _buildMenuItem(Icons.star_border, "Rate Us"),
              _buildMenuItem(Icons.share_outlined, "Share Kisangro"),
              _buildMenuItem(Icons.settings_outlined, "Settings"),
              _buildMenuItem(Icons.logout, "Logout"),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        centerTitle: false,
        elevation: 0,
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            "Rewards",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); // Open drawer on menu icon tap
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrder()));
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
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => WishlistPage()));
            },
            icon: Image.asset(
              'assets/heart.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => noti()));
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
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffFFD9BD),
              Color(0xffFFFFFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Your Rewards",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffEB7720),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Dummy content for rewards
              _buildRewardCard(
                title: "Welcome Bonus",
                description: "Get 10% off on your first order!",
                icon: Icons.card_giftcard,
                color: Colors.green,
              ),
              const SizedBox(height: 15),
              _buildRewardCard(
                title: "Loyalty Discount",
                description: "Earn 5% off on every 10th purchase.",
                icon: Icons.loyalty,
                color: Colors.blue,
              ),
              const SizedBox(height: 15),
              _buildRewardCard(
                title: "Referral Bonus",
                description: "Refer a friend and get ₹100 credit.",
                icon: Icons.person_add,
                color: Colors.purple,
              ),
              const SizedBox(height: 30),
              Text(
                "How to Earn Rewards:",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _buildHowToEarnPoint(
                  "1. Make purchases through the app."),
              _buildHowToEarnPoint(
                  "2. Refer new users to Kisangro."),
              _buildHowToEarnPoint(
                  "3. Participate in special seasonal campaigns."),
              _buildHowToEarnPoint(
                  "4. Leave reviews for products you buy."),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Action to view all rewards or claim rewards
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Viewing all available rewards!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEB7720),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "View All Rewards",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single reward card.
  Widget _buildRewardCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 40,
            color: color,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a point for "How to Earn Rewards" section.
  Widget _buildHowToEarnPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline,
              size: 20, color: const Color(0xffEB7720)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the header section of the drawer, including the user profile image.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Row(
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
                    // Use Consumer to dynamically display the uploaded image from KycImageProvider.
                    child: Consumer<KycImageProvider>(
                      builder: (context, kycImageProvider, child) {
                        final Uint8List? kycImageBytes =
                            kycImageProvider.kycImageBytes; // Get image bytes
                        return kycImageBytes != null
                            ? Image.memory(
                                // Display image from bytes if available
                                kycImageBytes,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/profile.png', // Fallback to default profile image
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                "Hi Smart!\n 9876543210", // User name and number
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 400, // Fixed width for the button
            child: Padding(
              padding: const EdgeInsets.only(left: 100),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MembershipDetailsScreen(), // Navigate to membership screen
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEB7720), // Orange button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "Not A Member Yet",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 30, thickness: 1, color: Colors.black), // Divider
        ],
      ),
    );
  }

  /// Builds a single menu item in the drawer.
  Widget _buildMenuItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        height: 40,
        decoration: const BoxDecoration(color: Color(0xffffecdc)), // Light orange background
        child: ListTile(
          leading: Icon(icon, color: const Color(0xffEB7720)), // Orange icon
          title: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold, // Consistent bold font weight
            ),
          ),
          onTap: () {
            // Handle navigation based on the tapped menu item label
            switch (label) {
              case 'My Account':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyAccountPage()),
                );
                break;
              case 'Wishlist': // Added Wishlist navigation
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WishlistPage()),
                );
                break;
              case 'Transaction History':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionHistoryPage(),
                  ),
                );
                break;
              case 'Ask Us!':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AskUsPage()),
                );
                break;
              case 'Rate Us':
                showComplaintDialog(context); // Show review dialog
                break;
              case 'Settings':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
                break;
              case 'Logout':
                _showLogoutDialog(context); // Show logout confirmation dialog
                break;
              case 'About Us':
              // Handle About Us navigation
                break;
              case 'Share Kisangro':
              // Handle Share functionality
                break;
            }
          },
        ),
      ),
    );
  }
}
