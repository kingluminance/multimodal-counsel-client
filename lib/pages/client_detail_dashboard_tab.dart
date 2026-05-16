import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import '../widgets/section_card.dart';

enum _Period { session, monthly, quarterly }

extension _PeriodUnit on _Period {
  String get unit {
    switch (this) {
      case _Period.session:
        return 'session';
      case _Period.monthly:
        return 'month';
      case _Period.quarterly:
        return 'quarter';
    }
  }
}

class ClientDetailDashboardTab extends StatefulWidget {
  final String clientId;

  const ClientDetailDashboardTab({super.key, required this.clientId});

  @override
  State<ClientDetailDashboardTab> createState() => _ClientDetailDashboardTabState();
}

class _ClientDetailDashboardTabState extends State<ClientDetailDashboardTab> {
  _Period _period = _Period.session;
  DateTime _focusedDay = DateTime.now();

  // 혈압·심박
  List<double> _bpSystolic = [];
  List<double> _bpDiastolic = [];
  List<double> _heartRate = [];

  // 감정
  List<double> _emotionPos = [];
  List<double> _emotionNeg = [];

  // 스트레스
  List<double> _stress = [];

  // 목표 달성률
  double _goalAchieved = 0;

  // 서비스 연계 타임라인
  List<({String date, String label})> _serviceTimeline = [];

  // 위험 신호
  Set<DateTime> _riskDays = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadVitals(),
        _loadEmotions(),
        _loadStress(),
        _loadGoals(),
        _loadReferrals(),
        _loadRiskHistory(),
      ]);
    } catch (_) {
      // 개별 에러는 각 메서드에서 처리
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPeriodData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadVitals(),
        _loadEmotions(),
        _loadStress(),
      ]);
    } catch (_) {
      // 무시
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadVitals() async {
    try {
      final result = await DashboardService().vitals(widget.clientId, unit: _period.unit);
      if (!mounted) return;
      final data = result['data'] as List? ?? [];
      setState(() {
        _bpSystolic = data.map((e) => (e['bp_systolic_avg'] as num?)?.toDouble() ?? 0).toList();
        _bpDiastolic = data.map((e) => (e['bp_diastolic_avg'] as num?)?.toDouble() ?? 0).toList();
        _heartRate = data.map((e) => (e['heart_rate_avg'] as num?)?.toDouble() ?? 0).toList();
      });
    } on DioException {
      // 에러 무시, 빈 데이터 유지
    }
  }

  Future<void> _loadEmotions() async {
    try {
      final result = await DashboardService().emotions(widget.clientId, unit: _period.unit);
      if (!mounted) return;
      final data = result['data'] as List? ?? [];
      setState(() {
        _emotionPos = data.map((e) => (e['joy'] as num?)?.toDouble() ?? 0).toList();
        _emotionNeg = data.map((e) {
          final sadness = (e['sadness'] as num?)?.toDouble() ?? 0;
          final anger = (e['anger'] as num?)?.toDouble() ?? 0;
          final fear = (e['fear'] as num?)?.toDouble() ?? 0;
          return (sadness + anger + fear) / 3.0;
        }).toList();
      });
    } on DioException {
      // 에러 무시
    }
  }

  Future<void> _loadStress() async {
    try {
      final result = await DashboardService().stress(widget.clientId, unit: _period.unit);
      if (!mounted) return;
      final data = result['data'] as List? ?? [];
      setState(() {
        _stress = data.map((e) => (e['stress_avg'] as num?)?.toDouble() ?? 0).toList();
      });
    } on DioException {
      // 에러 무시
    }
  }

  Future<void> _loadGoals() async {
    try {
      final result = await DashboardService().goals(widget.clientId);
      if (!mounted) return;
      setState(() {
        _goalAchieved = (result['progress_pct'] as num?)?.toDouble() ?? 0;
      });
    } on DioException {
      // 에러 무시
    }
  }

  Future<void> _loadReferrals() async {
    try {
      final result = await DashboardService().referrals(widget.clientId);
      if (!mounted) return;
      final referrals = result['referrals'] as List? ?? [];
      setState(() {
        _serviceTimeline = referrals.map((e) {
          final date = (e['referral_date'] as String? ?? '').substring(0, 7).replaceAll('-', '.');
          final label = '${e['agency_name'] ?? ''}\n${e['service_name'] ?? ''}';
          return (date: date, label: label);
        }).toList();
      });
    } on DioException {
      // 에러 무시
    }
  }

  Future<void> _loadRiskHistory() async {
    try {
      final result = await DashboardService().riskHistory(widget.clientId);
      if (!mounted) return;
      final events = result['events'] as List? ?? [];
      final days = <DateTime>{};
      for (final e in events) {
        final dateStr = e['date'] as String?;
        if (dateStr != null) {
          try {
            final parts = dateStr.split('-');
            days.add(DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])));
          } catch (_) {}
        }
      }
      setState(() => _riskDays = days);
    } on DioException {
      // 에러 무시
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // 기간 필터
        _PeriodFilter(
          selected: _period,
          onChanged: (p) {
            setState(() => _period = p);
            _loadPeriodData();
          },
        ),
        const SizedBox(height: 20),

        // 로딩 인디케이터 (데이터가 없을 때만)
        if (_isLoading && _bpSystolic.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          // 1. 혈압·심박
          _ChartCard(
            title: '혈압·심박 추이',
            child: _BpChart(
              bpSystolic: _bpSystolic,
              bpDiastolic: _bpDiastolic,
              heartRate: _heartRate,
            ),
          ),
          const SizedBox(height: 16),

          // 2. 감정 변화
          _ChartCard(
            title: '감정 변화',
            child: _EmotionChart(
              emotionPos: _emotionPos,
              emotionNeg: _emotionNeg,
            ),
          ),
          const SizedBox(height: 16),

          // 3. 스트레스 지수
          _ChartCard(
            title: '스트레스 지수',
            subtitle: '빨간 점선: 위험 임계선 (80)',
            child: _StressChart(stress: _stress),
          ),
          const SizedBox(height: 16),

          // 4. 목표 달성률
          _ChartCard(
            title: '목표 달성률',
            child: _GoalDonut(goalAchieved: _goalAchieved),
          ),
          const SizedBox(height: 16),

          // 5. 서비스 연계 타임라인
          _ChartCard(
            title: '서비스 연계 타임라인',
            padding: const EdgeInsets.fromLTRB(16, 14, 0, 16),
            child: _ServiceTimeline(serviceTimeline: _serviceTimeline),
          ),
          const SizedBox(height: 16),

          // 6. 위험 신호 달력
          _ChartCard(
            title: '위험 신호 달력',
            child: _RiskCalendar(
              focusedDay: _focusedDay,
              onDaySelected: (d) => setState(() => _focusedDay = d),
              riskDays: _riskDays,
            ),
          ),
        ],
      ],
    );
  }
}

// ── 기간 필터 ─────────────────────────────────────────────────

class _PeriodFilter extends StatelessWidget {
  final _Period selected;
  final ValueChanged<_Period> onChanged;
  const _PeriodFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_Period>(
      segments: const [
        ButtonSegment(value: _Period.session, label: Text('회기별')),
        ButtonSegment(value: _Period.monthly, label: Text('월별')),
        ButtonSegment(value: _Period.quarterly, label: Text('분기별')),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(
          const TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w500),
        ),
        side: MaterialStateProperty.all(
          const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

// ── 차트 카드 래퍼 ────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _ChartCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.sectionHeader),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: AppTypography.caption),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── 1. 혈압·심박 LineChart ────────────────────────────────────

class _BpChart extends StatelessWidget {
  final List<double> bpSystolic;
  final List<double> bpDiastolic;
  final List<double> heartRate;

  const _BpChart({
    required this.bpSystolic,
    required this.bpDiastolic,
    required this.heartRate,
  });

  @override
  Widget build(BuildContext context) {
    if (bpSystolic.isEmpty) {
      return const _EmptyChart();
    }
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: 50,
              maxY: 160,
              lineBarsData: [
                _line(bpSystolic, AppColors.primary),
                _line(bpDiastolic, AppColors.primaryDark),
                _line(heartRate, AppColors.amber, dashed: true),
              ],
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt() + 1}회',
                      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.textHint),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.textHint),
                    ),
                  ),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: AppColors.border, strokeWidth: 0.5),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _Legend(items: [
          (color: AppColors.primary, label: '수축기 혈압'),
          (color: AppColors.primaryDark, label: '이완기 혈압'),
          (color: AppColors.amber, label: '심박수'),
        ]),
      ],
    );
  }

  LineChartBarData _line(List<double> vals, Color color, {bool dashed = false}) {
    return LineChartBarData(
      spots: vals.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      color: color,
      isCurved: true,
      barWidth: 2,
      dotData: FlDotData(
        getDotPainter: (_, __, ___, ____) =>
            FlDotCirclePainter(radius: 3, color: color, strokeWidth: 0),
      ),
      dashArray: dashed ? [4, 3] : null,
      belowBarData: BarAreaData(show: false),
    );
  }
}

// ── 2. 감정 변화 AreaChart ────────────────────────────────────

class _EmotionChart extends StatelessWidget {
  final List<double> emotionPos;
  final List<double> emotionNeg;

  const _EmotionChart({required this.emotionPos, required this.emotionNeg});

  @override
  Widget build(BuildContext context) {
    if (emotionPos.isEmpty) {
      return const _EmptyChart();
    }
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: emotionPos.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                  color: AppColors.primaryDark,
                  isCurved: true,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryDark.withOpacity(0.15),
                  ),
                ),
                LineChartBarData(
                  spots: emotionNeg.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                  color: AppColors.red,
                  isCurved: true,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.red.withOpacity(0.1),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt() + 1}',
                      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.textHint),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 25,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.textHint),
                    ),
                  ),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: AppColors.border, strokeWidth: 0.5),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _Legend(items: [
          (color: AppColors.primaryDark, label: '긍정 감정'),
          (color: AppColors.red, label: '부정 감정'),
        ]),
      ],
    );
  }
}

// ── 3. 스트레스 BarChart + 임계선 ─────────────────────────────

class _StressChart extends StatelessWidget {
  final List<double> stress;

  const _StressChart({required this.stress});

  @override
  Widget build(BuildContext context) {
    if (stress.isEmpty) {
      return const _EmptyChart();
    }
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: 100,
          barGroups: stress.asMap().entries.map((e) {
            final isHigh = e.value > 80;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  color: isHigh ? AppColors.red : AppColors.primary,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 80,
                color: AppColors.red,
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  labelResolver: (_) => '임계 80',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt() + 1}회',
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.textHint),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 25,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, color: AppColors.textHint),
                ),
              ),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.border, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
        ),
      ),
    );
  }
}

// ── 4. 목표 달성률 DonutChart ─────────────────────────────────

class _GoalDonut extends StatelessWidget {
  final double goalAchieved;

  const _GoalDonut({required this.goalAchieved});

  @override
  Widget build(BuildContext context) {
    final achieved = goalAchieved;
    final remaining = 100 - achieved;

    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: achieved > 0 ? achieved : 0.001,
                    color: AppColors.primary,
                    radius: 28,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: remaining > 0 ? remaining : 0.001,
                    color: AppColors.inputBackground,
                    radius: 28,
                    title: '',
                  ),
                ],
                centerSpaceRadius: 52,
                sectionsSpace: 2,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${achieved.toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text('목표 달성률', style: AppTypography.caption),
                const SizedBox(height: 16),
                const _LegendDot(color: AppColors.primary, label: '달성'),
                const SizedBox(height: 6),
                const _LegendDot(color: AppColors.inputBackground, label: '미달성'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 5. 서비스 연계 타임라인 ───────────────────────────────────

class _ServiceTimeline extends StatelessWidget {
  final List<({String date, String label})> serviceTimeline;

  const _ServiceTimeline({required this.serviceTimeline});

  @override
  Widget build(BuildContext context) {
    if (serviceTimeline.isEmpty) {
      return const _EmptyChart();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < serviceTimeline.length; i++) ...[
            _TimelineNode(
              item: serviceTimeline[i],
              isFirst: i == 0,
              isLast: i == serviceTimeline.length - 1,
            ),
          ],
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final ({String date, String label}) item;
  final bool isFirst;
  final bool isLast;

  const _TimelineNode({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        children: [
          // 선 + 점
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  color: isFirst ? Colors.transparent : AppColors.primary.withOpacity(0.3),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: isLast ? Colors.transparent : AppColors.primary.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 날짜
          Text(
            item.date,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          // 레이블
          Text(
            item.label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── 6. 위험 신호 달력 ─────────────────────────────────────────

class _RiskCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final ValueChanged<DateTime> onDaySelected;
  final Set<DateTime> riskDays;

  const _RiskCalendar({
    required this.focusedDay,
    required this.onDaySelected,
    required this.riskDays,
  });

  bool _isRiskDay(DateTime day) {
    return riskDays.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(2024),
      lastDay: DateTime(2026),
      focusedDay: focusedDay,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: '월'},
      onDaySelected: (selected, focused) => onDaySelected(selected),
      eventLoader: (day) => _isRiskDay(day) ? [day] : [],
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          return Positioned(
            bottom: 2,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, size: 20, color: AppColors.textSecondary),
        rightChevronIcon: Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        weekendTextStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          color: AppColors.red,
        ),
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        weekendStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          color: AppColors.red,
        ),
      ),
    );
  }
}

// ── 데이터 없음 플레이스홀더 ──────────────────────────────────

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Center(
        child: Text(
          '데이터가 없습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

// ── 공통 범례 위젯 ────────────────────────────────────────────

class _Legend extends StatelessWidget {
  final List<({Color color, String label})> items;
  const _Legend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items
          .expand((item) => [
                _LegendDot(color: item.color, label: item.label),
                const SizedBox(width: 16),
              ])
          .toList()
        ..removeLast(),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
