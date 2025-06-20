import 'package:flutter/material.dart';
import 'package:kisangro/login/onprocess.dart'; // Keep if KisanProApp is used elsewhere
import 'package:shared_preferences/shared_preferences.dart'; // Keep if SharedPreferences is used elsewhere
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/login/licence4.dart'; // Import licence4

class licence2 extends StatefulWidget {
  @override
  _licence2State createState() => _licence2State();
}

class _licence2State extends State<licence2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const licence4(licenseTypeToDisplay: 'pesticide')), // Pass 'pesticide'
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xffEB7720),
        leading: BackButton(color: Colors.white),
        title: Transform.translate(offset: Offset(-25, 0),
          child: Text("Upload License",style: GoogleFonts.poppins(color: Colors.white,fontSize: 18),),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xffEB7720)),
            SizedBox(height: 20),
            Text('Loading pesticide license...', style: GoogleFonts.poppins()), // Updated loading text
          ],
        ),
      ),
    );
  }
}