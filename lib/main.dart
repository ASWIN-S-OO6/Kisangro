import 'package:flutter/material.dart';
import 'package:kisangro/login/splashscreen.dart';
import 'package:kisangro/models/address_model.dart';
import 'package:provider/provider.dart';
import 'package:kisangro/home/bottom.dart'; // Assuming this is your main navigation after splash
import 'package:kisangro/models/cart_model.dart';
import 'package:kisangro/models/wishlist_model.dart';
import 'package:kisangro/models/order_model.dart';
import 'package:kisangro/models/kyc_image_provider.dart';
import 'package:kisangro/services/product_service.dart'; // Import ProductService
import 'package:kisangro/models/kyc_business_model.dart';
import 'package:kisangro/models/license_provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for GoogleFonts

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load product and category data from the API service before the app starts
  try {
    // Load categories first, as product data might depend on them for classification
    await ProductService.loadCategoriesFromApi();
    debugPrint('Category data loaded successfully.');

    // Then load all products (general + all categories for global search)
    await ProductService.loadProductsFromApi();
    debugPrint('Product data loaded successfully.');
  } catch (e) {
    debugPrint('Failed to load initial data: $e');
    // In a production app, you might want a more user-friendly error display or retry mechanism.
    // For now, it will just print to debug console.
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => WishlistModel()),
        ChangeNotifierProvider(create: (context) => OrderModel()),
        ChangeNotifierProvider(create: (context) => KycImageProvider()),
        ChangeNotifierProvider(create: (context) => AddressModel()),
        ChangeNotifierProvider(create: (context) => LicenseProvider()),
        ChangeNotifierProvider(create: (context) => KycBusinessDataProvider()),
        // No global provider for Product model itself, as individual products are ChangeNotifiers
        // and usually managed within lists or passed directly to detail screens.
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
        // Apply Poppins font family globally for consistent typography
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const splashscreen(), // Your main navigation widget (start with splash screen)
      debugShowCheckedModeBanner: false, // Hide the debug banner in UI
    );
  }
}
