import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary palette (Brand · Mint/Teal) ──────────────────────────────────
  static const Color primary = Color(0xFF3B9A91); // primary/600
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF2E7D78); // primary/700
  static const Color primaryLight = Color(0xFFD8EFED); // primary/100
  static const Color primary50 = Color(0xFFEFF8F7);
  static const Color primary200 = Color(0xFFB0DFDD);
  static const Color primary300 = Color(0xFF8ED4CF);
  static const Color primary400 = Color(0xFF6FC6BE);
  static const Color primary500 = Color(0xFF4FB4AB);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accentNavy = Color(0xFF3A4179);
  static const Color accentBlue = Color(0xFF4A64E3);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color danger = Color(0xFFF26F73); // semantic/danger
  static const Color success = Color(0xFF5ABC64); // semantic/success
  static const Color warning = Color(0xFFFBBC05); // semantic/warning
  static const Color info = Color(0xFF3B82F6); // semantic/info

  /// 기존 코드와의 호환성 유지
  static const Color red = danger;
  static const Color purple = accentNavy;
  static const Color amber = warning;

  // ── Background & Surface ──────────────────────────────────────────────────
  static const Color backgroundGrey = Color(0xFFF9F8EF); // bg/app — 따뜻한 크림
  static const Color backgroundWhite = Color(0xFFFFFFFF); // bg/card
  static const Color backgroundSubtle = Color(0xFFF5F5F2); // bg/subtle
  static const Color inputBackground = backgroundSubtle;

  // ── Neutral / Grayscale ───────────────────────────────────────────────────
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF9F9F9);
  static const Color neutral100 = Color(0xFFF3F3F3);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD3D3D3);
  static const Color neutral400 = Color(0xFFA8A8A8);
  static const Color neutral500 = Color(0xFF7F7F7F);
  static const Color neutral600 = Color(0xFF606060);
  static const Color neutral700 = Color(0xFF444444);
  static const Color neutral800 = Color(0xFF2B2B2B);
  static const Color neutral900 = Color(0xFF141414);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = neutral800; // #2B2B2B
  static const Color textMedium = neutral700; // #444444
  static const Color textSecondary = neutral600; // #606060
  static const Color textHint = neutral400; // #A8A8A8

  // ── Border ────────────────────────────────────────────────────────────────
  static const Color border = neutral200; // #E5E5E5

  // ── Status Chips ──────────────────────────────────────────────────────────
  static const Color chipScheduledBg = Color(0xFFE3F2FD);
  static const Color chipScheduledFg = Color(0xFF1D6BC6);
  static const Color chipDoneBg = Color(0xFFE2F2E8);
  static const Color chipDoneFg = Color(0xFF2E8D57);
  static const Color chipCancelBg = Color(0xFFFDE3E3);
  static const Color chipCancelFg = Color(0xFFD83838);

  // ── Risk Chips (시멘틱 색상 재사용) ──────────────────────────────────────
  static const Color riskHighBg = Color(0xFFFFE5E5);
  static const Color riskHighText = Color(0xFFD83838);
  static const Color riskMediumBg = Color(0xFFFFF8E0);
  static const Color riskMediumText = Color(0xFFB08800);
  static const Color riskLowBg = primaryLight;
  static const Color riskLowText = primaryDark;

  // ── Navigation ────────────────────────────────────────────────────────────
  static const Color navActive = primary;
  static const Color navInactive = neutral400;
  static const Color navBadge = danger;

  // ── Dark theme ────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF111111);
  static const Color darkForeground = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2E2E2E);
  static const Color darkMutedForeground = Color(0xFFB8B9B6);
  static const Color darkDestructive = Color(0xFFFF5C33);

  // ── Primitive ─────────────────────────────────────────────────────────────
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
}
