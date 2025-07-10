import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/models/product_model.dart'; // Ensure Product model is imported


import 'orders_product_detail_page.dart'; // Import the new OrdersProductDetailPage

class MultiProductOrderDetailPage extends StatelessWidget {
  final Order order;

  const MultiProductOrderDetailPage({Key? key, required this.order}) : super(key: key);

  // Helper to check if the image URL is valid (not an asset path or empty)
  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }
    return Uri.tryParse(url)?.isAbsolute == true && !url.endsWith('erp/api/');
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy h:mm a');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title: Text(
          "Order Details (ID: ${order.id})",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFD9BD), Color(0xffFFFFFF)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Summary', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xffEB7720))),
                    const Divider(),
                    _buildDetailRow('Order ID:', order.id),
                    _buildDetailRow('Order Date:', dateFormat.format(order.orderDate)),
                    _buildDetailRow('Total Amount:', '₹${order.totalAmount.toStringAsFixed(2)}'),
                    _buildDetailRow('Status:', order.status.name.toUpperCase()),
                    if (order.deliveredDate != null)
                      _buildDetailRow('Delivered On:', dateFormat.format(order.deliveredDate!)),
                  ],
                ),
              ),
            ),
            Text('Products in this Order', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            ...order.products.map((orderedProduct) {
              // Convert OrderedProduct to Product for OrdersProductDetailPage
              final productForDetailPage = Product(
                id: orderedProduct.id,
                title: orderedProduct.title,
                subtitle: orderedProduct.description,
                imageUrl: orderedProduct.imageUrl,
                category: orderedProduct.category,
                // For availableSizes, create a list with just the ordered unit/price
                availableSizes: [
                  ProductSize(
                    size: orderedProduct.unit,
                    price: orderedProduct.price,
                  ),
                ],
                selectedUnit: orderedProduct.unit, // Set the selected unit to the ordered unit
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrdersProductDetailPage(product: productForDetailPage),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orderedProduct.title,
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                orderedProduct.description,
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unit: ${orderedProduct.unit}',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                              Text(
                                'Price: ₹${orderedProduct.price.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xffEB7720)),
                              ),
                              Text(
                                'Quantity: ${orderedProduct.quantity}',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
