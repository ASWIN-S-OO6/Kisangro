import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NEW: Import SharedPreferences

// Imports for mutual navigation
import 'package:kisangro/home/myorder.dart'; // For navigating to My Orders
import 'package:kisangro/menu/wishlist.dart'; // For navigating to Wishlist
import 'package:kisangro/home/bottom.dart'; // For navigating back to Home

// NEW: Import the CustomAppBar


import '../common/common_app_bar.dart';

// NEW: Data model for a Notification Item
class AppNotification {
  final String id; // Unique ID for the notification
  final String title;
  final String timestamp;
  final String product; // For order-related notifications
  final String description; // For order-related notifications
  final String? additionalText; // For membership/new arrival
  final String type; // e.g., 'order', 'membership', 'new_arrival'
  bool isRead; // NEW: Track read status

  AppNotification({
    required this.id,
    required this.title,
    required this.timestamp,
    this.product = '', // Default empty for non-order types
    this.description = '', // Default empty for non-order types
    this.additionalText,
    required this.type,
    this.isRead = false, // Default to unread
  });

  // Convert AppNotification to JSON for SharedPreferences
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timestamp': timestamp,
    'product': product,
    'description': description,
    'additionalText': additionalText,
    'type': type,
    'isRead': isRead,
  };

  // Create AppNotification from JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    title: json['title'] as String,
    timestamp: json['timestamp'] as String,
    product: json['product'] as String,
    description: json['description'] as String,
    additionalText: json['additionalText'] as String?,
    type: json['type'] as String,
    isRead: json['isRead'] as bool,
  );
}

// NEW: Order Arriving Details screen UI (Remains mostly unchanged, just made sure it's here for context)
class OrderArrivingDetailsPage extends StatelessWidget {
  final AppNotification notification; // Pass the specific notification

  const OrderArrivingDetailsPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final Color orange = const Color(0xffEB7720); // Your app's theme orange
    final Color textColor = Colors.black; // Consistent text color to black

    return Scaffold(
      appBar: CustomAppBar( // Use CustomAppBar here as well
        title: "Order Details", // A more specific title for this page
        showBackButton: true,
        showMenuButton: false,
        isMyOrderActive: false,
        isWishlistActive: false,
        isNotiActive: false, // Not highlighting any icon in the app bar for this detail page
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
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
              // Date and time from notification
              Center(
                child: Text(
                  notification.timestamp,
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order status (using notification title for simplicity here)
                    Text(
                      notification.title,
                      style: GoogleFonts.poppins(
                        color: orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product name
                    Text(
                      notification.product,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Product details
                    Text(
                      notification.description,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Order date
                    Text(
                      'Ordered on: ${notification.timestamp}', // Reusing timestamp for ordered on
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Specification
                    Text(
                      'Specification',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad.', // Placeholder
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Track Status button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tracking order status...', style: GoogleFonts.poppins())),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
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

class noti extends StatefulWidget {
  const noti({Key? key}) : super(key: key);

  @override
  State<noti> createState() => _notiState();
}

class _notiState extends State<noti> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // NEW: List to hold notifications with their read status
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadNotifications(); // NEW: Load notifications from storage
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  void _startAnimation() {
    if (_notifications.any((n) => !n.isRead)) { // Only animate if there's at least one unread notification
      if (!_animationController.isAnimating) { // Prevent starting if already animating
        _animationController.forward();
      }
    } else {
      _animationController.stop(); // Stop animation if all are read
      _animationController.value = 1.0; // Reset scale
    }
  }

  // NEW: Load notifications from SharedPreferences
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    // Example notifications - in a real app, these would come from an API
    // We assign a unique ID to each, which is crucial for persistence
    final List<AppNotification> defaultNotifications = [
      AppNotification(
        id: 'order_1',
        title: 'Order Arriving Today',
        timestamp: 'Friday, 3 November 2024  2:40 pm',
        product: 'AURASTAR',
        description: 'Fungicide | Order Units: 02',
        type: 'order',
      ),
      AppNotification(
        id: 'order_2',
        title: 'Order Delivered',
        timestamp: '03/11/2024 2:40 pm',
        product: 'AURASTAR',
        description: 'Fungicide | Order Units: 02',
        type: 'order',
      ),
      AppNotification(
        id: 'membership_1',
        title: 'Membership: basic',
        timestamp: '03/11/2024 2:40 pm',
        description: 'Congratulations Smart!',
        additionalText: 'You\'ve become our member in our...',
        type: 'membership',
      ),
      AppNotification(
        id: 'new_arrival_1',
        title: 'New Arrival!',
        timestamp: '03/11/2024 2:40 pm',
        description: 'New Product launched on the "Abk',
        additionalText: 'Industries"-your recent search. Bro...',
        type: 'new_arrival',
      ),
      // Add a new unread notification to test the dot and animation
      AppNotification(
        id: 'promo_1',
        title: 'Special Discount!',
        timestamp: '15/11/2024 10:00 am',
        description: 'Get 20% off on all pesticides this week!',
        type: 'promotion',
        isRead: false, // This one starts as unread
      ),
    ];


    // Load read status for each default notification
    setState(() {
      _notifications = defaultNotifications.map((notif) {
        final isRead = prefs.getBool('notification_${notif.id}_isRead') ?? false;
        notif.isRead = isRead;
        return notif;
      }).toList();
    });

    _startAnimation(); // Restart animation based on loaded read status
  }

  // NEW: Save notification read status to SharedPreferences
  Future<void> _saveNotificationReadStatus(String notificationId, bool isRead) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_${notificationId}_isRead', isRead);
    debugPrint('Saved read status for $notificationId: $isRead');

    // Update animation state based on new read status
    _startAnimation();
  }

  // NEW: Mark a notification as read and update UI/storage
  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index].isRead = true;
        _saveNotificationReadStatus(notificationId, true); // Persist change
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if there are any unread notifications to determine dot visibility
    final bool hasUnreadNotifications = _notifications.any((n) => !n.isRead);

    return Scaffold(
      appBar: CustomAppBar( // Replaced AppBar with CustomAppBar
        title: "Notification",
        showBackButton: true, // Show back button
        showMenuButton: false, // Do not show menu button
        // scaffoldKey is not needed here as there's no drawer
        isMyOrderActive: false,
        isWishlistActive: false,
        isNotiActive: true, // Highlight Notification icon
        // showWhatsAppIcon is false by default in CustomAppBar
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
                ])),
        child: ListView.builder(
          itemCount: _notifications.length + 1, // +1 for the "Browse More" button
          itemBuilder: (context, index) {
            if (index == _notifications.length) {
              return _buildBrowseMoreButton();
            }

            final notification = _notifications[index];
            Widget notificationWidget;

            if (notification.type == 'order') {
              notificationWidget = _buildNotificationItem(
                isNew: !notification.isRead, // Pass read status
                title: notification.title,
                timestamp: notification.timestamp,
                product: notification.product,
                description: notification.description,
              );
            } else if (notification.type == 'membership' || notification.type == 'new_arrival' || notification.type == 'promotion') {
              // Handle new 'promotion' type here
              notificationWidget = _buildMembershipItem(
                isNew: !notification.isRead, // Pass read status
                title: notification.title,
                timestamp: notification.timestamp,
                description: notification.description,
                additionalText: notification.additionalText ?? '',
              );
            } else {
              // Fallback for unknown types
              notificationWidget = Container();
            }

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Mark as read when tapped
                    _markAsRead(notification.id);
                    if (notification.type == 'order') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderArrivingDetailsPage(notification: notification)),
                      );
                    }
                    // Add other navigation based on notification.type if needed
                  },
                  child: notificationWidget,
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
              ],
            );
          },
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
          // Orange dot for individual new notifications
          if (isNew)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 8, right: 10),
              decoration: BoxDecoration(
                color: const Color(0xffEB7720), // Changed to orange for individual items
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 18), // Space for alignment if no dot

          SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
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
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: const Color(0xffEB7720),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        timestamp,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.right,
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
          // Orange dot for individual new notifications
          if (isNew)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 8, right: 10),
              decoration: BoxDecoration(
                color: const Color(0xffEB7720), // Changed to orange for individual items
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 18), // Space for alignment if no dot

          SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
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
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: const Color(0xffEB7720),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        timestamp,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  additionalText,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
