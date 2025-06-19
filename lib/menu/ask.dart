import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/menu/chat.dart';

class AskUsPage extends StatefulWidget {
  @override
  _AskUsPageState createState() => _AskUsPageState();
}

class _AskUsPageState extends State<AskUsPage> {
  final List<bool> _commonExpanded = [false, false, false, false];
  final List<bool> _buyersExpanded = [false, false, false, false];

  final String sampleAnswer =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3E7),
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Transform.translate(offset: Offset(-20, 0),
          child: Text("Ask Us!",style: GoogleFonts.poppins(color: Colors.white,fontSize: 18),),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const Icon(CupertinoIcons.cube_box,color: Colors.white,),
          const SizedBox(width: 12),
          const Icon(Icons.favorite_border,color: Colors.white,),
          const SizedBox(width: 12),
          const Icon(CupertinoIcons.bell,color: Colors.white,),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
          width: double.infinity,
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
          ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with image and text
                  Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/ask1.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.lato(
                                  fontSize: 17,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                                children: [
                                   TextSpan(text: "‘Stuck?\nLet Us Untangle It\n",style: GoogleFonts.poppins(fontSize: 14)),
                                  TextSpan(
                                    text: "For You!’",
                                    style: GoogleFonts.lato(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Contact box as an image
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Center(
                        child: Image.asset(
                          'assets/ask2.png',
                          width: 267,
                          height: 58,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(),

                  _buildSectionTitle('Common Queries'),
                  const SizedBox(height: 12,),
                  ...List.generate(4, (index) {
                    return _buildCustomExpansionTile(
                      title: '${index + 1}. How to sell the product on Kisangro?',
                      isExpanded: _commonExpanded[index],
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _commonExpanded[index] = expanded;
                        });
                      },
                      answer: sampleAnswer,
                    );
                  }),
                  const SizedBox(height: 32),

                  // Buyers Queries Section (centered with underline)
                  _buildSectionTitle('Buyers Queries'),
                  const SizedBox(height: 12),
                  ...List.generate(4, (index) {
                    return _buildCustomExpansionTile(
                      title: '${index + 1}. How to sell the product on Kisangro?',
                      isExpanded: _buyersExpanded[index],
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _buyersExpanded[index] = expanded;
                        });
                      },
                      answer: sampleAnswer,
                    );
                  }),
                  const SizedBox(height: 100), // Extra space for button
                ],
              ),
            ),

            // Fixed bottom button
            Positioned(
              bottom: 16,
              left: 24,
              right: 24,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEB7720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>ChatScreen()));// Handle start asking action
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start Asking',
                      style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                         Icon(Icons.arrow_forward,color: Colors.white,),

                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      children: [
        Center(
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Container(
            width: 60,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.black87.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomExpansionTile({
    required String title,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required String answer,
  }) {
    if (!isExpanded) {
      return ListTile(
        title: Text(
          title,
          style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.black54,
        ),
        onTap: () => onExpansionChanged(true),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        dense: true,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            trailing: Icon(
              Icons.keyboard_arrow_up,
              color: Colors.black54,
            ),
            onTap: () => onExpansionChanged(false),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            dense: true,
          ),
          Divider(
            color: Colors.grey.shade400,
            thickness: 1,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              answer,
              style: GoogleFonts.lato(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}