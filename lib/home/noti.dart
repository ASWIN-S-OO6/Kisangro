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
        title: Text(
          "Notification",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => WishlistPage()));
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
        decoration: BoxDecoration(
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

          CircleAvatar(
            radius: 30, // Increase this value to make it bigger
            backgroundImage: AssetImage("assets/logo.png"),
          ),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Color(0xffEB7720),
                        fontSize: 14,
                        fontWeight: isNew ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    Text(
                      timestamp,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
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
          // Logo image
          CircleAvatar(
            radius: 30, // Increase this value to make it bigger
            backgroundImage: AssetImage("assets/logo.png"),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Color(0xffEB7720),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      timestamp,
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  additionalText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
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
          backgroundColor: Color(0xffEB7720),
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
