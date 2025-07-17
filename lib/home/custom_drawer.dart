import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // NEW: Import image_picker

// Import your custom models and services needed by the drawer's logic
import 'package:kisangro/models/kyc_image_provider.dart'; // Your custom KYC image provider
import 'package:kisangro/models/kyc_business_model.dart'; // Import KycBusinessData and KycBusinessDataProvider

// Your existing page imports for drawer navigation targets
import 'package:kisangro/home/membership.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/login/login.dart';
import 'package:kisangro/menu/account.dart';
import 'package:kisangro/menu/ask.dart';
import 'package:kisangro/menu/logout.dart';
import 'package:kisangro/menu/setting.dart';
import 'package:kisangro/menu/transaction.dart';
import 'package:kisangro/menu/wishlist.dart';


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  double _rating = 4.0;
  final TextEditingController _reviewController = TextEditingController();
  static const int maxChars = 100;
  bool _isMembershipActive = false;

  @override
  void initState() {
    super.initState();
    _checkMembershipStatus();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _checkMembershipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool('isMembershipActive') ?? false;
    if (isActive != _isMembershipActive) {
      setState(() {
        _isMembershipActive = isActive;
      });
      debugPrint('Membership status updated in CustomDrawer: $_isMembershipActive');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogoutConfirmationDialog(
        onCancel: () => Navigator.of(context).pop(),
        onLogout: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', false);
          await prefs.setBool('hasUploadedLicenses', false);
          await prefs.setBool('isMembershipActive', false);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginApp()),
                (Route<dynamic> route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully!')),
          );
        },
      ),
    );
  }

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
            builder: (context, setState) {
              return SizedBox(
                width: 328,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xffEB7720),
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
                              _rating = rating;
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
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (_) =>
                          setState(() {}),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_reviewController.text.length}/$maxChars',
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
                          Navigator.pop(context);

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
                                          Navigator.pop(context),
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

  // NEW: Function to pick an image from camera or gallery (kept for reference, but not used in drawer profile pic)
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      final bytes = await image.readAsBytes();
      // Update the KycBusinessDataProvider with the new image bytes
      Provider.of<KycBusinessDataProvider>(context, listen: false)
          .setKycBusinessData(shopImageBytes: bytes);
      // Also update the KycImageProvider if it's used elsewhere for temporary display
      Provider.of<KycImageProvider>(context, listen: false)
          .setKycImage(bytes);

      // You can add a success message if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image picking cancelled.')),
        );
      }
    }
  }

  // NEW: Function to show a modal bottom sheet for image source selection (kept for reference)
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xffEB7720)),
                title: Text('Take Photo', style: GoogleFonts.poppins(color: Colors.black87)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xffEB7720)),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins(color: Colors.black87)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildHeader() {
    return Consumer<KycBusinessDataProvider>( // Use Consumer to rebuild when KYC data changes
      builder: (context, kycBusinessDataProvider, child) {
        final kycData = kycBusinessDataProvider.kycBusinessData;
        final Uint8List? shopImageBytes = kycData?.shopImageBytes;
        final String fullName = kycData?.fullName ?? "Smart"; // Fallback to "Smart"
        final String whatsAppNumber = kycData?.whatsAppNumber ?? "9876543210"; // Fallback number

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  // Profile Image (without the edit button/gesture detector)
                  DottedBorder(
                    borderType: BorderType.Circle,
                    color: Colors.red,
                    strokeWidth: 2,
                    dashPattern: const [6, 3],
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: shopImageBytes != null
                            ? Image.memory(
                          shopImageBytes,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'assets/profile.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Removed Positioned(Edit Icon Button) from here
                  const SizedBox(width: 20),
                  Text(
                    "$fullName\n$whatsAppNumber", // Use actual name and number
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MembershipDetailsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffEB7720),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isMembershipActive ? "You Are A Member" : "Not A Member Yet",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 30, thickness: 1, color: Colors.black),
            ],
          ),
        );
      },
    );
  }
  Widget _buildMenuItem(IconData icon, String label) {
    return Column( // Use Column to include the Divider
      children: [
        Container(
          // No margin here, instead use padding on the ListTile
          // No fixed height or background color here for merging effect
          decoration: const BoxDecoration( // Changed to const as color is now fixed
            color: Color(0xffffecdc), // Background color for the item
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Adjust padding to remove inner spacing
            leading: Icon(icon, color: const Color(0xffEB7720)),
            title: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);

              switch (label) {
                case 'My Account':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyAccountPage()),
                  );
                  break;
                case 'My Orders':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrder()),
                  );
                  break;
                case 'Wishlist':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WishlistPage()),
                  );
                  break;
                case 'Transaction History':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  TransactionHistoryPage(),
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
                  showComplaintDialog(context);
                  break;
                case 'Settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                  break;
                case 'Logout':
                  _showLogoutDialog(context);
                  break;
                case 'About Us':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('About Us page coming soon!')),
                  );
                  break;
                case 'Share Kisangro':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality coming soon!')),
                  );
                  break;
              }
            },
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Colors.grey), // Divider between items
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.person_outline, "My Account"),
                  _buildMenuItem(Icons.receipt_long, "My Orders"),
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
          ],
        ),
      ),
    );
  }
}
