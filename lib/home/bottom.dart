import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/home/cart.dart'; // Corrected import
import 'package:kisangro/home/categories.dart'; // Corrected import
import 'package:kisangro/home/homepage.dart'; // Corrected import
import 'package:kisangro/home/reward_screen.dart'; // Corrected import
// MyOrder, WishlistPage, and noti are intentionally not imported here
// as they are no longer part of the bottom navigation.


class Bot extends StatefulWidget {
  // Added initialIndex to the constructor to allow setting the starting tab
  final int initialIndex;

  const Bot({super.key, this.initialIndex = 0}); // Default to 0 (Home)

  @override
  State<Bot> createState() => _BotState();
}

class _BotState extends State<Bot> {
  late int _selectedIndex; // Make it late to initialize from widget

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Initialize from the passed index
  }

  // If the widget is rebuilt with a different initialIndex (e.g., from a programmatic
  // navigation that rebuilds Bot), update the selected index.
  @override
  void didUpdateWidget(covariant Bot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  // List of main screens for the bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(), // Index 0
    ProductCategoriesScreen(), // Index 1
    RewardScreen(), // Index 2
    Cart(), // Index 3 - Your original cart class
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Adjust shadow opacity
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xffEB7720),
          unselectedItemColor: const Color(0xff575757),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // Ensures all items are visible

          // Apply Poppins font for labels
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),

          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/home.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 0 ? const Color(0xffEB7720) : const Color(0xff575757),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/cat.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 1 ? const Color(0xffEB7720) : const Color(0xff575757),
              ),
              label: "Categories",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/reward.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 2 ? const Color(0xffEB7720) : const Color(0xff575757),
              ),
              label: "Rewards",
            ),
            BottomNavigationBarItem(
              // Cart tab - now at index 3
              icon: Image.asset(
                'assets/cart.png',
                width: 24,
                height: 24,
                color: _selectedIndex == 3 ? const Color(0xffEB7720) : const Color(0xff575757),
              ),
              label: "Cart",
            ),
            // Removed 'Orders', 'Wishlist', 'Notifications' from bottom bar as per request
          ],
        ),
      ),
    );
  }
}
