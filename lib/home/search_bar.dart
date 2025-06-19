import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> recentSearches = ["Aurastar", "Oxyfen", "Azeem", "Hyfen", "Aurastar"];
  final List<String> trendingSearches = ["Aurastar", "Oxyfen", "Azeem", "Hyfen", "Aurastar"];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        // Rebuilds the widget when text changes to update clear button visibility
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                                  // Optionally trigger a search here with empty string
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
                        // This is where you'd typically trigger a search to your product API
                        print('Search submitted: $query');
                        // Example: Call a provider method or navigate to search results
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Responsive "Coimbatore" location button
              Align(
                alignment: Alignment.centerRight, // Align to right
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 180), // Max width to prevent excessive stretching
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
                      Text('Coimbatore', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Recent Searches", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: recentSearches.map((term) => _buildTag(term)).toList(),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Text("Trending Searches", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: trendingSearches.map((term) => _buildTag(term)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffEB7720)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14)),
          const SizedBox(width: 5),
          const Icon(Icons.trending_up, size: 14, color: Color(0xffEB7720)),
        ],
      ),
    );
  }
}
