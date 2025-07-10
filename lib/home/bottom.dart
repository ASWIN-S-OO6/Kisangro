import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // For post-frame callback
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/home/cart.dart';
import 'package:kisangro/home/categories.dart'; // ProductCategoriesScreen
import 'package:kisangro/home/homepage.dart';
import 'package:kisangro/home/reward_screen.dart';
import 'package:kisangro/home/rewards_popup.dart'; // Import RewardsPopup

class Bot extends StatefulWidget {
  final int initialIndex;
  final bool showRewardsPopup; // Parameter to trigger RewardsPopup

  const Bot({
    super.key,
    this.initialIndex = 0, // Default to Home tab
    this.showRewardsPopup = false, // Default to false
  });

  @override
  State<Bot> createState() => _BotState();
}

class _BotState extends State<Bot> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // Show RewardsPopup if showRewardsPopup is true and we're on the Home tab
    if (widget.showRewardsPopup && widget.initialIndex == 0) {
      // Use post-frame callback to show dialog after the widget is built
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // Keep as false per your RewardsPopup design
            builder: (BuildContext dialogContext) => const RewardsPopup(coinsEarned: 100),
          );
        }
      });
    }
  }

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
  // NOTE: ProductCategoriesScreen is at index 1
  final List<Widget> _screens = [
    // We will pass the _onItemTapped callback to HomeScreen
    // so HomeScreen can request a tab change.
    // Wrap HomeScreen in a builder to provide the callback.
    Builder(builder: (context) {
      return HomeScreen(
        onCategoryViewAll: () {
          // When "View All" for categories is tapped in HomeScreen,
          // we update the selected index of the BottomNavigationBar to 1 (Categories).
          final _BotState? botState = context.findAncestorStateOfType<_BotState>();
          botState?._onItemTapped(1); // Set index to 1 for Categories tab
        },
      );
    }),
    const ProductCategoriesScreen(), // Index 1
    const RewardScreen(), // Index 2
    const Cart(), // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope( // Use PopScope to handle back button press
      canPop: _selectedIndex == 0, // Only allow pop if on the Home screen
      onPopInvoked: (didPop) {
        if (didPop) return;
        // If not on Home screen, navigate to Home (index 0)
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
            type: BottomNavigationBarType.fixed,
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
                icon: Image.asset(
                  'assets/cart.png',
                  width: 24,
                  height: 24,
                  color: _selectedIndex == 3 ? const Color(0xffEB7720) : const Color(0xff575757),
                ),
                label: "Cart",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
