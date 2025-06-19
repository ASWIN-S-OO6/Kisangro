import 'package:flutter/material.dart';
import 'package:kisangro/menu/logout.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MaterialApp(
    home: RaiseComplaintScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class RaiseComplaintScreen extends StatefulWidget {
  const RaiseComplaintScreen({Key? key}) : super(key: key);

  @override
  State<RaiseComplaintScreen> createState() => _RaiseComplaintScreenState();
}

class _RaiseComplaintScreenState extends State<RaiseComplaintScreen> {
  String? selectedReason = 'Wrong Product Delivered';
  final TextEditingController otherController = TextEditingController();

  final List<String> complaintOptions = [
    'Wrong Product Delivered',
    'Damaged Or Expired Items',
    'Late Delivery',
    'Quantity Mismatch',
    'Payment Not Updated Or Failed',
    'Invoice Issues (Missing Or Incorrect)',
    'Refund Not Received',
    'Poor Quality Product',
    'No Response From Customer Support',
    'Others',
  ];

  void alertbox(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogoutConfirmationDialog(
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
      backgroundColor: Colors.transparent, // Important
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Row(
                  children: [
                    IconButton(onPressed: (){
                      Navigator.pop(context);
                    }, icon:const Icon(Icons.arrow_back, color: Colors.black)),
                    const SizedBox(width: 10),
                     Text(
                      'Raise Complaint',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Complaint Options
                Expanded(
                  child: ListView.builder(
                    itemCount: complaintOptions.length,
                    itemBuilder: (context, index) {
                      final option = complaintOptions[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: Colors.black,
                            ),
                            child: RadioListTile<String>(
                              activeColor: Colors.black,
                              value: option,
                              groupValue: selectedReason,
                              onChanged: (value) {
                                setState(() {
                                  selectedReason = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                option,
                                style:  GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          if (!(option == 'Others' &&
                              selectedReason == 'Others'))
                            const Divider(
                              thickness: 1,
                              height: 1,
                              color: Colors.black,
                            ),
                          if (option == 'Others' &&
                              selectedReason == 'Others')
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 20),
                              child: TextField(
                                controller: otherController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: 'Type Here...',
                                  hintStyle:  GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide:
                                    const BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide:
                                    const BorderSide(color: Colors.black),
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                style:  GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Submit Button
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      onPressed: () {
                        final complaint = selectedReason == 'Others'
                            ? otherController.text.trim()
                            : selectedReason;

                        if (complaint == null || complaint.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a complaint.')),
                          );
                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title:Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                              Container(
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
                            ],),

                            
                            actions: [
                          Center(child: Image(image: AssetImage("assets/complaint.gif"))),
                              Center(child: Text("Complaint raised successfully.",style: GoogleFonts.poppins(fontSize:13 ),)),
                              SizedBox(height: 10,),
                              Text("Soon our support team will resole it shortly ",style: GoogleFonts.poppins(fontSize: 13),)

                            ],
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffEB7720),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child:  Text(
                        'Submit',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
