import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/section_card.dart';

// ── 차트 샘플 데이터 ──────────────────────────────────────────

// 혈압·심박 (회기별)
const _bpSystolic = [135.0, 128.0, 140.0, 122.0, 118.0, 132.0, 125.0, 120.0];
const _bpDiastolic = [88.0, 82.0, 92.0, 78.0, 76.0, 85.0, 80.0, 77.0];
const _heartRate = [92.0, 88.0, 96.0, 84.0, 80.0, 88.0, 82.0, 79.0];

// 감정 변화 (긍정/부정 점수, 0~100)
const _emotionPos = [30.0, 35.0, 28.0, 42.0, 48.0, 45.0, 55.0, 60.0];
const _emotionNeg = [70.0, 65.0, 72.0, 58.0, 52.0, 55.0, 45.0, 40.0];

// 스트레스 지수 (0~100)
const _stress = [78.0, 85.0, 92.0, 70.0, 65.0, 88.0, 72.0, 60.0];

// 목표 달성률
const _goalAchieved = 68.0; // %

// 서비스 연계
const _serviceTimeline = [
  (date: '2024.03', label: '정신건강복지센터\n연계'),
  (date: '2024.05', label: '일자리 지원\n프로그램'),
  (date: '2024.08', label: '주거 안정\n지원'),
  (date: '2025.01', label: '의료비 지원\n신청'),
  (date: '2025.04', label: '자조모임\n참여'),
];

// 위험 신호 발생일
final _riskDays = {
  DateTime(2025, 4, 8),
  DateTime(2025, 4, 22),
  DateTime(2025, 5, 3),
  DateTime(2025, 5, 10),
};

// ── 대시보드 탭 ───────────────────────────────────────────────

enum _Period { session, monthly, quarterly }

class ClientDetailDashboardTab extends StatefulWidget {
  const ClientDetailDashboardTab({super.key});

  @override
  State<ClientDetailDashboardTab> createState() =>
      _ClientDetailDashboardTabState();
}

class _ClientDetailDashboardTabState extends State<ClientDetailDashboardTab> {
  _Period _period = _Period.session;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // 기간 필터
        _PeriodFilter(
          selected: _period,
          onChanged: (p) => setState(() => _period = p),
        ),
        const SizedBox(height: 20),

        // 1. 혈압·심박
        const _ChartCard(
          title: '혈압·심박 추이',
          child: _BpChart(),
        ),
        const SizedBox(height: 16),

        // 2. 감정 변화
        const _ChartCard(
          title: '감정 변화',
          child: _EmotionChart(),
        ),
        const SizedBox(height: 16),

        // 3. 스트레스 지수
        const _ChartCard(
          title: '스트레스 지수',
          subtitle: '빨간 점선: 위험 임계선 (80)',
          child: _StressChart(),
        ),
        const SizedBox(height: 16),

        // 4. 목표 달성률
        const _ChartCard(
          title: '목표 달성률',
          child: _GoalDonut(),
        ),
        const SizedBox(height: 16),

        // 5. 서비스 연계 타임라인
        const _ChartCard(
          title: '서비스 연계 타임라인',
          padding: EdgeInsets.fromLTRB(16, 14, 0, 16),
          child: _ServiceTimeline(),
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
  const _BpChart();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: 50,
              maxY: 160,
              lineBarsData: [
                _line(_bpSystolic, AppColors.primary),
                _line(_bpDiastolic, AppColors.primaryDark),
                _line(_heartRate, AppColors.amber, dashed: true),
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
  const _EmotionChart();

  @override
  Widget build(BuildContext context) {
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
                  spots: _emotionPos.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
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
                  spots: _emotionNeg.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
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
  const _StressChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: 100,
          barGroups: _stress.asMap().entries.map((e) {
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
  const _GoalDonut();

  @override
  Widget build(BuildContext context) {
    const achieved = _goalAchieved;
    const remaining = 100 - achieved;

    return SizedBox(
      height: 160,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: achieved,
                    color: AppColors.primary,
                    radius: 28,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: remaining,
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
  const _ServiceTimeline();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < _serviceTimeline.length; i++) ...[
            _TimelineNode(
              item: _serviceTimeline[i],
              isFirst: i == 0,
              isLast: i == _serviceTimeline.length - 1,
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
