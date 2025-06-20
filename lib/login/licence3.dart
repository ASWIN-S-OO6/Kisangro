import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/login/licence4.dart'; // Import licence4

class licence3 extends StatefulWidget {
  const licence3({super.key});

  @override
  _licence3State createState() => _licence3State();
}

class _licence3State extends State<licence3> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const licence4(licenseTypeToDisplay: 'fertilizer')), // Pass 'fertilizer'
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
            Text('Loading fertilizer license...', style: GoogleFonts.poppins()), // Updated loading text
          ],
        ),
      ),
    );
  }
}