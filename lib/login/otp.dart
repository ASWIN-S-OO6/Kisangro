import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import 'package:kisangro/login/kyc.dart'; // Update the path if needed
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For JSON encoding/decoding

class OtpScreen extends StatefulWidget {
  // Added phoneNumber as a required parameter
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  Timer? _timer;
  int _start = 30;
  bool canResend = false;
  bool isOtpFilled = false;
  bool _isVerifying = false; // To show loading state during verification

  // Define your API URL as a constant for easy modification
  static const String _verifyOtpApiUrl = 'https://sgserp.in/erp/api/m_api/';

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() {
      _start = 30;
      canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (!isOtpFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the complete OTP.',
              style: GoogleFonts.poppins()),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true; // Start loading
    });

    try {
      Uri url = Uri.parse(_verifyOtpApiUrl);

      // Construct the body with the verification parameters
      Map<String, String> body = {
        'cid': '21472147',
        'type': '1003', // OTP verification type
        'ln': '322334', // Latitude
        'lt': '233432', // Longitude
        'device_id': '122334', // Device ID
        'mobile': widget.phoneNumber, // Use the phone number passed from login screen
        'otp': otpController.text, // The OTP entered by user
      };

      print("Sending OTP verification request to $_verifyOtpApiUrl with body: $body");

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      ).timeout(const Duration(seconds: 10)); // Add a timeout for network requests

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('OTP Verification API Response: $responseData'); // Debug print

        if (responseData['error'] == false) {
          // OTP verification successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['error_msg'] ?? 'OTP verified successfully!',
                  style: GoogleFonts.poppins()),
            ),
          );

          // Navigate to KYC screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => kyc()),
          );
        } else {
          // OTP verification failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['error_msg'] ?? 'Invalid OTP. Please try again.',
                  style: GoogleFonts.poppins()),
            ),
          );

          // Clear the OTP field for retry
          otpController.clear();
          setState(() {
            isOtpFilled = false;
          });
        }
      } else {
        // Handle non-200 status codes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to verify OTP. Status Code: ${response.statusCode}',
                style: GoogleFonts.poppins()),
          ),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network Error: $e. Please check your internet connection.',
              style: GoogleFonts.poppins()),
        ),
      );
      print('Network/API Error: $e'); // Print error for debugging
    } finally {
      setState(() {
        _isVerifying = false; // End loading
      });
    }
  }

  Future<void> _resendOtp() async {
    // Reuse the same logic from login screen to resend OTP
    try {
      Uri url = Uri.parse(_verifyOtpApiUrl);

      Map<String, String> body = {
        'cid': '21472147',
        'type': '1002', // Login/Resend OTP type
        'ln': '322334',
        'lt': '233432',
        'device_id': '122334',
        'mobile': widget.phoneNumber,
      };

      print("Resending OTP to ${widget.phoneNumber}");

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['error'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP resent successfully!',
                  style: GoogleFonts.poppins()),
            ),
          );
          startTimer(); // Restart the timer
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['error_msg'] ?? 'Failed to resend OTP.',
                  style: GoogleFonts.poppins()),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend OTP. Please try again.',
              style: GoogleFonts.poppins()),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Enable keyboard resize behavior
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20), // Reduced spacing
                      Center(
                        child: Image.asset(
                          'assets/logo.png',
                          height: 80, // Reduced from 100
                        ),
                      ),
                      const SizedBox(height: 40), // Reduced from 100
                      Center(
                        child: Text(
                          'OTP Verification',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffEB7720)),
                        ),
                      ),
                      const SizedBox(height: 30), // Reduced from 50
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                            children: [
                              const TextSpan(
                                text:
                                'We sent an OTP (One Time Password) to your mobile number ',
                              ),
                              // Use widget.phoneNumber to display the number passed from LoginScreen
                              TextSpan(
                                text: widget.phoneNumber,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: otpController,
                        onChanged: (value) {
                          setState(() {
                            isOtpFilled = value.length == 6;
                          });
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.underline,
                          fieldWidth: 30,
                          activeColor: const Color(0xffEB7720),
                          selectedColor: const Color(0xffEB7720),
                          inactiveColor: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Didn't receive OTP?", style: GoogleFonts.poppins(fontSize: 13)),
                          canResend
                              ? GestureDetector(
                            onTap: _resendOtp, // Call the resend OTP function
                            child: Text(
                              'Resend now',
                              style: GoogleFonts.poppins(
                                  color: Color(0xffEB7720),
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                              : Text(
                            '0:${_start.toString().padLeft(2, '0')}',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ],
                      ),
                      // Add extra space to accommodate keyboard
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 40 : 20),
                    ],
                  ),
                ),
              ),

              // Bottom button section
              Container(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16.0 : 30.0, // Adaptive bottom padding
                ),
                child: ElevatedButton(
                  onPressed: (isOtpFilled && !_isVerifying) ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffEB7720),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Verify & Proceed',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}