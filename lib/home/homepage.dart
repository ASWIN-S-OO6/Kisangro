import 'dart:async';
import 'dart:typed_data'; // Essential for Uint8List to display image bytes
import 'package:flutter/cupertino.dart'; // For CupertinoIcons, if used
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:carousel_slider/carousel_slider.dart'; // For carousel functionality
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // For rating UI
// ProductCategoriesScreen (old reference)
import 'package:kisangro/home/categories.dart'; // ProductCategoriesScreen (updated reference)
import 'package:kisangro/home/product.dart'; // ProductDetailPage
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // For carousel page indicators
import 'package:dotted_border/dotted_border.dart'; // For dotted borders
import 'package:provider/provider.dart'; // For state management
import 'package:geolocator/geolocator.dart'; // Import geolocator
import 'package:geocoding/geocoding.dart'; // Import geocoding for reverse geocoding

// Import your custom models
import 'package:kisangro/models/product_model.dart'; // Assuming this model exists
import 'package:kisangro/models/cart_model.dart'; // Assuming this model exists
import 'package:kisangro/models/wishlist_model.dart'; // Assuming this model exists
import 'package:kisangro/models/kyc_image_provider.dart'; // Your custom KYC image provider
import 'package:kisangro/services/product_service.dart'; // Import ProductService

// Your existing page imports (ensure these paths are correct in your project)
import 'package:kisangro/home/membership.dart'; // MembershipDetailsScreen
import 'package:kisangro/home/myorder.dart'; // MyOrder
import 'package:kisangro/home/noti.dart'; // noti
import 'package:kisangro/home/search_bar.dart'; // SearchScreen
import 'package:kisangro/home/bottom.dart'; // Import the Bot widget for navigation with bottom bar
import 'package:kisangro/payment/payment3.dart'; // Import PaymentPage

// Category-specific product screens
// Menu imports
import '../categories/category_products_screen.dart';
import '../login/login.dart'; // LoginApp
import '../menu/account.dart'; // MyAccountPage
import '../menu/ask.dart'; // AskUsPage
import '../menu/logout.dart'; // LogoutConfirmationDialog
import '../menu/setting.dart'; // SettingsPage
import '../menu/transaction.dart'; // TransactionHistoryPage
import '../menu/wishlist.dart'; // WishlistPage
import 'package:kisangro/home/cart.dart'; // Import the cart page for navigation to cart
import 'package:kisangro/home/trending_products_screen.dart'; // NEW: Import TrendingProductsScreen


class HomeScreen extends StatefulWidget { // Class name: HomeScreen - UNCHANGED
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // Class name: _HomeScreenState - UNCHANGED
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _carouselTimer; // Declared for the carousel auto-scrolling
  Timer? _refreshTimer; // Declared for the auto-refresh logic
  String _currentLocation = 'Detecting...'; // Placeholder for location
  double _rating = 4.0; // Initial rating for the review dialog
  final TextEditingController _reviewController =
  TextEditingController(); // Controller for review text field
  static const int maxChars = 100; // Max characters for review

  // --- Dynamic product lists, populated from ProductService.getAllProducts() ---
  // This ensures the homepage still displays products from the main API call (type=1041).
  List<Product> _trendingItems = [];
  List<Product> _newOnKisangroItems = [];
  List<Map<String, String>> _categories = []; // Now dynamic

  // Dummy data for deals section (if not coming from API)
  final List<Map<String, String>> _deals = [
    {'name': 'VALAX', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/Valaxa.png'},
    {'name': 'OXYFEN', 'price': '₹ 1000/piece', 'original': '₹ 2000', 'image': 'assets/Oxyfen.png'},
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/hyfen.png'},
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/Valaxa.png'}, // Cycle image
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/Oxyfen.png'}, // Cycle image
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/hyfen.png'}, // Cycle image
  ];


  // Carousel images for the top banner
  final List<String> _carouselImages = [
    'assets/veg.png',
    'assets/product.png',
    'assets/bulk.png',
    'assets/nature.png',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for Scaffold to open drawer

  // HELPER FUNCTION: Determines the effective image URL, handling placeholders and invalid URLs.
  String _getEffectiveImageUrl(String rawImageUrl) {
    // If the image URL is the base API URL, it's not a valid product image.
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png'; // Fallback to a local asset placeholder
    }
    return rawImageUrl; // Use the provided URL if it's valid
  }


  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Load products and categories initially
    _startCarousel(); // Start auto-scrolling carousel
    _determinePosition(); // Fetch location on init

    // Start auto-refresh timer (e.g., every 5 minutes)
    // Adjust the duration as needed for your application's refresh frequency.
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (Timer timer) {
      debugPrint('Auto-refreshing homepage data...');
      _refreshData();
    });
  }

  /// Loads initial product and category data from ProductService.
  /// This method is called once on initState and also during auto-refresh.
  Future<void> _loadInitialData() async {
    // ProductService.loadProductsFromApi() should ideally be called once at app startup
    // and keep _allProducts updated. Here, we just retrieve the already loaded list.
    // If you need to re-fetch from API specifically for this screen, uncomment the line below.
    // await ProductService.loadProductsFromApi();
    try {
      await ProductService.loadProductsFromApi(); // Re-fetch products from API (POST request with type=1041)
      await ProductService.loadCategoriesFromApi(); // Ensure categories are loaded (type=1043)
    } catch (e) {
      debugPrint('Error during initial data load/refresh: $e');
      // Optionally, show a snackbar or an error message to the user
    }

    // After loading (or failing to load), update the UI state.
    if (mounted) { // Check if the widget is still in the widget tree
      setState(() {
        _trendingItems = ProductService.getAllProducts().take(6).toList(); // Get top 6 for trending
        // Adjusted how "New On Kisangro" items are picked to ensure they are distinct
        _newOnKisangroItems = ProductService.getAllProducts().reversed.take(6).toList(); // Simple reversal for "new"
        _categories = ProductService.getAllCategories(); // Get categories from ProductService
      });
    }
  }

  /// Method specifically for triggering a refresh of all homepage data.
  /// Called by the auto-refresh timer.
  Future<void> _refreshData() async {
    await _loadInitialData();
  }

  /// Shows a confirmation dialog for logging out.
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
            MaterialPageRoute(builder: (context) => LoginApp()),
                (Route<dynamic> route) => false, // Remove all routes below
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully!')),
          );
        },
      ),
    );
  }

  /// Shows a dialog for giving ratings and writing a review.
  void showComplaintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          content: StatefulBuilder( // Use StatefulBuilder to manage dialog's internal state
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
                        RatingBar.builder( // Star rating bar
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
                      onChanged: (_) => setState(() {}), // Rebuild to update character count
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
                                      onPressed: () => Navigator.pop(context), // Close thank you dialog
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

  /// Starts a timer for auto-scrolling the carousel.
  void _startCarousel() {
    // Changed carousel auto-scrolling logic for seamless loop (1 to 4 and 4 to 1)
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && mounted) {
        int nextPageIndex = _currentPage + 1;
        if (nextPageIndex >= _carouselImages.length) {
          // If at the last image, jump directly to the first without animation
          _pageController.jumpToPage(0);
          nextPageIndex = 0; // Reset nextPageIndex for consistency
        } else {
          _pageController.animateToPage(
            nextPageIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        setState(() {
          _currentPage = nextPageIndex; // Update _currentPage after animation or jump
        });
      }
    });
  }

  /// Fetches and updates the current location using geolocator.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _currentLocation = 'Location services disabled.';
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
          _currentLocation = 'Location permission denied.';
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
        _currentLocation = 'Location permission permanently denied.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied. Please enable from app settings.')),
      );
      return;
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Added timeout for position retrieval
      );

      // Reverse geocoding to get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (mounted) {
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          setState(() {
            // Prioritize subLocality, locality, administrativeArea (state)
            _currentLocation = '${place.subLocality ?? ''}, ${place.locality ?? place.administrativeArea ?? ''}';
            _currentLocation = _currentLocation.trim().replaceAll(RegExp(r'^,?\s*'), '').replaceAll(RegExp(r',?\s*,+'), ', ').trim(); // Clean up commas
            if (_currentLocation.isEmpty) { // Fallback if above is still empty
              _currentLocation = 'Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)}';
            }
          });
        } else {
          setState(() {
            _currentLocation = 'Location found, but address unknown.';
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        setState(() {
          _currentLocation = 'Could not get location.';
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting current location: ${e.toString()}.')),
      );
    }
  }


  @override
  void dispose() {
    _carouselTimer?.cancel(); // Cancel carousel timer
    _refreshTimer?.cancel(); // Cancel auto-refresh timer
    _pageController.dispose(); // Dispose page controller
    _reviewController.dispose(); // Dispose text editing controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign scaffold key to control drawer
      drawer: Drawer(
        child: SafeArea( // Ensures content is not under status bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(), // Custom header for the drawer, now displaying KYC image
              _buildMenuItem(Icons.person_outline, "My Account"), // Drawer menu items
              _buildMenuItem(Icons.history, "Transaction History"),
              _buildMenuItem(Icons.headset_mic, "Ask Us!"),
              _buildMenuItem(Icons.info_outline, "About Us"),
              _buildMenuItem(Icons.star_border, "Rate Us"),
              _buildMenuItem(Icons.share, "Share Kisangro"),
              _buildMenuItem(Icons.settings_outlined, "Settings"),
              _buildMenuItem(Icons.logout, "Logout"),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720), // AppBar background color
        centerTitle: false,
        title: Transform.translate(
          offset: const Offset(-20, 0), // Adjust title position
          child: Text(
            "Hello Smart Global!",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer(); // Open drawer on menu icon tap
          },
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
        actions: [
          // Using a Row to contain the action icons for proper right alignment and spacing
          Row(
            // Aligns all children to the end (right) of the row
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // WhatsApp icon
              GestureDetector(
                child: Image.asset("assets/whats.png", width: 24, height: 24,),
              ),
              const SizedBox(width: 5), // Consistent smaller spacing

              // My Orders icon
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrder()), // Navigate to My Orders
                  );
                },
                icon: Image.asset(
                  'assets/box.png',
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 5), // Consistent smaller spacing

              // Wishlist icon
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WishlistPage()), // Navigate to Wishlist
                  );
                },
                icon: Image.asset(
                  'assets/heart.png',
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 5), // Consistent smaller spacing

              // Notifications icon (removed Padding as SizedBox handles spacing)
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const noti()), // Navigate to Notifications
                  );
                },
                icon: Image.asset(
                  'assets/noti.png',
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10), // Small padding at the very end to keep icons from touching edge
            ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFF7F1), // Background color for the screen body
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient( // Gradient background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Start of the Stack containing search bar, location, and carousel
              Stack(
                children: [
                  // This Container ensures the Stack has a minimum height even if the image fails to load
                  Container(
                    height: 290, // Fixed height for the stack background
                    width: double.infinity,
                    color: Colors.grey.shade200, // Fallback background color
                    child: Image.asset(
                      'assets/bghome.jpg', // Background image for the top section
                      height: 290,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // Add errorBuilder for debug visibility if image is missing
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Error loading image: assets/bghome.jpg',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: _buildSearchBar(), // Search bar widget (includes location)
                  ),
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 180,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _carouselImages.length,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index), // Update current page index
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                image: AssetImage(_carouselImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 270,
                    left: 0,
                    right: 0,
                    child: _buildDotIndicators(), // Carousel dot indicators
                  ),
                ],
              ),
              // End of the Stack
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Trending Items",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // NEW: Navigate to TrendingProductsScreen
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const TrendingProductsScreen()));
                      },
                      child: Text(
                        "View All",
                        style: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 305,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _trendingItems.length,
                  padding: const EdgeInsets.only(left: 12, right: 12), // Add overall padding if needed
                  itemBuilder: (context, index) {
                    final product = _trendingItems[index];
                    return Padding( // Wrap _buildProductTile with Padding
                      padding: const EdgeInsets.only(right: 12), // Add space to the right of each tile
                      child: _buildProductTile(context, product),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 400, // Fixed height for promotional banner
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/diwali.png"), // Diwali promotional image
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 160), // Spacer to position deals
                    SizedBox(
                      height: 180, // Height for horizontal deals list
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _deals.length, // Use dynamic deals
                        itemBuilder: (context, index) {
                          final deal = _deals[index];
                          // Dummy Product for deals to allow adding to cart/wishlist
                          // Assuming Product.fromJson or a similar constructor could be used for real data
                          final Product dealProduct = Product(
                            id: 'Deal_${deal['name']!}_$index',
                            title: deal['name']!,
                            subtitle: 'Special Deal',
                            imageUrl: deal['image']!,
                            category: 'Deals', // Or a more specific category if applicable
                            availableSizes: [
                              ProductSize(size: 'piece', price: double.tryParse(deal['price']!.replaceAll('₹ ', '').replaceAll('/piece', '')) ?? 0.0),
                            ],
                            selectedUnit: 'piece',
                          );

                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Handle both network and asset images for deals if necessary
                                // Apply the same refined image handling for deals as well
                                SizedBox(
                                  width: double.infinity, // Take full width of parent column
                                  height: 80, // Fixed height for the deal image display area
                                  child: Center( // Center the AspectRatio/Image within this fixed height box
                                    child: AspectRatio(
                                      aspectRatio: 1.0, // Aim for a square image container within the 100px height
                                      child: _getEffectiveImageUrl(deal['image']!).startsWith('http')
                                          ? Image.network(
                                        _getEffectiveImageUrl(deal['image']!),
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Image.asset(
                                          'assets/placeholder.png',
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                          : Image.asset(
                                        _getEffectiveImageUrl(deal['image']!),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  deal['name']!,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1, // Ensure text fits
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  deal['original']!,
                                  style: GoogleFonts.poppins(
                                    decoration: TextDecoration.lineThrough, // Strikethrough for original price
                                  ),
                                  maxLines: 1, // Ensure text fits
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  deal['price']!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.green, // Discounted price color
                                  ),
                                  maxLines: 1, // Ensure text fits
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Expanded( // Ensure button takes available space
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Add to cart for deal products
                                      Provider.of<CartModel>(context, listen: false)
                                          .addItem(dealProduct.copyWith());
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${dealProduct.title} added to cart!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xffEB7720),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 8)),
                                    child: Text(
                                      "Add",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                      shrinkWrap: true, // Wrap content to minimum size
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 items per row
                        childAspectRatio: 1.1, // Aspect ratio for grid items
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _categories.length, // Uses _categories populated from ProductService.getAllCategories()
                      itemBuilder: (context, index) {
                        final categoryItem = _categories[index];
                        final categoryLabel = categoryItem['label']!;
                        final categoryIcon = categoryItem['icon']!;
                        final categoryId = categoryItem['cat_id']!; // Get the cat_id

                        return GestureDetector( // Added GestureDetector for category tiles
                          onTap: () {
                            // Navigate to the specific category product screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryProductsScreen( // Added const
                                  categoryTitle: categoryLabel,
                                  categoryId: categoryId, // Pass the category ID
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset( // Assuming category icons are local assets
                                  categoryIcon,
                                  width: 32,
                                  height: 32,
                                  color: const Color(0xffEB7720), // Orange icon color
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  categoryLabel,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2, // Allow more lines for long labels
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to the Bot widget with initialIndex 1 for Categories
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Bot(initialIndex: 1)),
                                (Route<dynamic> route) => false, // Clears the navigation stack
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          backgroundColor: const Color(0xffEB7720), // Orange button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'View All',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "New On Kisangro",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                      shrinkWrap: true,
                      itemCount: _newOnKisangroItems.length, // Uses _newOnKisangroItems populated from ProductService.getAllProducts()
                      gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200, // Max width for items
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        mainAxisExtent: 320, // Explicitly set height for each tile to avoid overflow
                      ),
                      itemBuilder: (context, index) {
                        final product = _newOnKisangroItems[index]; // Use dynamic product
                        return _buildProductTile(context, product); // Reuse the same tile builder
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Extracted Product Tile Builder for Reusability and Pixel Overflow Fixes
  Widget _buildProductTile(BuildContext context, Product product) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42, // For trending, this controls its width
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [ // Added consistent shadow for tiles
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Allows column to take minimum vertical space
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
        children: [
          // Image Section - Refined for "autoscale" and no overflow
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider<Product>.value(
                    value: product,
                    child: ProductDetailPage(product: product),
                  ),
                ),
              );
            },
            child: SizedBox(
              width: double.infinity, // Take full width of parent column
              height: 100, // Fixed height for the image display area
              child: Center( // Center the AspectRatio/Image within this fixed height box
                child: AspectRatio(
                  aspectRatio: 1.0, // Aim for a square image container within the 100px height
                  child: _getEffectiveImageUrl(product.imageUrl).startsWith('http')
                      ? Image.network(
                    _getEffectiveImageUrl(product.imageUrl),
                    fit: BoxFit.contain, // Image scales to fit within the square AspectRatio, preserving aspect ratio
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/placeholder.png',
                      fit: BoxFit.contain,
                    ),
                  )
                      : Image.asset(
                    _getEffectiveImageUrl(product.imageUrl),
                    fit: BoxFit.contain, // Image scales to fit within the square AspectRatio, preserving aspect ratio
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 3), // Reduced from 5
          Text(
            product.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1, // Limit to one line
            overflow: TextOverflow.ellipsis, // Add ellipsis if too long
          ),
          const SizedBox(height: 2), // Very small space
          Text(
            product.subtitle,
            style: GoogleFonts.poppins(fontSize: 12),
            maxLines: 1, // Limit to one line
            overflow: TextOverflow.ellipsis,
          ),
          // Price display (if available and greater than 0)
          // NOTE: Price will show '0.00' or not at all if API doesn't provide 'mrp' for sizes.
          if (product.pricePerSelectedUnit != null && product.pricePerSelectedUnit! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0), // Small top padding
              child: Text(
                '₹${product.pricePerSelectedUnit!.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 5), // Reduced from 8
          SizedBox(
            height: 36, // Fixed height for dropdown to prevent it from growing too much
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: product.selectedUnit,
                icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xffEB7720)),
                isExpanded: true,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.black),
                items: product.availableSizes.map((ProductSize sizeOption) {
                  return DropdownMenuItem<String>(
                    value: sizeOption.size,
                    child: Text(sizeOption.size),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (!mounted) return;
                  setState(() {
                    product.selectedUnit = newValue!; // Update selected unit
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 5), // Reduced from 10
          Row(
            children: [
              Expanded( // Ensures button takes available space
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<CartModel>(context, listen: false)
                        .addItem(product.copyWith()); // Add to cart
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.title} added to cart!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffEB7720),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8)),
                  child: Text(
                    "Add",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Space between add and wishlist button
              // Fixed size for IconButton to prevent horizontal overflow
              SizedBox(
                width: 44, // Standard IconButton size to control width
                height: 44, // Standard IconButton size to control height
                child: Consumer<WishlistModel>( // Consumer for wishlist state
                  builder: (context, wishlist, child) {
                    final bool isFavorite = wishlist.items.any(
                          (item) => item.id == product.id && item.selectedUnit == product.selectedUnit,
                    );
                    return IconButton(
                      padding: EdgeInsets.zero, // Remove default padding
                      visualDensity: VisualDensity.compact, // Make it compact
                      onPressed: () {
                        if (!mounted) return;
                        if (isFavorite) {
                          wishlist.removeItem(product.id, product.selectedUnit); // Remove from wishlist
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${product.title} removed from wishlist!'),
                                backgroundColor: Colors.red),
                          );
                        } else {
                          wishlist.addItem(product.copyWith()); // Add to wishlist
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${product.title} added to wishlist!'),
                                backgroundColor: Colors.blue),
                          );
                        }
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xffEB7720),
                        size: 24, // Explicitly set icon size for consistency
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xffEB7720)), // Search icon (Orange)
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(), // Navigate to search screen
                            ),
                          );
                        },
                        style: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                        decoration: InputDecoration(
                          hintText: 'Search here',
                          hintStyle: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                          border: InputBorder.none, // No border for text field
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // The container holding the location icon and text
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            height: 40,
            // Changed constraints to Expanded and added Row with MainAxisSize.min
            // This ensures it takes available space but doesn't force too much growth
            // when the text is short.
            constraints: const BoxConstraints(minWidth: 50, maxWidth: 150), // Set a reasonable max width
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Key: Make Row consume minimum horizontal space
              children: [
                // Replaced GestureDetector with IconButton
                IconButton(
                  icon: const Icon(Icons.location_on_outlined, color: Color(0xffEB7720)),
                  onPressed: _determinePosition, // Re-call location detection on tap
                  padding: EdgeInsets.zero, // Remove default padding
                  constraints: const BoxConstraints(), // Remove default constraints
                  splashRadius: 20, // Define splash radius
                ),
                const SizedBox(width: 4),
                // Using Flexible with FittedBox to ensure text always tries to fit within available space
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown, // Shrink text if necessary
                    alignment: Alignment.centerLeft, // Align text to the left within FittedBox
                    child: Text(
                      _currentLocation.isNotEmpty ? _currentLocation : 'Location', // Fallback text
                      style: GoogleFonts.poppins(
                        color: const Color(0xffEB7720),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                      maxLines: 1, // Ensure it doesn't wrap to multiple lines
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the dot indicators for the image carousel.
  Widget _buildDotIndicators() {
    return Center(
      child: SmoothPageIndicator(
        controller: _pageController,
        count: _carouselImages.length,
        effect: const ExpandingDotsEffect(
          activeDotColor: Color(0xFF5EFF66), // Green active dot
          dotColor: Color(0xFFCBFFCE), // Light green inactive dot
          dotHeight: 5,
          dotWidth: 5,
          spacing: 6,
        ),
      ),
    );
  }

  /// Builds the header section for the drawer.
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
                        final Uint8List? kycImageBytes = kycImageProvider.kycImageBytes; // Get image bytes
                        return kycImageBytes != null
                            ? Image.memory( // Display image from bytes if available
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
                "Hi Smart!\n9876543210", // User name and number
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, // Use double.infinity to fill available width
            child: Padding(
              padding: const EdgeInsets.only(left: 0), // Removed left padding to center
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MembershipDetailsScreen(), // Navigate to membership screen
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        height: 40,
        decoration: const BoxDecoration(color: Color(0xffffecdc)), // Light orange background
        child: ListTile(
          leading: Icon(icon, color: const Color(0xffEB7720)), // Orange icon
          title: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
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
                  MaterialPageRoute(builder: (context) => const MyAccountPage()),
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
                  MaterialPageRoute(builder: (context) =>  AskUsPage()),
                );
                break;
              case 'Rate Us':
                showComplaintDialog(context); // Show review dialog
                break;
              case 'Settings':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  SettingsPage()),
                );
                break;
              case 'Logout':
                _showLogoutDialog(context); // Show logout confirmation dialog
                break;
              case 'About Us':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('About Us page coming soon!')),
                );
                break;
              case 'Share Kisangro':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share functionality coming soon!')),
                );
                break;
              case 'Wishlist': // Handle Wishlist as it was added back to menu items
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistPage()),
                );
                break;
            }
          },
        ),
      ),
    );
  }
}
