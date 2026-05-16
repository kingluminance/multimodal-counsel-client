import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<_NotifItem> _items = [
    _NotifItem(text: '홍길동님 오늘 오후 3시 상담 예정입니다.', date: '2026.01.06 13:30', isRead: false),
    _NotifItem(text: '김홍동님 내일 오전 10시 상담 예정입니다.', date: '2026.01.05 09:00', isRead: false),
    _NotifItem(text: '새로 올라온 공지사항이 있습니다.', date: '2026.01.04 18:00', isRead: false),
    _NotifItem(text: '박서연님 상담이 완료되었습니다.', date: '2026.01.03 16:30', isRead: true),
    _NotifItem(text: '이번 주 상담 일정을 확인해보세요.', date: '2026.01.02 08:00', isRead: true),
  ];

  void _markAllRead() {
    setState(() {
      for (final item in _items) {
        item.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text('사회복지사 지원', style: AppTypography.h4),
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('더보기', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 반투명 배경
          Container(color: const Color(0x33000000)),
          // 알림 카드
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications, color: AppColors.textPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text('알림 목록', style: AppTypography.h4),
                        ],
                      ),
                      TextButton(
                        onPressed: _markAllRead,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '읽음 처리',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border, height: 1),
                  // 알림 목록
                  Expanded(
                    child: ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        return GestureDetector(
                          onTap: () => setState(() => item.isRead = true),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: Opacity(
                              opacity: item.isRead ? 0.5 : 1.0,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.text, style: AppTypography.bodySmall),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.date,
                                          style: AppTypography.caption.copyWith(color: AppColors.textHint),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!item.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.danger,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary300,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        elevation: 0,
                      ),
                      child: Text('닫기', style: AppTypography.buttonText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final String text;
  final String date;
  bool isRead;

  _NotifItem({required this.text, required this.date, required this.isRead});
}
