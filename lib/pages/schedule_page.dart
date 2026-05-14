import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'notification_page.dart';
import 'schedule_add_page.dart';
import 'schedule_detail_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedMonth = DateTime(2026, 5);
  DateTime _selectedDay = DateTime(2026, 5, 14);

  static const _todaySchedules = [
    {'name': '김민지', 'topic': '진로 상담', 'time': '14:30'},
    {'name': '박지현', 'topic': '대인관계', 'time': '15:31'},
    {'name': '이서연', 'topic': '학교생활 적응', 'time': '17:00'},
  ];

  // 상담 예정 날짜 (5월 기준)
  final Set<int> _scheduledDays = {1, 5, 7, 8, 12, 14, 19, 21, 22, 26, 28};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        title: Text('일정', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScheduleAddPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 캘린더 섹션
            Container(
              color: AppColors.backgroundWhite,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 월 네비게이션
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 22),
                        onPressed: () => setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                        }),
                        color: AppColors.textSecondary,
                      ),
                      Text(
                        '${_focusedMonth.year}년 ${_focusedMonth.month}월',
                        style: AppTypography.h4,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 22),
                        onPressed: () => setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                        }),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 요일 헤더
                  Row(
                    children: ['일', '월', '화', '수', '목', '금', '토']
                        .asMap()
                        .entries
                        .map((e) => Expanded(
                              child: Text(
                                e.value,
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  color: e.key == 0
                                      ? AppColors.danger
                                      : e.key == 6
                                          ? AppColors.chipScheduledFg
                                          : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  // 달력 그리드
                  _buildCalendarGrid(),
                ],
              ),
            ),
            // 오늘의 일정 카드
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedDay.month}월 ${_selectedDay.day}일(${_weekdayStr(_selectedDay)})',
                    style: AppTypography.sectionHeader,
                  ),
                  const SizedBox(height: 10),
                  ..._todaySchedules.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ScheduleDetailPage()),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border, width: 1),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${s['name']} · ${s['topic']}',
                                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        s['time']!,
                                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
                              ],
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7; // 0=Sun, 1=Mon..6=Sat
    final totalCells = startWeekday + lastDay.day;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final dayNum = cellIndex - startWeekday + 1;

            if (dayNum < 1 || dayNum > lastDay.day) {
              return const Expanded(child: SizedBox(height: 40));
            }

            final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
            final isToday = date.year == 2026 && date.month == 5 && date.day == 14;
            final isSelected = date.year == _selectedDay.year &&
                date.month == _selectedDay.month &&
                date.day == _selectedDay.day;
            final hasSchedule = _scheduledDays.contains(dayNum);
            final isSun = col == 0;
            final isSat = col == 6;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: Container(
                  height: 44,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected || isToday ? AppColors.primary : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: AppTypography.bodySmall.copyWith(
                              color: (isSelected || isToday)
                                  ? AppColors.white
                                  : isSun
                                      ? AppColors.danger
                                      : isSat
                                          ? AppColors.chipScheduledFg
                                          : AppColors.textPrimary,
                              fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      if (hasSchedule)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  String _weekdayStr(DateTime date) {
    const days = ['일', '월', '화', '수', '목', '금', '토'];
    return days[date.weekday % 7];
  }
}
