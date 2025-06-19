import 'dart:typed_data'; // Essential for Uint8List, which holds raw image data
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:image_picker/image_picker.dart'; // For image selection
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:kisangro/login/licence.dart'; // Assuming this is your next screen
import 'package:provider/provider.dart'; // For state management
import 'package:kisangro/models/kyc_image_provider.dart'; // Your custom KYC image provider

class kyc extends StatefulWidget {
  @override
  _kycState createState() => _kycState();
}

class _kycState extends State<kyc> {
  // Local state to hold the selected image bytes for immediate display on this screen.
  Uint8List? _imageBytes;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _panController = TextEditingController();

  /// Handles picking an image from the specified [source] (camera or gallery).
  /// Reads the image as raw bytes (Uint8List) and updates both local state
  /// and the shared [KycImageProvider].
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      // Read the image content as bytes. This is cross-platform compatible.
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes; // Update local state for immediate UI refresh
      });
      // Update the shared KycImageProvider so other screens can access this image.
      Provider.of<KycImageProvider>(context, listen: false).setKycImage(bytes); // Changed to setKycImage as per KycImageProvider
      print('KycImageProvider: Image bytes set. Length: ${bytes.lengthInBytes} bytes'); // Debug print for monitoring
    } else {
      print('Image picking cancelled from $source.');
    }
  }

  /// Displays a modal bottom sheet allowing the user to choose between
  /// taking a new photo with the camera. The "Choose from Gallery" option is removed.
  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Make the column as small as needed
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xffEB7720)),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.poppins(color: Colors.black87),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _pickImage(ImageSource.camera); // Call pick image from camera
                },
              ),
              // Removed the "Choose from Gallery" ListTile
              // ListTile(
              //   leading: const Icon(Icons.photo_library, color: Color(0xffEB7720)),
              //   title: Text(
              //     'Choose from Gallery',
              //     style: GoogleFonts.poppins(color: Colors.black87),
              //   ),
              //   onTap: () {
              //     Navigator.pop(context); // Close the bottom sheet
              //     _pickImage(ImageSource.gallery); // Call pick image from gallery
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  /// A helper widget to create styled section titles.
  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xffEB7720),
          ),
        ),
      ),
    );
  }

  /// A helper widget to create styled text form fields with validation and optional features.
  Widget _textFormField(
      String label, {
        String? hintText,
        bool isNumber = false,
        bool showVerify = false,
        bool isPAN = false,
        TextEditingController? controller,
      }) {
    return SizedBox(
      height: 70, // Fixed height to prevent layout shifts
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isPAN
              ? [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), // Allow alphanumeric for PAN
            UpperCaseTextFormatter(), // Custom formatter for uppercase
          ]
              : isNumber
              ? [FilteringTextInputFormatter.digitsOnly] // Allow only digits for numbers
              : null,
          maxLength: () { // Dynamic maxLength based on field type
            if (isPAN) return 10;
            if (!isNumber) return null;
            if (label == "WhatsApp Number" || label == "Business Contact Number") return 10;
            if (label == "Aadhaar Number (Owner)") return 12;
            return null;
          }(),
          decoration: InputDecoration(
            counterText: "", // Hides the default maxLength counter
            // Using OutlineInputBorder directly for transparent borders (web compatible)
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xfff8bc8c), width: 2)),
            filled: true,
            fillColor: Color(0xfff8bc8c),
            labelText: label,
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
            suffixIcon: showVerify // Conditional "Verify" button for GSTIN
                ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('GST Verified (dummy logic)!', style: GoogleFonts.poppins())),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  backgroundColor: Color(0xffEB7720),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
                child: Text(
                  'Verify',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              ),
            )
                : null,
          ),
          style: GoogleFonts.poppins(color: Colors.black),
          validator: (value) { // Basic validation
            if (value == null || value.isEmpty) return 'Please enter $label';

            if (isNumber) {
              if (label == "WhatsApp Number" || label == "Business Contact Number") {
                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                  return 'Enter a valid 10-digit $label';
                }
              }

              if (label == "Aadhaar Number (Owner)") {
                if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                  return 'Enter a valid 12-digit Aadhaar number';
                }
              }
            }

            if (isPAN) {
              if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(value.toUpperCase())) {
                return 'Enter a valid PAN number (e.g. ABCDE1234F)';
              }
            }

            return null;
          },
        ),
      ),
    );
  }

  /// A helper widget to create styled dropdown form fields.
  Widget _dropdownField(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SizedBox(
        height: 70, // Fixed height
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xfff8bc8c),
            labelText: label,
            border: OutlineInputBorder(), // Default OutlineInputBorder
          ),
          items: const [ // Added const for DropdownMenuItem list
            DropdownMenuItem(value: 'Retail', child: Text('Retail')),
            DropdownMenuItem(value: 'Wholesale', child: Text('Wholesale')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) {
            // Handle dropdown value change if needed
          },
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please select $label';
            return null;
          },
        ),
      ),
    );
  }

  /// Widget for the photo upload area, showing a camera icon or the selected image.
  Widget _photoUploadBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _showImageSourceSelection, // Tapping calls the source selection bottom sheet
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 1),
              ),
              // Display either the camera icon or the uploaded image
              child: _imageBytes == null
                  ? Icon(Icons.camera_alt, size: 50, color: Color(0xffEB7720))
                  : ClipOval(
                child: Image.memory( // Use Image.memory to display Uint8List
                  _imageBytes!, // Display the selected image bytes
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tap to upload a photo of your shop with good quality.', // Updated text
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey, // Associate form key for validation
            child: Column(
              children: [
                SizedBox(height: 10),
                Image.asset("assets/kyc1.gif"), // Your KYC illustration
                SizedBox(height: 10),
                Text(
                  '"Safe, Secure, And Hassle-Free KYC"',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  "Submit Your Details And Unlock Access To All KISANGRO B2B Products",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                Divider(endIndent: 130, indent: 130, color: Colors.black),
                _sectionTitle("Primary Details"),
                _textFormField("Full Name"),
                _textFormField("Mail Id"),
                _textFormField("WhatsApp Number", isNumber: true),
                _sectionTitle("Business Details"),
                _textFormField("Business Name"),
                _textFormField("GSTIN", showVerify: true),
                _textFormField("Aadhaar Number (Owner)", isNumber: true),
                _textFormField("Business PAN Number", isPAN: true, controller: _panController),
                _dropdownField("Nature Of Core Business"),
                _textFormField("Business Contact Number", isNumber: true),
                _sectionTitle("Establishment Photo"),
                _photoUploadBox(), // The updated photo upload box
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '(Note: A verification team will be arriving within 3 working days at the given address to verify your business. Make sure you are available at that time.)',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate form fields and check if an image has been uploaded
                      if (_formKey.currentState!.validate() && _imageBytes != null) {
                        // In a real app, you would send this data to your KYC API here.
                        // For now, we navigate.
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => licence1()), // Navigate to license selection screen
                        );
                      } else if (_imageBytes == null) {
                        // Show a message if no image is uploaded
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please upload a photo of your establishment.', style: GoogleFonts.poppins())),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      backgroundColor: Color(0xffEB7720),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
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

// Formatter to uppercase text for fields like PAN
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
