import 'dart:async';
import 'dart:typed_data'; // Needed for Uint8List to display image bytes
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // For star rating UI
import 'package:dotted_border/dotted_border.dart'; // For dotted borders around profile image
import 'package:provider/provider.dart'; // For state management (accessing KycImageProvider)

import 'package:flutter/material.dart';
import 'package:kisangro/home/membership.dart'; // Assuming this page exists
import 'package:kisangro/home/myorder.dart'; // Assuming this page exists
import 'package:kisangro/home/noti.dart'; // Assuming this page exists
import 'package:kisangro/menu/wishlist.dart'; // Assuming this page exists
import 'package:kisangro/services/product_service.dart'; // Import ProductService to fetch categories

import '../common/common_app_bar.dart'; // Import CustomAppBar
import '../login/login.dart'; // For logout navigation
import '../menu/account.dart'; // For My Account navigation
import '../menu/ask.dart'; // For Ask Us! navigation
import '../menu/logout.dart'; // For LogoutConfirmationDialog
import '../menu/setting.dart'; // For Settings navigation
import '../menu/transaction.dart'; // For Transaction History navigation
import '../models/kyc_image_provider.dart'; // Import your custom KYC image provider
import 'package:kisangro/categories/category_products_screen.dart';

import 'custom_drawer.dart'; // Import the CustomDrawer


class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({super.key}); // Add const constructor

  @override
  _ProductCategoriesScreenState createState() =>
      _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>(); // Key for Scaffold to open drawer

  double _rating = 4.0; // Initial rating for the review dialog
  final TextEditingController _reviewController =
  TextEditingController(); // Controller for review text field
  static const int maxChars = 100; // Max characters for review

  List<Map<String, String>> _categories = []; // Now dynamically loaded
  bool _isLoading = true; // To show loading indicator for categories

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Load categories when the screen initializes
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      await ProductService.loadCategoriesFromApi(); // Ensure categories are fetched
      if (mounted) {
        setState(() {
          _categories = ProductService.getAllCategories();
          _isLoading = false; // Stop loading
          debugPrint('ProductCategoriesScreen: Loaded ${_categories.length} categories.');
        });
      }
    } catch (e) {
      debugPrint('Error loading categories in ProductCategoriesScreen: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading even on error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load categories: $e')),
          );
        });
      }
    }
  }


  /// Shows a confirmation dialog for logging out, clears navigation stack.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (context) => LogoutConfirmationDialog(
        onCancel: () => Navigator.of(context).pop(), // Close dialog on cancel
        onLogout: () {
          // Perform logout actions and navigate to LoginApp, clearing navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginApp()),
                (Route<dynamic> route) => false, // Remove all routes below
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully!')),
          );
        },
      ),
    );
  }

  /// Shows a dialog for giving ratings and writing a review about the app.
  void showComplaintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          content: StatefulBuilder(
            // Use StatefulBuilder to manage dialog's internal state for _rating and _reviewController
            builder: (context, setState) {
              return SizedBox(
                width: 328, // Fixed width for dialog content
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Make column content fit
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context), // Close dialog
                        child: const Icon(
                          Icons.close,
                          color: Color(0xffEB7720), // Orange close icon
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Give ratings and write a review about your experience using this app.",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text("Rate:", style: GoogleFonts.lato(fontSize: 16)),
                        const SizedBox(width: 12),
                        RatingBar.builder(
                          // Star rating bar
                          initialRating: _rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 32,
                          unratedColor: Colors.grey[300],
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Color(0xffEB7720),
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _rating = rating; // Update rating state
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _reviewController,
                      maxLength: maxChars,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '', // Hide default counter text
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (_) => setState(
                              () {}), // Rebuild to update character count dynamically
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_reviewController.text.length}/$maxChars', // Character counter
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffEB7720),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close review dialog

                          // Show "Thank you" confirmation dialog
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.all(24),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xffEB7720),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Thank you!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thanks for rating us.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context), // Close thank you dialog
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xffEB7720),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'OK',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // Define tablet based on width

    int crossAxisCount = 3;
    double childAspectRatio = 0.85; // Default for mobile and tablet portrait

    if (isTablet && orientation == Orientation.landscape) {
      crossAxisCount = 5; // More columns for tablet landscape
      childAspectRatio = 0.9; // Adjust aspect ratio for more compact tiles
    } else if (isTablet && orientation == Orientation.portrait) {
      crossAxisCount = 4; // More columns for tablet portrait
      childAspectRatio = 0.9; // Adjust aspect ratio for more compact tiles
    }


    return Scaffold(
      key: _scaffoldKey, // Assign scaffold key to control drawer
      drawer: const CustomDrawer(), // Use const for CustomDrawer
      appBar: CustomAppBar( // Integrated CustomAppBar
        title: "Product Categories", // Title for the app bar
        showBackButton: false, // Do NOT show back button
        showMenuButton: true, // Show menu button to open the drawer
        scaffoldKey: _scaffoldKey, // Pass the scaffold key
        showWhatsAppIcon: false, // Do not show WhatsApp icon
        isMyOrderActive: false,
        isWishlistActive: false,
        isNotiActive: false,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _isLoading // Show loading indicator if categories are not loaded
              ? const Center(child: CircularProgressIndicator(color: Color(0xffEB7720)))
              : GridView.builder(
            itemCount: _categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to the generic CategoryProductsScreen
                  // Pass the category title AND the cat_id to the new screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsScreen(
                        categoryTitle: category['label']!, // Use 'label' key
                        categoryId: category['cat_id']!, // Pass the 'cat_id'
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        category['icon']!, // Use 'icon' key
                        height: 40,
                        width: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.category, size: 40, color: Color(0xffEB7720)); // Fallback icon
                        },
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          category['label']!, // Use 'label' key
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                          ),
                          maxLines: 2, // Allow two lines for category titles
                          overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds the header section of the drawer, including the user profile image.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              DottedBorder(
                borderType: BorderType.Circle,
                color: Colors.red,
                strokeWidth: 2,
                dashPattern: const [6, 3],
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    // Use Consumer to dynamically display the uploaded image from KycImageProvider.
                    child: Consumer<KycImageProvider>(
                      builder: (context, kycImageProvider, child) {
                        final Uint8List? kycImageBytes =
                            kycImageProvider.kycImageBytes; // Get image bytes
                        return kycImageBytes != null
                            ? Image.memory(
                          // Display image from bytes if available
                          kycImageBytes,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'assets/profile.png', // Fallback to default profile image
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                "Hi Smart!\n 9876543210", // User name and number
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, // Changed to double.infinity
            child: Padding(
              padding: const EdgeInsets.only(left: 0), // Removed left padding to center
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MembershipDetailsScreen(), // Added const
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEB7720), // Orange button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center content in button
                  children: [
                    Text(
                      "Not A Member Yet",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.white70,
                      size: 14, // Adjusted size for better visual balance
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 30, thickness: 1, color: Colors.black), // Divider
        ],
      ),
    );
  }

  /// Builds a single menu item in the drawer.
  Widget _buildMenuItem(IconData icon, String label) {
    return Column( // Use Column to include the Divider
      children: [
        Container(
          decoration: const BoxDecoration( // Changed to const as color is now fixed
            color: Color(0xffffecdc), // Background color for the item
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Adjust padding to remove inner spacing
            leading: Icon(icon, color: const Color(0xffEB7720)), // Orange icon
            title: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold, // Consistent bold font weight
              ),
            ),
            onTap: () {
              // Close the drawer before navigating
              Navigator.pop(context);

              // Handle navigation based on the tapped menu item label
              switch (label) {
                case 'My Account':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyAccountPage()), // Added const
                  );
                  break;
                case 'My Orders': // Added My Orders navigation
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrder()), // Added const
                  );
                  break;
                case 'Wishlist': // Added Wishlist navigation
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WishlistPage()), // Added const
                  );
                  break;
                case 'Transaction History':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  TransactionHistoryPage(),
                    ),
                  );
                  break;
                case 'Ask Us!':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AskUsPage()),
                  );
                  break;
                case 'Rate Us':
                  showComplaintDialog(context); // Show review dialog
                  break;
                case 'Settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                  break;
                case 'Logout':
                  _showLogoutDialog(context); // Show logout confirmation dialog
                  break;
                case 'About Us':
                // Handle About Us navigation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('About Us page coming soon!')),
                  );
                  break;
                case 'Share Kisangro':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality coming soon!')),
                  );
                  break;
              }
            },
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Colors.grey), // Divider between items
      ],
    );
  }
}
