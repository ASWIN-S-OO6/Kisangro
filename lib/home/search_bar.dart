import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/services/product_service.dart'; // Import ProductService
import 'package:kisangro/models/product_model.dart'; // Import Product model
import 'package:kisangro/home/product.dart'; // Import ProductDetailPage
import 'package:provider/provider.dart'; // Import Provider for CartModel and WishlistModel
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'dart:async'; // For Timer for debouncing
import 'package:geolocator/geolocator.dart'; // Import geolocator
import 'package:geocoding/geocoding.dart'; // Import geocoding


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Changed to store Products instead of just strings
  List<Product> _recentSearches = [];
  List<Product> _trendingSearches = [];

  List<Product> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounce; // For debouncing search input

  String _currentLocation = 'Detecting...';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _determinePosition();
    _loadInitialSearchSuggestions(); // Load products for recent/trending
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  // New: Load initial products for Recent and Trending searches
  void _loadInitialSearchSuggestions() {
    final allProducts = ProductService.getAllProducts();
    if (allProducts.isNotEmpty) {
      // For recent searches, take some recent products (e.g., last 5 added)
      // This is a dummy implementation; in a real app, this would come from user search history.
      _recentSearches = allProducts.reversed.take(5).toList();

      // For trending searches, take some popular products (e.g., first 5)
      // This is a dummy implementation; in a real app, this would come from analytics.
      _trendingSearches = allProducts.take(5).toList();
    }
    setState(() {}); // Refresh UI
  }


  String _getEffectiveImageUrl(String rawImageUrl) {
    if (rawImageUrl.isEmpty || rawImageUrl == 'https://sgserp.in/erp/api/' || (Uri.tryParse(rawImageUrl)?.isAbsolute != true && !rawImageUrl.startsWith('assets/'))) {
      return 'assets/placeholder.png';
    }
    return rawImageUrl;
  }

  void _performSearch(String query) {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    try {
      final results = ProductService.searchProductsLocally(query); // This should now work
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Error searching products: ${e.toString()}';
        _searchResults = [];
        _isSearching = false;
      });
      debugPrint('Search error: $e');
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8), // Small space after back button
                  Expanded( // Search field takes remaining space
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                        hintText: 'Search by item/crop/chemical name',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch(''); // Clear search results
                          },
                        )
                            : const Icon(Icons.search, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xffEB7720), width: 2), // Orange border on focus
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      textInputAction: TextInputAction.search, // Keyboard action for search
                      onSubmitted: (query) {
                        _performSearch(query); // Trigger search on submit
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Responsive "Location" button - now uses dynamic location
              Align(
                alignment: Alignment.centerRight, // Align to right
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffEB7720),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Make row take minimum space
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Flexible( // Wrap Text in Flexible to handle potential overflow gracefully
                        child: Text(
                          _currentLocation, // Display dynamic location
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                          overflow: TextOverflow.ellipsis, // Truncate long location names
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Search Results Display or Default Content
              if (_isSearching)
                const Center(child: CircularProgressIndicator(color: Color(0xffEB7720)))
              else if (_searchError != null)
                Center(
                  child: Text(
                    _searchError!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                )
              else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No products found for "${_searchController.text}".',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else if (_searchResults.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final product = _searchResults[index];
                          return _buildSearchResultTile(context, product);
                        },
                      ),
                    )
                  else
                  // Default content when no search is active or query is empty
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Recent Searches", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _recentSearches.map((product) => _buildProductTag(product)).toList(), // Use _buildProductTag
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text("Trending Searches", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _trendingSearches.map((product) => _buildProductTag(product)).toList(), // Use _buildProductTag
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // Modified _buildTag to accept a Product and display its image/name, and navigate
  Widget _buildProductTag(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffEB7720)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display product image next to text
            SizedBox(
              width: 24, // Small size for the icon/image
              height: 24,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _getEffectiveImageUrl(product.imageUrl).startsWith('http')
                    ? Image.network(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/placeholder.png',
                    fit: BoxFit.contain,
                  ),
                )
                    : Image.asset(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8), // Space between image and text
            Text(product.title, style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(width: 5),
            const Icon(Icons.trending_up, size: 14, color: Color(0xffEB7720)),
          ],
        ),
      ),
    );
  }

  // Widget to build individual search result tiles (remains largely the same)
  Widget _buildSearchResultTile(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            SizedBox(
              width: 80,
              height: 80,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _getEffectiveImageUrl(product.imageUrl).startsWith('http')
                    ? Image.network(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/placeholder.png',
                    fit: BoxFit.contain,
                  ),
                )
                    : Image.asset(
                  _getEffectiveImageUrl(product.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${product.pricePerSelectedUnit?.toStringAsFixed(2) ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Add to Cart and Wishlist actions (simplified for search results)
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            "Add to Cart",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<WishlistModel>(
                        builder: (context, wishlist, child) {
                          final bool isFavorite = wishlist.containsItem(product.id, product.selectedUnit);
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
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: const Color(0xffEB7720),
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
