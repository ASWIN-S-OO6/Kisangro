import 'package:flutter/material.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/home/cart.dart';
import 'package:intl/intl.dart';

// Import CustomAppBar

// Import Bot for navigation (for back button functionality)
import 'package:kisangro/home/bottom.dart';

import '../common/common_app_bar.dart';


class TransactionHistoryPage extends StatefulWidget {
  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int entries = 0; // 0 means no limit (show all)
  String history = 'All'; // Default to show all transactions
  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderModel = Provider.of<OrderModel>(context, listen: false);
      setState(() {
        // Initialize expanded list to match the number of *all* orders initially
        // This ensures the index is valid when filtering later.
        expanded = List<bool>.filled(orderModel.orders.length, false);
      });
    });
  }

  List<Order> _filterOrders(List<Order> orders, String history, int entries) {
    List<Order> filtered = orders
        .where((order) => order.status == OrderStatus.confirmed) // Keep confirmed status filter
        .toList()
        .reversed
        .toList();

    // Apply time-based filter only if history is not 'All'
    if (history != 'All') {
      final now = DateTime.now();
      DateTime startDate;
      switch (history) {
        case '1 week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case '1 month':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case '3 months':
          startDate = now.subtract(const Duration(days: 90));
          break;
        default:
          startDate = now.subtract(const Duration(days: 365 * 100)); // Arbitrary large range for 'All'
      }
      filtered = filtered
          .where((order) => order.orderDate.isAfter(startDate))
          .toList();
    }

    // Apply entries limit only if entries is not 0
    if (entries > 0) {
      filtered = filtered.take(entries).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final orderModel = Provider.of<OrderModel>(context);
    final filteredOrders = _filterOrders(orderModel.orders, history, entries);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: CustomAppBar( // Integrated CustomAppBar
        title: "Transaction History", // Set the title
        showBackButton: true, // Show back button
        showMenuButton: false, // Do NOT show menu button (drawer icon)
        // scaffoldKey is not needed here as there's no drawer
        isMyOrderActive: false, // Not active
        isWishlistActive: false, // Not active
        isNotiActive: false, // Not active
        // showWhatsAppIcon is false by default, matching original behavior
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
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Text('Entries:',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: DropdownButton<int>(
                      value: entries == 0 ? null : entries,
                      underline: const SizedBox(),
                      hint: Text('All', style: GoogleFonts.poppins()),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                      items: [0, 10, 20, 50, 100]
                          .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e == 0 ? 'All' : '$e')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => entries = val);
                        }
                      },
                    ),
                  ),
                  const Spacer(),
                  Text('History:',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: DropdownButton<String>(
                      value: history,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                      items: ['All', '1 week', '1 month', '3 months']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => history = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredOrders.isEmpty
                    ? Center(
                  child: Text(
                    'No transactions found',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    // Ensure the expanded list has enough elements
                    if (expanded.length <= index) {
                      expanded = List.from(expanded)..length = index + 1;
                      expanded[index] = false; // Default to not expanded
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _transactionCard(
                        avatarLetter: order.products.isNotEmpty
                            ? order.products[0].title[0]
                            : 'K',
                        title: order.products.length == 1
                            ? 'To Kisangro Product'
                            : 'To Kisangro Products',
                        subtitle: order.products.length == 1
                            ? 'Order: ${order.products[0].title}'
                            : 'Order: Multiple Items',
                        amount:
                        '₹ ${order.totalAmount.toStringAsFixed(2)}',
                        paymentMethod: order.paymentMethod,
                        dateTime: DateFormat('dd/MM/yyyy hh:mm a')
                            .format(order.orderDate),
                        expanded: expanded[index],
                        onToggleExpanded: () {
                          setState(() {
                            expanded[index] = !expanded[index];
                          });
                        },
                        invoiceCallback: () {
                          // Invoice action
                        },
                        reorderCallback: () {
                          final cartModel =
                          Provider.of<CartModel>(context, listen: false);
                          // MODIFIED: Use addProductsToCartFromOrder instead of populateCartFromOrder
                          cartModel.addProductsToCartFromOrder(order.products);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Order added to cart for reordering!',
                                  style: GoogleFonts.poppins()),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Cart()));
                        },
                        detailsWidget: order.products.length == 1
                            ? _productDetailsWidget(order.products[0])
                            : _multipleItemsDetailsWidget(order),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionCard({
    required String avatarLetter,
    required String title,
    required String subtitle,
    required String amount,
    required String paymentMethod,
    required String dateTime,
    required bool expanded,
    required VoidCallback onToggleExpanded,
    required VoidCallback invoiceCallback,
    required VoidCallback reorderCallback,
    Widget? detailsWidget,
  }) {
    String paymentImage;
    switch (paymentMethod) {
      case 'Google Pay':
        paymentImage = 'assets/gpay.png';
        break;
      case 'Phone Pe':
        paymentImage = 'assets/phonepay.png';
        break;
      case 'Paytm':
        paymentImage = 'assets/paytm.png';
        break;
      case 'Amazon Pay':
        paymentImage = 'assets/amzpay.png';
        break;
      case 'Apple Pay':
        paymentImage = 'assets/applepay.png';
        break;
      case 'Debit/Credit Card':
        paymentImage = 'assets/debit.png';
        break;
      case 'Net Banking':
        paymentImage = 'assets/netbanking.png';
        break;
      default:
        paymentImage = 'assets/gpay.png';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  avatarLetter,
                  style: GoogleFonts.poppins(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                          color: const Color(0xffEB7720),
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Paid using: ',
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade700)),
                        Image(image: AssetImage(paymentImage), width: 30),
                        const SizedBox(width: 4),
                        Text(paymentMethod,
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color(0xffEB7720)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: invoiceCallback,
                icon: const Icon(Icons.download, size: 16, color: Colors.white),
                label: Text(
                  'Invoice',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  backgroundColor: const Color(0xffEB7720),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                ),
              ),
              const Spacer(),
              Text(
                dateTime,
                style:
                GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(width: 8),
              if (detailsWidget != null)
                GestureDetector(
                  onTap: onToggleExpanded,
                  child: Text(
                    expanded ? 'Hide Details ▲' : 'Show Details ▼',
                    style: GoogleFonts.poppins(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          if (expanded && detailsWidget != null) ...[
            const SizedBox(height: 12),
            detailsWidget,
          ],
          // Re-order button for single product details
          if (expanded && detailsWidget is Widget && (detailsWidget as dynamic).runtimeType.toString() == '_ProductDetailsWidget') // Check if it's the single product details widget
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: reorderCallback, // Use the reorderCallback provided
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffEB7720),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(
                  'Re-order',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _productDetailsWidget(OrderedProduct product) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100, // Adjusted width for better fit
              height: 100, // Adjusted height for better fit
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white),
                color: Colors.grey.shade100,
              ),
              child: product.imageUrl.startsWith('http')
                  ? Image.network(product.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/placeholder.png', fit: BoxFit.cover))
                  : Image.asset(product.imageUrl, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(product.description,
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade700, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Unit Size: ${product.unit}',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('₹ ${product.price.toStringAsFixed(2)}/piece',
                      style: GoogleFonts.poppins(
                          color: const Color(0xffEB7720), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Ordered Units: ${product.quantity}',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('Order ID: ${product.orderId}',
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12), // Spacing before the re-order button
      ],
    );
  }

  Widget _multipleItemsDetailsWidget(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${order.products.length} Items',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(order.products.map((p) => p.title).join(', '),
            style: GoogleFonts.poppins(fontSize: 12)),
        const SizedBox(height: 6),
        Text('Total Cost: ₹ ${order.totalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Order ID: ${order.id}',
            style: GoogleFonts.poppins(fontSize: 12)),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              final cartModel = Provider.of<CartModel>(context, listen: false);
              // MODIFIED: Use addProductsToCartFromOrder instead of populateCartFromOrder
              cartModel.addProductsToCartFromOrder(order.products);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order added to cart for reordering!',
                      style: GoogleFonts.poppins()),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const Cart()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffEB7720),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(
              'Re-order',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
