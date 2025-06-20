import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/login/onprocess.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show File;

class licence4 extends StatefulWidget {
  final String? licenseTypeToDisplay; // New parameter

  const licence4({super.key, this.licenseTypeToDisplay}); // Updated constructor

  @override
  _licence4State createState() => _licence4State();
}

class _licence4State extends State<licence4> {
  // Controllers for license numbers
  final TextEditingController _insecticideLicenseController = TextEditingController();
  final TextEditingController _fertilizerLicenseController = TextEditingController();

  // State variables for expiration dates
  DateTime? _insecticideExpirationDate;
  DateTime? _fertilizerExpirationDate;

  // State variables for "no expiry" checkboxes
  bool _insecticideNoExpiry = false;
  bool _fertilizerNoExpiry = false;

  // State variables for uploaded document bytes
  Uint8List? _insecticideImageBytes;
  Uint8List? _fertilizerImageBytes;

  // State variables to track if the uploaded file was an image or PDF for display
  bool _insecticideIsImage = true;
  bool _fertilizerIsImage = true;

  // ML Kit text recognizer for images
  final TextRecognizer _textRecognizer = TextRecognizer();

  // Regex patterns for extraction
  final RegExp _insecticideLicenseRegExp = RegExp(
    r'.*(?:License Number|Licence Number)\s*(TKK\s*/\s*PP\s*/\s*\d+\s*/\s*\d{4}\s*-\s*\d{2,4})',
    caseSensitive: false,
  );

  final RegExp _fertilizerLicenseRegExp = RegExp(
    r'CR\s*No\.?\s*(\d+\s*/\s*NR\s*/\s*CPT\s*/\s*TKK\s*/\s*\d{4}\s*-\s*\d{4})',
    caseSensitive: false,
  );

  final List<RegExp> _datePatterns = [
    RegExp(r'(?:Valid\s+upto|Valid\s+up\s+to)\s*:?\s*(\d{1,2}[\.\-\/]\d{1,2}[\.\-\/]\d{4})', caseSensitive: false),
    RegExp(r'\b(\d{1,2}[\.\-\/]\d{1,2}[\.\-\/]\d{4})\b'),
    RegExp(r'\b(\d{4}[\.\-\/]\d{1,2}[\.\-\/]\d{1,2})\b'),
  ];

  final RegExp _permanentPattern = RegExp(
    r'(?:Permanent|No\s+Expiry|Non\s+Expiring|Validity\s+wherever\s+applicable\s*:\s*Permanent)',
    caseSensitive: false,
  );

  // Variable to store which section to display
  String? _currentLicenseTypeToDisplay;

  @override
  void initState() {
    super.initState();
    _currentLicenseTypeToDisplay = widget.licenseTypeToDisplay; // Initialize from widget parameter
    _insecticideLicenseController.addListener(_checkFormValidity);
    _fertilizerLicenseController.addListener(_checkFormValidity);
    _checkFormValidity();
  }

  // Getters to check validity of each section
  bool get _isInsecticideSectionValid {
    // Only validate if this section is displayed or intended to be valid
    if (_currentLicenseTypeToDisplay == 'fertilizer') return true; // If only fertilizer is shown, pesticide section is implicitly valid
    return _insecticideLicenseController.text.isNotEmpty &&
        (_insecticideNoExpiry || _insecticideExpirationDate != null) &&
        _insecticideImageBytes != null;
  }

  bool get _isFertilizerSectionValid {
    // Only validate if this section is displayed or intended to be valid
    if (_currentLicenseTypeToDisplay == 'pesticide') return true; // If only pesticide is shown, fertilizer section is implicitly valid
    return _fertilizerLicenseController.text.isNotEmpty &&
        (_fertilizerNoExpiry || _fertilizerExpirationDate != null) &&
        _fertilizerImageBytes != null;
  }

  // Overall form validity
  bool get isFormValid {
    if (_currentLicenseTypeToDisplay == 'pesticide') {
      return _isInsecticideSectionValid;
    } else if (_currentLicenseTypeToDisplay == 'fertilizer') {
      return _isFertilizerSectionValid;
    } else { // 'all' or null
      return _isInsecticideSectionValid || _isFertilizerSectionValid;
    }
  }

  void _checkFormValidity() {
    setState(() {});
  }

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
              primary: Color(0xffEB7720),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xffEB7720)),
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
          _insecticideNoExpiry = false;
        } else {
          _fertilizerExpirationDate = picked;
          _fertilizerNoExpiry = false;
        }
      });
      _checkFormValidity();
    }
  }

  Future<void> _pickFile(bool isInsecticide) async {
    try {
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
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (pickedFile != null) {
                    await _processImageFile(pickedFile, isInsecticide);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xffEB7720)),
                title: const Text('Open Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );
                  if (pickedFile != null) {
                    await _processImageFile(pickedFile, isInsecticide);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Color(0xffEB7720)),
                title: const Text('Upload PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );
                  if (result != null && (result.files.single.bytes != null || result.files.single.path != null)) {
                    await _processPdfFile(result.files.single, isInsecticide);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No PDF selected. Please try again.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file picker: $e')),
      );
    }
  }

  Future<void> _processImageFile(XFile imageFile, bool isInsecticide) async {
    _showProcessingDialog('Processing image...');
    try {
      final bytes = await imageFile.readAsBytes();
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      final extractedText = recognizedText.text;

      Navigator.pop(context);

      if (extractedText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text found in the image. Please enter details manually.')),
        );
        setState(() {
          if (isInsecticide) {
            _insecticideImageBytes = bytes;
            _insecticideIsImage = true;
          } else {
            _fertilizerImageBytes = bytes;
            _fertilizerIsImage = true;
          }
        });
        _checkFormValidity();
        return;
      }

      await _extractLicenseData(extractedText, isInsecticide, bytes, true);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e. Please enter details manually.')),
      );
      try {
        final bytes = await imageFile.readAsBytes();
        setState(() {
          if (isInsecticide) {
            _insecticideImageBytes = bytes;
            _insecticideIsImage = true;
          } else {
            _fertilizerImageBytes = bytes;
            _fertilizerIsImage = true;
          }
        });
        _checkFormValidity();
      } catch (e2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e2')),
        );
      }
    }
  }

  Future<void> _processPdfFile(PlatformFile file, bool isInsecticide) async {
    _showProcessingDialog('Processing PDF...');

    File? tempFile;
    try {
      Uint8List bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      } else {
        throw Exception('No bytes or path available for the PDF file.');
      }

      final tempDir = await getTemporaryDirectory();
      tempFile = File('${tempDir.path}/${file.name?.replaceAll(RegExp(r'[^\w\.]'), '_') ?? 'temp_pdf.pdf'}');
      await tempFile.writeAsBytes(bytes);

      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final StringBuffer textBuffer = StringBuffer();
      for (int i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        textBuffer.writeln(pageText);
      }
      final extractedText = textBuffer.toString();
      document.dispose();

      Navigator.pop(context);

      if (extractedText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text found in the PDF. Please enter details manually.')),
        );
        setState(() {
          if (isInsecticide) {
            _insecticideImageBytes = bytes;
            _insecticideIsImage = false;
          } else {
            _fertilizerImageBytes = bytes;
            _fertilizerIsImage = false;
          }
        });
        _checkFormValidity();
        return;
      }

      await _extractLicenseData(extractedText, isInsecticide, bytes, false);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing PDF: $e. Please enter details manually.')),
      );
      try {
        Uint8List bytes;
        if (file.bytes != null) {
          bytes = file.bytes!;
        } else if (file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        } else {
          throw Exception('No bytes or path available for the PDF file.');
        }
        setState(() {
          if (isInsecticide) {
            _insecticideImageBytes = bytes;
            _insecticideIsImage = false;
          } else {
            _fertilizerImageBytes = bytes;
            _fertilizerIsImage = false;
          }
        });
        _checkFormValidity();
      } catch (e2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading PDF: $e2')),
        );
      }
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }

  void _showProcessingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  Future<void> _extractLicenseData(String extractedText, bool isInsecticide, Uint8List bytes, bool isImage) async {
    String? licenseNumber;
    String? expiryDateStr;
    bool isPermanent = false;

    final cleanText = extractedText.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
    print('Extracted text (cleaned): $cleanText');

    if (isInsecticide) {
      final licenseMatch = _insecticideLicenseRegExp.firstMatch(cleanText);
      if (licenseMatch != null && licenseMatch.group(1) != null) {
        licenseNumber = licenseMatch.group(1)?.replaceAll(RegExp(r'\s+'), '');
      }
    } else {
      final licenseMatch = _fertilizerLicenseRegExp.firstMatch(cleanText);
      if (licenseMatch != null && licenseMatch.group(1) != null) {
        licenseNumber = licenseMatch.group(1)?.replaceAll(RegExp(r'\s+'), '');
      }
    }

    if (_permanentPattern.hasMatch(cleanText)) {
      isPermanent = true;
      expiryDateStr = 'Permanent';
    } else {
      for (RegExp pattern in _datePatterns) {
        final match = pattern.firstMatch(cleanText);
        if (match != null) {
          String matchedDate = match.group(1) ?? match.group(0)!;
          if (!cleanText.contains('date of grant of licence') || !cleanText.contains(matchedDate)) {
            expiryDateStr = matchedDate;
            break;
          }
        }
      }
    }

    setState(() {
      if (isInsecticide) {
        _insecticideImageBytes = bytes;
        _insecticideIsImage = isImage;
        if (licenseNumber != null) {
          _insecticideLicenseController.text = licenseNumber.toUpperCase();
        } else {
          _insecticideLicenseController.clear();
        }
        if (isPermanent) {
          _insecticideNoExpiry = true;
          _insecticideExpirationDate = null;
        } else if (expiryDateStr != null && expiryDateStr != 'Permanent') {
          _insecticideNoExpiry = false;
          _insecticideExpirationDate = _parseDate(expiryDateStr);
        } else {
          _insecticideNoExpiry = false;
          _insecticideExpirationDate = null;
        }
      } else {
        _fertilizerImageBytes = bytes;
        _fertilizerIsImage = isImage;
        if (licenseNumber != null) {
          _fertilizerLicenseController.text = licenseNumber.toUpperCase();
        } else {
          _fertilizerLicenseController.clear();
        }
        if (isPermanent) {
          _fertilizerNoExpiry = true;
          _fertilizerExpirationDate = null;
        } else if (expiryDateStr != null && expiryDateStr != 'Permanent') {
          _fertilizerNoExpiry = false;
          _fertilizerExpirationDate = _parseDate(expiryDateStr);
        } else {
          _fertilizerNoExpiry = false;
          _fertilizerExpirationDate = null;
        }
      }
    });

    _checkFormValidity();

    String message = 'Document uploaded successfully!\n';
    if (licenseNumber != null) {
      message += 'License: ${licenseNumber.toUpperCase()}\n';
    }
    if (isPermanent) {
      message += 'Validity: Permanent';
    } else if (expiryDateStr != null) {
      message += 'Expiry: $expiryDateStr';
    }
    if (licenseNumber == null && expiryDateStr == null) {
      message = 'Document uploaded but could not extract license details. Please verify or enter manually.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  DateTime? _parseDate(String dateStr) {
    String cleanDate = dateStr.replaceAll(RegExp(r'[^\d\.\-\/]'), '');
    List<String> formats = ['dd.MM.yyyy', 'dd-MM.yyyy', 'dd/MM/yyyy', 'yyyy.MM.dd', 'yyyy-MM-dd', 'yyyy/MM/dd'];

    for (String format in formats) {
      try {
        return DateFormat(format).parseStrict(cleanDate);
      } catch (e) {
        continue;
      }
    }
    print('Failed to parse date: $cleanDate');
    return null;
  }

  @override
  void dispose() {
    _insecticideLicenseController.removeListener(_checkFormValidity);
    _fertilizerLicenseController.removeListener(_checkFormValidity);
    _insecticideLicenseController.dispose();
    _fertilizerLicenseController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showPesticideSection = _currentLicenseTypeToDisplay == null || _currentLicenseTypeToDisplay == 'pesticide' || _currentLicenseTypeToDisplay == 'all';
    bool showFertilizerSection = _currentLicenseTypeToDisplay == null || _currentLicenseTypeToDisplay == 'fertilizer' || _currentLicenseTypeToDisplay == 'all';

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

                if (showPesticideSection) // Conditionally render Pesticide Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1. Pesticide License', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xffEB7720))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _insecticideLicenseController,
                        style: GoogleFonts.poppins(),
                        decoration: _inputDecoration("Enter Pesticide License Number"),
                      ),
                      const SizedBox(height: 20),
                      _buildDatePickerRow(context, true),
                      _buildCheckbox(true),
                      _buildImageUpload("Upload Document", _insecticideImageBytes, _insecticideIsImage, () => _pickFile(true)),
                      if (showFertilizerSection) const SizedBox(height: 20), // Add spacing if both sections are shown
                    ],
                  ),

                if (showFertilizerSection) // Conditionally render Fertilizer Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('2. Fertilizer License', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xffEB7720))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _fertilizerLicenseController,
                        style: GoogleFonts.poppins(),
                        decoration: _inputDecoration("Enter Fertilizer License Number"),
                      ),
                      const SizedBox(height: 20),
                      _buildDatePickerRow(context, false),
                      _buildCheckbox(false),
                      _buildImageUpload("Upload Document", _fertilizerImageBytes, _fertilizerIsImage, () => _pickFile(false)),
                    ],
                  ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isFormValid
                      ? () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => KisanProApp()),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(),
      filled: true,
      fillColor: const Color(0xfff8bc8c),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }

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
        ),
      ],
    );
  }

  Widget _buildCheckbox(bool isInsecticide) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      checkColor: Colors.white,
      activeColor: const Color(0xffEB7720),
      title: Text('This License Doesn\'t Expire', style: GoogleFonts.poppins()),
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
        _checkFormValidity();
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildImageUpload(String title, Uint8List? imageBytes, bool isImage, VoidCallback onTap) {
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
            child: imageBytes == null
                ? const Center(child: Icon(Icons.camera_alt, color: Color(0xffEB7720), size: 40))
                : isImage
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(imageBytes, fit: BoxFit.cover),
            )
                : const Center(child: Icon(Icons.picture_as_pdf, color: Color(0xffEB7720), size: 40)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '(Note: The given documents\nwill be verified by our team\nshortly to verify its\nauthentication)',
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }
}