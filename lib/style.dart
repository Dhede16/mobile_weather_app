import 'package:flutter/material.dart';

final ThemeData orangeWhiteTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFF6F8FA),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.orange,
    primary: Colors.orange,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF2D3748),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFFE0B2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFFE0B2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.orange, width: 2),
    ),
    labelStyle: const TextStyle(color: Colors.orange),
  ),
);
