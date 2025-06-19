import 'dart:typed_data'; // Essential for Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/login/onprocess.dart'; // Assuming KisanProApp is defined here
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class licence4 extends StatefulWidget {
  const licence4({super.key});

  @override
  _licence4State createState() => _licence4State();
}

class _licence4State extends State<licence4> {
  final TextEditingController _insecticideLicenseController = TextEditingController();
  final TextEditingController _fertilizerLicenseController = TextEditingController();
  DateTime? _insecticideExpirationDate;
  DateTime? _fertilizerExpirationDate;
  bool _insecticideNoExpiry = false;
  bool _fertilizerNoExpiry = false;
  Uint8List? _insecticideImageBytes; // Changed from File? to Uint8List?
  Uint8List? _fertilizerImageBytes; // Changed from File? to Uint8List?

  // Regex to validate license number (at least one letter and one digit)
  final RegExp _licenseRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$');

  @override
  void initState() {
    super.initState();
    // Add listeners to text fields to trigger form validity checks
    _insecticideLicenseController.addListener(_checkFormValidity);
    _fertilizerLicenseController.addListener(_checkFormValidity);
    _checkFormValidity(); // Initial check to set button state
  }

  /// Helper to check the validity of the Pesticide section
  bool get _isInsecticideSectionValid {
    return _licenseRegExp.hasMatch(_insecticideLicenseController.text.trim()) &&
        (_insecticideNoExpiry || _insecticideExpirationDate != null) &&
        _insecticideImageBytes != null;
  }

  /// Helper to check the validity of the Fertilizer section
  bool get _isFertilizerSectionValid {
    return _licenseRegExp.hasMatch(_fertilizerLicenseController.text.trim()) &&
        (_fertilizerNoExpiry || _fertilizerExpirationDate != null) &&
        _fertilizerImageBytes != null;
  }

  // Updated logic: Form is valid if AT LEAST ONE section is valid
  bool get isFormValid {
    return _isInsecticideSectionValid || _isFertilizerSectionValid;
  }

  /// Re-evaluates form validity and updates the UI.
  void _checkFormValidity() {
    setState(() {
      // isFormValid getter will re-evaluate based on current state
    });
  }

  /// Handles picking a date for license expiration.
  Future<void> _pickDate(BuildContext context, bool isInsecticide) async {
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
        if (isInsecticide) {
          _insecticideExpirationDate = picked;
        } else {
          _fertilizerExpirationDate = picked;
        }
      });
      _checkFormValidity(); // Re-check validity after date selection
    }
  }

  /// Handles picking an image (from camera or gallery) for a license.
  Future<void> _pickImage(bool isInsecticide) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xffEB7720)),
              title: const Text('Open Camera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  final bytes = await pickedFile.readAsBytes(); // Read as bytes
                  setState(() {
                    if (isInsecticide) {
                      _insecticideImageBytes = bytes; // Store bytes for insecticide
                    } else {
                      _fertilizerImageBytes = bytes; // Store bytes for fertilizer
                    }
                  });
                  _checkFormValidity(); // Re-check validity after image selection
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xffEB7720)),
              title: const Text('Open Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  final bytes = await pickedFile.readAsBytes(); // Read as bytes
                  setState(() {
                    if (isInsecticide) {
                      _insecticideImageBytes = bytes; // Store bytes for insecticide
                    } else {
                      _fertilizerImageBytes = bytes; // Store bytes for fertilizer
                    }
                  });
                  _checkFormValidity(); // Re-check validity after image selection
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _insecticideLicenseController.removeListener(_checkFormValidity);
    _fertilizerLicenseController.removeListener(_checkFormValidity);
    _insecticideLicenseController.dispose();
    _fertilizerLicenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: const Color(0xffEB7720),
        title: Transform.translate(
          offset: const Offset(-25, 0),
          child: Text("Upload License", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step 2/2', style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xffEB7720), fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                // Pesticide License Section
                Text('1. Pesticide license', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xffEB7720))),
                const SizedBox(height: 10),
                TextField(
                  controller: _insecticideLicenseController,
                  style: GoogleFonts.poppins(),
                  decoration: _inputDecoration("Enter Pesticide License Number"),
                ),
                const SizedBox(height: 20),
                _buildDatePickerRow(context, true), // For Pesticide
                _buildCheckbox(true), // For Pesticide
                _buildImageUpload("Upload Document", _insecticideImageBytes, () => _pickImage(true)), // For Pesticide
                const SizedBox(height: 20),
                // Fertilizer License Section
                Text('2. Fertilizer license', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xffEB7720))),
                const SizedBox(height: 10),
                TextField(
                  controller: _fertilizerLicenseController,
                  style: GoogleFonts.poppins(),
                  decoration: _inputDecoration("Enter Fertilizer License Number"),
                ),
                const SizedBox(height: 20),
                _buildDatePickerRow(context, false), // For Fertilizer
                _buildCheckbox(false), // For Fertilizer
                _buildImageUpload("Upload Document", _fertilizerImageBytes, () => _pickImage(false)), // For Fertilizer
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isFormValid // Button enabled if at least one section is valid
                      ? () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', true); // Set the flag to true
                          Navigator.pushReplacement( // Use pushReplacement to clear previous routes
                            context,
                            MaterialPageRoute(builder: (context) => KisanProApp()), // Your onprocess.dart
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: const Color(0xffEB7720),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text('Proceed', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for consistent InputDecoration styling
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(),
      filled: true,
      fillColor: const Color(0xfff8bc8c),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }

  // Helper method to build date picker rows for licenses
  Widget _buildDatePickerRow(BuildContext context, bool isInsecticide) {
    DateTime? expirationDate = isInsecticide ? _insecticideExpirationDate : _fertilizerExpirationDate;
    bool noExpiry = isInsecticide ? _insecticideNoExpiry : _fertilizerNoExpiry;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: noExpiry ? null : () => _pickDate(context, isInsecticide),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xfff8bc8c), borderRadius: BorderRadius.circular(8)),
              child: Text(
                expirationDate != null ? DateFormat('dd/MM/yyyy').format(expirationDate) : 'Expiration Date',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: expirationDate != null ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.calendar_month, color: Color(0xffEB7720), size: 40),
          onPressed: noExpiry ? null : () => _pickDate(context, isInsecticide),
        )
      ],
    );
  }

  // Helper method to build "Doesn't Expire" checkbox
  Widget _buildCheckbox(bool isInsecticide) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      checkColor: Colors.white,
      activeColor: const Color(0xffEB7720),
      title: Text('This License Doesn’t Expire', style: GoogleFonts.poppins()),
      value: isInsecticide ? _insecticideNoExpiry : _fertilizerNoExpiry,
      onChanged: (value) {
        setState(() {
          if (isInsecticide) {
            _insecticideNoExpiry = value!;
            if (value) _insecticideExpirationDate = null;
          } else {
            _fertilizerNoExpiry = value!;
            if (value) _fertilizerExpirationDate = null;
          }
        });
        _checkFormValidity(); // Re-check form validity when checkbox changes
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  // Helper method to build image upload sections
  Widget _buildImageUpload(String title, Uint8List? imageBytes, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 150,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: const Color(0xffEB7720)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageBytes == null // Check for Uint8List?
                ? const Center(child: Icon(Icons.camera_alt, color: Color(0xffEB7720), size: 40))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(imageBytes, fit: BoxFit.cover), // Use Image.memory
                  ),
          ),
        ),
      ],
    );
  }
}
