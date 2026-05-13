import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/section_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _notifications = [
    _NotifData(
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.red,
      title: '긴급 알림: 김지수 고위험 지표 감지',
      body: 'AI 분석 결과 자해 위험도가 크게 상승했습니다.',
      time: '10분 전',
      isRead: false,
    ),
    _NotifData(
      icon: Icons.smart_toy_outlined,
      iconColor: AppColors.purple,
      title: 'AI 분석 리포트 준비됨',
      body: '이준혁 내담자 최신 세션 분석이 완료되었습니다.',
      time: '1시간 전',
      isRead: false,
    ),
    _NotifData(
      icon: Icons.calendar_today_outlined,
      iconColor: AppColors.primaryBlue,
      title: '오늘 일정 리마인더',
      body: '14:00 이준혁 정기 상담이 1시간 후입니다.',
      time: '2시간 전',
      isRead: false,
    ),
    _NotifData(
      icon: Icons.check_circle_outline,
      iconColor: AppColors.teal,
      title: '세션 기록 저장 완료',
      body: '박서연 내담자 세션 노트가 저장되었습니다.',
      time: '어제 16:30',
      isRead: true,
    ),
    _NotifData(
      icon: Icons.person_add_outlined,
      iconColor: AppColors.primaryBlue,
      title: '새 내담자 등록',
      body: '강도윤 내담자가 새로 등록되었습니다.',
      time: '2일 전',
      isRead: true,
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('알림'),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unread',
                  style: AppTypography.microLabel.copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                '모두 읽음',
                style: AppTypography.caption.copyWith(color: AppColors.primaryBlue),
              ),
            ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final n = _notifications[i];
          return _NotifCard(
            data: n,
            onTap: () => setState(() => n.isRead = true),
          );
        },
      ),
    );
  }
}

class _NotifData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  bool isRead;

  _NotifData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}

class _NotifCard extends StatelessWidget {
  final _NotifData data;
  final VoidCallback onTap;

  const _NotifCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: data.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: data.iconColor, size: 20),
              ),
              if (!data.isRead)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTypography.body.copyWith(
                    fontWeight: data.isRead ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(data.body, style: AppTypography.caption),
                const SizedBox(height: 6),
                Text(
                  data.time,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
