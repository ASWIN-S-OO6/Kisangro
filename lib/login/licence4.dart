import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/login/onprocess.dart'; // Correct import for KycSplashScreen
import 'package:shared_preferences/shared_preferences.dart';
// Removed: import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// Removed: import 'package:syncfusion_flutter_pdf/pdf.dart';
// Removed: import 'package:path_provider/path_provider.dart';
import 'dart:io' show File; // Keep File for reading bytes from path
import 'package:provider/provider.dart';
import 'package:kisangro/models/license_provider.dart';
import 'package:kisangro/home/bottom.dart'; // Import Bot for direct navigation after process

class licence4 extends StatefulWidget {
  final String? licenseTypeToDisplay;

  const licence4({super.key, this.licenseTypeToDisplay});

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

  Uint8List? _insecticideImageBytes;
  Uint8List? _fertilizerImageBytes;

  bool _insecticideIsImage = true;
  bool _fertilizerIsImage = true;

  // Removed: final TextRecognizer _textRecognizer = TextRecognizer();
  // Removed: final RegExp _licenseNumberRegExp = ...
  // Removed: final List<RegExp> _datePatterns = ...
  // Removed: final RegExp _permanentPattern = ...

  String? _currentLicenseTypeToDisplay;

  @override
  void initState() {
    super.initState();
    _currentLicenseTypeToDisplay = widget.licenseTypeToDisplay;
    _insecticideLicenseController.addListener(_checkFormValidity);
    _fertilizerLicenseController.addListener(_checkFormValidity);
    _loadExistingLicenseData(); // Load data first
    _checkFormValidity(); // Then check validity based on loaded data
  }

  Future<void> _loadExistingLicenseData() async {
    final licenseProvider = Provider.of<LicenseProvider>(context, listen: false);

    final pesticideData = licenseProvider.pesticideLicense;
    if (pesticideData != null) {
      setState(() {
        _insecticideLicenseController.text = pesticideData.licenseNumber ?? '';
        _insecticideExpirationDate = pesticideData.expirationDate;
        _insecticideNoExpiry = pesticideData.noExpiry;
        _insecticideImageBytes = pesticideData.imageBytes;
        _insecticideIsImage = pesticideData.isImage;
      });
    }

    final fertilizerData = licenseProvider.fertilizerLicense;
    if (fertilizerData != null) {
      setState(() {
        _fertilizerLicenseController.text = fertilizerData.licenseNumber ?? '';
        _fertilizerExpirationDate = fertilizerData.expirationDate;
        _fertilizerNoExpiry = fertilizerData.noExpiry;
        _fertilizerImageBytes = fertilizerData.imageBytes;
        _fertilizerIsImage = fertilizerData.isImage;
      });
    }
  }

  bool get _shouldShowPesticideSection => widget.licenseTypeToDisplay == 'pesticide' || widget.licenseTypeToDisplay == 'all';
  bool get _shouldShowFertilizerSection => widget.licenseTypeToDisplay == 'fertilizer' || widget.licenseTypeToDisplay == 'all';

  bool get _isInsecticideSectionValid {
    return _insecticideLicenseController.text.isNotEmpty &&
        (_insecticideNoExpiry || _insecticideExpirationDate != null) &&
        _insecticideImageBytes != null;
  }

  bool get _isFertilizerSectionValid {
    return _fertilizerLicenseController.text.isNotEmpty &&
        (_fertilizerNoExpiry || _fertilizerExpirationDate != null) &&
        _fertilizerImageBytes != null;
  }

  bool get isFormValid {
    if (_shouldShowPesticideSection && _shouldShowFertilizerSection) {
      return _isInsecticideSectionValid && _isFertilizerSectionValid;
    } else if (_shouldShowPesticideSection) {
      return _isInsecticideSectionValid;
    } else if (_shouldShowFertilizerSection) {
      return _isFertilizerSectionValid;
    }
    return false;
  }

  void _checkFormValidity() {
    setState(() {}); // Rebuilds the UI to update button state
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
                    await _storeFileBytes(pickedFile, isInsecticide, true);
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
                    await _storeFileBytes(pickedFile, isInsecticide, true);
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
                    await _storeFileBytes(result.files.single, isInsecticide, false);
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

  // New function to handle storing file bytes
  Future<void> _storeFileBytes(dynamic file, bool isInsecticide, bool isImage) async {
    Uint8List? bytes;
    try {
      if (isImage) {
        // For XFile (image)
        bytes = await (file as XFile).readAsBytes();
      } else {
        // For PlatformFile (PDF)
        if ((file as PlatformFile).bytes != null) {
          bytes = file.bytes!;
        } else if (file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        }
      }

      if (bytes != null) {
        setState(() {
          if (isInsecticide) {
            _insecticideImageBytes = bytes;
            _insecticideIsImage = isImage;
          } else {
            _fertilizerImageBytes = bytes;
            _fertilizerIsImage = isImage;
          }
        });
        _checkFormValidity();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isImage ? 'Image' : 'PDF'} uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read file bytes. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading file: $e')),
      );
    }
  }

  // Removed _showProcessingDialog as OCR is removed
  // Removed _extractLicenseData as OCR is removed
  // Removed _parseDate as OCR is removed

  @override
  void dispose() {
    _insecticideLicenseController.removeListener(_checkFormValidity);
    _fertilizerLicenseController.removeListener(_checkFormValidity);
    _insecticideLicenseController.dispose();
    _fertilizerLicenseController.dispose();
    // Removed: _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showPesticideSection = _shouldShowPesticideSection;
    final bool showFertilizerSection = _shouldShowFertilizerSection;

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

                if (showPesticideSection)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Moved _buildImageUpload to the top
                      _buildImageUpload("Upload Pesticide License Document", _insecticideImageBytes, _insecticideIsImage, () => _pickFile(true)),
                      const SizedBox(height: 20), // Spacing after image upload
                      Text('Pesticide License', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xffEB7720))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _insecticideLicenseController,
                        style: GoogleFonts.poppins(),
                        decoration: _inputDecoration("Enter Pesticide License Number"),
                        onChanged: (value) {
                          final licenseProvider = Provider.of<LicenseProvider>(context, listen: false);
                          licenseProvider.setPesticideLicense(
                            imageBytes: _insecticideImageBytes,
                            isImage: _insecticideIsImage,
                            licenseNumber: value,
                            expirationDate: _insecticideExpirationDate,
                            noExpiry: _insecticideNoExpiry,
                            displayDate: _insecticideNoExpiry ? 'Permanent' : (_insecticideExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_insecticideExpirationDate!) : null),
                          );
                          _checkFormValidity();
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDatePickerRow(context, true),
                      _buildCheckbox(true),
                      if (showFertilizerSection) const SizedBox(height: 20),
                    ],
                  ),

                if (showFertilizerSection)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Moved _buildImageUpload to the top
                      _buildImageUpload("Upload Fertilizer License Document", _fertilizerImageBytes, _fertilizerIsImage, () => _pickFile(false)),
                      const SizedBox(height: 20), // Spacing after image upload
                      Text('Fertilizer License', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xffEB7720))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _fertilizerLicenseController,
                        style: GoogleFonts.poppins(),
                        decoration: _inputDecoration("Enter Fertilizer License Number"),
                        onChanged: (value) {
                          final licenseProvider = Provider.of<LicenseProvider>(context, listen: false);
                          licenseProvider.setFertilizerLicense(
                            imageBytes: _fertilizerImageBytes,
                            isImage: _fertilizerIsImage,
                            licenseNumber: value,
                            expirationDate: _fertilizerExpirationDate,
                            noExpiry: _fertilizerNoExpiry,
                            displayDate: _fertilizerNoExpiry ? 'Permanent' : (_fertilizerExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_fertilizerExpirationDate!) : null),
                          );
                          _checkFormValidity();
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDatePickerRow(context, false),
                      _buildCheckbox(false),
                    ],
                  ),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: isFormValid
                      ? () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('hasUploadedLicenses', true);

                    final licenseProvider = Provider.of<LicenseProvider>(context, listen: false);
                    if (_shouldShowPesticideSection) {
                      await licenseProvider.setPesticideLicense(
                        imageBytes: _insecticideImageBytes,
                        isImage: _insecticideIsImage,
                        licenseNumber: _insecticideLicenseController.text,
                        expirationDate: _insecticideExpirationDate,
                        noExpiry: _insecticideNoExpiry,
                        displayDate: _insecticideNoExpiry ? 'Permanent' : (_insecticideExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_insecticideExpirationDate!) : null),
                      );
                    }
                    if (_shouldShowFertilizerSection) {
                      await licenseProvider.setFertilizerLicense(
                        imageBytes: _fertilizerImageBytes,
                        isImage: _fertilizerIsImage,
                        licenseNumber: _fertilizerLicenseController.text,
                        expirationDate: _fertilizerExpirationDate,
                        noExpiry: _fertilizerNoExpiry,
                        displayDate: _fertilizerNoExpiry ? 'Permanent' : (_fertilizerExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_fertilizerExpirationDate!) : null),
                      );
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => KycSplashScreen()),
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
            onTap: noExpiry ? null : () async {
              await _pickDate(context, isInsecticide);
              final licenseProvider = Provider.of<LicenseProvider>(context, listen: false);
              if (isInsecticide) {
                await licenseProvider.setPesticideLicense(
                  imageBytes: _insecticideImageBytes,
                  isImage: _insecticideIsImage,
                  licenseNumber: _insecticideLicenseController.text,
                  expirationDate: _insecticideExpirationDate,
                  noExpiry: _insecticideNoExpiry,
                  displayDate: _insecticideNoExpiry ? 'Permanent' : (_insecticideExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_insecticideExpirationDate!) : null),
                );
              } else {
                await licenseProvider.setFertilizerLicense(
                  imageBytes: _fertilizerImageBytes,
                  isImage: _fertilizerIsImage,
                  licenseNumber: _fertilizerLicenseController.text,
                  expirationDate: _fertilizerExpirationDate,
                  noExpiry: _fertilizerNoExpiry,
                  displayDate: _fertilizerNoExpiry ? 'Permanent' : (_fertilizerExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_fertilizerExpirationDate!) : null),
                );
              }
            },
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
          onPressed: noExpiry ? null : () async {
            await _pickDate(context, isInsecticide);
            final licenseProvider = Provider.of<LicenseProvider>(context, listen: false);
            if (isInsecticide) {
              await licenseProvider.setPesticideLicense(
                imageBytes: _insecticideImageBytes,
                isImage: _insecticideIsImage,
                licenseNumber: _insecticideLicenseController.text,
                expirationDate: _insecticideExpirationDate,
                noExpiry: _insecticideNoExpiry,
                displayDate: _insecticideNoExpiry ? 'Permanent' : (_insecticideExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_insecticideExpirationDate!) : null),
              );
            } else {
              await licenseProvider.setFertilizerLicense(
                imageBytes: _fertilizerImageBytes,
                isImage: _fertilizerIsImage,
                licenseNumber: _fertilizerLicenseController.text,
                expirationDate: _fertilizerExpirationDate,
                noExpiry: _fertilizerNoExpiry,
                displayDate: _fertilizerNoExpiry ? 'Permanent' : (_fertilizerExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_fertilizerExpirationDate!) : null),
              );
            }
          },
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
      onChanged: (value) async {
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

        final licenseProvider = Provider.of<LicenseProvider>(context, listen: false);
        if (isInsecticide) {
          await licenseProvider.setPesticideLicense(
            imageBytes: _insecticideImageBytes,
            isImage: _insecticideIsImage,
            licenseNumber: _insecticideLicenseController.text,
            expirationDate: _insecticideExpirationDate,
            noExpiry: _insecticideNoExpiry,
            displayDate: _insecticideNoExpiry ? 'Permanent' : (_insecticideExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_insecticideExpirationDate!) : null),
          );
        } else {
          await licenseProvider.setFertilizerLicense(
            imageBytes: _fertilizerImageBytes,
            isImage: _fertilizerIsImage,
            licenseNumber: _fertilizerLicenseController.text,
            expirationDate: _fertilizerExpirationDate,
            noExpiry: _fertilizerNoExpiry,
            displayDate: _fertilizerNoExpiry ? 'Permanent' : (_fertilizerExpirationDate != null ? DateFormat('dd/MM/yyyy').format(_fertilizerExpirationDate!) : null),
          );
        }
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
