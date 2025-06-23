import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:kisangro/payment/payment1.dart';
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
  late final List<String> imageAssets;
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _videoLoadError = false;
  final List<String> _allowedProductImages = [
    'assets/Oxyfen.png',
    'assets/hyfen.png',
    'assets/Valaxa.png',
    'assets/placeholder.png',
  ];
  List<Product> similarProducts = [];
  List<Product> topSellingProducts = [];
  final Color primaryColor = const Color(0xFFF37021);
  final Color themeOrange = const Color(0xffEB7720);
  final Color redColor = const Color(0xFFDC2F2F);
  final Color backgroundColor = const Color(0xFFFFF8F5);

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  bool get _isOrderedProduct => widget.orderedProduct != null;

  String get _displayTitle => _isOrderedProduct ? widget.orderedProduct!.title : widget.product!.title;
  String get _displaySubtitle => _isOrderedProduct ? widget.orderedProduct!.description : widget.product!.subtitle;
  String get _displayImageUrl => _isOrderedProduct ? widget.orderedProduct!.imageUrl : widget.product!.imageUrl;

  double? get _displayPricePerUnit {
    if (_isOrderedProduct) {
      return widget.orderedProduct!.price;
    } else {
      return widget.product!.pricePerSelectedUnit;
    }
  }

  String get _displayUnitSizeDescription {
    if (_isOrderedProduct) {
      return 'Ordered Unit: ${widget.orderedProduct!.unit}';
    } else {
      return 'Unit: $_currentSelectedUnit';
    }
  }

  Product get _currentProductForActions {
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
      return widget.product!.copyWith();
    }
  }

  @override
  void initState() {
    super.initState();
    _currentSelectedUnit = _isOrderedProduct ? widget.orderedProduct!.unit : widget.product!.selectedUnit;
    String mainDisplayImage = _displayImageUrl;
    if (!_isValidUrl(mainDisplayImage)) {
      mainDisplayImage = 'assets/placeholder.png';
    }
    imageAssets = List.generate(3, (index) => mainDisplayImage);
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
    if (!_isOrderedProduct) {
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
            _displayTitle,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
          ),
        ),
        leading: IconButton(
          onPressed: () {
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                      return _isValidUrl(imageUrl)
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/placeholder.png',
                          fit: BoxFit.contain,
                        ),
                      )
                          : Image.asset(imageUrl, fit: BoxFit.contain);
                    },
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) => setState(() => activeIndex = index),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8 + 48,
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
                          height: 28,
                          width: 28,
                          color: isFavorite ? redColor : Colors.grey,
                        ),
                        splashRadius: 24,
                      );
                    },
                  ),
                ),
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
            Text(_displayTitle, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_displaySubtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 10),
            if (!_isOrderedProduct)
              Wrap(
                spacing: 15,
                children: widget.product!.availableSizes.map((productSize) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        widget.product!.selectedUnit = productSize.size;
                        _currentSelectedUnit = productSize.size;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _currentSelectedUnit == productSize.size ? const Color(0xffEB7720) : Colors.transparent,
                      side: const BorderSide(color: Color(0xffEB7720)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      productSize.size,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _currentSelectedUnit == productSize.size ? Colors.white : const Color(0xffEB7720),
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordered Unit: ${widget.orderedProduct!.unit}',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xffEB7720)),
                  ),
                  Text(
                    'Quantity: ${widget.orderedProduct!.quantity}',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xffEB7720)),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Text('₹ ${_displayPricePerUnit?.toStringAsFixed(2) ?? 'N/A'}/piece',
                style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xffEB7720), fontWeight: FontWeight.bold)),
            Text(_displayUnitSizeDescription, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              _isOrderedProduct
                  ? 'Total for ordered quantity: ₹ ${((_displayPricePerUnit ?? 0.0) * widget.orderedProduct!.quantity).toStringAsFixed(2)}'
                  : 'Price for $_currentSelectedUnit: ₹ ${(widget.product!.pricePerSelectedUnit ?? 0.0).toStringAsFixed(2)}',
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      cart.addItem(_currentProductForActions);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${_currentProductForActions.title} (${_currentProductForActions.selectedUnit}) added to cart!'),
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
                      // Navigate directly to delivery screen, passing the product
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => delivery(product: _currentProductForActions),
                        ),
                      );
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
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Pincode: 641 012",
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text("Deliverable by 11 Dec, 2024",
                            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFF37021), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Image.asset('assets/delivery.gif', height: 50, width: 80, fit: BoxFit.contain),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildHeaderSection('Cancellation Policy'),
            const SizedBox(height: 8),
            _buildDottedText('Upto 5 days returnable'),
            _buildDottedText('Wrong product received'),
            _buildDottedText('Damaged product received'),
            const SizedBox(height: 20),
            _buildHeaderSection('About Product'),
            const SizedBox(height: 8),
            Text(_displaySubtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
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
                      aspectRatio: _videoController.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_videoController),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _videoController.value.isPlaying ? _videoController.pause() : _videoController.play();
                              });
                            },
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  _videoController.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
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
                    child: const Center(child: CircularProgressIndicator(color: Color(0xffEB7720))),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            _buildHeaderSection("Browse Similar Products"),
            _productSlider(similarProducts),
            _buildHeaderSection("Top Selling Products"),
            _productSlider(topSellingProducts),
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
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
                    );
                  },
                  child: _isValidUrl(product.imageUrl)
                      ? Image.network(
                    product.imageUrl,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset('assets/placeholder.png', height: 70, fit: BoxFit.contain),
                  )
                      : Image.asset(product.imageUrl, height: 70, fit: BoxFit.contain),
                ),
                const SizedBox(height: 5),
                Text(product.title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(product.subtitle,
                    style: GoogleFonts.poppins(fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  '₹ ${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.green),
                ),
                Text('Unit: ${product.selectedUnit}',
                    style: GoogleFonts.poppins(fontSize: 8, color: const Color(0xffEB7720))),
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
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xffEB7720)),
                      isExpanded: true,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                      items: product.availableSizes
                          .map((ProductSize sizeOption) => DropdownMenuItem<String>(
                          value: sizeOption.size,
                          child: Text(sizeOption.size)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
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
                          Provider.of<CartModel>(context, listen: false).addItem(product.copyWith());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.title} added to cart!'), backgroundColor: Colors.green),
                          );
                        },
                        child: Text("Add", style: GoogleFonts.poppins(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffEB7720),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8)),
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
                                SnackBar(content: Text('${product.title} removed from wishlist!'), backgroundColor: Colors.red),
                              );
                            } else {
                              wishlist.addItem(product.copyWith());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${product.title} added to wishlist!'), backgroundColor: Colors.blue),
                              );
                            }
                          },
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: const Color(0xffEB7720)),
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
    child: Text(title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
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
            child: Text(text, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}