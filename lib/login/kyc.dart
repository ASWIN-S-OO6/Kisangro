import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kisangro/login/licence.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/kyc_image_provider.dart';
import 'package:kisangro/models/kyc_business_model.dart';

class kyc extends StatefulWidget {
  @override
  _kycState createState() => _kycState();
}

class _kycState extends State<kyc> {
  Uint8List? _imageBytes;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mailIdController = TextEditingController();
  final TextEditingController _whatsAppNumberController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _aadhaarNumberController = TextEditingController();
  final TextEditingController _panNumberController = TextEditingController();
  String? _natureOfBusinessSelected;
  final TextEditingController _businessContactNumberController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();

  bool _isGstinVerified = false;
  Map<String, dynamic>? _gstinDetails;
  KycBusinessDataProvider? _kycBusinessDataProvider;
  KycImageProvider? _kycImageProvider;

  static const int maxChars = 100;

  @override
  void initState() {
    super.initState();
    debugPrint('KYC Screen: initState called');
    try {
      _kycBusinessDataProvider = Provider.of<KycBusinessDataProvider>(context, listen: false);
      _kycImageProvider = Provider.of<KycImageProvider>(context, listen: false);
      debugPrint('KYC Screen: Providers initialized successfully');
    } catch (e) {
      debugPrint('KYC Screen: Error initializing providers: $e');
    }

    _loadExistingKycData();
    _whatsAppNumberController.addListener(_autoFillBusinessContactNumber);
  }

  @override
  void dispose() {
    debugPrint('KYC Screen: dispose called');
    _fullNameController.dispose();
    _mailIdController.dispose();
    _whatsAppNumberController.dispose();
    _businessNameController.dispose();
    _gstinController.dispose();
    _aadhaarNumberController.dispose();
    _panNumberController.dispose();
    _businessContactNumberController.dispose();
    _businessAddressController.dispose();
    _whatsAppNumberController.removeListener(_autoFillBusinessContactNumber);
    super.dispose();
  }

  void _loadExistingKycData() {
    debugPrint('KYC Screen: Loading existing KYC data');
    try {
      final existingBusinessData = _kycBusinessDataProvider?.kycBusinessData;
      if (existingBusinessData != null) {
        setState(() {
          _fullNameController.text = existingBusinessData.fullName ?? '';
          _mailIdController.text = existingBusinessData.mailId ?? '';
          _whatsAppNumberController.text = existingBusinessData.whatsAppNumber ?? '';
          _businessNameController.text = existingBusinessData.businessName ?? '';
          _gstinController.text = existingBusinessData.gstin ?? '';
          _isGstinVerified = existingBusinessData.isGstinVerified;
          _aadhaarNumberController.text = existingBusinessData.aadhaarNumber ?? '';
          _panNumberController.text = existingBusinessData.panNumber ?? '';
          _natureOfBusinessSelected = existingBusinessData.natureOfBusiness;
          _businessContactNumberController.text = existingBusinessData.businessContactNumber ?? '';
          _businessAddressController.text = existingBusinessData.businessAddress ?? '';
          _imageBytes = existingBusinessData.shopImageBytes;

          if (existingBusinessData.shopImageBytes != null) {
            _kycImageProvider?.setKycImage(existingBusinessData.shopImageBytes!);
            debugPrint('KYC Screen: Loaded shop image bytes, length: ${existingBusinessData.shopImageBytes!.lengthInBytes}');
          }
          debugPrint('KYC Screen: Existing KYC data loaded successfully');
        });
      } else {
        debugPrint('KYC Screen: No existing KYC data found');
      }
    } catch (e) {
      debugPrint('KYC Screen: Error loading existing KYC data: $e');
    }
  }

  void _autoFillBusinessContactNumber() {
    if (_whatsAppNumberController.text.length == 10 && _businessContactNumberController.text.isEmpty) {
      _businessContactNumberController.text = _whatsAppNumberController.text;
      debugPrint('KYC Screen: Autofilled business contact number with WhatsApp number: ${_whatsAppNumberController.text}');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint('KYC Screen: Attempting to pick image from $source');
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
        await _kycBusinessDataProvider?.setKycBusinessData(shopImageBytes: bytes);
        _kycImageProvider?.setKycImage(bytes);
        debugPrint('KYC Screen: Shop image bytes set to both business and image providers. Length: ${bytes.lengthInBytes} bytes');
      } else {
        debugPrint('KYC Screen: Image picking cancelled from $source');
      }
    } catch (e) {
      debugPrint('KYC Screen: Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e', style: GoogleFonts.poppins())),
      );
    }
  }

  Widget _sectionTitle(String title, bool isTablet) { // Added isTablet parameter
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 15 : 10), // Responsive padding
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold, color: const Color(0xffEB7720)), // Responsive font size
        ),
      ),
    );
  }

  Widget _textFormField(
      String label, {
        String? hintText,
        bool isNumber = false,
        bool showVerify = false,
        bool isPAN = false,
        TextEditingController? controller,
        required bool isTablet, // Added isTablet parameter
      }) {
    return SizedBox(
      height: isTablet ? 80 : 70, // Responsive height for text fields
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 10), // Responsive horizontal padding
        child: TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isPAN
              ? [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), UpperCaseTextFormatter()]
              : isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          maxLength: () {
            if (isPAN) return 10;
            if (!isNumber) return null;
            if (label == "WhatsApp Number" || label == "Business Contact Number") return 10;
            if (label == "Aadhaar Number (Owner)") return 12;
            return null;
          }(),
          decoration: InputDecoration(
            counterText: "",
            border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xfff8bc8c), width: 2)),
            filled: true,
            fillColor: const Color(0xfff8bc8c),
            labelText: label,
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold),
            // Ensure content padding allows text to breathe
            contentPadding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16, horizontal: isTablet ? 20 : 12),
            isDense: true, // Add this to make the input field more compact
            suffixIcon: showVerify
                ? Padding(
              padding: EdgeInsets.zero, // Set padding to zero for perfect alignment
              child: ElevatedButton(
                onPressed: () async {
                  debugPrint('KYC Screen: Verify button clicked for GSTIN: ${controller?.text}');
                  if (controller != null && controller.text.isNotEmpty) {
                    if (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$')
                        .hasMatch(controller.text)) {
                      debugPrint('KYC Screen: Invalid GSTIN format: ${controller.text}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid GSTIN format. Please enter a valid GSTIN.', style: GoogleFonts.poppins())),
                      );
                      return;
                    }

                    debugPrint('KYC Screen: Showing loading indicator for GSTIN verification');
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final response = await _verifyGstinWithRetry(
                        gstin: controller.text,
                        cid: '21472147',
                        type: '1011',
                        ln: '2324',
                        lt: '23',
                        deviceId: '122',
                      );

                      Navigator.pop(context);
                      debugPrint('KYC Screen: Full GSTIN verification response: $response'); // Print full response

                      setState(() {
                        if (response['status'] == 'success') {
                          _isGstinVerified = true;
                          _gstinDetails = null;
                          String? businessAddressFromApi;

                          if (response['data'] is Map && response['data']['result']?['gstnDetailed'] != null) {
                            final gstnDetailed = response['data']['result']['gstnDetailed'];
                            businessAddressFromApi = gstnDetailed['principalPlaceOfBusiness']?['addrBldgNo'] != null ?
                            '${gstnDetailed['principalPlaceOfBusiness']['addrBldgNo']}, '
                                '${gstnDetailed['principalPlaceOfBusiness']['addrSt'] ?? ''}, '
                                '${gstnDetailed['principalPlaceOfBusiness']['addrLoc'] ?? ''}, '
                                '${gstnDetailed['principalPlaceOfBusiness']['addrDst'] ?? ''}, '
                                '${gstnDetailed['principalPlaceOfBusiness']['addrStcd'] ?? ''}, '
                                '${gstnDetailed['principalPlaceOfBusiness']['addrPncd'] ?? ''}'
                                .replaceAll(RegExp(r',?\s*,+'), ', ')
                                .trim()
                                .replaceAll(RegExp(r'^,?\s*'), '')
                                : null;

                            if (businessAddressFromApi == null || businessAddressFromApi.isEmpty) {
                              businessAddressFromApi = gstnDetailed['address'] ?? gstnDetailed['fullAddress'];
                            }

                            _gstinDetails = {
                              'Legal Name': gstnDetailed['legalNameOfBusiness'] ?? 'N/A',
                              'Centre Jurisdiction': gstnDetailed['centreJurisdiction'] ?? 'N/A',
                              'Business Address': businessAddressFromApi ?? 'N/A', // Store the full address
                            };

                            debugPrint('KYC Screen: Extracted GSTIN details: $_gstinDetails');
                            debugPrint('KYC Screen: Extracted Business Address from API: $businessAddressFromApi');
                          } else {
                            debugPrint('KYC Screen: gstnDetailed not found or unexpected data format in response. Using minimal details.');
                            _gstinDetails = {
                              'GSTIN': controller.text,
                              'Business Address': 'N/A', // Default if API doesn't provide it
                            };
                          }

                          _kycBusinessDataProvider?.setKycBusinessData(
                            gstin: controller.text,
                            isGstinVerified: true,
                            businessAddress: businessAddressFromApi,
                          );
                          debugPrint('KYC Screen: GSTIN verified successfully. Details: $_gstinDetails');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('GSTIN Verified Successfully!', style: GoogleFonts.poppins())),
                          );
                        } else {
                          _isGstinVerified = false;
                          _gstinDetails = null;
                          _businessAddressController.text = '';
                          final errorMsg = response['error_msg'] ?? 'GSTIN Verification Failed.';
                          debugPrint('KYC Screen: GSTIN verification failed: $errorMsg');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMsg, style: GoogleFonts.poppins())),
                          );
                        }
                      });
                    } catch (e) {
                      Navigator.pop(context);
                      debugPrint('KYC Screen: Error verifying GSTIN: $e');
                      setState(() {
                        _isGstinVerified = false;
                        _gstinDetails = null;
                        _businessAddressController.text = '';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error verifying GSTIN: $e', style: GoogleFonts.poppins())),
                      );
                    }
                  } else {
                    debugPrint('KYC Screen: GSTIN field is empty');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter GSTIN to verify.', style: GoogleFonts.poppins())),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  backgroundColor: const Color(0xffEB7720),
                  // Increased horizontal padding for wider button
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  minimumSize: Size.zero, // Allow button to shrink to content size
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Shrink tap target
                ),
                child: Text('Verify', style: GoogleFonts.poppins(fontSize: isTablet ? 14 : 12, color: Colors.white)), // Responsive font size
              ),
            )
                : null,
          ),
          style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black), // Responsive font size
          validator: (value) {
            if (value == null || value.isEmpty) {
              debugPrint('KYC Screen: Validation failed for $label: Field is empty');
              return 'Please enter $label';
            }
            if (isNumber) {
              if (label == "WhatsApp Number" || label == "Business Contact Number") {
                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                  debugPrint('KYC Screen: Validation failed for $label: Invalid 10-digit number: $value');
                  return 'Enter a valid 10-digit $label';
                }
              }
              if (label == "Aadhaar Number (Owner)") {
                if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                  debugPrint('KYC Screen: Validation failed for Aadhaar: Invalid 12-digit number: $value');
                  return 'Enter a valid 12-digit Aadhaar number';
                }
              }
            }
            if (isPAN) {
              if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(value.toUpperCase())) {
                debugPrint('KYC Screen: Validation failed for PAN: Invalid format: $value');
                return 'Enter a valid PAN number (e.g. ABCDE1234F)';
              }
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _dropdownField(String label, String? selectedValue, ValueChanged<String?> onChanged, bool isTablet) { // Added isTablet
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 10, vertical: isTablet ? 8 : 6), // Responsive padding
      child: SizedBox(
        height: isTablet ? 80 : 70, // Responsive height
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xfff8bc8c),
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16, horizontal: isTablet ? 20 : 12), // Responsive content padding
          ),
          items: const [
            DropdownMenuItem(value: 'contractor', child: Text('contractor')),
            /*DropdownMenuItem(value: 'Wholesale', child: Text('Wholesale')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),*/
          ],
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              debugPrint('KYC Screen: Validation failed for $label: No selection made');
              return 'Please select $label';
            }
            debugPrint('KYC Screen: Selected $label: $value');
            return null;
          },
          style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black), // Responsive font size
        ),
      ),
    );
  }

  Widget _photoUploadBox(bool isTablet) { // Added isTablet
    return Padding(
      padding: EdgeInsets.only(top: isTablet ? 20 : 10, left: isTablet ? 20 : 0, right: isTablet ? 20 : 0), // Responsive padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _pickImage(ImageSource.camera), // MODIFIED: Directly call camera
            child: Container(
              width: isTablet ? 160 : 130, // Responsive size
              height: isTablet ? 160 : 130, // Responsive size
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1)),
              child: _imageBytes == null
                  ? Icon(Icons.camera_alt, size: isTablet ? 70 : 50, color: const Color(0xffEB7720)) // Responsive icon size
                  : ClipOval(child: Image.memory(_imageBytes!, width: isTablet ? 160 : 130, height: isTablet ? 160 : 130, fit: BoxFit.cover)),
            ),
          ),
          SizedBox(width: isTablet ? 20 : 10), // Responsive spacing
          Expanded(
            child: Text(
              'Tap to upload a photo of your shop with good quality.',
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(fontSize: isTablet ? 15 : 13, color: Colors.black54), // Responsive font size
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _verifyGstinWithRetry({
    required String gstin,
    required String cid,
    required String type,
    required String ln,
    required String lt,
    required String deviceId,
    int retries = 2,
  }) async {
    const String apiUrl = 'https://sgserp.in/erp/api/m_api/';
    int attempt = 1;

    while (attempt <= retries) {
      debugPrint('KYC Screen: Initiating GSTIN verification for GSTIN: $gstin (Attempt $attempt/$retries)');

      try {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.headers['Content-Type'] = 'multipart/form-data';
        request.fields['gstin'] = gstin;
        request.fields['cid'] = cid;
        request.fields['type'] = type;
        request.fields['ln'] = ln;
        request.fields['lt'] = lt;
        request.fields['device_id'] = deviceId;

        if (_imageBytes != null) {
          request.files.add(http.MultipartFile.fromBytes('image', _imageBytes!, filename: 'shop_image.png'));
          debugPrint('KYC Screen: Added shop image to API request, size: ${_imageBytes!.lengthInBytes} bytes');
        } else {
          debugPrint('KYC Screen: No shop image included in API request');
        }

        debugPrint('KYC Screen: Sending POST request to $apiUrl with fields: ${request.fields}, headers: ${request.headers}');
        final response = await request.send().timeout(const Duration(seconds: 15));
        final responseBody = await response.stream.bytesToString();

        debugPrint('KYC Screen: API response status code: ${response.statusCode}');
        debugPrint('KYC Screen: Raw API response body: $responseBody');

        if (response.statusCode == 200) {
          try {
            String validJson = responseBody;
            if (responseBody.contains('}{')) {
              final jsonObjects = responseBody.split('}{');
              // Assuming the second JSON object is the desired one in case of concatenation
              validJson = '{${jsonObjects[1]}';
              debugPrint('KYC Screen: Detected malformed JSON, attempting to parse second object: $validJson');
            } else {
              debugPrint('KYC Screen: Using single JSON object for parsing.');
            }

            final Map<String, dynamic> responseData = jsonDecode(validJson);
            debugPrint('KYC Screen: Parsed API response: $responseData');
            return responseData;
          } catch (e) {
            debugPrint('KYC Screen: Error parsing JSON response: $e');
            if (attempt == retries) {
              throw Exception('Failed to parse API response after $retries attempts: $e');
            }
          }
        } else {
          debugPrint('KYC Screen: API request failed with status: ${response.statusCode}');
          if (attempt == retries) {
            throw Exception('API request failed with status ${response.statusCode} after $retries attempts');
          }
        }
      } catch (e) {
        debugPrint('KYC Screen: Network or API error: $e');
        if (attempt == retries) {
          throw Exception('Network error after $retries attempts: $e');
        }
      }
      attempt++;
      await Future.delayed(const Duration(seconds: 2)); // Delay before retry
    }
    throw Exception('Failed to verify GSTIN after $retries attempts');
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xffEB7720);
    debugPrint('KYC Screen: Building UI');

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
        child: LayoutBuilder( // Added LayoutBuilder to get constraints
          builder: (context, constraints) {
            // Determine if it's a "tablet-like" width
            final bool isTablet = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 24 : 16), // Responsive overall padding
              child: Center( // Center the content
                child: ConstrainedBox( // Constrain width for larger screens
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 700 : double.infinity, // Max width for tablet
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: isTablet ? 20 : 10), // Responsive spacing
                        Image.asset("assets/kyc1.gif", height: isTablet ? 200 : 150), // Responsive GIF size
                        SizedBox(height: isTablet ? 20 : 10), // Responsive spacing
                        Text('"Safe, Secure, And Hassle-Free KYC"', style: GoogleFonts.poppins(fontSize: isTablet ? 18 : 16, color: Colors.black87), textAlign: TextAlign.center), // Responsive font size
                        SizedBox(height: isTablet ? 10 : 5), // Responsive spacing
                        Text(
                          "Submit Your Details And Unlock Access To All KISANGRO B2B Products",
                          style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black54), // Responsive font size
                          textAlign: TextAlign.center,
                        ),
                        Divider(endIndent: isTablet ? 200 : 130, indent: isTablet ? 200 : 130, color: Colors.black), // Responsive indent
                        _sectionTitle("Primary Details", isTablet), // Pass isTablet
                        _textFormField("Full Name", controller: _fullNameController, isTablet: isTablet), // Pass isTablet
                        _textFormField("Mail Id", controller: _mailIdController, isTablet: isTablet), // Pass isTablet
                        _textFormField("WhatsApp Number", isNumber: true, controller: _whatsAppNumberController, isTablet: isTablet), // Pass isTablet
                        _sectionTitle("Business Details", isTablet), // Pass isTablet
                        _textFormField("Business Name", controller: _businessNameController, isTablet: isTablet), // Pass isTablet
                        _textFormField("GSTIN", showVerify: true, controller: _gstinController, isTablet: isTablet), // Pass isTablet
                        _textFormField("Aadhaar Number (Owner)", isNumber: true, controller: _aadhaarNumberController, isTablet: isTablet), // Pass isTablet
                        _textFormField("Business PAN Number", isPAN: true, controller: _panNumberController, isTablet: isTablet), // Pass isTablet
                        _dropdownField("Nature Of Core Business", _natureOfBusinessSelected, (newValue) {
                          setState(() {
                            _natureOfBusinessSelected = newValue;
                            debugPrint('KYC Screen: Nature of Business selected: $newValue');
                          });
                        }, isTablet), // Pass isTablet
                        _textFormField("Business Contact Number", isNumber: true, controller: _businessContactNumberController, isTablet: isTablet), // Pass isTablet
                        _textFormField("Business Address", controller: _businessAddressController, isTablet: isTablet), // Pass isTablet
                        if (_isGstinVerified) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 10, vertical: isTablet ? 15 : 10), // Responsive padding
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Verified GSTIN Details", style: GoogleFonts.poppins(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.bold, color: orange)), // Responsive font size
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 10), // Responsive padding
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _gstinDetails != null && _gstinDetails!.containsKey('Legal Name')
                                  ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Legal Name: ',
                                            style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black87, fontWeight: FontWeight.bold), // Responsive font size
                                          ),
                                          TextSpan(
                                            text: '${_gstinDetails!['Legal Name']}',
                                            style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black87), // Responsive font size
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Centre Jurisdiction: ',
                                            style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black87, fontWeight: FontWeight.bold), // Responsive font size
                                          ),
                                          TextSpan(
                                            text: '${_gstinDetails!['Centre Jurisdiction']}',
                                            style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black87), // Responsive font size
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Display Business Address from GSTIN details if available
                                  if (_gstinDetails!.containsKey('Business Address') && _gstinDetails!['Business Address'] != 'N/A')
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Business Address: ',
                                              style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black87, fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                              text: '${_gstinDetails!['Business Address']}',
                                              style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )
                                  : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'GSTIN: ',
                                            style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black87, fontWeight: FontWeight.bold), // Responsive font size
                                          ),
                                          TextSpan(
                                            text: '${_gstinDetails?['GSTIN'] ?? _gstinController.text}',
                                            style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black87), // Responsive font size
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text('Business details not available. Please contact support.', style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, color: Colors.black87)), // Responsive font size
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 20 : 10), // Responsive spacing
                        ],
                        _sectionTitle("Establishment Photo", isTablet), // Pass isTablet
                        _photoUploadBox(isTablet), // Pass isTablet
                        SizedBox(height: isTablet ? 30 : 20), // Responsive spacing
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 8.0), // Responsive padding
                          child: Text(
                            '(Note: A verification team will be arriving within 3 working days at the given address to verify your business. Make sure you are available at that time.)',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(fontSize: isTablet ? 14 : 12, color: Colors.black87), // Responsive font size
                          ),
                        ),
                        SizedBox(height: isTablet ? 30 : 20), // Responsive spacing
                        SizedBox(
                          width: isTablet ? 400 : double.infinity, // Adjusted button width for tablets
                          child: ElevatedButton(
                            onPressed: () async {
                              debugPrint('KYC Screen: Next button clicked');
                              FocusScope.of(context).unfocus();

                              if (_formKey.currentState!.validate()) {
                                if (_imageBytes == null) {
                                  debugPrint('KYC Screen: No establishment photo uploaded');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please upload a photo of your establishment.', style: GoogleFonts.poppins())),
                                  );
                                  return;
                                }
                                if (!_isGstinVerified) {
                                  debugPrint('KYC Screen: GSTIN not verified');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please verify GSTIN before proceeding.', style: GoogleFonts.poppins())),
                                  );
                                  return;
                                }

                                try {
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
                                    // Use the address from the controller if manually entered,
                                    // otherwise, it will be the one populated from GSTIN verification.
                                    businessAddress: _businessAddressController.text.isNotEmpty
                                        ? _businessAddressController.text
                                        : _kycBusinessDataProvider?.kycBusinessData?.businessAddress,
                                    shopImageBytes: _imageBytes,
                                  );
                                  debugPrint('KYC Screen: KYC data saved to provider successfully');
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => licence1()));
                                  debugPrint('KYC Screen: Navigated to licence1 screen');
                                } catch (e) {
                                  debugPrint('KYC Screen: Error saving KYC data or navigating: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error saving KYC data: $e', style: GoogleFonts.poppins())),
                                  );
                                }
                              } else {
                                debugPrint('KYC Screen: Form validation failed');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please correct the errors in the form.', style: GoogleFonts.poppins())),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              backgroundColor: orange,
                              minimumSize: Size.fromHeight(isTablet ? 60 : 50), // Responsive height
                            ),
                            child: Text('Next', style: GoogleFonts.poppins(fontSize: isTablet ? 20 : 18, color: Colors.white)), // Responsive font size
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}
