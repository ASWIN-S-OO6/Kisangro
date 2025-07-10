import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For WhatsApp icon

// Imports for navigation to common destinations
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:kisangro/home/noti.dart';
// Removed import for cart as it's not linked in the top bar actions
import 'package:kisangro/home/bottom.dart'; // Import Bot for navigation

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showMenuButton;
  final bool showWhatsAppIcon; // New parameter to control WhatsApp icon visibility
  final GlobalKey<ScaffoldState>? scaffoldKey; // Required for opening drawer
  final bool isMyOrderActive; // New: Flag for MyOrder icon highlight
  final bool isWishlistActive; // New: Flag for Wishlist icon highlight
  final bool isNotiActive; // New: Flag for Noti icon highlight
  // Removed isCartActive as per instruction

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true, // Default to showing back button
    this.showMenuButton = false, // Default to not showing menu button
    this.showWhatsAppIcon = false, // Default to not showing WhatsApp icon
    this.scaffoldKey, // Optional, only needed if showMenuButton is true
    this.isMyOrderActive = false, // Default to false
    this.isWishlistActive = false, // Default to false
    this.isNotiActive = false, // Default to false
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Standard AppBar height

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFEB7720);

    // Helper function to build a highlighted icon
    Widget _buildActionIcon({
      required String assetPath,
      required double height,
      required double width,
      required bool isActive,
      required VoidCallback onPressed,
      IconData? fontAwesomeIcon, // For WhatsApp
    }) {
      // Increase size if active
      final double effectiveHeight = isActive ? height * 1.2 : height;
      final double effectiveWidth = isActive ? width * 1.2 : width;

      return IconButton(
        onPressed: onPressed,
        icon: Padding( // Added Padding to ensure consistent spacing even when size changes
          padding: EdgeInsets.all(isActive ? 0 : 2), // Adjust padding if icon grows
          child: fontAwesomeIcon != null
              ? Icon(fontAwesomeIcon, color: Colors.white, size: effectiveWidth) // For FontAwesome icons
              : Image.asset(
            assetPath,
            height: effectiveHeight,
            width: effectiveWidth,
            color: Colors.white,
          ),
        ),
      );
    }

    Widget? leadingWidget;
    if (showMenuButton) {
      leadingWidget = IconButton(
        onPressed: () {
          scaffoldKey?.currentState?.openDrawer(); // Open drawer
        },
        icon: const Icon(Icons.menu, color: Colors.white),
      );
    } else if (showBackButton) {
      leadingWidget = IconButton(
        onPressed: () {
          // Navigate back to the home screen (Bot with initialIndex: 0)
          // This will replace all routes until the Bot screen.
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Bot(initialIndex: 0)),
                (Route<dynamic> route) => false, // Remove all previous routes
          );
        },
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      );
    }
    // If both showMenuButton and showBackButton are false, leadingWidget remains null.

    return AppBar(
      backgroundColor: orange,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0.0, // <--- CHANGED THIS TO 0.0
      automaticallyImplyLeading: false, // Explicitly prevent automatic leading widget
      leading: leadingWidget, // Use the determined leading widget
      title: Text(
        title,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
      ),
      actions: [
        if (showWhatsAppIcon) // Conditionally show WhatsApp icon
          _buildActionIcon(
            assetPath: '', // Not used for FontAwesome
            height: 24,
            width: 24,
            isActive: false, // WhatsApp icon is not part of the highlighting logic
            onPressed: () {
              // TODO: Add WhatsApp functionality for homepage
            },
            fontAwesomeIcon: FontAwesomeIcons.whatsapp,
          ),
        _buildActionIcon(
          assetPath: 'assets/box.png',
          height: 24,
          width: 24,
          isActive: isMyOrderActive,
          onPressed: () {
            // Smooth navigation to MyOrder, replacing current route
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const MyOrder(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300), // Adjust duration as needed
              ),
            );
          },
        ),
        _buildActionIcon(
          assetPath: 'assets/heart.png',
          height: 26,
          width: 26,
          isActive: isWishlistActive,
          onPressed: () {
            // Smooth navigation to Wishlist, replacing current route
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const WishlistPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300), // Adjust duration as needed
              ),
            );
          },
        ),
        _buildActionIcon(
          assetPath: 'assets/noti.png',
          height: 28,
          width: 28,
          isActive: isNotiActive,
          onPressed: () {
            // Smooth navigation to Noti, replacing current route
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const noti(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300), // Adjust duration as needed
              ),
            );
          },
        ),
        // Removed Cart icon from CustomAppBar actions as per instruction
        const SizedBox(width: 10), // Add some trailing space
      ],
    );
  }
}
