import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import 'package:kisangro/login/kyc.dart'; // Update the path if needed
import 'package:google_fonts/google_fonts.dart';

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
  // Removed hardcoded phoneNumber, now using widget.phoneNumber

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

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 100),
            Center(
              child: Text(
                'OTP Verification',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffEB7720)),
              ),
            ),
            const SizedBox(height: 50),
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
                        onTap: () {
                          startTimer();
                        },
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
            const Spacer(), // Pushes the button to the bottom
            ElevatedButton(
              onPressed: isOtpFilled
                  ? () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => kyc())); // Your KYC screen
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffEB7720),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Proceed',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30), // Padding at the very bottom
          ],
        ),
      ),
    );
  }
}
