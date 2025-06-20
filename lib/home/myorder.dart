import 'dart:async';
import 'dart:typed_data'; // Needed for Uint8List to display image bytes
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart'; // For dotted borders around profile image
import 'package:kisangro/home/bottom.dart';
import 'package:kisangro/home/product.dart'; // Import ProductDetailPage
import 'package:provider/provider.dart'; // For state management (accessing KycImageProvider, OrderModel)
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // For star rating UI
import 'package:intl/intl.dart'; // For date formatting

// Existing imports for My Orders functionality
import 'package:kisangro/home/cancel1.dart'; // Ensure CancellationStep1Page is imported
import 'package:kisangro/home/noti.dart'; // Assuming this page exists for notifications
import 'package:kisangro/home/cart.dart'; // Import for CartScreen navigation (for Modify Order)
import 'package:kisangro/home/multi_product_order_detail_page.dart'; // Import the new MultiProductOrderDetailPage

// Import for the DispatchedOrdersScreen (if you create it)
import 'dispatched_orders_screen.dart'; // Make sure this path is correct if you have this file

// Imports for Drawer functionality (some of these will remain even if the drawer widget is removed,
// if _buildHeader or _buildMenuItem methods are kept for other purposes or future use).
import '../login/login.dart'; // For LoginApp
import '../menu/account.dart'; // For MyAccountPage
import '../menu/ask.dart'; // For AskUsPage
import '../menu/logout.dart'; // For LogoutConfirmationDialog
import '../menu/setting.dart'; // For SettingsPage
import '../menu/transaction.dart'; // For TransactionHistoryPage
import '../menu/wishlist.dart'; // For WishlistPage

// Models
import 'package:kisangro/models/order_model.dart'; // Order and OrderModel
import 'package:kisangro/models/cart_model.dart'; // CartModel for modifying order
import 'package:kisangro/models/kyc_image_provider.dart'; // KycImageProvider


class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _rating = 4; // Initial rating for the review dialog
  final TextEditingController _reviewController = TextEditingController();
  static const int maxChars = 100;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for Scaffold to open drawer


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  /// Shows a confirmation dialog for logging out.
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (context) => LogoutConfirmationDialog(
        onCancel: () => Navigator.of(context).pop(), // Close dialog on cancel
        onLogout: () {
          // Perform logout actions and navigate to LoginApp, clearing navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginApp()),
                (Route<dynamic> route) => false, // Remove all routes below
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully!')),
          );
        },
      ),
    );
  }

  /// Shows a dialog for giving ratings and writing a review.
  void showComplaintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          content: StatefulBuilder( // Use StatefulBuilder to manage dialog's internal state
            builder: (context, setState) {
              return SizedBox(
                width: 328, // Fixed width for dialog content
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Make column content fit
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context), // Close dialog
                        child: const Icon(
                          Icons.close,
                          color: Color(0xffEB7720), // Orange close icon
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Give ratings and write a review about your experience using this app.",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text("Rate:", style: GoogleFonts.lato(fontSize: 16)),
                        const SizedBox(width: 12),
                        RatingBar.builder( // Star rating bar
                          initialRating: _rating.toDouble(),
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 32,
                          unratedColor: Colors.grey[300],
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Color(0xffEB7720),
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _rating = rating.toInt(); // Update rating state
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _reviewController,
                      maxLength: maxChars,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '', // Hide default counter text
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (_) => setState(() {}), // Rebuild to update character count
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_reviewController.text.length}/$maxChars', // Character counter
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffEB7720),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close review dialog

                          // Show "Thank you" confirmation dialog
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.all(24),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xffEB7720),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Thank you!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thanks for rating us.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context), // Close thank you dialog
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xffEB7720),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        'OK',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea( // Ensures content is not under status bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(), // Custom header for the drawer, now displaying KYC image
              _buildMenuItem(Icons.person_outline, "My Account"), // Drawer menu items
              _buildMenuItem(Icons.history, "Transaction History"),
              _buildMenuItem(Icons.headset_mic, "Ask Us!"),
              _buildMenuItem(Icons.info_outline, "About Us"),
              _buildMenuItem(Icons.star_border, "Rate Us"),
              _buildMenuItem(Icons.share, "Share Kisangro"),
              _buildMenuItem(Icons.settings_outlined, "Settings"),
              _buildMenuItem(Icons.logout, "Logout"),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        centerTitle: false,
        title: Transform.translate(
          offset: const Offset(-20, 0),
          child: Text(
            "My Orders",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Bot(initialIndex: 0))); // Go to Home tab
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          // Highlighted My Orders Icon (box.png)
          IconButton(
            onPressed: () {
              // No navigation needed, as we are already on the My Orders page
            },
            icon: Image.asset(
              'assets/box.png',
              height: 28, // Increased size to highlight
              width: 28, // Increased size to highlight
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const WishlistPage()));
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
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const noti()));
            },
            icon: Image.asset(
              'assets/noti.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          // REMOVED: The shopping bag icon (assets/bag.png) is removed as requested.
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(),
          tabs: const [
            Tab(text: 'Booked'),
            Tab(text: 'Dispatched'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Container( // Added Container to apply gradient to the entire body
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)], // Matching wishlist.dart gradient
          ),
        ),
        child: Consumer<OrderModel>(
          builder: (context, orderModel, child) {
            final bookedOrders = orderModel.orders
                .where((order) => order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed)
                .toList();
            final dispatchedOrders = orderModel.orders
                .where((order) => order.status == OrderStatus.dispatched)
                .toList();
            final deliveredOrders = orderModel.orders
                .where((order) => order.status == OrderStatus.delivered)
                .toList();
            final cancelledOrders = orderModel.orders
                .where((order) => order.status == OrderStatus.cancelled)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(bookedOrders, orderModel),
                _buildOrderList(dispatchedOrders, orderModel),
                _buildOrderList(deliveredOrders, orderModel),
                _buildOrderList(cancelledOrders, orderModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, OrderModel orderModel) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No orders in this category yet!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Once you place orders, they will appear here.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(order: order, orderModel: orderModel);
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              DottedBorder(
                borderType: BorderType.Circle,
                color: Colors.red,
                strokeWidth: 2,
                dashPattern: const [6, 3],
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Consumer<KycImageProvider>(
                      builder: (context, kycImageProvider, child) {
                        final Uint8List? kycImageBytes = kycImageProvider.kycImageBytes;
                        return kycImageBytes != null
                            ? Image.memory(
                          kycImageBytes,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          'assets/profile.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                "Hi Smart!\n9876543210",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to MembershipDetailsScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEB7720),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not A Member Yet",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 30, thickness: 1, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        height: 40,
        decoration: const BoxDecoration(color: Color(0xffffecdc)),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xffEB7720)),
          title: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.pop(context); // Close the drawer

            switch (label) {
              case 'My Account':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountPage()));
                break;
              case 'Transaction History':
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  TransactionHistoryPage()));
                break;
              case 'Ask Us!':
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  AskUsPage()));
                break;
              case 'Rate Us':
                showComplaintDialog(context);
                break;
              case 'Settings':
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  SettingsPage()));
                break;
              case 'Logout':
                _showLogoutDialog(context);
                break;
              case 'About Us':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('About Us page coming soon!')),
                );
                break;
              case 'Share Kisangro':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share functionality coming soon!')),
                );
                break;
              case 'Wishlist':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistPage()));
                break;
            }
          },
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final OrderModel orderModel; // Pass OrderModel to allow status updates

  const OrderCard({Key? key, required this.order, required this.orderModel}) : super(key: key);

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  @override
  Widget build(BuildContext context) {
    // Determine the color based on the order status
    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.booked:
      case OrderStatus.confirmed:
        statusColor = Colors.blue;
        break;
      case OrderStatus.dispatched:
        statusColor = Colors.orange;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    // Determine button visibility based on order status
    bool showCancelButton = (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed);
    bool showTrackOrderButton = (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed || order.status == OrderStatus.dispatched);
    bool showBrowseMoreButton = order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled;
    bool showRateProductButton = order.status == OrderStatus.delivered;
    bool showModifyOrderButton = (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed);


    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      // Changed Card color to match WishlistItemCard's slightly transparent orange
      color: Colors.orange.shade50.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID: ${order.id}',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    order.status.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                        color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order Date: ${DateFormat('dd MMMんですよ, hh:mm a').format(order.orderDate)}',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            if (order.status == OrderStatus.delivered &&
                order.deliveredDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Delivered On: ${DateFormat('dd MMMんですよ').format(order.deliveredDate!)}',
                  style: GoogleFonts.poppins(
                      color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ),
            const Divider(height: 20, thickness: 1),
            // Display ordered products (can be a ListView.builder if many)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.products.length,
              itemBuilder: (context, idx) {
                final product = order.products[idx];
                return GestureDetector(
                  onTap: () {
                    // Navigate to MultiProductOrderDetailPage.
                    // REMOVED `initialProductIndex: idx` as it is not a parameter in MultiProductOrderDetailPage constructor.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiProductOrderDetailPage(
                          order: order, // Pass the whole order
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                            image: _isValidUrl(product.imageUrl)
                                ? DecorationImage(
                              image: NetworkImage(product.imageUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stacktrace) {
                                // Fallback to asset image on error
                                debugPrint("Error loading image: ${product.imageUrl}");
                                return; // Indicate that default onError handling should proceed
                              },
                            )
                                : DecorationImage( // For asset images
                              image: AssetImage(product.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _isValidUrl(product.imageUrl)
                              ? null // If network image is used, the DecorationImage handles it
                              : (product.imageUrl.isEmpty // If asset image path is empty or invalid
                              ? Center(
                              child: Icon(Icons.broken_image, color: Colors.grey[400]))
                              : null),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                product.subtitle,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey[700]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${product.selectedUnit} x ${product.quantity}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              Text(
                                '₹${product.pricePerUnit.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xffEB7720)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffEB7720)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons based on status
            Row(
              children: [
                if (showTrackOrderButton)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Simulate dispatching for demo purposes
                          if (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed) {
                            orderModel.updateOrderStatus(order.id, OrderStatus.dispatched);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Order ${order.id} dispatched!', style: GoogleFonts.poppins(),)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tracking order ${order.id}!', style: GoogleFonts.poppins(),)),
                            );
                            // In a real app, navigate to a tracking page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DispatchedOrdersScreen()), // Example tracking screen
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xffEB7720)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        icon: const Icon(Icons.delivery_dining,
                            color: Color(0xffEB7720), size: 16),
                        label: Text(
                          order.status == OrderStatus.dispatched ? 'Track Order' : (order.status == OrderStatus.delivered ? 'View Details' : 'Dispatch Now (Demo)'),
                          style:
                          GoogleFonts.poppins(color: const Color(0xffEB7720)),
                        ),
                      ),
                    ),
                  ),
                if (showTrackOrderButton && showCancelButton) // Add some spacing if both buttons are visible
                  const SizedBox(width: 12),
                if (showCancelButton)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CancellationStep1Page( // Removed `currentStatus: order.status`
                                  orderId: order.id,)),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.red, size: 16),
                        label: Text(
                          'Cancel Order',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (showRateProductButton || showBrowseMoreButton || showModifyOrderButton)
              const SizedBox(height: 12), // Spacer if buttons are below

            Row(
              children: [
                if (showModifyOrderButton)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Populate cart with current order items and navigate to cart
                          Provider.of<CartModel>(context, listen: false).populateCartFromOrder(order.products);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Cart()), // Corrected to const
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order ${order.id} loaded to cart for modification!', style: GoogleFonts.poppins())),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xffEB7720)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        icon: const Icon(Icons.edit, color: Color(0xffEB7720), size: 16),
                        label: Text(
                          'Modify Order',
                          style: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                        ),
                      ),
                    ),
                  ),
                if (showModifyOrderButton && (showRateProductButton || showBrowseMoreButton))
                  const SizedBox(width: 12), // Spacing between buttons
                if (showRateProductButton)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Action for "Rate Product" (e.g., show a rating dialog)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Rating product for order ${order.id}!', style: GoogleFonts.poppins())),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffEB7720),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        icon: const Icon(Icons.star, color: Colors.white, size: 16),
                        label: Text(
                          'Rate Product',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (showBrowseMoreButton && (showRateProductButton))
              const SizedBox(width: 12),
            if (showBrowseMoreButton)
              Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Action for "Invoice" (e.g., navigate to invoice view or download)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Generating invoice for order ${order.id}!', style: GoogleFonts.poppins())),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xffEB7720)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          icon: const Icon(Icons.file_download_sharp, color: Color(0xffEB7720), size: 16),
                          label: Text(
                            'Invoice',
                            style: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              // Action for "Browse More" (e.g., navigate to homepage or categories)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Browsing more products!', style: GoogleFonts.poppins())),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xffEB7720),
                              padding: const EdgeInsets.symmetric(vertical: 5),
                            ),
                            child: Text('Browse More', style: GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
