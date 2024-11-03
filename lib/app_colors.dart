import 'package:flutter/material.dart';

class AppColors {
  static const MaterialColor primaryColor = MaterialColor(
    0xFF2196F3,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  static const Color shadowColor = Colors.black;
  static const Color greyTextColor = Color.fromARGB(255, 48, 48, 48);
  static const Color appBarColor = Colors.white;
  static const Color scaffoldBackgroundColor = Colors.white;
  static const Color secondaryBackgroundColor =
      Color.fromARGB(255, 221, 221, 221);
  static const Color drawerBackgroundColor = Color(0xFFEFEFEF);
  static const Color drawerHeaderColor = Color(0xFF2196F3);
  static const Color lightOrangeSplashColor = Color.fromARGB(255, 255, 202, 86);
  static const Color orangeSelectionColor = Color.fromARGB(255, 253, 179, 19);
}
