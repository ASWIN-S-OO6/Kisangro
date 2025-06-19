import 'package:flutter/material.dart';
import 'package:kisangro/login/licence2.dart'; // Corrected import to LicenceUpload class
import 'package:kisangro/login/licence3.dart'; // Import for the mock licence3.dart
import 'package:kisangro/login/licence4.dart'; // Ensure this import is correct
import 'package:google_fonts/google_fonts.dart';// Ensure this import is correct

class licence1 extends StatefulWidget {
  @override
  _licence1State createState() => _licence1State();
}

class _licence1State extends State<licence1> {
  bool isPesticideSelected = false;
  bool isFertilizerSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xffEB7720),
        title: Transform.translate(offset: Offset(-25, 0),
          child: Text("Upload License!",style: GoogleFonts.poppins(color: Colors.white,fontSize: 18),),),
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffFFD9BD),
                  Color(0xffFFFFFF),
                ]
            )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step 1/2',
                style: GoogleFonts.poppins(fontSize: 18, color: Color(0xffEB7720), fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              Text(
                'Select The Category You Are Selling',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xffEB7720)),
              ),
              SizedBox(height: 30),

              // Category Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPesticideSelected = !isPesticideSelected;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPesticideSelected
                            ? Color(0xffEB7720)
                            : Colors.transparent,
                        side: BorderSide(color: Colors.orange),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        'Pesticide',
                        style: GoogleFonts.poppins(
                          color: isPesticideSelected ? Colors.white : Color(0xffEB7720),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isFertilizerSelected = !isFertilizerSelected;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFertilizerSelected
                            ? Color(0xffEB7720)
                            : Colors.transparent,
                        side: BorderSide(color: Colors.orange),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        'Fertilizers',
                        style: GoogleFonts.poppins(
                          color: isFertilizerSelected ? Colors.white : Color(0xffEB7720),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Spacer(),

              // Note Text
              Text(
                '(Note: A verification team will be arriving at the given address to verify your business in 48 hrs. Make sure you are available at that time.)',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
              ),
              SizedBox(height: 20),

              // Proceed Button
              ElevatedButton(
                onPressed: (isPesticideSelected || isFertilizerSelected)
                    ? () {
                  // Navigate based on the selected category
                  if (isPesticideSelected && isFertilizerSelected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => licence4(), // Navigate to licence4 if both are selected
                      ),
                    );
                  } else if (isPesticideSelected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LicenceUpload(), // Navigate to licence2 for Pesticide
                      ),
                    );
                  } else if (isFertilizerSelected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => licence3(), // Navigate to licence3 for Fertilizer
                      ),
                    );
                  }
                }
                    : null, // Button is disabled if no category is selected
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffEB7720),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Proceed', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
