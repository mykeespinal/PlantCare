import 'package:flutter/material.dart';

const forestGreen = Color(0xFF245B45);
const leafGreen = Color(0xFF6D9B72);
const cream = Color(0xFFF7F7F0);
const sageGreen = Color(0xFFE7F0E5);
const warmSand = Color(0xFFF1E8D5);

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: forestGreen,
    primary: forestGreen,
    secondary: leafGreen,
    surface: Colors.white,
  ),
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: cream,
  appBarTheme: const AppBarTheme(
    backgroundColor: cream,
    foregroundColor: forestGreen,
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      color: forestGreen,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: sageGreen,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final selected = states.contains(WidgetState.selected);
      return TextStyle(
        color: selected ? forestGreen : const Color(0xFF65736A),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      );
    }),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE6EAE3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: forestGreen, width: 1.5),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: forestGreen,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: forestGreen,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: const BorderSide(color: leafGreen),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
);
