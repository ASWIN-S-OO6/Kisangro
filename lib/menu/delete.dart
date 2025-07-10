import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/login/login.dart';



class logout extends StatelessWidget {
  const logout({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logout Dialog Demo',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => deleteAccount(
        onCancel: () => Navigator.of(context).pop(),
        onLogout: () {
          Navigator.of(context).pop();
          // Add your logout logic here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logout Dialog Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _deleteAccount(context),
          child: const Text('Show Logout Dialog'),
        ),
      ),
    );
  }
}

class deleteAccount extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onLogout;

  const deleteAccount({
    super.key,
    required this.onCancel,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFEB7720);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: 340,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Illustration placeholder (replace with your asset)
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image.asset(
                      'assets/delete.gif', // Replace with your image path
                      fit: BoxFit.contain,
                    ),
                    // If no image, uncomment below:
                    // child: Icon(Icons.account_circle, size: 80, color: orange),
                  ),
                  const SizedBox(height: 16),
                  // Text with icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          // border: Border.all(color: Color(0xffEB7720), width: 1.8),
                          // borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Icon(Icons.delete_forever_outlined, color: Colors.red, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.lato(
                              fontSize: 17,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                            children: [
                              TextSpan(text: "Are you sure you want to",style: GoogleFonts.poppins()),
                              TextSpan(
                                text: "Delete Account?",
                                style: GoogleFonts.poppins(
                                  color:Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          width: 130,
                          child: ElevatedButton(
                            onPressed: onCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffEB7720),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                fontSize: 16,

                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 50,
                        width: 100,
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginApp()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffF0F0F0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "delete",
                            style: GoogleFonts.poppins(
                                fontSize: 16,color: Colors.black

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Close icon inside orange border circle
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: onCancel,
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xffEB7720), width: 1),
                  ),
                  padding: const EdgeInsets.only(right: 1),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color:Color(0xffEB7720),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}