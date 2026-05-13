import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors — Emergency/Safety palette
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryDark = Color(0xFF9A0007);
  static const Color primaryLight = Color(0xFFFF6659);
  static const Color secondary = Color(0xFF1565C0);
  static const Color accent = Color(0xFFFFA000);

  static const Color bgDark = Color(0xFF0D0D0D);
  static const Color bgCard = Color(0xFF1A1A1A);
  static const Color bgSurface = Color(0xFF242424);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6E6E6E);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color danger = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0277BD);

  // Status colors laporan
  static const Color statusPending = Color(0xFFFFA000);
  static const Color statusMenuju = Color(0xFF1E88E5);
  static const Color statusDiproses = Color(0xFF8E24AA);
  static const Color statusSelesai = Color(0xFF2E7D32);
  static const Color statusCancel = Color(0xFF757575);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: bgCard,
      background: bgDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    scaffoldBackgroundColor: bgDark,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    cardTheme: CardTheme(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2E2E2E), width: 1),
      ),
    ),
  );

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return statusPending;
      case 'menuju_lokasi': return statusMenuju;
      case 'diproses': return statusDiproses;
      case 'selesai': return statusSelesai;
      case 'cancel': return statusCancel;
      default: return textMuted;
    }
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Menunggu';
      case 'menuju_lokasi': return 'Satpam Menuju Lokasi';
      case 'diproses': return 'Sedang Diproses';
      case 'selesai': return 'Selesai';
      case 'cancel': return 'Dibatalkan';
      default: return status;
    }
  }
}
