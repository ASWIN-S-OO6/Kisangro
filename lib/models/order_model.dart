import 'package:flutter/foundation.dart';
import 'package:kisangro/models/product_model.dart';
import 'database_helper.dart';
enum OrderStatus {
  pending,
  booked,
  dispatched,
  delivered,
  cancelled,
  confirmed,
}

class OrderedProduct {
  final String id;
  final String title;
  final String description; // Maps to CartItem.subtitle
  final String imageUrl;
  final String category;
  final String unit; // Maps to CartItem.selectedUnit
  final double price; // Maps to CartItem.pricePerUnit
  final int quantity;
  final String orderId;

  OrderedProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.orderId,
  });

  factory OrderedProduct.fromProduct(Product product, int quantity, String orderId) {
    return OrderedProduct(
      id: product.id,
      title: product.title,
      description: product.subtitle,
      imageUrl: product.imageUrl,
      category: product.category,
      unit: product.selectedUnit,
      price: product.pricePerSelectedUnit ?? 0.0,
      quantity: quantity,
      orderId: orderId,
    );
  }
}

class Order {
  final String id;
  final List<OrderedProduct> products;
  final double totalAmount;
  final DateTime orderDate;
  OrderStatus status;
  DateTime? deliveredDate;
  final String paymentMethod;

  Order({
    required this.id,
    required this.products,
    required this.totalAmount,
    required this.orderDate,
    this.deliveredDate,
    required this.status,
    required this.paymentMethod,
  });

  void updateStatus(OrderStatus newStatus) {
    if (status != newStatus) {
      status = newStatus;
      if (newStatus == OrderStatus.delivered) {
        deliveredDate = DateTime.now();
      }
    }
  }
}

class OrderModel extends ChangeNotifier {
  final List<Order> _orders = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Order> get orders => List.unmodifiable(_orders);

  OrderModel() {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      _orders.clear();
      _orders.addAll(await _dbHelper.getOrders());
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  void addOrder(Order order) {
    _orders.add(order);
    _dbHelper.insertOrder(order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex].updateStatus(newStatus);
      _dbHelper.updateOrderStatus(orderId, newStatus);
      notifyListeners();
    }
  }

  void dispatchAllBookedOrders() {
    for (var order in _orders) {
      if (order.status == OrderStatus.booked) {
        order.updateStatus(OrderStatus.dispatched);
        _dbHelper.updateOrderStatus(order.id, OrderStatus.dispatched);
      }
    }
    notifyListeners();
  }

  void deliverOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.delivered);
  }

  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  void clearOrders() {
    _orders.clear();
    _dbHelper.clearOrders();
    notifyListeners();
  }
}