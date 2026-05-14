import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';

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

  // ── 상담 상태 ─────────────────────────────────────────────────────────────

  /// 예정 (chip/scheduled)
  const StatusBadge.scheduled({super.key, this.label = '예정'})
      : backgroundColor = AppColors.chipScheduledBg,
        textColor = AppColors.chipScheduledFg;

  /// 완료 (chip/done)
  const StatusBadge.done({super.key, this.label = '완료'})
      : backgroundColor = AppColors.chipDoneBg,
        textColor = AppColors.chipDoneFg;

  /// 취소 (chip/cancel)
  const StatusBadge.cancelled({super.key, this.label = '취소'})
      : backgroundColor = AppColors.chipCancelBg,
        textColor = AppColors.chipCancelFg;

  // ── 내담자 상태 ───────────────────────────────────────────────────────────

  /// 활성
  const StatusBadge.active({super.key, this.label = '활성'})
      : backgroundColor = AppColors.primaryLight,
        textColor = AppColors.primaryDark;

  /// 대기
  const StatusBadge.pending({super.key, this.label = '대기'})
      : backgroundColor = const Color(0xFFFFF8E0),
        textColor = const Color(0xFFB08800);

  /// 종결
  const StatusBadge.closed({super.key, this.label = '종결'})
      : backgroundColor = AppColors.neutral200,
        textColor = AppColors.textSecondary;

  /// 긴급
  const StatusBadge.urgent({super.key, this.label = '긴급'})
      : backgroundColor = AppColors.riskHighBg,
        textColor = AppColors.riskHighText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: textColor),
      ),
    );
  }
}
