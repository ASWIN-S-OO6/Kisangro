import 'dart:async';
import 'dart:typed_data'; // Essential for Uint8List to display image bytes
import 'package:flutter/cupertino.dart'; // For CupertinoIcons, if used
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:carousel_slider/carousel_slider.dart'; // For carousel functionality
import 'package:kisangro/home/categories.dart'; // ProductCategoriesScreen (updated reference)
import 'package:kisangro/home/product.dart'; // ProductDetailPage
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // For carousel page indicators
import 'package:dotted_border/dotted_border.dart'; // For dotted borders - now only for UI elements outside drawer
import 'package:provider/provider.dart'; // For state management
import 'package:geolocator/geolocator.dart'; // Import geolocator
import 'package:geocoding/geocoding.dart'; // Import geocoding for reverse geocoding
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // NEW: Import for Font Awesome icons

// Import your custom models
import 'package:kisangro/models/product_model.dart'; // Assuming this model exists
import 'package:kisangro/models/cart_model.dart'; // Assuming this model exists
import 'package:kisangro/models/wishlist_model.dart'; // Assuming this model exists
import 'package:kisangro/models/kyc_image_provider.dart'; // Your custom KYC image provider (still needed for profile image display outside drawer if any)
import 'package:kisangro/services/product_service.dart'; // Import ProductService

// Your existing page imports (ensure these paths are correct in your project)
import 'package:kisangro/home/myorder.dart'; // MyOrder
import 'package:kisangro/home/noti.dart'; // noti
import 'package:kisangro/home/search_bar.dart'; // SearchScreen
import 'package:kisangro/home/bottom.dart'; // Import the Bot widget for navigation with bottom bar

import '../categories/category_products_screen.dart';
import 'package:kisangro/home/cart.dart'; // Import the cart page for navigation to cart
import 'package:kisangro/home/trending_products_screen.dart'; // TrendingProductsScreen
import 'package:kisangro/home/new_on_kisangro_screen.dart'; // Import the new screen


// NEW: Import the CustomDrawer
import 'custom_drawer.dart';
import '../menu/wishlist.dart'; // Ensure WishlistPage is imported for navigation from AppBar


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _carouselTimer; // Declared for the carousel auto-scrolling
  Timer? _refreshTimer; // Declared for the auto-refresh logic
  String _currentLocation = 'Detecting...'; // Placeholder for location

  // --- Dynamic product lists, populated from ProductService.getAllProducts() ---
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
    WidgetsBinding.instance.addObserver(this); // Add observer for lifecycle events
    _loadInitialData(); // Load products and categories initially
    _startCarousel(); // Start auto-scrolling carousel
    _determinePosition(); // Fetch location on init

    // Start auto-refresh timer (e.g., every 5 minutes)
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (Timer timer) {
      debugPrint('Auto-refreshing homepage data...');
      _refreshData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    _carouselTimer?.cancel(); // Cancel carousel timer
    _refreshTimer?.cancel(); // Cancel auto-refresh timer
    _pageController.dispose(); // Dispose page controller
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // This method is called when the app's lifecycle state changes
    if (state == AppLifecycleState.resumed) {
      // When the app resumes (e.g., coming back from another screen like payment)
      debugPrint('App resumed to homepage, re-checking membership status...');
    }
  }

  /// Loads initial product and category data from ProductService.
  /// This method is called once on initState and also during auto-refresh.
  Future<void> _loadInitialData() async {
    try {
      await ProductService.loadProductsFromApi(); // Re-fetch products from API (POST request with type=1041)
      await ProductService.loadCategoriesFromApi(); // Ensure categories are loaded (type=1043)
    } catch (e) {
      debugPrint('Error during initial data load/refresh: $e');
    }

    if (mounted) {
      setState(() {
        _trendingItems = ProductService.getAllProducts().take(6).toList();
        _newOnKisangroItems = ProductService.getAllProducts().reversed.take(6).toList();
        _categories = ProductService.getAllCategories();
      });
    }
  }

  /// Method specifically for triggering a refresh of all homepage data.
  /// Called by the auto-refresh timer.
  Future<void> _refreshData() async {
    await _loadInitialData();
  }

  /// Starts a timer for auto-scrolling the carousel.
  void _startCarousel() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && mounted) {
        int nextPageIndex = _currentPage + 1;
        if (nextPageIndex >= _carouselImages.length) {
          _pageController.jumpToPage(0);
          nextPageIndex = 0;
        } else {
          _pageController.animateToPage(
            nextPageIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        setState(() {
          _currentPage = nextPageIndex;
        });
      }
    });
  }

  /// Fetches and updates the current location using geolocator.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

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

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (mounted) {
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          setState(() {
            _currentLocation = '${place.subLocality ?? ''}, ${place.locality ?? place.administrativeArea ?? ''}';
            _currentLocation = _currentLocation.trim().replaceAll(RegExp(r'^,?\s*'), '').replaceAll(RegExp(r',?\s*,+'), ', ').trim();
            if (_currentLocation.isEmpty) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign scaffold key to control drawer
      drawer: const CustomDrawer(), // *** USE THE NEW CUSTOM DRAWER HERE ***
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720), // AppBar background color
        centerTitle: false,
        title: Transform.translate(
          offset: const Offset(-20, 0), // Adjust title position
          child: Text(
            "Hello !",
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
              IconButton( // Changed to IconButton for consistency
                onPressed: () {
                  // Implement WhatsApp functionality here (e.g., launch URL)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('WhatsApp functionality coming soon!')),
                  );
                },
                icon: const FaIcon( // Replaced with Font Awesome outline icon
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 1), // Standardized spacing to 8

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
              const SizedBox(width: 1), // Standardized spacing to 8

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
                  height: 26,
                  width: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 1), // Standardized spacing to 8

              // Notifications icon
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const noti()), // Navigate to Notifications
                  );
                },
                icon: Image.asset(
                  'assets/noti.png',
                  height: 28,
                  width: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 2), // Standardized padding at the very end
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
                    child: _buildSearchBar(), // Modified Search bar widget (includes location)
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
                        onPageChanged: (index) => setState(() => _currentPage = index),
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
                height: 305, // Retain fixed height for horizontal scroll
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _trendingItems.length,
                  padding: const EdgeInsets.only(left: 12, right: 12), // Add overall padding if needed
                  itemBuilder: (context, index) {
                    final product = _trendingItems[index];
                    return Padding( // Wrap _buildProductTile with Padding
                      padding: const EdgeInsets.only(right: 12), // Add space to the right of each tile
                      // Pass the product object when tapping the tile
                      child: GestureDetector( // Added GestureDetector here for navigation
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: _buildProductTile(context, product, tileWidth: 150), // *** PASS FIXED WIDTH HERE ***
                      ),
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
                            width: 140, // Fixed width for deal tiles
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
                                      child: _getEffectiveImageUrl(deal['image']!).startsWith('http') ? Image.network(
                                        _getEffectiveImageUrl(deal['image']!),
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Image.asset(
                                          'assets/placeholder.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ) : Image.asset(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween
                  children: [
                    Text(
                      "New On Kisangro",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector( // Added GestureDetector for "View All"
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOnKisangroScreen()));
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
              // --- MODIFIED: New On Kisangro Section to display vertically with adjusted childAspectRatio ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.55, // Adjusted to make tiles taller and provide more vertical space
                  ),
                  itemCount: _newOnKisangroItems.length,
                  itemBuilder: (context, index) {
                    final product = _newOnKisangroItems[index];
                    // Pass the product object when tapping the tile
                    return GestureDetector( // Added GestureDetector here for navigation
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(product: product),
                          ),
                        );
                      },
                      child: _buildProductTile(context, product),
                    );
                  },
                ),
              ),
              // --- END MODIFIED SECTION ---
              const SizedBox(height: 30), // Removed the SizedBox after the membership section as well
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the search bar and location display
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, // White container background
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search part (clickable)
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
            },
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xffEB7720)), // Orange icon
                const SizedBox(width: 10),
                Text(
                  'Search here...',
                  style: GoogleFonts.poppins(color: const Color(0xffEB7720)), // Orange text
                ),
              ],
            ),
          ),
          const Spacer(), // Pushes search to left, location to right

          // Separator (visual only)
          Container(
            height: 24, // Height of the divider to match text height
            child: const VerticalDivider(color: Colors.grey),
          ),
          const SizedBox(width: 10),

          // Location part (display only)
          Expanded( // Use Expanded to ensure the location text is properly handled
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align contents to the end
              children: [
                const Icon(Icons.location_on, color: Color(0xffEB7720), size: 18), // Orange icon
                const SizedBox(width: 5),
                Expanded( // Nested Expanded to allow text overflow handling if needed
                  child: Text(
                    _currentLocation,
                    style: GoogleFonts.poppins(
                      color: const Color(0xffEB7720), // Orange text
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis, // Truncate long location names
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build carousel dot indicators
  Widget _buildDotIndicators() {
    return Center(
      child: AnimatedSmoothIndicator(
        activeIndex: _currentPage,
        count: _carouselImages.length,
        effect: ExpandingDotsEffect(
          activeDotColor: const Color(0xffEB7720),
          dotHeight: 5,
          dotWidth: 8,
        ),
      ),
    );
  }

  // Widget to build individual product tiles
  Widget _buildProductTile(BuildContext context, Product product, {double? tileWidth}) {
    return Container(
      width: tileWidth, // This will be 150 for Trending, and null for New On Kisangro, allowing GridView to manage
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed height for image area to ensure consistency and prevent layout shifts
          SizedBox(
            height: 100, // Adjusted height to give more space to other components
            width: double.infinity, // Take full width of the tile
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _getEffectiveImageUrl(product.imageUrl).startsWith('http')
                    ? Image.network(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain, // Use BoxFit.contain to ensure the whole image is visible
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/placeholder.png', // Fallback local image
                    fit: BoxFit.contain,
                  ),
                )
                    : Image.asset(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.subtitle,
                  style: GoogleFonts.poppins(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '₹ ${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600),
                ),
                Text('Unit: ${product.selectedUnit}',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: const Color(0xffEB7720))),
                const SizedBox(height: 8),
                Container(
                  height: 36, // Fixed height for consistency
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffEB7720)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: product.selectedUnit,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xffEB7720), size: 20),
                      underline: const SizedBox(),
                      isExpanded: true,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                      items: product.availableSizes
                          .map((sizeOption) => DropdownMenuItem<String>(
                        value: sizeOption.size,
                        child: Text(sizeOption.size),
                      ))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          product.selectedUnit = val!; // Update the product's selected unit
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Add to cart functionality
                          Provider.of<CartModel>(context, listen: false)
                              .addItem(product.copyWith());
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
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                        child: Text(
                          "Add",
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                    Consumer<WishlistModel>(
                      builder: (context, wishlist, child) {
                        final bool isFavorite = wishlist.items.any(
                              (item) =>
                          item.id == product.id &&
                              item.selectedUnit == product.selectedUnit,
                        );
                        return IconButton(
                          onPressed: () {
                            if (isFavorite) {
                              wishlist.removeItem(product.id, product.selectedUnit);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${product.title} removed from wishlist!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              wishlist.addItem(product.copyWith());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${product.title} added to wishlist!'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            }
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: const Color(0xffEB7720),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
