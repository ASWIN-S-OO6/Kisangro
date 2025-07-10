import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/services/product_service.dart';
import 'package:kisangro/home/product.dart'; // Your existing ProductDetailPage
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';

class NewOnKisangroProductsScreen extends StatefulWidget {
  const NewOnKisangroProductsScreen({super.key});

  @override
  State<NewOnKisangroProductsScreen> createState() => _NewOnKisangroProductsScreenState();
}

class _NewOnKisangroProductsScreenState extends State<NewOnKisangroProductsScreen> {
  List<Product> _newOnKisangroItems = [];

  @override
  void initState() {
    super.initState();
    _loadNewOnKisangroProducts();
  }

  Future<void> _loadNewOnKisangroProducts() async {
    setState(() {
      _newOnKisangroItems = ProductService.getAllProducts(); // Load all products
    });
  }

  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png';
    }
    return rawImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    // Determine crossAxisCount and childAspectRatio based on orientation and device type
    int crossAxisCount;
    double childAspectRatio;

    if (isTablet) {
      if (orientation == Orientation.portrait) {
        crossAxisCount = 3; // 3 tiles horizontally in portrait mode for tablets
        childAspectRatio = 0.6; // Adjusted for vertical fit and medium size
      } else { // Orientation.landscape
        crossAxisCount = 5; // 5 tiles horizontally in landscape mode for tablets
        // Adjusted childAspectRatio to make tiles shorter (more compact horizontally)
        childAspectRatio = 0.5; // Increased from 0.45 to 0.5 for shorter height
      }
    } else { // Mobile phones
      crossAxisCount = 2; // 2 tiles for mobile phones
      childAspectRatio = 0.55; // Default for mobile
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Text(
          "New On Kisangro", // Correct title for this screen
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        child: _newOnKisangroItems.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'No new products available right now!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
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
      ),
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    final List<ProductSize> availableSizes = product.availableSizes.isNotEmpty
        ? product.availableSizes
        : [ProductSize(size: 'Unit', price: product.pricePerSelectedUnit ?? 0.0)];

    final String selectedUnit = availableSizes.any((size) => size.size == product.selectedUnit)
        ? product.selectedUnit
        : availableSizes.first.size;

    return Container(
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
                              setState(() {
                                product.selectedUnit = val!;
                                debugPrint('Selected unit for ${product.title}: $val, Price: ₹${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}');
                              });
                            },
                          ),
                        ),
                      ),
                    ],
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
          ),
        ],
      ),
    );
  }
}
