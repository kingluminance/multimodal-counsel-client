import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import 'notification_page.dart';
import 'schedule_add_page.dart';
import 'schedule_detail_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const _storage = FlutterSecureStorage();

  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  List<Map<String, dynamic>> _allSessions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final userId = await _storage.read(key: 'user_id') ?? '';
      if (userId.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final result = await SessionService().upcoming(userId);
      if (!mounted) return;
      setState(() {
        _allSessions = List<Map<String, dynamic>>.from(result['sessions'] ?? []);
        _isLoading = false;
      });
    } on DioException catch (_) {
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Set<int> _scheduledDaysForMonth() {
    final days = <int>{};
    for (final s in _allSessions) {
      final dateStr = s['session_date'] as String? ?? '';
      if (dateStr.isEmpty) continue;
      try {
        final d = DateTime.parse(dateStr);
        if (d.year == _focusedMonth.year && d.month == _focusedMonth.month) {
          days.add(d.day);
        }
      } catch (_) {}
    }
    return days;
  }

  List<Map<String, dynamic>> _sessionsForDay(DateTime day) {
    final dayStr =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return _allSessions.where((s) => s['session_date'] == dayStr).toList()
      ..sort((a, b) =>
          (a['session_time_start'] as String? ?? '').compareTo(b['session_time_start'] as String? ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final scheduledDays = _scheduledDaysForMonth();
    final daySchedules = _sessionsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        title: Text('일정', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScheduleAddPage()),
              );
              _loadSessions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: AppColors.backgroundWhite,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 22),
                              onPressed: () => setState(() {
                                _focusedMonth = DateTime(
                                    _focusedMonth.year, _focusedMonth.month - 1);
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
                                _focusedMonth = DateTime(
                                    _focusedMonth.year, _focusedMonth.month + 1);
                              }),
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                        _buildCalendarGrid(scheduledDays),
                      ],
                    ),
                  ),
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
                        if (daySchedules.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                '일정이 없습니다.',
                                style: AppTypography.bodyMedium
                                    .copyWith(color: AppColors.textHint),
                              ),
                            ),
                          )
                        else
                          ...daySchedules.map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const ScheduleDetailPage()),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundWhite,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.border, width: 1),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
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
                                                [
                                                  s['client_name'] as String? ?? '',
                                                  s['session_type'] as String? ?? '',
                                                ].where((v) => v.isNotEmpty).join(' · '),
                                                style: AppTypography.bodyMedium
                                                    .copyWith(fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                s['session_time_start'] as String? ?? '',
                                                style: AppTypography.bodySmall
                                                    .copyWith(color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right,
                                            color: AppColors.textHint, size: 18),
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

  Widget _buildCalendarGrid(Set<int> scheduledDays) {
    final now = DateTime.now();
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
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
            final isToday = date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
            final isSelected = date.year == _selectedDay.year &&
                date.month == _selectedDay.month &&
                date.day == _selectedDay.day;
            final hasSchedule = scheduledDays.contains(dayNum);
            final isSun = col == 0;
            final isSat = col == 6;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: SizedBox(
                  height: 44,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected || isToday
                              ? AppColors.primary
                              : Colors.transparent,
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
                              fontWeight: isToday || isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
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
