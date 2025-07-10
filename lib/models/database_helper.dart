import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/models/cart_model.dart'; // NEW: Import CartModel for CartItem

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kisangro_app.db'); // Changed database name to be more general
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Create orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        orderDate INTEGER NOT NULL,
        deliveredDate INTEGER,
        status TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        paymentMethod TEXT NOT NULL
      )
    ''');

    // Create ordered_products table
    await db.execute('''
      CREATE TABLE ordered_products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId TEXT NOT NULL,
        productId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        category TEXT NOT NULL,
        unit TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

    // NEW: Create cart_items table for persistence
    await db.execute('''
      CREATE TABLE cart_items (
        id TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        category TEXT NOT NULL,
        selectedUnit TEXT NOT NULL,
        pricePerUnit REAL NOT NULL,
        quantity INTEGER NOT NULL,
        PRIMARY KEY (id, selectedUnit) -- Composite primary key to ensure uniqueness for product-unit combination
      )
    ''');
  }

  Future<void> insertOrder(Order order) async {
    final db = await database;
    await db.insert(
      'orders',
      {
        'id': order.id,
        'orderDate': order.orderDate.millisecondsSinceEpoch,
        'deliveredDate': order.deliveredDate?.millisecondsSinceEpoch,
        'status': order.status.name,
        'totalAmount': order.totalAmount,
        'paymentMethod': order.paymentMethod,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for (var product in order.products) {
      await db.insert(
        'ordered_products',
        {
          'orderId': order.id,
          'productId': product.id,
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'category': product.category,
          'unit': product.unit,
          'price': product.price,
          'quantity': product.quantity,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final orderMaps = await db.query('orders');
    List<Order> orders = [];

    for (var orderMap in orderMaps) {
      final productMaps = await db.query(
        'ordered_products',
        where: 'orderId = ?',
        whereArgs: [orderMap['id']],
      );
      List<OrderedProduct> products = productMaps.map((p) => OrderedProduct(
        id: p['productId'] as String,
        title: p['title'] as String,
        description: p['description'] as String,
        imageUrl: p['imageUrl'] as String,
        category: p['category'] as String,
        unit: p['unit'] as String,
        price: p['price'] as double,
        quantity: p['quantity'] as int,
        orderId: p['orderId'] as String,
      )).toList();

      // CORRECTED: Pass the 'products' list to the Order constructor
      orders.add(Order(
        id: orderMap['id'] as String,
        products: products, // This was the missing argument
        orderDate: DateTime.fromMillisecondsSinceEpoch(orderMap['orderDate'] as int),
        deliveredDate: orderMap['deliveredDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(orderMap['deliveredDate'] as int)
            : null,
        status: OrderStatus.values.firstWhere((e) => e.name == orderMap['status']),
        totalAmount: orderMap['totalAmount'] as double,
        paymentMethod: orderMap['paymentMethod'] as String,
      ));
    }
    return orders;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final db = await database;
    await db.update(
      'orders',
      {
        'status': status.name,
        'deliveredDate': status == OrderStatus.delivered ? DateTime.now().millisecondsSinceEpoch : null,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> clearOrders() async {
    final db = await database;
    await db.delete('orders');
    await db.delete('ordered_products');
  }

  // Cart Item Database Operations

  Future<void> insertCartItem(CartItem item) async {
    final db = await database;
    await db.insert(
      'cart_items',
      {
        'id': item.id,
        'title': item.title,
        'subtitle': item.subtitle,
        'imageUrl': item.imageUrl,
        'category': item.category,
        'selectedUnit': item.selectedUnit,
        'pricePerUnit': item.pricePerUnit,
        'quantity': item.quantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if item with same ID and unit exists
    );
  }

  Future<void> updateCartItemQuantity(String id, String selectedUnit, int newQuantity) async {
    final db = await database;
    await db.update(
      'cart_items',
      {'quantity': newQuantity},
      where: 'id = ? AND selectedUnit = ?',
      whereArgs: [id, selectedUnit],
    );
  }

  Future<void> removeCartItem(String id, String selectedUnit) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'id = ? AND selectedUnit = ?',
      whereArgs: [id, selectedUnit],
    );
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart_items');

    return List.generate(maps.length, (i) {
      return CartItem(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
        subtitle: maps[i]['subtitle'] as String,
        imageUrl: maps[i]['imageUrl'] as String,
        category: maps[i]['category'] as String,
        selectedUnit: maps[i]['selectedUnit'] as String,
        pricePerUnit: maps[i]['pricePerUnit'] as double,
        quantity: maps[i]['quantity'] as int,
      );
    });
  }

  Future<void> clearCartItems() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<void> close() async {
    final db = await database;
    _database = null; // Reset _database to null for proper re-initialization if needed
    await db.close();
  }
}
