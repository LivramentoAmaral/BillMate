import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1E88E5), // Azul
    hintColor: const Color(0xFFFF9800), // Cinza claro
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      displayLarge: TextStyle(color: Colors.black),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E88E5),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF1E88E5), // Azul
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1E88E5),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1E88E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1E88E5)),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1E88E5)),
      ),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF1E88E5),
      onPrimary: Colors.black,
      secondary: Color(0xFFF5F5F5),
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      surface: Color(0xFFF5F5F5),
      onSurface: Colors.black,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1E88E5), // Azul
    hintColor: const Color(0xFFFF9800), // Cinza escuro
    scaffoldBackgroundColor: const Color(0xFF303030),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      displayLarge: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E88E5),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF1E88E5), // Azul
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF1E88E5),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF424242), // Cinza escuro
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1E88E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1E88E5)),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1E88E5)),
      ),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF1E88E5),
      onPrimary: Colors.black,
      secondary: Color(0xFFF5F5F5),
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      surface: Color(0xFFF5F5F5),
      onSurface: Colors.black,
    ),
  );

  static var colorScheme;
}
