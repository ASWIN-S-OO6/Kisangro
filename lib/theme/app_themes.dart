import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Define your Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xffEB7720), // Your primary orange color
    hintColor: Colors.blueAccent, // Example accent color
    scaffoldBackgroundColor: const Color(0xFFFFF7F1), // Light background from your homepage
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xffEB7720),
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xffEB7720), // Primary color (your orange)
      onPrimary: Colors.white, // Color for text/icons on primary background
      secondary: Colors.blueAccent, // Secondary color (e.g., for accents)
      onSecondary: Colors.white,
      surface: Colors.white, // Card/container background
      onSurface: Colors.black87, // Text/icons on card/container background
      background: Color(0xFFFFF7F1), // Main screen background (light orange gradient start)
      onBackground: Colors.black87, // Text/icons on main background
      error: Colors.red,
      onError: Colors.white,
      // You can define more specific colors here if needed
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 96, fontWeight: FontWeight.w300, color: Colors.black87),
      displayMedium: GoogleFonts.poppins(fontSize: 60, fontWeight: FontWeight.w400, color: Colors.black87),
      displaySmall: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w400, color: Colors.black87),
      headlineMedium: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w400, color: Colors.black87),
      headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.black87),
      titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87),
      labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
      bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black87),
      labelSmall: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.black87),
    ).apply(
      // Apply default text color for light theme
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      surfaceTintColor: Colors.white, // Ensures cards don't have tinting from primary color
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffEB7720), // Default button background
        foregroundColor: Colors.white, // Default button text color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
      menuStyle: MenuStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        surfaceTintColor: MaterialStateProperty.all(Colors.white),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xffEB7720); // Active color for orange primary
        }
        return Colors.grey; // Inactive color
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xffEB7720).withOpacity(0.5); // Active track color
        }
        return Colors.grey.withOpacity(0.5); // Inactive track color
      }),
    ),
    dividerColor: Colors.grey[300], // Default divider color
  );

  // Define your Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xffEB7720), // Primary orange remains
    hintColor: Colors.cyanAccent, // Example accent color for dark mode
    scaffoldBackgroundColor: Colors.grey[900], // Dark background
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850], // Darker app bar
      foregroundColor: Colors.white,
      titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xffEB7720), // Primary orange remains
      onPrimary: Colors.white, // Text/icons on primary background
      secondary: Colors.cyanAccent, // Secondary color for dark mode
      onSecondary: Colors.black,
      surface: Colors.grey[800]!, // Card/container background in dark mode
      onSurface: Colors.white, // Text/icons on card/container background
      background: Colors.grey[900]!, // Main screen background (dark grey)
      onBackground: Colors.white, // Text/icons on main background
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(fontSize: 96, fontWeight: FontWeight.w300, color: Colors.white70),
      displayMedium: GoogleFonts.poppins(fontSize: 60, fontWeight: FontWeight.w400, color: Colors.white70),
      displaySmall: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w400, color: Colors.white70),
      headlineMedium: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w400, color: Colors.white70),
      headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white70),
      titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
      labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
      labelSmall: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.white70),
    ).apply(
      // Apply default text color for dark theme
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    cardTheme: CardTheme(
      color: Colors.grey[800],
      surfaceTintColor: Colors.grey[800],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xffEB7720), // Default button background
        foregroundColor: Colors.white, // Default button text color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
      menuStyle: MenuStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey[700]),
        surfaceTintColor: MaterialStateProperty.all(Colors.grey[700]),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xffEB7720); // Active color for orange primary
        }
        return Colors.grey[600]; // Inactive color for dark mode
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xffEB7720).withOpacity(0.5); // Active track color
        }
        return Colors.grey[700]; // Inactive track color for dark mode
      }),
    ),
    dividerColor: Colors.grey[700], // Default divider color for dark mode
  );
}
