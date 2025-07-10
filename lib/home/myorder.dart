import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:kisangro/home/bottom.dart';
import 'package:kisangro/home/product.dart'; // This is your existing ProductDetailPage
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:kisangro/home/cancel1.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/home/cart.dart';
import 'package:kisangro/home/multi_product_order_detail_page.dart'; // Correct import path for MultiProductOrderDetailPage
import 'package:kisangro/login/login.dart';
import 'package:kisangro/menu/account.dart';
import 'package:kisangro/menu/ask.dart';
import 'package:kisangro/menu/logout.dart';
import 'package:kisangro/menu/setting.dart';
import 'package:kisangro/menu/transaction.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/kyc_image_provider.dart';
import '../common/common_app_bar.dart';
import 'dispatched_orders_screen.dart';
// Keep this import if it's used elsewhere, but not for this specific navigation
import 'package:kisangro/models/product_model.dart'; // Ensure Product model is imported for conversion
import 'package:kisangro/home/trending_products_screen.dart'; // Import TrendingProductsScreen

// Import the common_app_bar file



class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _rating = 4; // Re-added for local management
  final TextEditingController _reviewController = TextEditingController(); // Re-added for local management
  static const int maxChars = 100; // Re-added for local management
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose(); // Re-added dispose
    super.dispose();
  }

  // Re-added _showLogoutDialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogoutConfirmationDialog(
        onCancel: () => Navigator.of(context).pop(),
        onLogout: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginApp()),
                (Route<dynamic> route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged out successfully!')),
          );
        },
      ),
    );
  }

  // Re-added showComplaintDialog
  void showComplaintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 328,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xffEB7720),
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
                        RatingBar.builder(
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
                              _rating = rating.toInt();
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
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_reviewController.text.length}/$maxChars',
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
                          Navigator.pop(context);
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
                                      onPressed: () => Navigator.pop(context),
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
      drawer: Drawer( // Original Drawer implementation
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildMenuItem(Icons.person_outline, "My Account"),
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
      appBar: CustomAppBar( // Use the CustomAppBar widget
        title: "My Orders",
        showBackButton: true, // Show back button as per original AppBar
        showMenuButton: false, // Do not show menu button
        scaffoldKey: _scaffoldKey, // Pass the scaffold key
        isMyOrderActive: true, // Highlight My Orders icon
        isWishlistActive: false,
        isNotiActive: false,
        // showWhatsAppIcon is false by default in CustomAppBar, matching original
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

            return Column( // Wrap TabBar and TabBarView in a Column
              children: [
                Material( // Wrap TabBar in Material to give it a background color
                  color: const Color(0xffEB7720), // Background color for TabBar
                  child: TabBar(
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
                Expanded( // TabBarView should take the remaining space
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(bookedOrders, orderModel),
                      _buildOrderList(dispatchedOrders, orderModel),
                      _buildOrderList(deliveredOrders, orderModel),
                      _buildOrderList(cancelledOrders, orderModel),
                    ],
                  ),
                ),
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
                    color: Colors.grey,

                  )
                  ,
                ),
              ])
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

  // Re-added _buildHeader
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

  // Re-added _buildMenuItem
  Widget _buildMenuItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        height: 40,
        decoration: const BoxDecoration(color: Color(0xffffecdc)),
        // ignore: prefer_const_constructors
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
            Navigator.pop(context);
            switch (label) {
              case 'My Account':
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAccountPage()));
                break;
              case 'Transaction History':
                Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionHistoryPage()));
                break;
              case 'Ask Us!':
                Navigator.push(context, MaterialPageRoute(builder: (context) => AskUsPage()));
                break;
              case 'Rate Us':
                showComplaintDialog(context);
                break;
              case 'Settings':
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
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
  final OrderModel orderModel;

  const OrderCard({Key? key, required this.order, required this.orderModel}) : super(key: key);

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  @override
  Widget build(BuildContext context) {
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
      default: // Added default case to ensure statusColor is always initialized
        statusColor = Colors.grey;
        break;
    }

    // Determine button visibility based on order status
    bool showCancelButton = (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed);
    bool showModifyOrderButton = (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed);
    bool showTrackOrderButton = (order.status == OrderStatus.dispatched); // Only for dispatched
    bool showRateProductButton = order.status == OrderStatus.delivered;
    bool showInvoiceButton = (order.status == OrderStatus.delivered); // Only for delivered orders
    bool showBrowseMoreButton = order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled;


    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      // MODIFIED: Darker background tile color
      color: Colors.orange.shade100.withOpacity(0.5), // Changed from shade50.withOpacity(0.3)
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
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Conditionally display the status box based on order status
                // This is a single widget (Container) so it can be directly in the Row's children list.
                if (!(order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed || order.status == OrderStatus.cancelled))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
                      style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order Date: ${DateFormat('dd MMMyyyy, hh:mm a').format(order.orderDate)}',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            // This is a single widget (Padding) so it can be directly in the Column's children list.
            if (order.status == OrderStatus.delivered && order.deliveredDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Delivered On: ${DateFormat('dd MMMyyyy').format(order.deliveredDate!)}',
                  style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ),
            const Divider(height: 20, thickness: 1),
            // The entire ListView.builder for products is now wrapped in a GestureDetector
            // to navigate to MultiProductOrderDetailPage for the whole order.
            // This is a single widget (GestureDetector) so it can be directly in the Column's children list.
            GestureDetector(
              onTap: () {
                // Navigate to MultiProductOrderDetailPage with the entire order object
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiProductOrderDetailPage(order: order),
                  ),
                );
              },
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.products.length,
                itemBuilder: (context, idx) {
                  final orderedProduct = order.products[idx];
                  // No need to convert to Product here as we are navigating to MultiProductOrderDetailPage
                  // which expects the Order object.
                  return Padding(
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
                            image: _isValidUrl(orderedProduct.imageUrl)
                                ? DecorationImage(
                              image: NetworkImage(orderedProduct.imageUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stacktrace) {
                                debugPrint("Error loading image: ${orderedProduct.imageUrl}");
                              },
                            )
                                : DecorationImage(
                              image: AssetImage(orderedProduct.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _isValidUrl(orderedProduct.imageUrl)
                              ? null
                              : (orderedProduct.imageUrl.isEmpty
                              ? Center(child: Icon(Icons.broken_image, color: Colors.grey[400]))
                              : null),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderedProduct.title,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                orderedProduct.description,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${orderedProduct.unit} x ${orderedProduct.quantity}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              Text(
                                '₹${orderedProduct.price.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, color: const Color(0xffEB7720)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
                      fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xffEB7720)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Row for Cancel and Modify (only for booked/pending/confirmed)
            // This entire block is conditionally rendered by the outer 'if'
            // The Column widget ensures that both the Row and the SizedBox are treated as a single child
            // within the parent Column's children list.
            if (showCancelButton || showModifyOrderButton)
              Column(
                children: [
                  Row(
                    children: [
                      if (showCancelButton)
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CancellationStep1Page(orderId: order.id)),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                // MODIFIED: Darker red color for outline
                                side: const BorderSide(color: Color(0xFFC62828)), // Darker red
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
                              label: Text(
                                'Cancel Order',
                                style: GoogleFonts.poppins(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      // Conditional spacing between buttons
                      if (showCancelButton && showModifyOrderButton)
                        const SizedBox(width: 12),
                      if (showModifyOrderButton)
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            // MODIFIED: Changed to ElevatedButton for filled highlight
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // MODIFIED: Call the new method to ADD products to cart
                                Provider.of<CartModel>(context, listen: false).addProductsToCartFromOrder(order.products);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Cart()),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Order ${order.id} loaded to cart for modification!', style: GoogleFonts.poppins())),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                // MODIFIED: Darker orange color for fill
                                backgroundColor: const Color(0xFFE65100), // Darker orange
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              icon: const Icon(Icons.edit, color: Colors.white, size: 16), // Icon color to white for better contrast
                              label: Text(
                                'Modify Order',
                                style: GoogleFonts.poppins(color: Colors.white), // Text color to white for better contrast
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Conditional spacing after this row of buttons, if other button rows follow
                  if (showTrackOrderButton || showRateProductButton || showBrowseMoreButton)
                    const SizedBox(height: 12),
                ],
              ),

            // Row for Track Order (only for dispatched)
            // This entire block is conditionally rendered by the outer 'if'
            // The Column widget ensures that both the Row and the SizedBox are treated as a single child
            // within the parent Column's children list.
            if (showTrackOrderButton)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tracking order ${order.id}!', style: GoogleFonts.poppins())),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DispatchedOrdersScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              // MODIFIED: Darker orange color for outline
                              side: const BorderSide(color: Color(0xFFE65100)), // Darker orange
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            icon: const Icon(Icons.delivery_dining, color: Color(0xffEB7720), size: 16),
                            label: Text(
                              'Track Order',
                              style: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Conditional spacing after this row of buttons, if other button rows follow
                  if (showRateProductButton || showBrowseMoreButton)
                    const SizedBox(height: 12),
                ],
              ),


            // Row for Rate Product and Browse More / Invoice (for delivered and cancelled)
            // This entire block is conditionally rendered by the outer 'if'
            // The Column widget ensures that the Row is treated as a single child
            // within the parent Column's children list.
            if (showRateProductButton || showBrowseMoreButton)
              Column(
                children: [
                  Row(
                    children: [
                      if (showInvoiceButton) // Only show Invoice button for delivered orders
                        SizedBox(
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Generating invoice for order ${order.id}!', style: GoogleFonts.poppins())),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              // MODIFIED: Darker orange color for outline
                              side: const BorderSide(color: Color(0xFFE65100)), // Darker orange
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            icon: const Icon(Icons.file_download_sharp, color: Color(0xffEB7720), size: 16),
                            label: Text(
                              'Invoice',
                              style: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                            ),
                          ),
                        ),
                      // Conditional spacing between buttons
                      if (showInvoiceButton && showBrowseMoreButton)
                        const SizedBox(width: 12),
                      if (showRateProductButton)
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Rating product for order ${order.id}!', style: GoogleFonts.poppins())),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                // MODIFIED: Darker orange color for fill
                                backgroundColor: const Color(0xFFE65100), // Darker orange
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              icon: const Icon(Icons.star, color: Colors.white, size: 16),
                              label: Text(
                                'Rate Product',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      // Conditional spacing between buttons
                      if (showRateProductButton && showBrowseMoreButton && order.status != OrderStatus.cancelled)
                        const SizedBox(width: 12),
                      if (showBrowseMoreButton) // Only show "Browse More" if needed for delivered or cancelled
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to TrendingProductsScreen on homepage.dart
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const TrendingProductsScreen()),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Browsing more products!', style: GoogleFonts.poppins())),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                // MODIFIED: Darker orange color for fill
                                backgroundColor: const Color(0xFFE65100), // Darker orange
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
