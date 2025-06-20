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

class licence2 extends StatefulWidget {
  @override
  _licence2State createState() => _licence2State();
}

class _licence2State extends State<licence2> {
  // Controllers for pesticide license only
  final TextEditingController _pesticideLicenseController = TextEditingController();

  // State variables for expiration date
  DateTime? _pesticideExpirationDate;

  // State variable for "no expiry" checkbox
  bool _pesticideNoExpiry = false;

  // State variable for uploaded document bytes
  Uint8List? _pesticideImageBytes;

  // State variable to track if the uploaded file was an image or PDF for display
  bool _pesticideIsImage = true;

  // ML Kit text recognizer for images
  final TextRecognizer _textRecognizer = TextRecognizer();

  // Regex pattern for pesticide license extraction
  final RegExp _pesticideLicenseRegExp = RegExp(
    r'.*(?:License Number|Licence Number)\s*(TKK\s*/\s*PP\s*/\s*\d+\s*/\s*\d{4}\s*-\s*\d{2,4})',
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

  @override
  void initState() {
    super.initState();
    _pesticideLicenseController.addListener(_checkFormValidity);
    _checkFormValidity();
  }

  // Form validity check
  bool get isFormValid {
    return _pesticideLicenseController.text.isNotEmpty &&
        (_pesticideNoExpiry || _pesticideExpirationDate != null) &&
        _pesticideImageBytes != null;
  }

  void _checkFormValidity() {
    setState(() {});
  }

  Future<void> _pickDate(BuildContext context) async {
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
        _pesticideExpirationDate = picked;
        _pesticideNoExpiry = false;
      });
      _checkFormValidity();
    }
  }

  Future<void> _pickFile() async {
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
                    await _processImageFile(pickedFile);
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
                    await _processImageFile(pickedFile);
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
                    await _processPdfFile(result.files.single);
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

  Future<void> _processImageFile(XFile imageFile) async {
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
          _pesticideImageBytes = bytes;
          _pesticideIsImage = true;
        });
        _checkFormValidity();
        return;
      }

      await _extractLicenseData(extractedText, bytes, true);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e. Please enter details manually.')),
      );
      try {
        final bytes = await imageFile.readAsBytes();
        setState(() {
          _pesticideImageBytes = bytes;
          _pesticideIsImage = true;
        });
        _checkFormValidity();
      } catch (e2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e2')),
        );
      }
    }
  }

  Future<void> _processPdfFile(PlatformFile file) async {
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
          _pesticideImageBytes = bytes;
          _pesticideIsImage = false;
        });
        _checkFormValidity();
        return;
      }

      await _extractLicenseData(extractedText, bytes, false);
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
          _pesticideImageBytes = bytes;
          _pesticideIsImage = false;
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

  Future<void> _extractLicenseData(String extractedText, Uint8List bytes, bool isImage) async {
    String? licenseNumber;
    String? expiryDateStr;
    bool isPermanent = false;

    final cleanText = extractedText.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();
    print('Extracted text (cleaned): $cleanText');

    final licenseMatch = _pesticideLicenseRegExp.firstMatch(cleanText);
    if (licenseMatch != null && licenseMatch.group(1) != null) {
      licenseNumber = licenseMatch.group(1)?.replaceAll(RegExp(r'\s+'), '');
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
      _pesticideImageBytes = bytes;
      _pesticideIsImage = isImage;
      if (licenseNumber != null) {
        _pesticideLicenseController.text = licenseNumber.toUpperCase();
      } else {
        _pesticideLicenseController.clear();
      }
      if (isPermanent) {
        _pesticideNoExpiry = true;
        _pesticideExpirationDate = null;
      } else if (expiryDateStr != null && expiryDateStr != 'Permanent') {
        _pesticideNoExpiry = false;
        _pesticideExpirationDate = _parseDate(expiryDateStr);
      } else {
        _pesticideNoExpiry = false;
        _pesticideExpirationDate = null;
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
    _pesticideLicenseController.removeListener(_checkFormValidity);
    _pesticideLicenseController.dispose();
    _textRecognizer.close();
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
                Text('Pesticide License', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xffEB7720))),
                const SizedBox(height: 10),
                TextField(
                  controller: _pesticideLicenseController,
                  style: GoogleFonts.poppins(),
                  decoration: _inputDecoration("Enter Pesticide License Number"),
                ),
                const SizedBox(height: 20),
                _buildDatePickerRow(context),
                _buildCheckbox(),
                _buildImageUpload("Upload Document", _pesticideImageBytes, _pesticideIsImage, () => _pickFile()),

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

  Widget _buildDatePickerRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pesticideNoExpiry ? null : () => _pickDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xfff8bc8c), borderRadius: BorderRadius.circular(8)),
              child: Text(
                _pesticideExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_pesticideExpirationDate!) : 'Expiration Date',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: _pesticideExpirationDate != null ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.calendar_month, color: Color(0xffEB7720), size: 40),
          onPressed: _pesticideNoExpiry ? null : () => _pickDate(context),
        ),
      ],
    );
  }

  Widget _buildCheckbox() {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      checkColor: Colors.white,
      activeColor: const Color(0xffEB7720),
      title: Text('This License Doesn\'t Expire', style: GoogleFonts.poppins()),
      value: _pesticideNoExpiry,
      onChanged: (value) {
        setState(() {
          _pesticideNoExpiry = value!;
          if (value) _pesticideExpirationDate = null;
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