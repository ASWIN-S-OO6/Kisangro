import 'package:flutter/material.dart';
import 'package:kisangro/login/splashscreen.dart';
import 'package:kisangro/models/address_model.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/home/bottom.dart';
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/models/kyc_image_provider.dart';
import 'package:kisangro/services/product_service.dart';

import 'models/kyc_business_model.dart';
import 'models/license_provider.dart'; // Import your ProductService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load product data from the API service before the app starts
  try {
    await ProductService.loadProductsFromApi();
    debugPrint('Product data loaded successfully.');
  } catch (e) {
    debugPrint('Failed to load product data: $e');
    // Handle error, e.g., show an error screen or a retry button
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => WishlistModel()),
        ChangeNotifierProvider(create: (context) => OrderModel()),
        ChangeNotifierProvider(create: (context) => KycImageProvider()),
        ChangeNotifierProvider(create: (context) => AddressModel()),
        ChangeNotifierProvider(create: (_) => LicenseProvider()),
        ChangeNotifierProvider(create: (context) => KycBusinessDataProvider()),
        // IMPORTANT: Product objects themselves (if you're using them as ChangeNotifier
        // directly in lists and their individual state needs to be reactive like selectedUnit)
        // are often provided at the widget level, not here globally, unless it's a single,
        // globally managed current product. Given your Product model extends ChangeNotifier,
        // ensure individual Product instances are created as ChangeNotifiers where needed
        // (e.g., when pushing to ProductDetailPage).
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kisangro App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: splashscreen(), // Your main navigation widget
      debugShowCheckedModeBanner: false,
    );
  }
}
