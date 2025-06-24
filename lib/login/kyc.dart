import 'dart:typed_data'; // Essential for Uint8List, which holds raw image data
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatter
import 'package:image_picker/image_picker.dart'; // For image selection
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:kisangro/login/licence.dart'; // Assuming this is your next screen
import 'package:provider/provider.dart'; // For state management
import 'package:kisangro/models/kyc_image_provider.dart'; // Your custom KYC image provider (for temporary image handling)
import 'package:kisangro/models/kyc_business_model.dart'; // NEW: Import KycBusinessData and KycBusinessDataProvider

class kyc extends StatefulWidget {
  @override
  _kycState createState() => _kycState();
}

class _kycState extends State<kyc> {
  // Local state to hold the selected image bytes for immediate display on this screen.
  Uint8List? _imageBytes;
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers for all input fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mailIdController = TextEditingController();
  final TextEditingController _whatsAppNumberController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _aadhaarNumberController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  String? _natureOfBusinessSelected; // For Dropdown
  final TextEditingController _businessContactNumberController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController(); // To store the autofilled address

  bool _isGstinVerified = false; // State to control visibility of Business Address
  KycBusinessDataProvider? _kycBusinessDataProvider; // Reference to the business provider
  KycImageProvider? _kycImageProvider; // Reference to the image provider

  static const int maxChars = 100; // Max characters for review (unused in this file but was there)

  @override
  void initState() {
    super.initState();
    // Access the providers here. listen: false as we're not rebuilding on every change here.
    _kycBusinessDataProvider = Provider.of<KycBusinessDataProvider>(context, listen: false);
    _kycImageProvider = Provider.of<KycImageProvider>(context, listen: false); // Initialize image provider

    _loadExistingKycData(); // Load existing data to pre-fill the form

    // Add listener for autofill of Business Contact Number
    _whatsAppNumberController.addListener(_autoFillBusinessContactNumber);
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _fullNameController.dispose();
    _mailIdController.dispose();
    _whatsAppNumberController.dispose();
    _businessNameController.dispose();
    _gstinController.dispose();
    _aadhaarNumberController.dispose();
    _panNumberController.dispose();
    _businessContactNumberController.dispose();
    _businessAddressController.dispose();
    _whatsAppNumberController.removeListener(_autoFillBusinessContactNumber); // Remove listener
    super.dispose();
  }

  /// Loads existing KYC data from the provider and populates the form fields.
  void _loadExistingKycData() {
    final existingBusinessData = _kycBusinessDataProvider?.kycBusinessData;
    if (existingBusinessData != null) {
      setState(() {
        _fullNameController.text = existingBusinessData.fullName ?? '';
        _mailIdController.text = existingBusinessData.mailId ?? '';
        _whatsAppNumberController.text = existingBusinessData.whatsAppNumber ?? '';
        _businessNameController.text = existingBusinessData.businessName ?? '';
        _gstinController.text = existingBusinessData.gstin ?? '';
        _isGstinVerified = existingBusinessData.isGstinVerified; // Set verification status
        _aadhaarNumberController.text = existingBusinessData.aadhaarNumber ?? '';
        _panNumberController.text = existingBusinessData.panNumber ?? '';
        _natureOfBusinessSelected = existingBusinessData.natureOfBusiness; // Set dropdown value
        _businessContactNumberController.text = existingBusinessData.businessContactNumber ?? '';
        _businessAddressController.text = existingBusinessData.businessAddress ?? ''; // Load saved address
        _imageBytes = existingBusinessData.shopImageBytes; // Set shop image for local display

        // Also ensure KycImageProvider is updated on load, if data exists
        if (existingBusinessData.shopImageBytes != null) {
          _kycImageProvider?.setKycImage(existingBusinessData.shopImageBytes!);
        }
      });
    }
  }

  /// Autofills the Business Contact Number with the WhatsApp Number.
  void _autoFillBusinessContactNumber() {
    if (_whatsAppNumberController.text.length == 10 && _businessContactNumberController.text.isEmpty) { // Only autofill if WhatsApp number is complete AND business contact is empty
      _businessContactNumberController.text = _whatsAppNumberController.text;
    }
  }

  /// Handles picking an image from the specified [source] (camera or gallery).
  /// Reads the image as raw bytes (Uint8List) and updates both local state,
  /// [KycBusinessDataProvider] (for persistence), and [KycImageProvider] (for UI display).
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes; // Update local state for immediate UI refresh
      });
      // Save image bytes to KycBusinessDataProvider for persistence
      await _kycBusinessDataProvider?.setKycBusinessData(shopImageBytes: bytes);
      // Also update KycImageProvider for real-time UI changes in CustomDrawer
      _kycImageProvider?.setKycImage(bytes); // *** THIS IS THE KEY ADDITION ***
      debugPrint('KYC Screen: Shop image bytes set to both business and image providers. Length: ${bytes.lengthInBytes} bytes'); // Debug print for monitoring
    } else {
      debugPrint('Image picking cancelled from $source.');
    }
  }

  /// Displays a modal bottom sheet allowing the user to choose between
  /// taking a new photo with the camera.
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
            ],
          ),
        );
      },
    );
  }

  /// A helper widget to create styled section titles.
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffEB7720),
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
            border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xfff8bc8c), width: 2)),
            filled: true,
            fillColor: const Color(0xfff8bc8c),
            labelText: label,
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
            suffixIcon: showVerify // Conditional "Verify" button for GSTIN
                ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Validate GSTIN field only before setting verified status
                  if (controller != null && controller.text.isNotEmpty) {
                    // Dummy GSTIN verification logic
                    // In a real app, this would be an API call that returns the address
                    setState(() {
                      _isGstinVerified = true;
                      // NEW: Autofill dummy business address here
                      _businessAddressController.text = "123 Verified Street, Business City, State - 600001";
                    });
                    // Also update in the provider
                    _kycBusinessDataProvider?.setKycBusinessData(
                        gstin: controller.text,
                        isGstinVerified: true,
                        businessAddress: _businessAddressController.text // Save the autofilled address
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('GST Verified (dummy logic)!', style: GoogleFonts.poppins())),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter GSTIN to verify.', style: GoogleFonts.poppins())),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  backgroundColor: const Color(0xffEB7720),
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
  Widget _dropdownField(String label, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SizedBox(
        height: 70, // Fixed height
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xfff8bc8c),
            labelText: label,
            border: const OutlineInputBorder(), // Default OutlineInputBorder
          ),
          items: const [
            DropdownMenuItem(value: 'Retail', child: Text('Retail')),
            DropdownMenuItem(value: 'Wholesale', child: Text('Wholesale')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: onChanged,
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
              // Display either the camera icon or the selected image
              child: _imageBytes == null
                  ? const Icon(Icons.camera_alt, size: 50, color: Color(0xffEB7720))
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
          const SizedBox(width: 10),
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
    final orange = const Color(0xffEB7720); // Define orange color here for local use

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey, // Associate form key for validation
            child: Column(
              children: [
                const SizedBox(height: 10),
                Image.asset("assets/kyc1.gif"), // Your KYC illustration
                const SizedBox(height: 10),
                Text(
                  '"Safe, Secure, And Hassle-Free KYC"',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  "Submit Your Details And Unlock Access To All KISANGRO B2B Products",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const Divider(endIndent: 130, indent: 130, color: Colors.black),
                _sectionTitle("Primary Details"),
                _textFormField("Full Name", controller: _fullNameController),
                _textFormField("Mail Id", controller: _mailIdController),
                _textFormField("WhatsApp Number", isNumber: true, controller: _whatsAppNumberController),
                _sectionTitle("Business Details"),
                _textFormField("Business Name", controller: _businessNameController),
                _textFormField("GSTIN", showVerify: true, controller: _gstinController),
                _textFormField("Aadhaar Number (Owner)", isNumber: true, controller: _aadhaarNumberController),
                _textFormField("Business PAN Number", isPAN: true, controller: _panNumberController),
                _dropdownField(
                  "Nature Of Core Business",
                  _natureOfBusinessSelected,
                      (newValue) {
                    setState(() {
                      _natureOfBusinessSelected = newValue;
                    });
                  },
                ),
                _textFormField("Business Contact Number", isNumber: true, controller: _businessContactNumberController),
                // NEW: Conditionally show Business Address HEADING and CONTENT
                if (_isGstinVerified) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Business Address", // Highlighted heading
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: orange, // Highlight in orange
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _businessAddressController.text.isNotEmpty
                            ? _businessAddressController.text
                            : 'Address not available.', // Display the autofilled address
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing after address
                ],
                _sectionTitle("Establishment Photo"),
                _photoUploadBox(), // The updated photo upload box
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '(Note: A verification team will be arriving within 3 working days at the given address to verify your business. Make sure you are available at that time.)',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate form fields and check if an image has been uploaded
                      if (_formKey.currentState!.validate() && _imageBytes != null) {
                        // Save all form data to KycBusinessDataProvider
                        await _kycBusinessDataProvider?.setKycBusinessData(
                          fullName: _fullNameController.text,
                          mailId: _mailIdController.text,
                          whatsAppNumber: _whatsAppNumberController.text,
                          businessName: _businessNameController.text,
                          gstin: _gstinController.text,
                          isGstinVerified: _isGstinVerified,
                          aadhaarNumber: _aadhaarNumberController.text,
                          panNumber: _panNumberController.text,
                          natureOfBusiness: _natureOfBusinessSelected,
                          businessContactNumber: _businessContactNumberController.text,
                          businessAddress: _businessAddressController.text, // Ensure this is saved
                          shopImageBytes: _imageBytes,
                        );

                        // Then navigate to the next screen
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
                      backgroundColor: orange,
                      minimumSize: const Size(double.infinity, 50),
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