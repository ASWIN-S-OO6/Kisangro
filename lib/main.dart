import 'package:flutter/material.dart';
import 'package:kisangro/login/splashscreen.dart';
import 'package:kisangro/models/address_model.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/home/bottom.dart'; // Assuming 'Bot' is your entry point with the bottom navigation
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/models/kyc_image_provider.dart';
import 'package:kisangro/services/product_service.dart'; // ProductService for data loading
import 'package:kisangro/models/kyc_business_model.dart';
import 'package:kisangro/models/license_provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for GoogleFonts

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load product data from the API service before the app starts
  try {
    await ProductService.loadProductsFromApi();
    debugPrint('Product data loaded successfully.');
  } catch (e) {
    debugPrint('Failed to load product data: $e');
    // Handle error, e.g., show an error screen or a retry button
    // In a production app, you might want a more user-friendly error display or retry mechanism.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => WishlistModel()),
        ChangeNotifierProvider(create: (context) => OrderModel()),
        ChangeNotifierProvider(create: (context) => KycImageProvider()),
        ChangeNotifierProvider(create: (context) => AddressModel()),
        ChangeNotifierProvider(create: (context) => LicenseProvider()), // Using (context) => to be consistent
        ChangeNotifierProvider(create: (context) => KycBusinessDataProvider()), // Using (context) => to be consistent
        // Note on Product model: If 'Product' itself is a ChangeNotifier and you need to listen
        // to changes on individual product instances globally, you might provide it here.
        // However, typically individual Product instances are passed down or managed by lists,
        // and only the list provider (e.g., ProductService) is global.
        // Based on your ProductDetailPage, it receives a 'Product' object directly,
        // so a global provider for 'Product' itself is generally not needed.
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
        // Apply Poppins font family globally
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: splashscreen(), // Your main navigation widget
      debugShowCheckedModeBanner: false, // Recommended to hide debug banner for cleaner UI
    );
  }
}
