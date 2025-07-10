import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:kisangro/payment/payment1.dart'; // Assuming 'delivery' is in payment1.dart
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/home/bottom.dart';
import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/home/cart.dart';
import 'package:kisangro/services/product_service.dart';
import '../models/address_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Product? product;
  final OrderedProduct? orderedProduct;

  const ProductDetailPage({
    Key? key,
    this.product,
    this.orderedProduct,
  }) : assert(product != null || orderedProduct != null, 'Either product or orderedProduct must be provided'),
        assert(!(product != null && orderedProduct != null), 'Only one of product or orderedProduct should be provided'),
        super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int activeIndex = 0;
  late String _currentSelectedUnit;
  late final List<String> imageAssets; // List of image URLs/paths for the carousel
  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;
  bool _videoLoadError = false;

  List<Product> similarProducts = [];
  List<Product> topSellingProducts = [];

  // Define consistent colors for the theme
  final Color primaryColor = const Color(0xFFF37021);
  final Color themeOrange = const Color(0xffEB7720);
  final Color redColor = const Color(0xFFDC2F2F);
  final Color backgroundColor = const Color(0xFFFFF8F5);

  // Helper function to validate and provide a fallback image URL
  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png'; // Fallback to a local placeholder image
    }
    return rawImageUrl;
  }

  // Determine if the current product is an ordered product or a regular product
  bool get _isOrderedProduct => widget.orderedProduct != null;

  // Get display title based on product type
  String get _displayTitle => _isOrderedProduct ? widget.orderedProduct!.title : widget.product!.title;
  // Get display subtitle/description based on product type
  String get _displaySubtitle => _isOrderedProduct ? widget.orderedProduct!.description : widget.product!.subtitle;
  // Get display image URL based on product type
  String get _displayImageUrl => _isOrderedProduct ? widget.orderedProduct!.imageUrl : widget.product!.imageUrl;

  // Get price per unit based on product type and selected unit
  double? get _displayPricePerUnit {
    if (_isOrderedProduct) {
      return widget.orderedProduct!.price;
    } else {
      try {
        return widget.product!.availableSizes.firstWhere((size) => size.size == _currentSelectedUnit).price;
      } catch (e) {
        debugPrint('Error: Selected unit $_currentSelectedUnit not found for product ${widget.product?.title}. Error: $e');
        return null; // Or throw an error, or return a default price
      }
    }
  }

  // Get unit size description based on product type
  String get _displayUnitSizeDescription {
    if (_isOrderedProduct) {
      return 'Ordered Unit: ${widget.orderedProduct!.unit}';
    } else {
      return 'Unit: $_currentSelectedUnit';
    }
  }

  // Helper function to create a Product object suitable for cart/wishlist actions
  // This ensures that even if viewing an OrderedProduct, we can add a corresponding Product to cart/wishlist.
  Product _currentProductForActions() {
    if (_isOrderedProduct) {
      return Product(
        id: widget.orderedProduct!.id,
        title: widget.orderedProduct!.title,
        subtitle: widget.orderedProduct!.description,
        imageUrl: widget.orderedProduct!.imageUrl,
        category: widget.orderedProduct!.category,
        availableSizes: [
          ProductSize(
            size: widget.orderedProduct!.unit,
            price: widget.orderedProduct!.price,
          )
        ],
        selectedUnit: widget.orderedProduct!.unit,
      );
    } else {
      // Use copyWith to create a new instance with the current selected unit
      return widget.product!.copyWith(selectedUnit: _currentSelectedUnit);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the currently selected unit based on product type
    _currentSelectedUnit = _isOrderedProduct ? widget.orderedProduct!.unit : widget.product!.selectedUnit;

    // Set up image assets for the carousel (can be dynamic if API provides multiple images)
    String mainDisplayImage = _getEffectiveImageUrl(_displayImageUrl);
    imageAssets = [mainDisplayImage, mainDisplayImage, mainDisplayImage]; // Placeholder for multiple images

    // Initialize video player for tutorial video
    _videoController = VideoPlayerController.asset('assets/video.mp4');
    _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
      debugPrint('Video initialized successfully: assets/video.mp4');
      setState(() {
        _videoLoadError = false; // Clear error if initialization succeeds
      });
    }).catchError((error) {
      debugPrint('Error initializing video: $error');
      setState(() {
        _videoLoadError = true; // Set error flag if initialization fails
      });
    });
    _videoController!.setLooping(true); // Loop the video

    // Load similar and top selling products after the first frame is rendered
    // This ensures that the context is fully available and ProductService has loaded data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSimilarProducts();
      _loadTopSellingProducts();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Dispose the video controller to free up resources
    debugPrint('Video controller disposed.');
    super.dispose();
  }

  // Method to load similar products based on the current product's category
  void _loadSimilarProducts() {
    final currentProductCategory = _currentProductForActions().category;
    debugPrint('ProductDetailPage: Loading similar products for category: $currentProductCategory');

    // Get products from the same category using ProductService
    final productsInSameCategory = ProductService.getProductsByCategoryName(currentProductCategory);

    setState(() {
      // Filter out the current product itself from the similar products list
      similarProducts = productsInSameCategory
          .where((p) => p.id != _currentProductForActions().id)
          .take(6) // Take up to 6 similar products
          .toList();
      debugPrint('ProductDetailPage: Found ${similarProducts.length} similar products in category.');

      // Fallback: If not enough similar products are found in the same category,
      // fill with other general products to ensure the section is not empty.
      if (similarProducts.length < 6) { // Aim for at least 6 products
        final allProducts = ProductService.getAllProducts();
        final otherProducts = allProducts
            .where((p) => p.id != _currentProductForActions().id && !similarProducts.any((sp) => sp.id == p.id))
            .take(6 - similarProducts.length) // Fill the remaining slots
            .toList();
        similarProducts.addAll(otherProducts);
        debugPrint('ProductDetailPage: Filled with ${otherProducts.length} additional products. Total similar: ${similarProducts.length}');
      }
    });
  }

  // Method to load "top selling" products (simulated from all available products)
  void _loadTopSellingProducts() {
    // Since there's no direct "top selling" API, we simulate it by taking a selection
    // from all available products. For example, the last 6 products loaded.
    final allProducts = ProductService.getAllProducts();
    setState(() {
      topSellingProducts = allProducts.reversed.take(6).toList(); // Get the last 6 products
      debugPrint('ProductDetailPage: Found ${topSellingProducts.length} top selling products (simulated).');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access CartModel and WishlistModel using Provider
    final cart = Provider.of<CartModel>(context, listen: false);
    final wishlist = Provider.of<WishlistModel>(context, listen: false);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: themeOrange,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Text(
            _displayTitle,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrder()));
            },
            icon: Image.asset('assets/box.png', height: 24, width: 24, color: Colors.white),
          ),
          const SizedBox(width: 5),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage()));
            },
            icon: Image.asset('assets/heart.png', height: 24, width: 24, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const noti()));
            },
            icon: Image.asset('assets/noti.png', height: 24, width: 24, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        child: ListView( // Use ListView to make the content scrollable
          padding: const EdgeInsets.all(16),
          children: [
            // Product Image Carousel Section
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: CarouselSlider.builder(
                    itemCount: imageAssets.length,
                    itemBuilder: (context, index, realIndex) {
                      final imageUrl = imageAssets[index];
                      // Display network image if it's a URL, otherwise display asset image
                      return _getEffectiveImageUrl(imageUrl).startsWith('http')
                          ? Image.network(
                        _getEffectiveImageUrl(imageUrl),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/placeholder.png', // Fallback for network image errors
                          fit: BoxFit.contain,
                        ),
                      )
                          : Image.asset(imageUrl, fit: BoxFit.contain);
                    },
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: false, // Set to true for auto-sliding carousel
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) => setState(() => activeIndex = index),
                    ),
                  ),
                ),
                // Wishlist Icon (Main Product Detail Page) - Now uses filled/outlined icon
                Positioned(
                  top: 8,
                  right: 8 + 48, // Adjust position to avoid overlap with share icon
                  child: Consumer<WishlistModel>(
                    builder: (context, wishlist, child) {
                      final Product productForActions = _currentProductForActions();
                      final bool isFavorite = wishlist.items.any(
                              (item) => item.id == productForActions.id && item.selectedUnit == productForActions.selectedUnit);
                      return IconButton(
                        onPressed: () {
                          if (isFavorite) {
                            wishlist.removeItem(productForActions.id, productForActions.selectedUnit);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${productForActions.title} removed from wishlist!', style: GoogleFonts.poppins()),
                                backgroundColor: redColor,
                              ),
                            );
                          } else {
                            wishlist.addItem(productForActions);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${productForActions.title} added to wishlist!', style: GoogleFonts.poppins()),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border, // Use filled/outlined icon
                          color: isFavorite ? redColor : Colors.grey, // Color based on favorite status
                          size: 28,
                        ),
                        splashRadius: 24,
                      );
                    },
                  ),
                ),
                // Share Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Share functionality coming soon!', style: GoogleFonts.poppins())),
                      );
                    },
                    icon: const Icon(Icons.share, color: Colors.black54, size: 28),
                    splashRadius: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Carousel Indicator
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: activeIndex,
                count: imageAssets.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: primaryColor,
                  dotHeight: 5,
                  dotWidth: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Title and Subtitle
            Text(_displayTitle, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_displaySubtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 10),

            // Product Unit Selection (only for non-ordered products)
            if (!_isOrderedProduct)
              Wrap(
                spacing: 15,
                children: widget.product!.availableSizes.map((productSize) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        _currentSelectedUnit = productSize.size;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _currentSelectedUnit == productSize.size ? themeOrange : Colors.transparent,
                      side: BorderSide(color: themeOrange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      productSize.size,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _currentSelectedUnit == productSize.size ? Colors.white : themeOrange,
                      ),
                    ),
                  );
                }).toList(),
              )
            else // Display ordered unit and quantity for ordered products
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordered Unit: ${widget.orderedProduct!.unit}',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: themeOrange),
                  ),
                  Text(
                    'Quantity: ${widget.orderedProduct!.quantity}',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: themeOrange),
                  ),
                ],
              ),
            const SizedBox(height: 10),

            // Price and Unit Description
            Text('₹ ${_displayPricePerUnit?.toStringAsFixed(2) ?? 'N/A'}',
                style: GoogleFonts.poppins(fontSize: 18, color: themeOrange, fontWeight: FontWeight.bold)),
            Text(_displayUnitSizeDescription, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              _isOrderedProduct
                  ? 'Total for ordered quantity: ₹ ${((_displayPricePerUnit ?? 0.0) * widget.orderedProduct!.quantity).toStringAsFixed(2)}'
                  : 'Price for $_currentSelectedUnit: ₹ ${(_displayPricePerUnit ?? 0.0).toStringAsFixed(2)}',
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
            const SizedBox(height: 10),

            // Add to Cart and Buy Now Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Add the current product (with its selected unit) to the cart
                      cart.addItem(_currentProductForActions());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${_currentProductForActions().title} (${_currentProductForActions().selectedUnit}) added to cart!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: primaryColor, side: BorderSide(color: primaryColor)),
                    child: const Text('Put in Cart'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the delivery/payment screen, passing the current product
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => delivery(product: _currentProductForActions()),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: Text('Buy Now', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Delivery Information Section
            const Divider(color: Colors.white, thickness: 3),
            const SizedBox(height: 20),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDADADA)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(12),
              child: Consumer<AddressModel>(
                builder: (context, addressModel, child) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Delivery To Your Location",
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Pincode: ${addressModel.currentPincode}",
                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text("Deliverable by 11 Dec, 2024", // This date might need to be dynamic
                                style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFF37021), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Image.asset('assets/delivery.gif', height: 50, width: 80, fit: BoxFit.contain),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Cancellation Policy Section
            const Divider(color: Colors.white, thickness: 3),
            const SizedBox(height: 20),
            _buildHeaderSection('Cancellation Policy'),
            const SizedBox(height: 8),
            _buildDottedText('Upto 5 days returnable'),
            _buildDottedText('Wrong product received'),
            _buildDottedText('Damaged product received'),
            const SizedBox(height: 20),

            // About Product Section
            const Divider(color: Colors.white, thickness: 3),
            const SizedBox(height: 20),
            _buildHeaderSection('About Product'),
            const SizedBox(height: 8),
            Text(
              // Display product subtitle/description, with some dummy text for illustration
              '$_displaySubtitle\n\nAbamectin 1.9% EC is a broad-spectrum insecticide and acaricide, effective against a wide range of mites and insects, particularly those that are motile or sucking, working through contact and stomach action, and also exhibiting translaminar activity.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Target Pests Section
            _buildHeaderSection('Target Pests'),
            const SizedBox(height: 8),
            _buildDottedText('Yellow mites, red mites, spotted mites, leaf miners, sucking insects'),
            const SizedBox(height: 12),

            // Target Crops Section
            _buildHeaderSection('Target Crops'),
            const SizedBox(height: 8),
            _buildDottedText('Grapes, roses, brinjal, chili, tea, cotton, ornamental plants'),
            const SizedBox(height: 12),

            // Dosage Section
            _buildHeaderSection('Dosage'),
            const SizedBox(height: 8),
            _buildDottedText('1 ml per liter of water (200 ml per acre)'),
            const SizedBox(height: 12),

            // Available Pack Section
            _buildHeaderSection('Available Pack'),
            const SizedBox(height: 8),
            _buildDottedText('50, 100, 250, 500, 1000 ml'),
            const SizedBox(height: 15),

            // Tutorial Video Section
            const Divider(color: Colors.white, thickness: 3),
            const SizedBox(height: 20),
            _buildHeaderSection('Tutorial Video'),
            const SizedBox(height: 8),
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_videoLoadError) {
                    return Container(
                      height: 200,
                      color: Colors.red.shade100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 40),
                            const SizedBox(height: 10),
                            Text(
                              'Could not load video. Check asset path or file format.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_videoController!),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
                              });
                            },
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  _videoController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 70,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: VideoProgressIndicator(
                              _videoController!,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: themeOrange,
                                bufferedColor: Colors.grey,
                                backgroundColor: Colors.white54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(child: CircularProgressIndicator(color: Color(0xffEB7720))),
                  );
                }
              },
            ),
            SizedBox(height: 20,),

            // Browse Similar Products Section (Horizontal Scroll)
            const Divider(color: Colors.white, thickness: 3),
            const SizedBox(height: 30),
            _buildHeaderSection("Browse Similar Products"),
            SizedBox(
              height: 305, // Fixed height for the horizontal ListView
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similarProducts.length,
                padding: const EdgeInsets.only(left: 0, right: 12), // Adjusted padding
                itemBuilder: (context, index) {
                  final product = similarProducts[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 12, right: 0), // Adjusted padding to match homepage
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
                        );
                      },
                      child: _buildProductTile(context, product), // Use the unified tile builder
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Top Selling Products Section (Horizontal Scroll)
            const Divider(color: Colors.white, thickness: 3),
            const SizedBox(height: 20),
            _buildHeaderSection("Top Selling Products"),
            SizedBox(
              height: 305, // Fixed height for the horizontal ListView
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: topSellingProducts.length,
                padding: const EdgeInsets.only(left: 0, right: 12), // Adjusted padding
                itemBuilder: (context, index) {
                  final product = topSellingProducts[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 12, right: 0), // Adjusted padding to match homepage
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
                        );
                      },
                      child: _buildProductTile(context, product), // Use the unified tile builder
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper widget for section headers
  Widget _buildHeaderSection(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
    ),
  );

  // Helper widget for dotted text lists
  Widget _buildDottedText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: Colors.black),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // COPIED FROM HOMEPAGE.DART: Unified Product Tile Widget for Similar Products and Top Selling Products
  // This function is now local to ProductDetailPageState
  Widget _buildProductTile(BuildContext context, Product product) {
    final themeOrange = const Color(0xffEB7720); // Define themeOrange here for local use
    final redColor = const Color(0xFFDC2F2F); // Define redColor for wishlist icon

    // Ensure availableSizes is never empty to prevent errors in DropdownButton.
    final List<ProductSize> availableSizes = product.availableSizes.isNotEmpty
        ? product.availableSizes
        : [ProductSize(size: 'Unit', price: product.pricePerSelectedUnit ?? 0.0)];

    // Ensure selectedUnit is one of the available sizes, or default to the first available.
    final String selectedUnit = availableSizes.any((size) => size.size == product.selectedUnit)
        ? product.selectedUnit
        : availableSizes.first.size;

    return Container(
      width: 150, // Fixed width to match homepage trending items
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100, // Fixed height for image area
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
                    style: GoogleFonts.poppins(fontSize: 10, color: themeOrange)),
                const SizedBox(height: 8),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: themeOrange),
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
                            backgroundColor: themeOrange,
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
                            color: themeOrange,
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
