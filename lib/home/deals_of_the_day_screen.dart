import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:kisangro/models/product_model.dart';
import 'package:kisangro/home/product.dart'; // ProductDetailPage
import 'package:kisangro/models/cart_model.dart'; // CartModel
import 'package:kisangro/models/wishlist_model.dart'; // WishlistModel
import 'package:kisangro/services/product_service.dart'; // Import ProductService for image fallback

class DealsOfTheDayScreen extends StatefulWidget {
  final List<Product> deals; // List of deal products to display

  const DealsOfTheDayScreen({super.key, required this.deals});

  @override
  State<DealsOfTheDayScreen> createState() => _DealsOfTheDayScreenState();
}

class _DealsOfTheDayScreenState extends State<DealsOfTheDayScreen> {
  late List<Product> _displayedDeals; // Products currently displayed (filtered/sorted)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSortBy; // 'price_asc', 'price_desc', 'alpha_asc', 'alpha_desc'

  @override
  void initState() {
    super.initState();
    _displayedDeals = List.from(widget.deals); // Initialize with all deals
    _searchController.addListener(_onSearchChanged);
    _filterAndSortProducts(); // Apply initial filter/sort if any
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterAndSortProducts();
    });
  }

  void _filterAndSortProducts() {
    List<Product> results = List.from(widget.deals); // Start with original deals

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      results = results.where((product) {
        return product.title.toLowerCase().contains(_searchQuery) ||
            product.subtitle.toLowerCase().contains(_searchQuery) ||
            product.category.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply sorting
    if (_selectedSortBy != null) {
      results.sort((a, b) {
        switch (_selectedSortBy) {
          case 'price_high_to_low':
            return (b.pricePerSelectedUnit ?? 0.0).compareTo(a.pricePerSelectedUnit ?? 0.0);
          case 'price_low_to_high':
            return (a.pricePerSelectedUnit ?? 0.0).compareTo(b.pricePerSelectedUnit ?? 0.0);
          case 'alpha_asc':
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          case 'alpha_desc':
            return b.title.toLowerCase().compareTo(a.title.toLowerCase());
          default:
            return 0; // No sorting
        }
      });
    }

    setState(() {
      _displayedDeals = results;
    });
  }

  // Helper function to determine the effective image URL
  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return ProductService.getRandomValidImageUrl(); // Fallback to a random valid API image
    }
    return rawImageUrl;
  }

  Widget _buildSearchBarAndSort() {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search deals...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              prefixIcon: Icon(Icons.search, color: const Color(0xffEB7720), size: isTablet ? 28 : 24),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, color: Colors.grey, size: isTablet ? 28 : 24),
                onPressed: () {
                  _searchController.clear();
                  _filterAndSortProducts();
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: isTablet ? 20.0 : 12.0, horizontal: 16.0),
            ),
            style: GoogleFonts.poppins(fontSize: isTablet ? 18 : 14),
          ),
          const SizedBox(height: 10),
          // Sort By Dropdown (Smaller and to the right)
          Align(
            alignment: Alignment.centerRight, // Align to the right
            child: SizedBox(
              width: isTablet ? 200 : 160, // Smaller width for dropdown
              child: DropdownButtonFormField<String>(
                value: _selectedSortBy,
                hint: Text('Sort By', style: GoogleFonts.poppins(fontSize: isTablet ? 14 : 12)), // Smaller font size
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: isTablet ? 12.0 : 8.0, horizontal: 12.0), // Smaller padding
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Relevance')),
                  const DropdownMenuItem(value: 'price_high_to_low', child: Text('Price: High to Low')),
                  const DropdownMenuItem(value: 'price_low_to_high', child: Text('Price: Low to High')),
                  const DropdownMenuItem(value: 'alpha_asc', child: Text('Name: A to Z')),
                  const DropdownMenuItem(value: 'alpha_desc', child: Text('Name: Z to A')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSortBy = value;
                    _filterAndSortProducts(); // Re-run filter/sort with new option
                  });
                },
                style: GoogleFonts.poppins(fontSize: isTablet ? 14 : 12, color: Colors.black), // Smaller font size
                iconSize: isTablet ? 24 : 20, // Smaller icon size
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color orange = const Color(0xffEB7720); // Your app's theme color

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        title: Text(
          'Deals of the Day',
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
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)], // Consistent theme gradient
          ),
        ),
        child: Column(
          children: [
            _buildSearchBarAndSort(), // Add search bar and sort dropdown
            Expanded(
              child: _displayedDeals.isEmpty
                  ? Center(
                child: Text(
                  _searchQuery.isNotEmpty
                      ? 'No deals found matching "${_searchController.text}".'
                      : 'No deals available today.',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(15.0),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, // Max width for items
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  mainAxisExtent: 320, // Explicitly set height for each tile to avoid overflow
                ),
                itemCount: _displayedDeals.length,
                itemBuilder: (context, index) {
                  final product = _displayedDeals[index];
                  return _buildProductTile(context, product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusing the _buildProductTile logic from homepage.dart for consistency
  Widget _buildProductTile(BuildContext context, Product product) {
    // Ensure selectedUnit is valid, default to first available if not
    final List<ProductSize> availableSizes = product.availableSizes.isNotEmpty
        ? product.availableSizes
        : [ProductSize(size: 'Unit', price: product.pricePerSelectedUnit ?? 0.0)];

    final String selectedUnit = availableSizes.any((size) => size.size == product.selectedUnit)
        ? product.selectedUnit
        : availableSizes.first.size;


    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              width: double.infinity,
              height: 100,
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
                    _getEffectiveImageUrl(product.imageUrl), // This will now use the dynamic fallback if rawImageUrl is empty
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 3),
          Text(
            product.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            product.subtitle,
            style: GoogleFonts.poppins(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (product.pricePerSelectedUnit != null && product.pricePerSelectedUnit! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '₹${product.pricePerSelectedUnit!.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 5),
          SizedBox(
            height: 36,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedUnit, // Use the resolved selectedUnit here
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xffEB7720)),
                isExpanded: true,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
                items: product.availableSizes.map((ProductSize sizeOption) {
                  return DropdownMenuItem<String>(
                    value: sizeOption.size,
                    child: Text(sizeOption.size),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (!mounted) return;
                  setState(() {
                    product.selectedUnit = newValue!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8)),
                  child: Text(
                    "Add",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 44,
                height: 44,
                child: Consumer<WishlistModel>(
                  builder: (context, wishlist, child) {
                    final bool isFavorite = wishlist.items.any(
                          (item) => item.id == product.id && item.selectedUnit == product.selectedUnit,
                    );
                    return IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (!mounted) return;
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
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xffEB7720),
                        size: 24,
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
}
