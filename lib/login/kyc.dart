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

  void _showImageSourceSelection() {
    debugPrint('KYC Screen: Showing image source selection');
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xffEB7720)),
                title: Text('Take Photo', style: GoogleFonts.poppins(color: Colors.black87)),
                onTap: () {
                  debugPrint('KYC Screen: Selected camera for image picking');
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xffEB7720)),
                title: Text('Choose from Gallery', style: GoogleFonts.poppins(color: Colors.black87)),
                onTap: () {
                  debugPrint('KYC Screen: Selected gallery for image picking');
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xffEB7720)),
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
      }) {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
            suffixIcon: showVerify
                ? Padding(
              padding: const EdgeInsets.only(right: 8.0),
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

                          if (response['data'] is Map && response['data']['result']?['gstnDetailed'] != null) {
                            final gstnDetailed = response['data']['result']['gstnDetailed'];
                            _gstinDetails = {
                              'Legal Name': gstnDetailed['legalNameOfBusiness'] ?? 'N/A',
                              'Centre Jurisdiction': gstnDetailed['centreJurisdiction'] ?? 'N/A',
                            };
                            debugPrint('KYC Screen: Extracted GSTIN details: $_gstinDetails');
                          } else {
                            debugPrint('KYC Screen: gstnDetailed not found or unexpected data format in response. Using minimal details.');
                            _gstinDetails = {
                              'GSTIN': controller.text, // Fallback to display GSTIN if detailed info isn't available
                            };
                          }

                          // We are no longer setting _businessAddressController.text here
                          _kycBusinessDataProvider?.setKycBusinessData(
                            gstin: controller.text,
                            isGstinVerified: true,
                            // businessAddress is not set from GSTIN details here
                          );
                          debugPrint('KYC Screen: GSTIN verified successfully. Details: $_gstinDetails');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('GSTIN Verified Successfully!', style: GoogleFonts.poppins())),
                          );
                        } else {
                          _isGstinVerified = false;
                          _gstinDetails = null;
                          _businessAddressController.text = ''; // Clear address if verification fails
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
                child: Text('Verify', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
              ),
            )
                : null,
          ),
          style: GoogleFonts.poppins(color: Colors.black),
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

  Widget _dropdownField(String label, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: SizedBox(
        height: 70,
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xfff8bc8c),
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Retail', child: Text('Retail')),
            DropdownMenuItem(value: 'Wholesale', child: Text('Wholesale')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
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
        ),
      ),
    );
  }

  Widget _photoUploadBox() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _showImageSourceSelection,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1)),
              child: _imageBytes == null
                  ? const Icon(Icons.camera_alt, size: 50, color: Color(0xffEB7720))
                  : ClipOval(child: Image.memory(_imageBytes!, width: 130, height: 130, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tap to upload a photo of your shop with good quality.',
              textAlign: TextAlign.start,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Image.asset("assets/kyc1.gif"),
                const SizedBox(height: 10),
                Text('"Safe, Secure, And Hassle-Free KYC"', style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87), textAlign: TextAlign.center),
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
                _dropdownField("Nature Of Core Business", _natureOfBusinessSelected, (newValue) {
                  setState(() {
                    _natureOfBusinessSelected = newValue;
                    debugPrint('KYC Screen: Nature of Business selected: $newValue');
                  });
                }),
                _textFormField("Business Contact Number", isNumber: true, controller: _businessContactNumberController),
                if (_isGstinVerified) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Verified GSTIN Details", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: orange)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '${_gstinDetails!['Legal Name']}',
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
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
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '${_gstinDetails!['Centre Jurisdiction']}',
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
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
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '${_gstinDetails?['GSTIN'] ?? _gstinController.text}',
                                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text('Business details not available. Please contact support.', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                _sectionTitle("Establishment Photo"),
                _photoUploadBox(),
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
                      debugPrint('KYC Screen: Next button clicked');
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
                            businessAddress: _businessAddressController.text,
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      backgroundColor: orange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text('Next', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}