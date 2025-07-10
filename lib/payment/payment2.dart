import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // REQUIRED: Import Provider
import 'package:kisangro/models/cart_model.dart'; // REQUIRED: Import CartModel
import 'package:kisangro/models/address_model.dart'; // NEW: Import AddressModel
import 'package:geolocator/geolocator.dart'; // NEW: Import geolocator
import 'package:geocoding/geocoding.dart'; // NEW: Import geocoding

// Import CustomAppBar

// Import Bot for navigation (for back button functionality)
import 'package:kisangro/home/bottom.dart';

import '../common/common_app_bar.dart';


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

  // NEW: Local state for auto-detected location, to update text fields
  String _autoDetectedAddress = '';
  String _autoDetectedPincode = '';
  bool _isDetectingLocation = false;

  void _onAddressChanged(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    setState(() {
      wordCount = words.length;
    });
  }

  // NEW: Determine current position and update AddressModel and text fields
  Future<void> _determinePosition() async {
    setState(() {
      _isDetectingLocation = true;
      _autoDetectedAddress = 'Detecting...';
      _autoDetectedPincode = 'Loading...';
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _autoDetectedAddress = 'Location services disabled.';
        _autoDetectedPincode = 'N/A';
        _isDetectingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _autoDetectedAddress = 'Location permission denied.';
          _autoDetectedPincode = 'N/A';
          _isDetectingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied. Cannot fetch current location.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(() {
        _autoDetectedAddress = 'Location permission permanently denied.';
        _autoDetectedPincode = 'N/A';
        _isDetectingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied. Please enable from app settings.')),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (mounted) {
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String address = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country
          ].where((element) => element != null && element.isNotEmpty).join(', ');

          String pincode = place.postalCode ?? ''; // Use empty string if null

          setState(() {
            addressController.text = address;
            pinController.text = pincode;
            _onAddressChanged(address); // Update word count for the new address
            _autoDetectedAddress = address; // Update local state for display
            _autoDetectedPincode = pincode; // Update local state for display
          });

          // No need to update AddressModel here, it will be updated when "Save" is pressed.

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location auto-detected: $address, $pincode')),
          );

        } else {
          setState(() {
            _autoDetectedAddress = 'Location found, but address unknown.';
            _autoDetectedPincode = 'N/A';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location found, but could not get readable address.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error getting location in payment2: $e');
      if (mounted) {
        setState(() {
          _autoDetectedAddress = 'Could not get location.';
          _autoDetectedPincode = 'N/A';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting current location: ${e.toString()}.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
        });
      }
    }
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
      appBar: CustomAppBar( // Integrated CustomAppBar
        title: "Add New Address", // Set the title
        showBackButton: true, // Show back button
        showMenuButton: false, // Do NOT show menu button (drawer icon)
        // scaffoldKey is not needed here as there's no drawer
        isMyOrderActive: false, // Not active
        isWishlistActive: false, // Not active
        isNotiActive: false, // Not active
        // showWhatsAppIcon is false by default, matching original behavior
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
              // NEW: Auto-detect Location Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDetectingLocation ? null : _determinePosition,
                  icon: _isDetectingLocation
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.my_location, color: Colors.white),
                  label: Text(
                    _isDetectingLocation ? 'Detecting...' : 'Auto-detect Location',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEB7720),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Spacing after auto-detect button
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
