import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const kBgColor      = Color(0xFFF5F5F5);
  static const kCardColor    = Color(0xFFFFFFFF);
  static const kTextDark     = Color(0xFF1A1A2E);
  static const kTextGray     = Color(0xFF8E8E93);
  static const kBorderColor  = Color(0xFFE8E8E8);
  static const kPrimary      = Color(0xFF4C9BE8);
  static const kSuccessColor = Color(0xFF25D366);
  static const kErrorColor   = Color(0xFFE85D75);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'SF Pro Display',
    scaffoldBackgroundColor: kBgColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: kTextDark),
    ),
  );
}