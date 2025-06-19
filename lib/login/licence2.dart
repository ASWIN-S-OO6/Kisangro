import 'dart:typed_data'; // NEW: For Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/login/onprocess.dart'; // Assuming KisanProApp is defined here
import 'package:shared_preferences/shared_preferences.dart'; // For isLoggedIn flag

class LicenceUpload extends StatefulWidget {
  @override
  _LicenceUploadState createState() => _LicenceUploadState();
}

class _LicenceUploadState extends State<LicenceUpload> {
  final TextEditingController _licenseController = TextEditingController();
  DateTime? _selectedDate;
  bool _noExpiry = false;
  Uint8List? _uploadedDocBytes; // Changed from File? to Uint8List?

  // Regex to validate license number (at least one letter and one digit)
  final RegExp _licenseRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$');

  // Getter to check if the form is valid for submission
  bool get _isFormValid {
    return _licenseRegExp.hasMatch(_licenseController.text.trim()) &&
        (_noExpiry || _selectedDate != null) &&
        _uploadedDocBytes != null; // Check for uploaded bytes
  }

  @override
  void initState() {
    super.initState();
    // Add listener to text field to update button state
    _licenseController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  /// Opens a date picker to select the expiration date.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xffEB7720), // Header background color
              onPrimary: Colors.white,    // Header text color
              onSurface: Colors.black,    // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffEB7720), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Opens a modal bottom sheet to choose between camera or gallery for image upload.
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                  leading: Icon(Icons.camera_alt, color: Color(0xffEB7720),),
                  title: Text('Open Camera', style: GoogleFonts.poppins()),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      final bytes = await pickedFile.readAsBytes(); // Read as bytes
                      setState(() {
                        _uploadedDocBytes = bytes; // Store bytes
                      });
                    }
                  }),
              ListTile(
                  leading: Icon(Icons.photo, color: Color(0xffEB7720),),
                  title: Text('Upload from Gallery', style: GoogleFonts.poppins()),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      final bytes = await pickedFile.readAsBytes(); // Read as bytes
                      setState(() {
                        _uploadedDocBytes = bytes; // Store bytes
                      });
                    }
                  }),
            ],
          ),
        );
      },
    );
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Step 2/2',
                style: GoogleFonts.poppins(
                    fontSize: 18, color: Color(0xffEB7720), fontWeight: FontWeight.w600)),
            SizedBox(height: 20),
            Text('1. Pesticide license',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xffEB7720))),
            SizedBox(height: 10),
            TextField(
              controller: _licenseController,
              onChanged: (_) => setState(() {}), // Trigger rebuild on text change for validation
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Enter License Number (letters & digits)',
                hintStyle: GoogleFonts.poppins(),
                filled: true,
                fillColor: Color(0xfff8bc8c),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _noExpiry ? null : _pickDate, // Disable if "no expiry" is checked
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xfff8bc8c),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'Expiration Date',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _selectedDate != null ? Colors.black87 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.calendar_month, color: Color(0xffEB7720), size: 40),
                  onPressed: _noExpiry ? null : _pickDate, // Disable if "no expiry" is checked
                ),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              checkColor: Colors.white,
              activeColor: Color(0xffEB7720),
              title: Text('This License Doesn’t Expire', style: GoogleFonts.poppins()),
              value: _noExpiry,
              onChanged: (value) {
                setState(() {
                  _noExpiry = value!;
                  if (_noExpiry) _selectedDate = null; // Clear date if no expiry
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: 20),
            Text('Upload Document',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage, // Call image picker
                  child: Container(
                    width: 150,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(color: Color(0xffEB7720)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _uploadedDocBytes == null // Check for uploaded bytes
                        ? Center(
                        child: Icon(Icons.camera_alt, color: Color(0xffEB7720), size: 40))
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_uploadedDocBytes!, fit: BoxFit.cover), // Display from bytes
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '(Note: The given documents\nwill be verified by our team\nshortly to verify its\nauthentication)',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _isFormValid // Button enabled only if form is valid
                  ? () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', true); // Set login flag
                Navigator.pushReplacement( // Navigate to onprocess screen
                  context,
                  MaterialPageRoute(builder: (context) => KisanProApp()), // Your onprocess.dart
                );
              }
                  : null,
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
    );
  }
}
