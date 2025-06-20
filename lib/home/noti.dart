import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports for mutual navigation
import 'package:kisangro/home/myorder.dart'; // For navigating to My Orders
import 'package:kisangro/menu/wishlist.dart'; // For navigating to Wishlist

class noti extends StatelessWidget {
  const noti({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        // Aligned title as per other screens (homepage.dart, wishlist.dart)
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            "Notification",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18, // Consistent font size
              // Removed fontWeight: FontWeight.bold for consistency
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Added const
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to MyOrder screen
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrder()));
            },
            icon: Image.asset(
              'assets/box.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              // Navigate to WishlistPage
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage())); // Added const
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
              // This is the current screen, so no navigation needed.
              // You could potentially add a refresh logic here if needed.
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
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration( // Added const
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffFFD9BD),
                  Color(0xffFFFFFF),
                ]
            )
        ),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildNotificationItem(
              isNew: true,
              title: 'Order Arriving Today',
              timestamp: '03/11/2024 2:40 pm',
              product: 'AURASTAR',
              description: 'Fungicide | Order Units: 02',
            ),
            const Divider(height: 1, thickness: 1),
            Center(
              child: Container(
                width: 131.2,
                height: 0.2,
                color: Colors.grey.shade300,
              ),
            ),
            const Divider(height: 1, thickness: 1),
            _buildNotificationItem(
              isNew: false,
              title: 'Order Delivered',
              timestamp: '03/11/2024 2:40 pm',
              product: 'AURASTAR',
              description: 'Fungicide | Order Units: 02',
            ),
            _buildBrowseMoreButton(),
            const Divider(height: 1, thickness: 1),
            Center(
              child: Container(
                width: 131.2,
                height: 0.2,
                color: Colors.grey.shade300,
              ),
            ),
            _buildMembershipItem(
              isNew: false,
              title: 'Membership: basic',
              timestamp: '03/11/2024 2:40 pm',
              description: 'Congratulations Smart!',
              additionalText: 'You\'ve become our member in our...',
            ),
            const Divider(height: 1, thickness: 1),
            Center(
              child: Container(
                width: 131.2,
                height: 0.2,
                color: Colors.grey.shade300,
              ),
            ),
            _buildMembershipItem(
              isNew: true,
              title: 'New Arrival!',
              timestamp: '03/11/2024 2:40 pm',
              description: 'New Product launched on the "Abk',
              additionalText: 'Industries"-your recent search. Bro...',
            ),
            const Divider(height: 1, thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required bool isNew,
    required String title,
    required String timestamp,
    required String product,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xffEB7720),
              shape: BoxShape.circle,
            ),
          ),
          // Logo image: Adjusted to ensure proper fit
          SizedBox(
            width: 40, // Equivalent to radius * 2 (20 * 2)
            height: 40, // Equivalent to radius * 2
            child: ClipOval(
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain, // Ensures the entire image is visible within the circle
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded( // Expanded to prevent overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Allow title to take available space
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: const Color(0xffEB7720), // Added const
                          fontSize: 14,
                          fontWeight: isNew ? FontWeight.bold : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis, // Add ellipsis for long titles
                      ),
                    ),
                    const SizedBox(width: 8), // Spacing between title and timestamp
                    Flexible( // Allow timestamp to shrink
                      child: Text(
                        timestamp,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.right, // Align timestamp to the right
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600, // Made thicker
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500, // Made thicker
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipItem({
    required bool isNew,
    required String title,
    required String timestamp,
    required String description,
    required String additionalText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xffEB7720),
              shape: BoxShape.circle,
            ),
          ),
          // Logo image: Adjusted to ensure proper fit
          SizedBox(
            width: 40, // Equivalent to radius * 2 (20 * 2)
            height: 40, // Equivalent to radius * 2
            child: ClipOval(
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain, // Ensures the entire image is visible within the circle
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Allow title to take available space
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: const Color(0xffEB7720), // Added const
                          fontSize: 12, // Slightly increased font size for readability
                          fontWeight: FontWeight.w500, // Made thicker
                        ),
                        overflow: TextOverflow.ellipsis, // Add ellipsis for long titles
                      ),
                    ),
                    const SizedBox(width: 8), // Spacing between title and timestamp
                    Flexible( // Allow timestamp to shrink
                      child: Text(
                        timestamp,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.right, // Align timestamp to the right
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13, // Adjusted font size to prevent overflow with thicker text
                    color: Colors.grey,
                    fontWeight: FontWeight.w500, // Made thicker
                  ),
                  maxLines: 2, // Allow text to wrap if necessary
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                ),
                const SizedBox(height: 2),
                Text(
                  additionalText,
                  style: GoogleFonts.poppins(
                    fontSize: 13, // Adjusted font size
                    color: Colors.grey,
                    fontWeight: FontWeight.w500, // Made thicker
                  ),
                  maxLines: 2, // Allow text to wrap
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseMoreButton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          // You can navigate to your main home/categories screen here
          // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoriesScreen()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffEB7720), // Added const
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Browse More',
          style: GoogleFonts.poppins(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
