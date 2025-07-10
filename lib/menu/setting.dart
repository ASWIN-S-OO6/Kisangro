import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/login/login.dart';
import 'package:kisangro/menu/delete.dart';
import 'package:kisangro/menu/logout.dart';
import 'package:kisangro/menu/wishlist.dart';

// Import CustomAppBar

// Import Bot for navigation (for back button functionality)
import 'package:kisangro/home/bottom.dart';

import '../common/common_app_bar.dart';


class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => deleteAccount(
        onCancel: () => Navigator.of(context).pop(),
        onLogout: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginApp()), // replace 'login()' with your LoginScreen
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out')),
          );
        },
      ),
    );
  }

  // Removed isNotificationOn, replaced with specific notification types
  bool _isEmailNotificationOn = true;
  bool _isSmsNotificationOn = true;
  bool _isWhatsappNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFFDF3E7), // Light orange background
        appBar: CustomAppBar( // Integrated CustomAppBar
          title: "Settings", // Set the title
          showBackButton: true, // Show back button
          showMenuButton: false, // Do NOT show menu button (drawer icon)
          // scaffoldKey is not needed here as there's no drawer
          isMyOrderActive: false, // Not active
          isWishlistActive: false, // Not active
          isNotiActive: false, // Not active
          // showWhatsAppIcon is false by default, matching original behavior
        ),
        body:Container(width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xffFFD9BD),
                Color(0xffFFFFFF),
              ],
            ),
          ),child:Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Terms & Conditions
                RichText(
                  text: TextSpan(
                    text: 'Read Kisangro ',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: GoogleFonts.lato(
                          color:const Color(0xffEB7720),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Preferred Language
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preferred Language',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: Text(
                        'English',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Notification Section Title
                Text(
                  'Notification',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Email Notifications
                Row(
                  children: [
                    Text(
                      'Email',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isEmailNotificationOn,
                      activeColor: const Color(0xffEB7720),
                      onChanged: (val) {
                        setState(() {
                          _isEmailNotificationOn = val;
                        });
                      },
                    ),
                  ],
                ),
                Divider(color: Colors.grey[300], height: 20, thickness: 1), // Divider

                // SMS Notifications
                Row(
                  children: [
                    Text(
                      'SMS',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isSmsNotificationOn,
                      activeColor: const Color(0xffEB7720),
                      onChanged: (val) {
                        setState(() {
                          _isSmsNotificationOn = val;
                        });
                      },
                    ),
                  ],
                ),
                Divider(color: Colors.grey[300], height: 20, thickness: 1), // Divider

                // WhatsApp Notifications
                Row(
                  children: [
                    Text(
                      'WhatsApp',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isWhatsappNotificationOn,
                      activeColor: const Color(0xffEB7720),
                      onChanged: (val) {
                        setState(() {
                          _isWhatsappNotificationOn = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 48), // Spacing before delete button

                // Delete Account Button
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        _deleteAccount(context);
                      },
                      child: Text(
                        'Delete Account',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),)
    );
  }
}
