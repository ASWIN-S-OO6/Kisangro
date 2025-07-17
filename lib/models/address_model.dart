import 'package:flutter/foundation.dart'; // For @required and ChangeNotifier

class AddressModel extends ChangeNotifier {
  // Default values for the address
  String _currentAddress = "D/no: 123, abc street, rrr nagar, near ppp, Coimbatore.";
  String _currentPincode = "641612";
  String _currentName = "Smart (name)"; // NEW: Default name for the address

  String get currentAddress => _currentAddress;
  String get currentPincode => _currentPincode;
  String get currentName => _currentName; // NEW: Getter for name

  // Method to update the address details, now including name
  void setAddress({
    required String address,
    required String pincode,
    String? name, // Optional name update
  }) {
    _currentAddress = address;
    _currentPincode = pincode;
    if (name != null) {
      _currentName = name; // Set name if provided
    }
    notifyListeners(); // Notify any widgets listening to this model
  }

  // You can also add a method to reset to default or clear the address
  void resetAddress() {
    _currentAddress = "D/no: 123, abc street, rrr nagar, near ppp, Coimbatore.";
    _currentPincode = "641612";
    _currentName = "Smart (name)";
    notifyListeners();
  }
}
