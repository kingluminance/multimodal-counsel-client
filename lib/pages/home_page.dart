import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/risk_chip.dart';
import '../widgets/section_card.dart';

// ── 데이터 모델 ──────────────────────────────────────────────

enum SessionType { initial, crisis, regular, phone, group }

extension SessionTypeX on SessionType {
  String get label {
    switch (this) {
      case SessionType.initial:
        return '초기 상담';
      case SessionType.crisis:
        return '위기 개입';
      case SessionType.regular:
        return '정기 상담';
      case SessionType.phone:
        return '전화 상담';
      case SessionType.group:
        return '집단 상담';
    }
  }

  Color get color {
    switch (this) {
      case SessionType.initial:
        return AppColors.primaryBlue;
      case SessionType.crisis:
        return AppColors.red;
      case SessionType.regular:
        return AppColors.teal;
      case SessionType.phone:
        return AppColors.amber;
      case SessionType.group:
        return AppColors.purple;
    }
  }
}

class _ScheduleItem {
  final String clientName;
  final SessionType type;
  final String time;
  final String method; // 대면/비대면/전화
  final RiskLevel risk;

  const _ScheduleItem({
    required this.clientName,
    required this.type,
    required this.time,
    required this.method,
    required this.risk,
  });
}

class _RiskAlert {
  final String clientName;
  final String summary;

  const _RiskAlert({required this.clientName, required this.summary});
}

// ── 샘플 데이터 ───────────────────────────────────────────────

const _userName = '김민지';
const _todaySessionCount = 3;
const _unreadCount = 2;

const _summaryStats = [
  (label: '담당 내담자', value: '24', color: AppColors.textPrimary),
  (label: '이번 주 상담', value: '8', color: AppColors.textPrimary),
  (label: '위험 알림', value: '2', color: AppColors.red),
  (label: '미완료 일지', value: '5', color: AppColors.amber),
];

const _todaySchedules = [
  _ScheduleItem(
    clientName: '김지수',
    type: SessionType.initial,
    time: '10:00',
    method: '대면',
    risk: RiskLevel.high,
  ),
  _ScheduleItem(
    clientName: '이준혁',
    type: SessionType.crisis,
    time: '14:00',
    method: '대면',
    risk: RiskLevel.high,
  ),
  _ScheduleItem(
    clientName: '박서연',
    type: SessionType.regular,
    time: '16:30',
    method: '비대면',
    risk: RiskLevel.low,
  ),
];

const _riskAlerts = [
  _RiskAlert(clientName: '김지수', summary: '자해 위험 발언 감지 · 긴급 개입 필요'),
  _RiskAlert(clientName: '이준혁', summary: '연락 두절 3일째 · 안전 확인 요망'),
];

// ── 페이지 ────────────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: const _HomeAppBar(
        userName: _userName,
        todayCount: _todaySessionCount,
        unreadCount: _unreadCount,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 요약 카드 그리드
            _SummaryGrid(),
            const SizedBox(height: 24),

            // 최근 위험 알림 섹션 (케이스 있을 때만)
            if (_riskAlerts.isNotEmpty) ...[
              const _RiskAlertSection(alerts: _riskAlerts),
              const SizedBox(height: 24),
            ],

            // 오늘 일정 섹션
            const _TodayScheduleSection(schedules: _todaySchedules),
          ],
        ),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final int todayCount;
  final int unreadCount;

  const _HomeAppBar({
    required this.userName,
    required this.todayCount,
    required this.unreadCount,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundWhite,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '안녕하세요, $userName님',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '오늘 상담 $todayCount건 예정',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _NotifButton(unreadCount: unreadCount),
        ),
      ],
    );
  }
}

class _NotifButton extends StatelessWidget {
  final int unreadCount;
  const _NotifButton({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 24),
          color: AppColors.textPrimary,
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        if (unreadCount > 0)
          Positioned(
            top: 2,
            right: 2,
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
    );
  }
}

// ── 요약 카드 그리드 ──────────────────────────────────────────

class _SummaryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 0,
        mainAxisSpacing: 16,
        childAspectRatio: 2.6,
        children: _summaryStats
            .map((s) => _SummaryCell(label: s.label, value: s.value, color: s.color))
            .toList(),
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ── 오늘 일정 섹션 ────────────────────────────────────────────

class _TodayScheduleSection extends StatelessWidget {
  final List<_ScheduleItem> schedules;
  const _TodayScheduleSection({required this.schedules});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('오늘 일정', style: AppTypography.sectionHeader),
            GestureDetector(
              onTap: () {},
              child: const Text(
                '전체 보기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 일정 카드 or 빈 상태
        schedules.isEmpty
            ? _EmptySchedule()
            : SectionCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (int i = 0; i < schedules.length; i++) ...[
                      _ScheduleRow(item: schedules[i]),
                      if (i < schedules.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.border,
                        ),
                    ],
                  ],
                ),
              ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final _ScheduleItem item;
  const _ScheduleRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // 좌측 3px 컬러 세로선
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: item.type.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // 내용
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.clientName} · ${item.type.label}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${item.time} · ${item.method}',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RiskChip(level: item.risk),
                  const SizedBox(width: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SectionCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            '오늘 예정된 상담이 없습니다',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textHint,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 최근 위험 알림 섹션 ───────────────────────────────────────

class _RiskAlertSection extends StatelessWidget {
  final List<_RiskAlert> alerts;
  const _RiskAlertSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('최근 위험 알림', style: AppTypography.sectionHeader),
        const SizedBox(height: 12),
        Column(
          children: alerts
              .map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RiskAlertCard(alert: a),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _RiskAlertCard extends StatelessWidget {
  final _RiskAlert alert;
  const _RiskAlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // 좌측 Red 세로선
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: AppColors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF5F5),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.clientName,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.riskHighText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.summary,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
