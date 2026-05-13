import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primaryBlue = Color(0xFF378ADD);
  static const Color teal = Color(0xFF1D9E75);
  static const Color amber = Color(0xFFEF9F27);
  static const Color red = Color(0xFFE24B4A);
  static const Color purple = Color(0xFF7F77DD);

  // Background
  static const Color backgroundGrey = Color(0xFFF8F9FA);
  static const Color backgroundWhite = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Border
  static const Color border = Color(0x14000000); // rgba(0,0,0,0.08)

  // Input background
  static const Color inputBackground = Color(0xFFF3F4F6);

  // Risk chip
  static const Color riskHighBg = Color(0xFFFFEBEB);
  static const Color riskHighText = Color(0xFFA32D2D);
  static const Color riskMediumBg = Color(0xFFFFF8E8);
  static const Color riskMediumText = Color(0xFFB07A1A);
  static const Color riskLowBg = Color(0xFFE8F5F0);
  static const Color riskLowText = Color(0xFF1D9E75);

  // Navigation
  static const Color navActive = primaryBlue;
  static const Color navInactive = Color(0xFF9CA3AF);
  static const Color navBadge = red;
}
