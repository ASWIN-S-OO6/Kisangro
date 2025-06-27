import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports for mutual navigation
import 'package:kisangro/home/myorder.dart'; // For navigating to My Orders
import 'package:kisangro/menu/wishlist.dart'; // For navigating to Wishlist
import 'package:kisangro/home/bottom.dart'; // For navigating back to Home

// NEW: Order Arriving Details screen UI
class OrderArrivingDetailsPage extends StatelessWidget {
  const OrderArrivingDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color orange = const Color(0xffEB7720); // Your app's theme orange
    final Color textColor = Colors.black; // Consistent text color to black

    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange, // Consistent app bar color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration( // Use const for BoxDecoration
                color: Colors.black87, // Dark circle
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'K',
                  style: GoogleFonts.poppins( // Use GoogleFonts
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12), // Use const
            Text(
              'Order',
              style: GoogleFonts.poppins( // Now using GoogleFonts.poppins for the heading
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Container( // Apply gradient background
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)], // Consistent theme gradient
          ),
        ),
        child: SingleChildScrollView( // Added SingleChildScrollView
          padding: const EdgeInsets.all(16.0), // Use const
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and time
              Center(
                child: Text(
                  'Friday, 3 November 2024  2:40 pm',
                  style: GoogleFonts.poppins( // Use GoogleFonts
                    color: Colors.black, // Changed to black
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24), // Use const

              // Order card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20), // Use const
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2), // Use const
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order status
                    Text(
                      'Order Arriving Today',
                      style: GoogleFonts.poppins( // Use GoogleFonts
                        color: orange, // Use consistent orange
                        fontSize: 20,
                        fontWeight: FontWeight.bold, // Made bolder
                      ),
                    ),
                    const SizedBox(height: 20), // Use const

                    // Product name
                    Text(
                      'AURASTAR',
                      style: GoogleFonts.poppins( // Use GoogleFonts
                        fontSize: 24,
                        fontWeight: FontWeight.bold, // Already bold, kept
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8), // Use const

                    // Product details
                    Text(
                      'Fungicide  |  Order Quantity: 04',
                      style: GoogleFonts.poppins( // Use GoogleFonts
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12), // Use const

                    // Order date
                    Text(
                      'Ordered on: 27/10/2024  2:23 pm',
                      style: GoogleFonts.poppins( // Use GoogleFonts
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 20), // Use const

                    // Specification
                    Text(
                      'Specification',
                      style: GoogleFonts.poppins( // Use GoogleFonts
                        fontSize: 18,
                        fontWeight: FontWeight.bold, // Made bolder
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8), // Use const

                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.',
                      style: GoogleFonts.poppins( // Use GoogleFonts
                        fontSize: 14,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24), // Use const

                    // Track Status button
                    SizedBox( // Use SizedBox instead of Container for width
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle track status button press
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tracking order status...', style: GoogleFonts.poppins())), // Use GoogleFonts
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange, // Use consistent orange
                          padding: const EdgeInsets.symmetric(vertical: 16), // Use const
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Track Status',
                              style: GoogleFonts.poppins( // Use GoogleFonts
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8), // Use const
                            const Icon( // Use const
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class noti extends StatefulWidget { // Changed to StatefulWidget
  const noti({Key? key}) : super(key: key);

  @override
  State<noti> createState() => _notiState();
}

class _notiState extends State<noti> with SingleTickerProviderStateMixin { // Added SingleTickerProviderStateMixin for animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Animation duration
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate( // Scale from 1.0 to 1.2
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation on initial load
    _animationController.forward(); // Scale up
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse(); // Scale down after completing forward
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward(); // Scale up again after completing reverse
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            "Notification",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            // Navigate back to the Home screen (index 0) of the Bot navigation
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Bot(initialIndex: 0)));
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage()));
            },
            icon: Image.asset(
              'assets/heart.png',
              height: 26,
              width: 26,
              color: Colors.white,
            ),
          ),
          // AnimatedScale for the notification icon
          AnimatedScale(
            scale: _animation.value, // Apply the animation value here
            duration: _animationController.duration!, // Use controller's duration
            child: IconButton(
              onPressed: () {
                // This is the current screen, so no navigation needed.
                // You could potentially add a refresh logic here if needed.
              },
              icon: Image.asset(
                'assets/noti.png',
                height: 30, // Slightly larger icon size
                width: 30, // Slightly larger icon size
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
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
            // NEW: Wrap with GestureDetector for navigation to the new OrderArrivingDetailsPage
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderArrivingDetailsPage()), // Navigate to new screen
                );
              },
              child: _buildNotificationItem(
                isNew: true,
                title: 'Order Arriving Today',
                timestamp: '03/11/2024 2:40 pm',
                product: 'AURASTAR',
                description: 'Fungicide | Order Units: 02',
              ),
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
                          color: const Color(0xffEB7720),
                          fontSize: 14,
                          fontWeight: FontWeight.bold, // Always bold for titles
                        ),
                        overflow: TextOverflow.ellipsis, // Add ellipsis for long titles
                      ),
                    ),
                    const SizedBox(width: 8), // Spacing between title and timestamp
                    Flexible( // Allow timestamp to shrink
                      child: Text(
                        timestamp,
                        style: GoogleFonts.poppins(
                          color: Colors.grey, // Kept grey for timestamp
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
                    fontWeight: FontWeight.bold, // Made bolder
                    color: Colors.black, // Changed to black
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black, // Changed to black
                    fontWeight: FontWeight.normal, // Normal weight for description
                  ),
                  maxLines: 2, // Allow text to wrap if necessary
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
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
                          color: const Color(0xffEB7720),
                          fontSize: 12, // Slightly increased font size for readability
                          fontWeight: FontWeight.bold, // Made bolder
                        ),
                        overflow: TextOverflow.ellipsis, // Add ellipsis for long titles
                      ),
                    ),
                    const SizedBox(width: 8), // Spacing between title and timestamp
                    Flexible( // Allow timestamp to shrink
                      child: Text(
                        timestamp,
                        style: GoogleFonts.poppins(
                          color: Colors.grey, // Kept grey for timestamp
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
                    color: Colors.black, // Changed to black
                    fontWeight: FontWeight.normal, // Normal weight for description
                  ),
                  maxLines: 2, // Allow text to wrap if necessary
                  overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                ),
                const SizedBox(height: 2),
                Text(
                  additionalText,
                  style: GoogleFonts.poppins(
                    fontSize: 13, // Adjusted font size
                    color: Colors.black, // Changed to black
                    fontWeight: FontWeight.normal, // Normal weight for description
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
          backgroundColor: const Color(0xffEB7720),
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
