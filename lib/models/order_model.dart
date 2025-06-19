import 'package:flutter/material.dart';
import 'product_model.dart'; // Import Product and ProductSize

// Enum to define the possible statuses of an order
enum OrderStatus {
  pending, // Order is placed but not yet confirmed/processed (e.g., awaiting payment)
  booked, // Order is confirmed/accepted (e.g., payment successful)
  dispatched,
  delivered,
  cancelled,
  confirmed, // This could represent a final "success" state for payment, often followed by "booked"
}

// Represents a single product as part of an order.
// This is similar to Product but captures the state at the time of order,
// including the quantity that was ordered.
class OrderedProduct {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String selectedUnit;
  final double pricePerUnit; // Price at the time of order for the selected unit
  final int quantity;
  final String category; // Added category to OrderedProduct

  OrderedProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.selectedUnit,
    required this.pricePerUnit,
    required this.quantity,
    required this.category,
  });

  // Factory constructor to create an OrderedProduct from a Product and a quantity
  factory OrderedProduct.fromProduct(Product product, int quantity) {
    return OrderedProduct(
      id: product.id,
      title: product.title,
      subtitle: product.subtitle,
      imageUrl: product.imageUrl,
      selectedUnit: product.selectedUnit,
      // Safely get price, defaulting to 0.0 if pricePerSelectedUnit is null
      pricePerUnit: product.pricePerSelectedUnit ?? 0.0,
      quantity: quantity,
      category: product.category,
    );
  }
}

// Order class to represent a single order made by a user.
class Order extends ChangeNotifier {
  final String id; // Unique order ID
  final List<OrderedProduct> products;
  final double totalAmount;
  final DateTime orderDate;
  OrderStatus _status; // Use a private variable for status to allow internal modification
  DateTime? deliveredDate; // New field for delivered date

  Order({
    required this.id,
    required this.products,
    required this.totalAmount,
    required this.orderDate,
    this.deliveredDate,
    OrderStatus status = OrderStatus.pending, // Default status is pending
  }) : _status = status;

  OrderStatus get status => _status;

  set status(OrderStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners(); // Notify UI if status changes
    }
  }

  // Method to update the status of the order (can be called internally or externally)
  void updateStatus(OrderStatus newStatus) {
    status = newStatus; // Use the setter to trigger notification
    if (newStatus == OrderStatus.delivered) {
      deliveredDate = DateTime.now(); // Set delivered date when status becomes delivered
    }
  }
}

// OrderModel to manage a list of orders (using Provider)
class OrderModel extends ChangeNotifier {
  final List<Order> _orders = []; // Private list of orders

  List<Order> get orders => _orders; // Getter to access orders

  // Adds a new order to the list
  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners(); // Notify UI to rebuild
  }

  // Updates the status of an existing order
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex].status = newStatus; // Directly update status
      if (newStatus == OrderStatus.delivered) {
        _orders[orderIndex].deliveredDate = DateTime.now();
      }
      notifyListeners(); // Notify UI to rebuild
    }
  }

  // Example: Mark all 'booked' orders as 'dispatched' (for simulation)
  void dispatchAllBookedOrders() {
    for (var order in _orders) {
      if (order.status == OrderStatus.booked) {
        order.updateStatus(OrderStatus.dispatched);
      }
    }
    notifyListeners();
  }

  // Example: Mark a specific order as delivered (for simulation)
  void deliverOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.delivered);
  }

  // Example: Cancel a specific order (for simulation)
  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  // Clears all orders (for testing or logout)
  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
