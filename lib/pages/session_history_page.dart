import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'notification_page.dart';

class SessionHistoryPage extends StatelessWidget {
  const SessionHistoryPage({super.key});

  static const _sessions = [
    {'topic': '진로 상담', 'date': '2026.03.14', 'status': '상담완료'},
    {'topic': '진로 상담', 'date': '2026.03.07', 'status': '상담완료'},
    {'topic': '진로 상담', 'date': '2026.02.28', 'status': '상담완료'},
    {'topic': '진로 상담', 'date': '2026.02.21', 'status': '상담완료'},
    {'topic': '대인관계', 'date': '2026.01.17', 'status': '상담완료'},
    {'topic': '대인관계', 'date': '2026.01.10', 'status': '상담완료'},
    {'topic': '학업', 'date': '2025.12.20', 'status': '상담완료'},
    {'topic': '학업', 'date': '2025.12.13', 'status': '상담완료'},
  ];

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
        title: Text('상담 이력', style: AppTypography.h3),
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
            // 헤더 카드
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
                  Text(
                    '김민지',
                    style: AppTypography.h2.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '총 상담 ${_sessions.length}회 · 최초 상담 2025.10.05',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 이력 리스트
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: _sessions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s['topic']!, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                            Row(
                              children: [
                                Text(
                                  s['date']!,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.chipDoneBg,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    s['status']!,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.chipDoneFg,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (i < _sessions.length - 1)
                        const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
