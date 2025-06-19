import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:kisangro/payment/payment1.dart'; // Assuming 'delivery' is defined here
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:video_player/video_player.dart';

import 'package:kisangro/models/product_model.dart'; // Import Product and ProductSize
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/home/bottom.dart'; // Import the Bot widget for navigation
import 'package:kisangro/models/order_model.dart'; // Import OrderedProduct (which is inside order_model.dart)
import 'package:kisangro/home/cart.dart'; // Import the cart page for navigation to cart
import 'package:kisangro/services/product_service.dart'; // Import ProductService for similar products

class ProductDetailPage extends StatefulWidget {
  // Now accepts either a Product (for general browsing) or an OrderedProduct (for order details)
  final Product? product;
  final OrderedProduct? orderedProduct;

  const ProductDetailPage({
    Key? key,
    this.product,
    this.orderedProduct,
  }) : assert(product != null || orderedProduct != null,
            'Either product or orderedProduct must be provided'),
        assert(!(product != null && orderedProduct != null),
            'Only one of product or orderedProduct should be provided'),
        super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int activeIndex = 0;
  // _currentSelectedUnit will now reflect the Product.selectedUnit if it's a regular product
  // or the OrderedProduct.selectedUnit if it's an ordered product.
  // It's primarily used for UI display of the selected unit.
  late String _currentSelectedUnit;

  late final List<String> imageAssets; // This will hold the images for the carousel

  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _videoLoadError = false;

  // List of allowed product image assets (for placeholder for deals section)
  // These are mostly for fallbacks or if some product images aren't dynamic
  // This list is now primarily for local placeholder fallback examples, not for dynamically cycling API images
  final List<String> _allowedProductImages = [
    'assets/Oxyfen.png',
    'assets/hyfen.png',
    'assets/Valaxa.png',
    'assets/placeholder.png', // Ensure this exists
  ];
  
  // Helper to check if a URL is valid and absolute
  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    // Check if it's a valid absolute URL AND not just the base API path as a placeholder
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  // Determine if we are viewing an OrderedProduct or a regular Product
  bool get _isOrderedProduct => widget.orderedProduct != null;

  // Helper to get the product details, whether it's Product or OrderedProduct
  String get _displayTitle =>
      _isOrderedProduct ? widget.orderedProduct!.title : widget.product!.title;
  String get _displaySubtitle =>
      _isOrderedProduct ? widget.orderedProduct!.subtitle : widget.product!.subtitle;
  String get _displayImageUrl =>
      _isOrderedProduct ? widget.orderedProduct!.imageUrl : widget.product!.imageUrl;

  // This getter needs to safely get the price based on the current selected unit
  double? get _displayPricePerUnit {
    if (_isOrderedProduct) {
      return widget.orderedProduct!.pricePerUnit;
    } else {
      // Safely get the price for the currently selected unit from the Product model
      return widget.product!.pricePerSelectedUnit; // This is already nullable
    }
  }

  // This getter provides the correct unit size description based on product type
  String get _displayUnitSizeDescription {
    if (_isOrderedProduct) {
      return 'Ordered Unit: ${widget.orderedProduct!.selectedUnit}';
    } else {
      // For a regular product, this should reflect the currently selected unit
      return 'Unit: $_currentSelectedUnit';
    }
  }

  // Helper to get the actual Product object for Cart/Wishlist operations
  // If it's a regular Product, we return the Product object itself
  // If it's an OrderedProduct, we construct a new Product object from its data.
  Product get _currentProductForActions {
    if (_isOrderedProduct) {
      // When converting OrderedProduct to Product, we only have the single ordered unit
      return Product(
        id: widget.orderedProduct!.id,
        title: widget.orderedProduct!.title,
        subtitle: widget.orderedProduct!.subtitle,
        imageUrl: widget.orderedProduct!.imageUrl,
        category: widget.orderedProduct!.category, // Ensure category is included
        availableSizes: [
          ProductSize(
              size: widget.orderedProduct!.selectedUnit,
              price: widget.orderedProduct!.pricePerUnit) // Corrected to use 'price'
        ],
        selectedUnit: widget.orderedProduct!.selectedUnit,
      );
    } else {
      // For a regular product, the widget.product object already holds the selectedUnit state.
      // Call copyWith to ensure a new instance (important for Provider if product changes)
      return widget.product!.copyWith();
    }
  }

  // Dummy data for similar and top-selling products using the new Product model structure
  // Now fetching from ProductService to ensure consistency with loaded products
  List<Product> similarProducts = [];
  List<Product> topSellingProducts = [];

  final Color primaryColor = const Color(0xFFF37021);
  final Color themeOrange = const Color(0xffEB7720);
  final Color redColor = const Color(0xFFDC2F2F);
  final Color backgroundColor = const Color(0xFFFFF8F5);

  @override
  void initState() {
    super.initState();
    // Initialize _currentSelectedUnit based on the product type
    _currentSelectedUnit = _isOrderedProduct
        ? widget.orderedProduct!.selectedUnit
        : widget.product!.selectedUnit;

    // Use the main product's image for all three carousel images, ensuring it's one of the allowed
    // Fallback to a generic placeholder if the display image URL is invalid or not an allowed local asset
    String mainDisplayImage = _displayImageUrl;
    if (!_isValidUrl(mainDisplayImage)) {
      mainDisplayImage = 'assets/placeholder.png'; // Default local placeholder
    }
    imageAssets = List.generate(3, (index) => mainDisplayImage);

    // Populate similar and top-selling products from ProductService
    // For a real app, this would be more sophisticated (e.g., based on product category, user history)
    // For now, we'll just take a subset of all products.
    similarProducts = ProductService.getAllProducts().take(3).toList();
    topSellingProducts = ProductService.getAllProducts().reversed.take(3).toList();


    _videoController = VideoPlayerController.asset('assets/video.mp4');
    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      debugPrint('Video initialized successfully: assets/video.mp4');
      setState(() {
        _videoLoadError = false;
      });
    }).catchError((error) {
      debugPrint('Error initializing video: $error');
      setState(() {
        _videoLoadError = true;
      });
    });
    _videoController.setLooping(true);
  }

  @override
  void dispose() {
    _videoController.dispose();
    debugPrint('Video controller disposed.');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to Product changes if it's a regular product
    // This will cause a rebuild when widget.product.selectedUnit changes.
    if (!_isOrderedProduct) {
      // This line means the ProductDetailPage will rebuild when the Product model it holds notifies listeners.
      // This is crucial for updating the price display when the unit changes via the dropdown/buttons.
      Provider.of<Product>(context, listen: true);
    }
    final cart = Provider.of<CartModel>(context, listen: false);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Text(
            _displayTitle, // Use display title
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            // Navigate back to the Home Screen (first tab of Bot) and clear the stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Bot(initialIndex: 0)),
              (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const MyOrder()));
            },
            icon: Image.asset(
              'assets/box.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 5),
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const WishlistPage()));
            },
            icon: Image.asset(
              'assets/heart.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const noti()));
            },
            icon: Image.asset(
              'assets/noti.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Stack( // Added Stack for positioning icons on the main product image
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
                      // Use Image.network if it's a valid URL, otherwise Image.asset
                      return _isValidUrl(imageUrl)
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/placeholder.png', // Fallback local image
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.asset(imageUrl, fit: BoxFit.contain);
                    },
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) =>
                          setState(() => activeIndex = index),
                    ),
                  ),
                ),
                // Heart Icon (Wishlist)
                Positioned(
                  top: 8,
                  right: 8 + 48, // Adjust right position to make space for share icon
                  child: Consumer<WishlistModel>(
                    builder: (context, wishlist, child) {
                      final bool isFavorite = wishlist.items.any(
                          (item) => item.id == _currentProductForActions.id && item.selectedUnit == _currentProductForActions.selectedUnit,
                      );
                      return IconButton(
                        onPressed: () {
                          if (isFavorite) {
                            wishlist.removeItem(_currentProductForActions.id, _currentProductForActions.selectedUnit);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${_currentProductForActions.title} removed from wishlist!', style: GoogleFonts.poppins()),
                                backgroundColor: redColor,
                              ),
                            );
                          } else {
                            wishlist.addItem(_currentProductForActions);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${_currentProductForActions.title} added to wishlist!', style: GoogleFonts.poppins()),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        },
                        icon: Image.asset(
                          'assets/heart.png',
                          height: 28, // Slightly larger icon
                          width: 28,
                          color: isFavorite ? redColor : Colors.grey, // Red if favorite, grey otherwise
                        ),
                        splashRadius: 24, // Larger splash radius for better touch feedback
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
                      // Implement share functionality here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Share functionality coming soon!', style: GoogleFonts.poppins())),
                      );
                    },
                    icon: const Icon(Icons.share, color: Colors.black54, size: 28), // Share icon
                    splashRadius: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: AnimatedSmoothIndicator(
                activeIndex: activeIndex,
                count: imageAssets.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: primaryColor, // Using primaryColor for dot
                  dotHeight: 5,
                  dotWidth: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(_displayTitle, // Use display title
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_displaySubtitle), // Use display subtitle
            const SizedBox(height: 10),

            // Conditional display for unit selection (if not an ordered product)
            if (!_isOrderedProduct)
              Wrap(
                spacing: 15,
                children: widget.product!.availableSizes.map((productSize) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        // Update the selected unit on the Product object itself
                        widget.product!.selectedUnit = productSize.size;
                        // Also update local state to reflect in UI
                        _currentSelectedUnit = productSize.size;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _currentSelectedUnit == productSize.size
                          ? const Color(0xffEB7720)
                          : Colors.transparent,
                      side: const BorderSide(
                        color: Color(0xffEB7720),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      productSize.size, // Display size from ProductSize object
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _currentSelectedUnit == productSize.size
                            ? Colors.white
                            : const Color(0xffEB7720),
                      ),
                    ),
                  );
                }).toList(),
              )
            else // Display static ordered unit and quantity for OrderedProduct
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordered Unit: ${widget.orderedProduct!.selectedUnit}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffEB7720),
                    ),
                  ),
                  Text(
                    'Quantity: ${widget.orderedProduct!.quantity}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffEB7720),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Text('₹ ${_displayPricePerUnit?.toStringAsFixed(2) ?? 'N/A'}/piece', // Use display price
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: const Color(0xffEB7720),
                    fontWeight: FontWeight.bold)),
            Text(_displayUnitSizeDescription), // Use display unit size description
            const SizedBox(height: 8),
            // Adjust calculation based on product type
            Text(
              _isOrderedProduct
                  ? 'Total for ordered quantity: ₹ ${((_displayPricePerUnit ?? 0.0) * widget.orderedProduct!.quantity).toStringAsFixed(2)}'
                  : 'Price for $_currentSelectedUnit: ₹ ${(widget.product!.pricePerSelectedUnit ?? 0.0).toStringAsFixed(2)}', // Safely access price
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      cart.addItem(_currentProductForActions); // Use helper getter
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${_currentProductForActions.title} (${_currentProductForActions.selectedUnit}) added to cart!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor)),
                    child: const Text('Put in Cart'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      cart.addItem(_currentProductForActions); // Use helper getter
                      // Navigate to payment screen
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const delivery()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    child: Text('Buy Now', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDADADA)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Delivery To Your Location",
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Pincode: 641 012",
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text("Deliverable by 11 Dec, 2024",
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFFF37021),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Image.asset('assets/delivery.gif',
                      height: 50, width: 80, fit: BoxFit.contain),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildHeaderSection('Cancellation Policy'), // Correct usage
            const SizedBox(height: 8),
            _buildDottedText('Upto 5 days returnable'),
            _buildDottedText('Wrong product received'),
            _buildDottedText('Damaged product received'),
            const SizedBox(height: 20),

            _buildHeaderSection('About Product'), // Correct usage
            const SizedBox(height: 8),
            Text(
              _displaySubtitle, // Use display subtitle
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            _buildHeaderSection('Tutorial Video'), // Correct usage
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
                      aspectRatio: _videoController.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_videoController),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _videoController.value.isPlaying
                                    ? _videoController.pause()
                                    : _videoController.play();
                              });
                            },
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  _videoController.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
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
                              _videoController,
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
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xffEB7720)),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 30),

            _buildHeaderSection("Browse Similar Products"), // Correct usage
            _productSlider(similarProducts),
            _buildHeaderSection("Top Selling Products"), // Correct usage
            _productSlider(topSellingProducts), // Use topSellingProducts here
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _productSlider(List<Product> items) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final product = items[index];
          return Container(
            width: 130,
            margin: const EdgeInsets.only(left: 15),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white, // Changed background to white
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to ProductDetailPage for similar products (regular Product)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: _isValidUrl(product.imageUrl)
                      ? Image.network(
                          product.imageUrl,
                          height: 70, // Consistent height for product images
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/placeholder.png',
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.asset(product.imageUrl, height: 70, fit: BoxFit.contain),
                ),
                const SizedBox(height: 5),
                Text(product.title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,),
                Text(product.subtitle,
                    style: GoogleFonts.poppins(fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,),
                // Display the price for the selected unit of the similar product
                Text(
                  '₹ ${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.green),
                ),
                Text('Unit: ${product.selectedUnit}', // Display selected unit
                    style: GoogleFonts.poppins(
                        fontSize: 8, color: const Color(0xffEB7720))),
                const SizedBox(height: 8),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffEB7720)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: product.selectedUnit,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Color(0xffEB7720)),
                      isExpanded: true,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.black),
                      // Map ProductSize objects to DropdownMenuItems
                      items: product.availableSizes
                          .map((ProductSize sizeOption) =>
                              DropdownMenuItem<String>(
                                  value: sizeOption.size,
                                  child: Text(sizeOption.size)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          // Update the selected unit of the product in the list
                          product.selectedUnit = val!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Add to cart for similar products
                          Provider.of<CartModel>(context, listen: false)
                              .addItem(product.copyWith()); // Use product's copyWith
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.title} added to cart!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Text("Add",
                            style: GoogleFonts.poppins(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffEB7720),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 8)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Consumer<WishlistModel>(
                      builder: (context, wishlist, child) {
                        final bool isFavorite = wishlist.items.any(
                              (item) => item.id == product.id && item.selectedUnit == product.selectedUnit,
                        );
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
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
        ),
      );

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
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
