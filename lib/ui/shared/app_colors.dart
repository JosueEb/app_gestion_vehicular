import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // evita instancias

  // 🎨 Base
  static const Color primary = Color(0xFF1E88E5);
  static const Color secondary = Color(0xFF43A047);

  // 🧱 Superficies
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;

  // 🟦 Headers / Top bars
  static const Color headerBackground =
      Color.fromARGB(255, 196, 236, 255);

  static const Color headerBackgroundRecarga =
    Color(0xFFF09C38);

static const Color headerNotificationBarRecarga =
    Color(0xFFE58231);


  // 📝 Texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // 🚦 Estados
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF1E88E5);

  // ➕ Acciones
  static const Color fab = Color(0xFF000000);
  static const Color divider = Color(0xFFE0E0E0);


}
