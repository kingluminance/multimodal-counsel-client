import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  // Convenience constructors for common states
  const StatusBadge.active({super.key, this.label = '활성'})
      : backgroundColor = const Color(0xFFE8F5F0),
        textColor = AppColors.teal;

  const StatusBadge.pending({super.key, this.label = '대기'})
      : backgroundColor = const Color(0xFFFFF8E8),
        textColor = const Color(0xFFB07A1A);

  const StatusBadge.closed({super.key, this.label = '종결'})
      : backgroundColor = const Color(0xFFF3F4F6),
        textColor = AppColors.textSecondary;

  const StatusBadge.urgent({super.key, this.label = '긴급'})
      : backgroundColor = const Color(0xFFFFEBEB),
        textColor = AppColors.riskHighText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.microLabel.copyWith(color: textColor),
      ),
    );
  }
}
