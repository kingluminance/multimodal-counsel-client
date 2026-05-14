import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'notification_page.dart';
import 'session_recording_page.dart';

class TodaySessionPage extends StatelessWidget {
  const TodaySessionPage({super.key});

  static const _sessions = [
    {'name': '김민지', 'topic': '진로 상담', 'time': '14:00 - 15:00'},
    {'name': '박지현', 'topic': '대인관계', 'time': '15:30 - 16:30'},
    {'name': '이서연', 'topic': '학교생활 적응', 'time': '17:00 - 18:00'},
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('오늘의 상담', style: AppTypography.h3),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 헤더
            Text('2026년 5월 14일 (목)', style: AppTypography.h4),
            const SizedBox(height: 4),
            Text(
              '오늘 예정된 상담 ${_sessions.length}건',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            // 상담 카드들
            ..._sessions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TodaySessionCard(
                    session: s,
                    onStart: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SessionRecordingPage()),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _TodaySessionCard extends StatelessWidget {
  final Map<String, String> session;
  final VoidCallback onStart;

  const _TodaySessionCard({required this.session, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이름: ${session['name']}', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('유형: ${session['topic']}', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.chipScheduledBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '상담예정',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.chipScheduledFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.textHint, size: 14),
              const SizedBox(width: 4),
              Text(session['time']!, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                elevation: 0,
              ),
              child: Text('상담 시작', style: AppTypography.buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
