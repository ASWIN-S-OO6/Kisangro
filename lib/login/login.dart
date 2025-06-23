import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert'; // For JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences

import 'package:kisangro/login/otp.dart';


class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  @override
  Widget build(BuildContext context) {
    return const LoginRegisterScreen();
  }
}

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  _LoginRegisterScreenState createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool isChecked = false;
  String _enteredPhoneNumber = ''; // Stores the 10-digit national number
  bool isValidNumber = false;
  bool _isLoading = false; // To show loading state on button

  // Define your API URL as a constant for easy modification
  static const String _loginApiUrl = 'https://sgserp.in/erp/api/m_api/';

  Future<void> _sendOtp() async {
    if (!isChecked || !isValidNumber) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please accept terms and enter a valid 10-digit mobile number.',
                style: GoogleFonts.poppins())),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      Uri url = Uri.parse(_loginApiUrl);

      // Construct the body with the 10-digit phone number
      Map<String, String> body = {
        'cid': '21472147',
        'type': '1002',
        'ln': '3433433', // Placeholder for latitude
        'lt': '2323434', // Placeholder for longitude
        'device_id': 'flutter_app_device', // A static device ID placeholder
        'mobile': _enteredPhoneNumber, // Use the 10-digit number directly
      };

      debugPrint("Sending login request to $_loginApiUrl with body: $body"); // Changed to debugPrint

      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      ).timeout(const Duration(seconds: 10)); // Add a timeout for network requests

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        debugPrint('API Response: $responseData'); // Changed to debugPrint

        if (responseData['error'] == false) {
          // OTP sent successfully, now set isLoggedIn flag
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true); // Set isLoggedIn to true

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['error_msg'] ?? 'OTP sent successfully!',
                    style: GoogleFonts.poppins())),
          );
          // Use pushReplacement to prevent navigating back to LoginScreen with browser back button
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(phoneNumber: _enteredPhoneNumber),
            ),
          );
        } else {
          // API returned an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['error_msg'] ?? 'Login failed. Please try again.',
                    style: GoogleFonts.poppins())),
          );
        }
      } else {
        // Handle non-200 status codes (e.g., 404, 500)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to connect to the server. Status Code: ${response.statusCode}',
                  style: GoogleFonts.poppins())),
        );
      }
    } catch (e) {
      // Handle network errors (e.g., no internet, timeout)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Network Error: $e. Please check your internet connection.',
                style: GoogleFonts.poppins())),
      );
      debugPrint('Network/API Error: $e'); // Print error for debugging
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50], // This background will be overridden by the Container gradient
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffFFD9BD),
              Color(0xffFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Image.asset("assets/logo.png", height: 100),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Login/Register',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xffEB7720),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'OTP (One Time Password) will be sent to this number',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      const SizedBox(height: 30),

                      /// PHONE FIELD
                      IntlPhoneField(
                        decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffEB7720),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xffEB7720),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          labelText: 'Enter mobile number',
                          labelStyle: GoogleFonts.poppins(color: Colors.black),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        initialCountryCode: 'IN',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (phone) {
                          setState(() {
                            // Store only the national number (without country code)
                            _enteredPhoneNumber = phone.number;
                            // Basic validation: checks for exactly 10 digits in the national number part
                            isValidNumber = phone.number.length == 10;
                          });
                        },
                      ),

                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "Don't worry your details are safe with us.",
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.verified, color: Color(0xffEB7720)),
                        ],
                      ),
                      const SizedBox(height: 30),

                      /// TERMS CHECKBOX
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: const Color(0xffEB7720),
                            onChanged: (value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'I accept the ',
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xffEB7720),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' of Aura.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // SEND OTP BUTTON at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (isChecked && isValidNumber && !_isLoading)
                        ? _sendOtp
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: const Color(0xffEB7720),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Send OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
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
