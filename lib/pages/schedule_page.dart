import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/risk_chip.dart';
import '../widgets/primary_button.dart';
import '../widgets/app_text_field.dart';

// ── 모델 ─────────────────────────────────────────────────────

class _ScheduleItem {
  final String clientName;
  final String time; // "HH:MM"
  final String type;
  final RiskLevel risk;

  const _ScheduleItem({
    required this.clientName,
    required this.time,
    required this.type,
    required this.risk,
  });
}

// ── 헬퍼 ─────────────────────────────────────────────────────

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

Color _typeColor(String type) {
  switch (type) {
    case '위기 개입':
      return AppColors.red;
    case '가족 상담':
    case '초기 면접':
      return AppColors.teal;
    case '프로그램':
      return AppColors.amber;
    case '사례 관리':
      return AppColors.purple;
    default:
      return AppColors.primaryBlue;
  }
}

// ── 상수 ─────────────────────────────────────────────────────

const _sessionTypeLabels = [
  '개인 상담',
  '가족 상담',
  '위기 개입',
  '프로그램',
  '사례 관리',
  '초기 면접',
];

const _sessionMethods = ['대면', '비대면', '전화', '방문'];

const _sampleClients = ['김지수', '이준혁', '박서연', '최민준', '한소희'];

// ── 샘플 이벤트 ───────────────────────────────────────────────

final _kToday = _dateOnly(DateTime.now());

Map<DateTime, List<_ScheduleItem>> _buildSampleEvents() {
  final d = _kToday;
  return {
    d: [
      const _ScheduleItem(
          clientName: '김지수',
          time: '10:00',
          type: '위기 개입',
          risk: RiskLevel.high),
      const _ScheduleItem(
          clientName: '이준혁',
          time: '14:00',
          type: '개인 상담',
          risk: RiskLevel.medium),
    ],
    DateTime(d.year, d.month, d.day + 1): [
      const _ScheduleItem(
          clientName: '박서연',
          time: '09:30',
          type: '초기 면접',
          risk: RiskLevel.low),
    ],
    DateTime(d.year, d.month, d.day + 3): [
      const _ScheduleItem(
          clientName: '최민준',
          time: '13:00',
          type: '가족 상담',
          risk: RiskLevel.medium),
      const _ScheduleItem(
          clientName: '한소희',
          time: '15:30',
          type: '사례 관리',
          risk: RiskLevel.low),
    ],
    DateTime(d.year, d.month, d.day + 5): [
      const _ScheduleItem(
          clientName: '이준혁',
          time: '11:00',
          type: '개인 상담',
          risk: RiskLevel.low),
    ],
    DateTime(d.year, d.month, d.day - 2): [
      const _ScheduleItem(
          clientName: '김지수',
          time: '16:00',
          type: '위기 개입',
          risk: RiskLevel.high),
    ],
    DateTime(d.year, d.month, d.day - 5): [
      const _ScheduleItem(
          clientName: '박서연',
          time: '10:30',
          type: '프로그램',
          risk: RiskLevel.low),
      const _ScheduleItem(
          clientName: '최민준',
          time: '14:00',
          type: '개인 상담',
          risk: RiskLevel.medium),
    ],
    DateTime(d.year, d.month, d.day + 8): [
      const _ScheduleItem(
          clientName: '한소희',
          time: '13:30',
          type: '위기 개입',
          risk: RiskLevel.high),
      const _ScheduleItem(
          clientName: '이준혁',
          time: '16:00',
          type: '개인 상담',
          risk: RiskLevel.low),
    ],
  };
}

final _sampleEvents = _buildSampleEvents();

// ── 페이지 ────────────────────────────────────────────────────

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedDay = _kToday;
  DateTime _selectedDay = _kToday;

  List<_ScheduleItem> _getEventsForDay(DateTime day) =>
      _sampleEvents[_dateOnly(day)] ?? [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddScheduleSheet(initialDate: _selectedDay),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        titleSpacing: 16,
        title: const Text('일정', style: AppTypography.title),
      ),
      body: Column(
        children: [
          // ── 캘린더 ──────────────────────────────────────────
          _CalendarSection(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
            onPageChanged: (fd) => setState(() => _focusedDay = fd),
            eventLoader: _getEventsForDay,
          ),
          const Divider(height: 1, color: AppColors.border),

          // ── 선택 날짜 일정 리스트 ───────────────────────────
          Expanded(
            child: _SessionList(date: _selectedDay, items: events),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          '상담 일정 추가',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── 캘린더 섹션 ───────────────────────────────────────────────

class _CalendarSection extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final List<_ScheduleItem> Function(DateTime) eventLoader;

  const _CalendarSection({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.eventLoader,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.only(bottom: 4),
      child: TableCalendar<_ScheduleItem>(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2027, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        eventLoader: eventLoader,
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: ''},
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 48,
        daysOfWeekHeight: 30,
        calendarBuilders: CalendarBuilders<_ScheduleItem>(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            final hasHigh =
                events.any((e) => e.risk == RiskLevel.high);
            return Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: hasHigh ? AppColors.red : AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            );
          },
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 22,
          ),
          headerPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          weekendStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryBlue, width: 1.5),
          ),
          todayTextStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
          selectedTextStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          defaultTextStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          weekendTextStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
          outsideTextStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            color: AppColors.textHint,
          ),
          cellMargin: const EdgeInsets.all(4),
        ),
      ),
    );
  }
}

// ── 일정 리스트 ───────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  final DateTime date;
  final List<_ScheduleItem> items;

  const _SessionList({required this.date, required this.items});

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  String _formatDate(DateTime d) =>
      '${d.month}월 ${d.day}일 (${_weekdays[d.weekday - 1]})';

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 날짜 헤더
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(_formatDate(date), style: AppTypography.sectionHeader),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${items.length}건',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 빈 상태
        if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SessionCard(item: items[i]),
                ),
                childCount: items.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_today_outlined,
            size: 40, color: AppColors.textHint),
        SizedBox(height: 12),
        Text(
          '이 날은 상담 일정이 없습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            color: AppColors.textHint,
          ),
        ),
        SizedBox(height: 80),
      ],
    );
  }
}

// ── 상담 카드 ─────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final _ScheduleItem item;

  const _SessionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(item.type);
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // 좌측 유형별 컬러 세로선
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // 시간 + 유형
          SizedBox(
            width: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.time,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.type,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 구분선
          Container(width: 1, height: 36, color: AppColors.border),
          const SizedBox(width: 14),

          // 내담자명
          Expanded(
            child: Text(
              item.clientName,
              style: AppTypography.sectionHeader,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // RiskChip
          RiskChip(level: item.risk),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

// ── 상담 일정 추가 시트 ────────────────────────────────────────

class _AddScheduleSheet extends StatefulWidget {
  final DateTime initialDate;
  const _AddScheduleSheet({required this.initialDate});

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  String? _selectedClient;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedType;
  String? _selectedMethod;
  final _locationCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  bool get _isValid =>
      _selectedClient != null &&
      _selectedTime != null &&
      _selectedType != null &&
      _selectedMethod != null;

  void _submit() {
    setState(() => _submitted = true);
    if (!_isValid) return;
    Navigator.of(context).pop();
    // TODO: 실제 저장 로직
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text('상담 일정 추가', style: AppTypography.title),
            const SizedBox(height: 20),

            // ── 내담자 선택 ──────────────────────────────────
            const _Label('내담자', required: true),
            const SizedBox(height: 6),
            _ClientDropdown(
              value: _selectedClient,
              onChanged: (v) => setState(() => _selectedClient = v),
              error: _submitted && _selectedClient == null
                  ? '내담자를 선택해주세요'
                  : null,
            ),
            const SizedBox(height: 16),

            // ── 날짜 / 시간 ──────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('날짜', required: true),
                      const SizedBox(height: 6),
                      _TapField(
                        text: _fmtDate(_selectedDate),
                        icon: Icons.calendar_today_outlined,
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('시간', required: true),
                      const SizedBox(height: 6),
                      _TapField(
                        text: _selectedTime != null
                            ? _fmtTime(_selectedTime!)
                            : null,
                        hint: '시간 선택',
                        icon: Icons.access_time_outlined,
                        onTap: _pickTime,
                        error: _submitted && _selectedTime == null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── 상담 유형 ────────────────────────────────────
            const _Label('상담 유형', required: true),
            const SizedBox(height: 8),
            _ChipSelector(
              options: _sessionTypeLabels,
              selected: _selectedType,
              onSelected: (v) => setState(() => _selectedType = v),
              error: _submitted && _selectedType == null,
            ),
            const SizedBox(height: 16),

            // ── 상담 방법 ────────────────────────────────────
            const _Label('상담 방법', required: true),
            const SizedBox(height: 8),
            _ChipSelector(
              options: _sessionMethods,
              selected: _selectedMethod,
              onSelected: (v) => setState(() => _selectedMethod = v),
              error: _submitted && _selectedMethod == null,
            ),
            const SizedBox(height: 16),

            // ── 장소 ─────────────────────────────────────────
            const _Label('장소'),
            const SizedBox(height: 6),
            AppTextField(
              controller: _locationCtrl,
              hint: '상담 장소를 입력하세요 (선택)',
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(label: '일정 추가', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

// ── 시트 내부 공용 위젯 ───────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final bool required;
  const _Label(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: AppTypography.sectionHeader),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
            ),
          ),
      ],
    );
  }
}

class _TapField extends StatelessWidget {
  final String? text;
  final String? hint;
  final IconData icon;
  final VoidCallback onTap;
  final bool error;

  const _TapField({
    this.text,
    this.hint,
    required this.icon,
    required this.onTap,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = text != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: error
              ? Border.all(color: AppColors.red, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? text! : (hint ?? ''),
                style: AppTypography.body.copyWith(
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                ),
              ),
            ),
            Icon(icon, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ClientDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? error;

  const _ClientDropdown({
    required this.value,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: error != null
                ? Border.all(color: AppColors.red, width: 1)
                : null,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                '내담자를 선택하세요',
                style: AppTypography.body.copyWith(color: AppColors.textHint),
              ),
              style: AppTypography.body,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              items: _sampleClients
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, style: AppTypography.body),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              error!,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.red,
              ),
            ),
          ),
      ],
    );
  }
}

class _ChipSelector extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;
  final bool error;

  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onSelected(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withOpacity(0.1)
                      : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (error)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 4),
            child: Text(
              '항목을 선택해주세요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.red,
              ),
            ),
          ),
      ],
    );
  }
}
