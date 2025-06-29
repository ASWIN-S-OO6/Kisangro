import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:kisangro/home/bottom.dart';
import 'package:kisangro/home/product.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:kisangro/home/cancel1.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/home/cart.dart';
import 'package:kisangro/home/multi_product_order_detail_page.dart';
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
import 'dispatched_orders_screen.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _rating = 4;
  final TextEditingController _reviewController = TextEditingController();
  static const int maxChars = 100;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      drawer: Drawer(
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
                context, MaterialPageRoute(builder: (context) => const Bot(initialIndex: 0)));
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              'assets/box.png',
              height: 28,
              width: 28,
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
              height: 26,
              width: 26,
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
              height: 28,
              width: 28,
              color: Colors.white,
            ),
          ),
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
    }

    bool showCancelButton = (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed);
    bool showTrackOrderButton = (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed || order.status == OrderStatus.dispatched);
    bool showBrowseMoreButton = order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled;
    bool showRateProductButton = order.status == OrderStatus.delivered;
    bool showModifyOrderButton = (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
              'Order Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate)}',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            if (order.status == OrderStatus.delivered && order.deliveredDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Delivered On: ${DateFormat('dd MMM yyyy').format(order.deliveredDate!)}',
                  style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ),
            const Divider(height: 20, thickness: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.products.length,
              itemBuilder: (context, idx) {
                final product = order.products[idx];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiProductOrderDetailPage(order: order),
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
                                debugPrint("Error loading image: ${product.imageUrl}");
                              },
                            )
                                : DecorationImage(
                              image: AssetImage(product.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: _isValidUrl(product.imageUrl)
                              ? null
                              : (product.imageUrl.isEmpty
                              ? Center(child: Icon(Icons.broken_image, color: Colors.grey[400]))
                              : null),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                product.description,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${product.unit} x ${product.quantity}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, color: const Color(0xffEB7720)),
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
                      fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xffEB7720)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (showTrackOrderButton)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (order.status == OrderStatus.booked || order.status == OrderStatus.pending || order.status == OrderStatus.confirmed) {
                            orderModel.updateOrderStatus(order.id, OrderStatus.dispatched);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Order ${order.id} dispatched!', style: GoogleFonts.poppins())),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tracking order ${order.id}!', style: GoogleFonts.poppins())),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DispatchedOrdersScreen()),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xffEB7720)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        icon: const Icon(Icons.delivery_dining, color: Color(0xffEB7720), size: 16),
                        label: Text(
                          order.status == OrderStatus.dispatched
                              ? 'Track Order'
                              : (order.status == OrderStatus.delivered ? 'View Details' : 'Dispatch Now (Demo)'),
                          style: GoogleFonts.poppins(color: const Color(0xffEB7720)),
                        ),
                      ),
                    ),
                  ),
                if (showTrackOrderButton && showCancelButton)
                  const SizedBox(width: 12),
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
                          side: const BorderSide(color: Colors.red),
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
              ],
            ),
            if (showRateProductButton || showBrowseMoreButton || showModifyOrderButton)
              const SizedBox(height: 12),
            Row(
              children: [
                if (showModifyOrderButton)
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Provider.of<CartModel>(context, listen: false).populateCartFromOrder(order.products);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Cart()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order ${order.id} loaded to cart for modification!', style: GoogleFonts.poppins())),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xffEB7720)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
                          backgroundColor: const Color(0xffEB7720),
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
              ],
            ),
            if (showBrowseMoreButton && showRateProductButton)
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Generating invoice for order ${order.id}!', style: GoogleFonts.poppins())),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xffEB7720)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Browsing more products!', style: GoogleFonts.poppins())),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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