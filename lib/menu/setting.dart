import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/login/login.dart';
import 'package:kisangro/menu/delete.dart';
import 'package:kisangro/menu/logout.dart';
import 'package:kisangro/menu/wishlist.dart';

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

  bool isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF3E7), // Light orange background
        appBar: AppBar(
          backgroundColor: const Color(0xffEB7720),
          elevation: 0,
          title:  Text(
            "Settings",
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize:16
            ),
          ),
          leading:

          IconButton(
              onPressed: () {
                Navigator.pop(context);// handle menu
              },
              icon:Icon(Icons.arrow_back,color: Colors.white,)
          ),
          actions: [

            IconButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>MyOrder()));

              },
              icon: Image.asset(
                'assets/box.png',
                height: 24,
                width: 24,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10,),
            IconButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>WishlistPage()));
              },
              icon: Image.asset(
                'assets/heart.png',
                height: 24,
                width: 24,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>noti()));
              },
              icon: Image.asset(
                'assets/noti.png',
                height: 24,
                width: 24,
                color: Colors.white,
              ),
            ),
          ],
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
                      color:Color(0xffEB7720),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

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
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            SizedBox(height: 32),

            // Notification
            Text(
              'Notification',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),

            Row(
              children: [
                Text(
                  '• Pop up on phone',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Switch(
                  value: isNotificationOn,
                  activeColor: Color(0xffEB7720),
                  onChanged: (val) {
                    setState(() {
                      isNotificationOn = val;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 48),

            // Delete Account Button
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: 16),
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
