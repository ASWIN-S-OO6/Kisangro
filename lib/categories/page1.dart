import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/categories/page2.dart'; // Assuming FungicideScreen2 is a generic "view all in category"
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/home/product.dart';
 // Corrected import for ProductDetailPage

import 'package:kisangro/menu/wishlist.dart';

// Import the Product model and Provider related models
import 'package:kisangro/models/product_model.dart'; // Ensure Product and ProductSize are available
import 'package:provider/provider.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/services/product_service.dart'; // Import ProductService to fetch products

class FungicideScreen extends StatefulWidget {
  const FungicideScreen({super.key});

  @override
  State<FungicideScreen> createState() => _FungicideScreenState();
}

class _FungicideScreenState extends State<FungicideScreen> {
  String selectedSort = 'Price: Low to High';

  final List<String> sortOptions = [
    'Price: Low to High',
    'Price: High to Low',
    'Name: A-Z',
    'Name: Z-A',
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of allowed product image assets (for placeholder for deals section)
  final List<String> _allowedProductImages = [
    'assets/Oxyfen.png',
    'assets/hyfen.png',
    'assets/Valaxa.png',
  ];

  // Helper to get image cyclically for placeholder items if needed
  String _getImageAsset(int index) {
    return _allowedProductImages[index % _allowedProductImages.length];
  }

  // List of Fungicide products, fetched from ProductService
  List<Product> fungicideProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchFungicideProducts();
  }

  void _fetchFungicideProducts() {
    // Using ProductService to get products specific to 'Fungicide'
    setState(() {
      fungicideProducts = ProductService.getProductsByCategory('Fungicide');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3D5C2),
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Transform.translate(
          offset: const Offset(-25, 0),
          child: Text(
            "Fungicide",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrder()));
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage()));
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const noti()));
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
            colors: [Color(0xFFF3D5C2), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 18),
              _buildHeaderSectionWithSort(),
              const SizedBox(height: 12),
              _buildDealGrid(),
              const SizedBox(height: 12),
              _buildViewAllButton(),
              const SizedBox(height: 28),
              _buildHeaderSection('Our Fungicide Products'),
              const SizedBox(height: 12),
              _buildProductGrid(fungicideProducts), // Use fetched products
              const SizedBox(height: 12),
              _buildViewAllButton(),
              const SizedBox(height: 28),
              _buildHeaderSection('New On Fungicide'),
              const SizedBox(height: 12),
              _buildProductGrid(fungicideProducts.take(2).toList()), // Example: subset for "New On"
              const SizedBox(height: 12),
              _buildViewAllButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by item/crop/chemical name',
          hintStyle: GoogleFonts.poppins(fontSize: 14),
          suffix: const Icon(Icons.search, size: 22, color: Color(0xffEB7720)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildHeaderSectionWithSort() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Deals of the day',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedSort,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xffEB7720)),
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xffEB7720)),
              items: sortOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.poppins(fontSize: 13)),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedSort = newValue!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(String title) {
    return Text(title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600));
  }

  Widget _buildDealGrid() {
    // Note: These deals are hardcoded and not fetched from ProductService based on new model.
    // If you want actual product deals, you'd fetch them similarly to `fungicideProducts`
    // and then map them to this UI, ensuring they have 'old' and 'new' price fields.
    List<Map<String, String>> deals = [
      {'name': 'AURASTAR', 'image': _getImageAsset(0), 'old': '2000', 'new': '1550'},
      {'name': 'AZEEM', 'image': _getImageAsset(1), 'old': '2000', 'new': '1000'},
      {'name': 'VALAX', 'image': _getImageAsset(2), 'old': '2000', 'new': '1550'},
      {'name': 'OXYFEN', 'image': _getImageAsset(0), 'old': '2000', 'new': '1000'},
      {'name': 'OXYFEN', 'image': _getImageAsset(1), 'old': '2000', 'new': '1000'},
      {'name': 'OXYFEN', 'image': _getImageAsset(2), 'old': '2000', 'new': '1000'},
    ];

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 130 / 150,
      children: deals.map((item) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Image.asset(item['image']!, height: 90),
              const SizedBox(height: 6),
              const Divider(),
              Text(item['name']!,
                  style:
                      GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '₹${item['old']} ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: '₹${item['new']}/piece',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Modified to take a List<Product>
  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Center(
        child: Text(
          'No products available in this category.',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 140 / 290,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigate to ProductDetailPage for individual product
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailPage(product: product),
                    ),
                  );
                },
                // Use product.imageUrl which is already one of the allowed assets
                child: Center(child: Image.asset(product.imageUrl, height: 120)),
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                product.title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(product.subtitle, style: GoogleFonts.poppins(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              // Display price per unit, safely handling null pricePerSelectedUnit
              Text('₹ ${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}/piece', // Formatted price
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.green)), // Green for price
              Text('Unit: ${product.selectedUnit}', // Display selected unit
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xffEB7720))),
              const SizedBox(height: 8),
              SizedBox( // Use SizedBox to give fixed height to dropdown
                height: 36,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: product.selectedUnit,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xffEB7720)),
                    isExpanded: true,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                    items: product.availableSizes.map((ProductSize sizeOption) {
                      return DropdownMenuItem<String>(
                        value: sizeOption.size,
                        child: Text(sizeOption.size),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                          product.selectedUnit = newValue!; // Update locally for visual feedback
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
                        // Add to Cart Logic using Provider
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                           padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8)
                      ),
                      child: Text('Add', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white)),
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
    );
  }

  Widget _buildViewAllButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // This navigates to the generic "page2" for categories, update if needed for a more specific list
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FungicideScreen2()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffEB7720),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('View All', style: GoogleFonts.poppins(color: Colors.white70)),
      ),
    );
  }
}
