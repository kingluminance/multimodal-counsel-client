import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

enum RiskLevel { high, medium, low }

class RiskChip extends StatelessWidget {
  final RiskLevel level;
  final String? label;

  const RiskChip({super.key, required this.level, this.label});

  String get _defaultLabel {
    switch (level) {
      case RiskLevel.high:
        return '고위험';
      case RiskLevel.medium:
        return '중위험';
      case RiskLevel.low:
        return '저위험';
    }
  }

  Color get _bg {
    switch (level) {
      case RiskLevel.high:
        return AppColors.riskHighBg;
      case RiskLevel.medium:
        return AppColors.riskMediumBg;
      case RiskLevel.low:
        return AppColors.riskLowBg;
    }
  }

  Color get _fg {
    switch (level) {
      case RiskLevel.high:
        return AppColors.riskHighText;
      case RiskLevel.medium:
        return AppColors.riskMediumText;
      case RiskLevel.low:
        return AppColors.riskLowText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label ?? _defaultLabel,
        style: AppTypography.microLabel.copyWith(color: _fg),
      ),
    );
  }
}
