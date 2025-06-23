import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // REQUIRED: Import Provider
import 'package:kisangro/models/cart_model.dart'; // REQUIRED: Import CartModel
import 'package:kisangro/models/address_model.dart'; // NEW: Import AddressModel

class delivery2 extends StatelessWidget {
  const delivery2({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    // This StatelessWidget simply returns the main screen for this file.
    return const AddAddressScreen();
  }
}

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key}); // Added const constructor

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  // wordCount and wordLimit are for the TextField's internal logic, not displayed
  int wordCount = 0;
  final int wordLimit = 100;

  void _onAddressChanged(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    setState(() {
      wordCount = words.length;
    });
  }

  @override
  void dispose() {
    addressController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addressModel = Provider.of<AddressModel>(context, listen: false); // Access AddressModel

    // Initialize text controllers with current address details from the model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (addressController.text.isEmpty && addressModel.currentAddress != "D/no: 123, abc street, rrr nagar, near ppp, Coimbatore.") {
        addressController.text = addressModel.currentAddress;
        _onAddressChanged(addressModel.currentAddress); // Update word count on initialization
      }
      if (pinController.text.isEmpty && addressModel.currentPincode != "641612") {
        pinController.text = addressModel.currentPincode;
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        centerTitle: false,
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            "Add New Address",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen (payment1.dart)
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle notification icon tap
            },
            icon: Image.asset(
              'assets/noti.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              // Handle wishlist icon tap
            },
            icon: Image.asset(
              'assets/heart.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          // Removed the cart icon button (bag.png)
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(thickness: 1),
              Text(
                'Step 2/3',
                style: GoogleFonts.poppins(
                    color: const Color(0xffEB7720), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Address details',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                maxLines: 4,
                maxLength: wordLimit,
                onChanged: _onAddressChanged,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Enter Address',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey),
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEB7720)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEB7720), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  counterText: '', // Hide default counter text
                  suffixText: '$wordCount/$wordLimit', // Show custom character count
                  suffixStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6), // Limit to 6 digits
                ],
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Pincode',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey),
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEB7720)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xffEB7720), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Basic validation
                    if (addressController.text.isNotEmpty &&
                        pinController.text.length == 6) {
                      // Update the AddressModel
                      addressModel.setAddress(
                        address: addressController.text,
                        pincode: pinController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Address saved to model!', style: GoogleFonts.poppins())),
                      );
                      Navigator.pop(context); // Go back to payment1.dart (delivery screen)
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a valid address and 6-digit pin code.', style: GoogleFonts.poppins())),
                      );
                    }
                  },
                  child: Text('Save', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: const Color(0xFFEB7722),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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