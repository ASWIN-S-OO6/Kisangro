import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kisangro/home/categories.dart'; // Ensure this import is correct for ProductCategoriesScreen
import 'package:kisangro/home/product.dart'; // Your existing ProductDetailPage
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/models/kyc_image_provider.dart';
import 'package:kisangro/services/product_service.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/home/search_bar.dart';
import 'package:kisangro/home/bottom.dart'; // This is your Bot/Home screen container
import '../categories/category_products_screen.dart'; // Ensure this import is correct
import 'package:kisangro/home/cart.dart';
import 'package:kisangro/home/trending_products_screen.dart';
import 'package:kisangro/home/new_on_kisangro_products_screen.dart'; // Import the new screen
import 'package:kisangro/home/deals_of_the_day_screen.dart'; // NEW: Import the new DealsOfTheDayScreen
// Removed 'dart:math' as random logic is now in ProductService

import '../common/common_app_bar.dart';
import 'custom_drawer.dart';


class HomeScreen extends StatefulWidget {
  final VoidCallback? onCategoryViewAll;

  const HomeScreen({super.key, this.onCategoryViewAll});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _carouselTimer;
  Timer? _refreshTimer;
  List<Product> _trendingItems = [];
  List<Product> _newOnKisangroItems = [];
  List<Map<String, String>> _categories = []; // This list will hold categories for the new section
  final List<Map<String, String>> _rawDeals = [ // Renamed to _rawDeals
    {'name': 'VALAX', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/Valaxa.png'},
    {'name': 'OXYFEN', 'price': '₹ 1000/piece', 'original': '₹ 2000', 'image': 'assets/Oxyfen.png'},
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/hyfen.png'},
    {'name': 'VALAX', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/Valaxa.png'}, // Duplicated
    {'name': 'OXYFEN', 'price': '₹ 1000/piece', 'original': '₹ 2000', 'image': 'assets/Oxyfen.png'}, // Duplicated
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/hyfen.png'}, // Duplicated
    {'name': 'VALAX', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/Valaxa.png'}, // Duplicated
    {'name': 'OXYFEN', 'price': '₹ 1000/piece', 'original': '₹ 2000', 'image': 'assets/Oxyfen.png'}, // Duplicated
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/hyfen.png'}, // Duplicated
  ];
  List<Product> _deals = []; // NEW: List to hold converted Product objects for deals

  final List<String> _carouselImages = [
    'assets/veg.png',
    'assets/product.png',
    'assets/bulk.png',
    'assets/nature.png',
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Removed _localFallbackImages and _random as logic is now in ProductService

  // Helper function to determine the effective image URL
  String _getEffectiveImageUrl(String rawImageUrl) {
    // ProductService now ensures imageUrl is always valid (API or deterministic fallback)
    return rawImageUrl;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
    _startCarousel();
    // _refreshTimer = Timer.periodic(const Duration(minutes: 5), (Timer timer) {
    //   debugPrint('Auto-refreshing homepage data...');
    //   //_refreshData();
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _carouselTimer?.cancel();
    _refreshTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed to homepage, re-checking membership status...');
    }
  }

  Future<void> _loadInitialData() async {
    // Rely on ProductService.initialize() to have already loaded data.
    // This method should be called once at app startup (e.g., in main.dart).
    // If data is not yet loaded, it might be a cold start or an issue with ProductService initialization.
    // We'll just get the current state of data from ProductService.
    if (mounted) {
      setState(() {
        _trendingItems = ProductService.getAllProducts().take(10).toList();
        _newOnKisangroItems = ProductService.getAllProducts().skip(0).take(10).toList();

        // Fallback for newOnKisangroItems if API data is empty (for initial development/testing)
        if (_newOnKisangroItems.isEmpty) {
          // These dummy products will now get their images handled deterministically by ProductService
          _newOnKisangroItems = List.generate(
            10,
                (index) => Product(
              id: 'new_dummy_$index',
              title: 'New Item $index',
              subtitle: 'Fresh Arrival',
              imageUrl: '', // Empty to trigger deterministic fallback in ProductService
              category: 'New',
              availableSizes: [ProductSize(size: 'kg', price: 100.0 + index * 5)],
              selectedUnit: 'kg',
            ),
          );
        }
        _categories = ProductService.getAllCategories();
        // Convert _rawDeals to Product objects
        _deals = _rawDeals.map((deal) {
          final double price = double.tryParse(deal['price']!.replaceAll('₹ ', '').replaceAll('/piece', '')) ?? 0.0;
          return Product(
            id: 'Deal_${deal['name']!}_${_rawDeals.indexOf(deal)}',
            title: deal['name']!,
            subtitle: 'Special Deal', // Or use original price if available
            imageUrl: deal['image']!, // Use the image from _rawDeals directly (which are assets)
            category: 'Deals',
            availableSizes: [ProductSize(size: 'piece', price: price)],
            selectedUnit: 'piece',
          );
        }).toList();

        debugPrint('HomeScreen: Loaded Trending Items: ${_trendingItems.length}');
        debugPrint('HomeScreen: Loaded New On Kisangro: ${_newOnKisangroItems.length}');
        debugPrint('HomeScreen: Loaded Categories: ${_categories.length}');
        debugPrint('HomeScreen: Loaded Deals: ${_deals.length}');
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(), // Integrate CustomDrawer
      appBar: CustomAppBar( // Integrate CustomAppBar
        title: "Hello!", // Title for the home screen
        showBackButton: false, // Home screen typically doesn't have a back button
        showMenuButton: true, // Show menu button to open the drawer
        scaffoldKey: _scaffoldKey, // Pass the scaffold key to open the drawer
        isMyOrderActive: false, // Not active on home screen
        isWishlistActive: false, // Not active on home screen
        isNotiActive: false, // Not active on home screen
        showWhatsAppIcon: true, // Show WhatsApp icon on home screen
      ),
      backgroundColor: const Color(0xFFFFF7F1),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 290,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Image.asset(
                      'assets/bghome.jpg',
                      height: 290,
                      width: double.infinity,
                      fit: BoxFit.cover,
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
                    child: _buildSearchBar(),
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
                    child: _buildDotIndicators(),
                  ),
                ],
              ),
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
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  itemBuilder: (context, index) {
                    final product = _trendingItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to your original ProductDetailPage (from product.dart)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        // Wrap each product tile with a ChangeNotifierProvider
                        child: ChangeNotifierProvider<Product>.value(
                          value: product,
                          child: _buildProductTile(context, product, tileWidth: 150), // Use the local function
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              // NEW: Title and View All for Deals of the Day
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Deals of the Day", // Changed title here
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to DealsOfTheDayScreen
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DealsOfTheDayScreen(deals: _deals)));
                      },
                      child: Text(
                        "View All",
                        style: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 400,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/diwali.png"),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 160),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _deals.length, // Use the converted _deals list
                        itemBuilder: (context, index) {
                          final product = _deals[index]; // Now directly a Product object
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                            child: GestureDetector( // Added GestureDetector for deal tiles
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(product: product),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 80,
                                    child: Center(
                                      child: AspectRatio(
                                        aspectRatio: 1.0,
                                        child: _getEffectiveImageUrl(product.imageUrl).startsWith('http')
                                            ? Image.network(
                                            _getEffectiveImageUrl(product.imageUrl),
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) => Image.asset(
                                              'assets/placeholder.png',
                                              fit: BoxFit.contain,
                                            ))
                                            : Image.asset(
                                          _getEffectiveImageUrl(product.imageUrl),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5), // Reduced from 10 to 5
                                  Text(
                                    product.title, // Use product.title
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Display original price if available in product.subtitle or a new field
                                  // For now, using a placeholder original price from _rawDeals for demo
                                  if (_rawDeals[index]['original'] != null)
                                    Text(
                                      _rawDeals[index]['original']!, // Still referencing raw for original price
                                      style: GoogleFonts.poppins(decoration: TextDecoration.lineThrough),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  // Removed Padding, adjusted font size slightly
                                  Text(
                                    '₹${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}', // Use product.pricePerSelectedUnit
                                    style: GoogleFonts.poppins(color: Colors.green, fontSize: 12.5), // Slightly reduced font size
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Top Categories Section (Vertical Grid)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Top Categories",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Use the callback to notify the parent Bot widget to change the tab
                        widget.onCategoryViewAll?.call();
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.builder(
                  shrinkWrap: true, // Important for nested scroll views
                  physics: const NeverScrollableScrollPhysics(), // Important for nested scroll views
                  itemCount: _categories.take(6).length, // Display only the first 6 categories
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( // Conditional grid delegate for categories
                    crossAxisCount: isTablet ? 4 : 3, // 4 columns for tablets, 3 for phones
                    mainAxisSpacing: 12, // Vertical spacing between tiles
                    crossAxisSpacing: 12, // Horizontal spacing between tiles
                    childAspectRatio: isTablet ? 0.9 : 0.85, // Adjust this for desired height/width ratio of tiles
                  ),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () {
                        // This navigation is for tapping individual category tiles,
                        // which should still push a new screen as before.
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
                            if (category['icon'] != null && category['icon']!.isNotEmpty)
                              Image.asset(
                                category['icon']!, // Use 'icon' key
                                height: 40,
                                width: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.category, size: 40, color: Color(0xffEB7720)); // Fallback icon
                                },
                              )
                            else
                              const Icon(Icons.category, size: 40, color: Color(0xffEB7720)), // Fallback if icon path is null/empty
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                category['label']!, // Use 'label' key
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
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
              const SizedBox(height: 30),
              const Divider(
                color: Colors.white,
                thickness: 8.0,
                height: 0,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "New On Kisangro",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOnKisangroProductsScreen()));
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double screenWidth = constraints.maxWidth;
                    final orientation = MediaQuery.of(context).orientation;
                    int crossAxisCount;
                    double childAspectRatio;

                    if (screenWidth > 900) { // Large tablets / Desktops
                      crossAxisCount = 5;
                      childAspectRatio = 0.43; // Further adjusted
                    } else if (screenWidth > 700) { // Medium tablets
                      crossAxisCount = 4;
                      childAspectRatio = 0.48; // Further adjusted
                    } else if (screenWidth > 450) { // Small tablets / Large phones
                      crossAxisCount = 3;
                      childAspectRatio = 0.53; // Further adjusted
                    } else { // Mobile phones
                      crossAxisCount = 2;
                      childAspectRatio = 0.56; // Further adjusted
                    }

                    // Further adjust for landscape on smaller screens if needed
                    if (orientation == Orientation.landscape && screenWidth < 700) {
                      crossAxisCount = 3; // More columns in landscape for phones
                      childAspectRatio = 0.70; // Make tiles wider in landscape
                    }

                    // MODIFICATION FOR TABLET LANDSCAPE COMPACTNESS (Adjusted for overflow)
                    if (isTablet && orientation == Orientation.landscape) {
                      crossAxisCount = 5; // More columns for a compact view
                      childAspectRatio = 0.65; // Adjusted to make tiles relatively taller/narrower
                    }


                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: _newOnKisangroItems.length,
                      itemBuilder: (context, index) {
                        final product = _newOnKisangroItems[index];
                        // Wrap each product tile with a ChangeNotifierProvider
                        return ChangeNotifierProvider<Product>.value(
                          value: product,
                          child: _buildProductTile(context, product), // Use the local function
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
              },
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xffEB7720)),
                  const SizedBox(width: 10),
                  Text(
                    'Search here...',
                    style: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Center(
      child: AnimatedSmoothIndicator(
        activeIndex: _currentPage,
        count: _carouselImages.length,
        effect: const ExpandingDotsEffect(
          activeDotColor: Color(0xffEB7720),
          dotHeight: 5,
          dotWidth: 8,
        ),
      ),
    );
  }

  // This is the private function for product tiles, now defined within the same State class
  Widget _buildProductTile(BuildContext context, Product product, {double? tileWidth}) {
    // Listen to changes in the Product object provided by ChangeNotifierProvider
    // This Consumer is crucial for the tile to rebuild when product.selectedUnit changes
    return Consumer<Product>(
      builder: (context, product, child) {
        // Ensure selectedUnit is valid, default to first available if not
        final List<ProductSize> availableSizes = product.availableSizes.isNotEmpty
            ? product.availableSizes
            : [ProductSize(size: 'Unit', price: product.pricePerSelectedUnit ?? 0.0)];

        final String selectedUnit = availableSizes.any((size) => size.size == product.selectedUnit)
            ? product.selectedUnit
            : availableSizes.first.size;

        return Container(
          width: tileWidth, // Apply optional width
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  height: 100, // Fixed height for image area
                  width: double.infinity,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _getEffectiveImageUrl(product.imageUrl).startsWith('http')
                          ? Image.network(
                        _getEffectiveImageUrl(product.imageUrl),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/placeholder.png', // Fallback to local placeholder if network image fails
                          fit: BoxFit.contain,
                        ),
                      )
                          : Image.asset(
                        _getEffectiveImageUrl(product.imageUrl), // This will now use the static placeholder
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded( // Use Expanded to allow content to take available space
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space vertically
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
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
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600),
                          ),
                          Text('Unit: $selectedUnit',
                              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xffEB7720))),
                          const SizedBox(height: 8),
                          Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xffEB7720)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedUnit,
                                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xffEB7720), size: 20),
                                underline: const SizedBox(),
                                isExpanded: true,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                                items: availableSizes.map((sizeOption) => DropdownMenuItem<String>(
                                  value: sizeOption.size,
                                  child: Text(sizeOption.size),
                                )).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    // Directly modify the product and notify listeners
                                    product.selectedUnit = val;
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), // Add some spacing before the buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Provider.of<CartModel>(context, listen: false).addItem(product.copyWith());
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
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8)), // Adjusted horizontal padding
                              child: Text(
                                "Add",
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ),
                          Consumer<WishlistModel>(
                            builder: (context, wishlist, child) {
                              final bool isFavorite = wishlist.items.any(
                                      (item) => item.id == product.id && item.selectedUnit == product.selectedUnit);
                              return IconButton(
                                onPressed: () {
                                  if (isFavorite) {
                                    wishlist.removeItem(product.id, product.selectedUnit);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.title} removed from wishlist!'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    wishlist.addItem(product.copyWith());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.title} added to wishlist!'),
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
              ),
            ],
          ),
        );
      },
    );
  }
}
