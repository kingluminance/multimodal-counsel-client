import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Pretendard',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.teal,
        tertiary: AppColors.purple,
        error: AppColors.red,
        surface: AppColors.backgroundWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.title,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundWhite,
        selectedItemColor: AppColors.navActive,
        unselectedItemColor: AppColors.navInactive,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
      ),
      textTheme: const TextTheme(
        titleLarge: AppTypography.title,
        titleMedium: AppTypography.sectionHeader,
        titleSmall: AppTypography.sectionHeader,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
        labelSmall: AppTypography.microLabel,
        labelMedium: AppTypography.microLabel,
      ),
      cardTheme: CardThemeData(
        color: AppColors.backgroundWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTypography.buttonText,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textHint),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide.none,
        labelStyle: AppTypography.microLabel,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}
