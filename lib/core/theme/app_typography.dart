import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography scale from Screens.pen (Noto Sans KR · 한글 최적화)
class AppTypography {
  AppTypography._();

  // ── Display ───────────────────────────────────────────────────────────────
  /// Display/Bold · 28px · 700
  static TextStyle get display => GoogleFonts.notoSansKr(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // ── Headings ──────────────────────────────────────────────────────────────
  /// Heading/H1 · 22px · 700
  static TextStyle get h1 => GoogleFonts.notoSansKr(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  /// Heading/H2 · 20px · 700
  static TextStyle get h2 => GoogleFonts.notoSansKr(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// Heading/H3 · 18px · 700
  static TextStyle get h3 => GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// Heading/H4 · 16px · 500
  static TextStyle get h4 => GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // ── Body ──────────────────────────────────────────────────────────────────
  /// Body/Large · 16px · 400, lineHeight 24
  static TextStyle get bodyLarge => GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// Body/Medium · 14px · 400, lineHeight 22
  static TextStyle get bodyMedium => GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.57,
      );

  /// Body/Small · 13px · 400, lineHeight 20
  static TextStyle get bodySmall => GoogleFonts.notoSansKr(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.54,
      );

  // ── Label & Caption ───────────────────────────────────────────────────────
  /// Label/Small · 12px · 500, lineHeight 16
  static TextStyle get labelSmall => GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.33,
      );

  /// Caption · 11px · 400, lineHeight 14
  static TextStyle get caption => GoogleFonts.notoSansKr(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.27,
      );

  // ── 버튼 텍스트 ──────────────────────────────────────────────────────────
  static TextStyle get buttonText => GoogleFonts.notoSansKr(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryForeground,
        height: 1.0,
      );

  // ── 기존 코드 호환 alias ──────────────────────────────────────────────────
  static TextStyle get title => h3;
  static TextStyle get sectionHeader => labelSmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
  static TextStyle get body => bodyMedium;
  static TextStyle get microLabel => labelSmall;
}
