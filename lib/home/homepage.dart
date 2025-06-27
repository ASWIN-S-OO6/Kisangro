import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kisangro/home/categories.dart';
import 'package:kisangro/home/product.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/models/kyc_image_provider.dart';
import 'package:kisangro/services/product_service.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/home/search_bar.dart';
import 'package:kisangro/home/bottom.dart';
import '../categories/category_products_screen.dart';
import 'package:kisangro/home/cart.dart';
import 'package:kisangro/home/trending_products_screen.dart';
import 'custom_drawer.dart';
import '../menu/wishlist.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  Timer? _carouselTimer;
  Timer? _refreshTimer;
  String _currentLocation = 'Detecting...';
  List<Product> _trendingItems = [];
  List<Product> _newOnKisangroItems = [];
  List<Map<String, String>> _categories = [];
  final List<Map<String, String>> _deals = [
    {'name': 'VALAX', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/Valaxa.png'},
    {'name': 'OXYFEN', 'price': '₹ 1000/piece', 'original': '₹ 2000', 'image': 'assets/Oxyfen.png'},
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/hyfen.png'},
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/Valaxa.png'},
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/Oxyfen.png'},
    {'name': 'HYFEN', 'price': '₹ 1550/piece', 'original': '₹ 2000', 'image': 'assets/hyfen.png'},
  ];
  final List<String> _carouselImages = [
    'assets/veg.png',
    'assets/product.png',
    'assets/bulk.png',
    'assets/nature.png',
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png';
    }
    return rawImageUrl;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialData();
    _startCarousel();
    _determinePosition();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (Timer timer) {
      debugPrint('Auto-refreshing homepage data...');
      _refreshData();
    });
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
    try {
      await ProductService.loadProductsFromApi();
      await ProductService.loadCategoriesFromApi();
      if (mounted) {
        setState(() {
          _trendingItems = ProductService.getAllProducts().take(6).toList();
          _newOnKisangroItems = ProductService.getAllProducts().take(6).toList();
          _categories = ProductService.getAllCategories();
          debugPrint('Trending Items: ${_trendingItems.map((p) => "${p.title}: ${p.availableSizes.map((s) => s.size).toList()}").toList()}');
          debugPrint('New On Kisangro: ${_newOnKisangroItems.map((p) => "${p.title}: ${p.availableSizes.map((s) => s.size).toList()}").toList()}');
        });
      }
    } catch (e) {
      debugPrint('Error during initial data load/refresh: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadInitialData();
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
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        centerTitle: false,
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            "Hello!",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu, color: Colors.white),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Add WhatsApp functionality
                },
                icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 1),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyOrder()),
                  );
                },
                icon: Image.asset(
                  'assets/box.png',
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 1),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WishlistPage()),
                  );
                },
                icon: Image.asset(
                  'assets/heart.png',
                  height: 26,
                  width: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 1),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const noti()),
                  );
                },
                icon: Image.asset(
                  'assets/noti.png',
                  height: 28,
                  width: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 1),
            ],
          ),
        ],
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                        child: _buildProductTile(context, product, tileWidth: 150),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
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
                        itemCount: _deals.length,
                        itemBuilder: (context, index) {
                          final deal = _deals[index];
                          final Product dealProduct = Product(
                            id: 'Deal_${deal['name']!}_$index',
                            title: deal['name']!,
                            subtitle: 'Special Deal',
                            imageUrl: deal['image']!,
                            category: 'Deals',
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
                                SizedBox(
                                  width: double.infinity,
                                  height: 80,
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: _getEffectiveImageUrl(deal['image']!).startsWith('http')
                                          ? Image.network(
                                          _getEffectiveImageUrl(deal['image']!),
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) => Image.asset(
                                            'assets/placeholder.png',
                                            fit: BoxFit.contain,
                                          ))
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
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  deal['original']!,
                                  style: GoogleFonts.poppins(decoration: TextDecoration.lineThrough),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  deal['price']!,
                                  style: GoogleFonts.poppins(color: Colors.green),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Provider.of<CartModel>(context, listen: false).addItem(dealProduct.copyWith());
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
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8)),
                                    child: Text(
                                      "Add",
                                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "New On Kisangro",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: _newOnKisangroItems.length,
                  itemBuilder: (context, index) {
                    final product = _newOnKisangroItems[index];
                    return GestureDetector(
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
          GestureDetector(
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
          const Spacer(),
          Container(
            height: 24,
            child: const VerticalDivider(color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.location_on, color: Color(0xffEB7720), size: 18),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _currentLocation,
                    style: GoogleFonts.poppins(
                      color: const Color(0xffEB7720),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
        effect: ExpandingDotsEffect(
          activeDotColor: const Color(0xffEB7720),
          dotHeight: 5,
          dotWidth: 8,
        ),
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product, {double? tileWidth}) {
    final List<ProductSize> availableSizes = product.availableSizes.isNotEmpty
        ? product.availableSizes
        : [ProductSize(size: 'Default', price: 0.0)];
    final String selectedUnit = availableSizes.any((size) => size.size == product.selectedUnit)
        ? product.selectedUnit
        : availableSizes.first.size;

    return Container(
      width: tileWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            width: double.infinity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
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
                        setState(() {
                          product.selectedUnit = val!;
                          debugPrint('Selected unit for ${product.title}: $val, Price: ₹${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}');
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
                            padding: const EdgeInsets.symmetric(vertical: 8)),
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
        ],
      ),
    );
  }
}