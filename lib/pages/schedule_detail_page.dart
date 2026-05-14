import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'notification_page.dart';
import 'schedule_edit_page.dart';

class ScheduleDetailPage extends StatelessWidget {
  const ScheduleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('일정 상세', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '진로 상담',
                      style: AppTypography.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '김민지',
                    style: AppTypography.h1.copyWith(color: AppColors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '2026.05.14 (목) 14:00 - 15:00',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 상세 정보 카드
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _DetailRow(label: '연락처', value: '010-1234-5678'),
                  const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                  _DetailRow(label: '상태', value: '상담 예정'),
                  const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                  _DetailRow(label: '진목', value: '매주 목요일'),
                  const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                  _DetailRow(label: '알림', value: '시작 30분 전'),
                  const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                  _DetailRow(label: '메모', value: '진로 적성 검사 결과 함께 검토'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 버튼 행
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('삭제', style: AppTypography.buttonText.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScheduleEditPage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text('수정하기', style: AppTypography.buttonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
