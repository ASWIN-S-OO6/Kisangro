import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/product_model.dart'; // Your Product model
import 'package:kisangro/models/cart_model.dart'; // Your CartModel
import 'package:kisangro/home/cart.dart'; // Your Cart page

// Renamed class to avoid conflict with existing ProductDetailPage
class OrdersProductDetailPage extends StatefulWidget {
  final Product product;

  const OrdersProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  State<OrdersProductDetailPage> createState() => _OrdersProductDetailPageState();
}

class _OrdersProductDetailPageState extends State<OrdersProductDetailPage> {
  String? _selectedUnit;
  double? _pricePerSelectedUnit;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Initialize selected unit and price based on the product passed.
    // Prioritize widget.product.selectedUnit if it's valid and present in availableSizes.
    // Otherwise, default to the first available size.
    if (widget.product.selectedUnit.isNotEmpty &&
        widget.product.availableSizes.any((size) => size.size == widget.product.selectedUnit)) {
      _selectedUnit = widget.product.selectedUnit;
      _pricePerSelectedUnit = widget.product.availableSizes
          .firstWhere((size) => size.size == widget.product.selectedUnit)
          .price;
    } else if (widget.product.availableSizes.isNotEmpty) {
      _selectedUnit = widget.product.availableSizes.first.size;
      _pricePerSelectedUnit = widget.product.availableSizes.first.price;
    }
    // If availableSizes is empty, _selectedUnit and _pricePerSelectedUnit will remain null,
    // and the UI will display "N/A" as handled in the Text widgets.
  }

  // Helper to check if the image URL is valid (not an asset path or empty)
  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Text(
          widget.product.title,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                    image: _isValidUrl(widget.product.imageUrl)
                        ? DecorationImage(
                      image: NetworkImage(widget.product.imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stacktrace) {
                        debugPrint("Error loading image: ${widget.product.imageUrl}");
                      },
                    )
                        : DecorationImage(
                      image: AssetImage(widget.product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: _isValidUrl(widget.product.imageUrl)
                      ? null
                      : (widget.product.imageUrl.isEmpty
                      ? Center(child: Icon(Icons.broken_image, color: Colors.grey[400], size: 60))
                      : null),
                ),
              ),
              const SizedBox(height: 20),

              // Product Title
              Text(
                widget.product.title,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Product Description
              Text(
                widget.product.subtitle, // Using subtitle as description
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),

              // Price and Unit Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price:',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹${_pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffEB7720),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Unit selection dropdown if multiple units are available
              if (widget.product.availableSizes.length > 1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Unit:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedUnit,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xffEB7720)),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedUnit = newValue;
                              _pricePerSelectedUnit = widget.product.availableSizes
                                  .firstWhere((size) => size.size == newValue)
                                  .price;
                            });
                          },
                          items: widget.product.availableSizes.map<DropdownMenuItem<String>>((ProductSize sizeOption) {
                            return DropdownMenuItem<String>(
                              value: sizeOption.size,
                              child: Text(
                                '${sizeOption.size} (₹${sizeOption.price.toStringAsFixed(2)})',
                                style: GoogleFonts.poppins(),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                )
              else if (widget.product.availableSizes.length == 1)
              // Display single unit if only one is available
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Unit: ${_selectedUnit ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity:',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xffEB7720)),
                        onPressed: () {
                          setState(() {
                            if (_quantity > 1) _quantity--;
                          });
                        },
                      ),
                      Text(
                        _quantity.toString(),
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xffEB7720)),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Add to Cart Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_selectedUnit == null || _pricePerSelectedUnit == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a unit for the product.', style: GoogleFonts.poppins())),
                      );
                      return;
                    }

                    final cartModel = Provider.of<CartModel>(context, listen: false);
                    // Create a copy of the product with the currently selected unit and quantity
                    // to pass to cartModel.addItem which expects a Product.
                    final productToAdd = widget.product.copyWith(
                      selectedUnit: _selectedUnit,
                      // The quantity is handled by CartModel's addItem logic
                      // which increments if existing or sets to 1 for new item.
                      // If you want to add the specific _quantity from this page,
                      // you'd need to modify CartModel.addItem to accept quantity.
                      // For now, it will add 1 or increment existing.
                    );

                    cartModel.addItem(productToAdd); // Correctly passing a Product object

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${_quantity} ${widget.product.title}(s) added to cart!', style: GoogleFonts.poppins())),
                    );
                    // Optionally navigate to cart or show a confirmation
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffEB7720),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                  label: Text(
                    'Add to Cart',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
