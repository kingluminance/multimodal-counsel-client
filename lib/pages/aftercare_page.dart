import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

// ── 모델 ─────────────────────────────────────────────────────

enum _AftercareStatus { completed, scheduled, missed }

extension _StatusX on _AftercareStatus {
  String get label {
    switch (this) {
      case _AftercareStatus.completed:
        return '연락완료';
      case _AftercareStatus.scheduled:
        return '예정';
      case _AftercareStatus.missed:
        return '미연락';
    }
  }

  Color get lineColor {
    switch (this) {
      case _AftercareStatus.completed:
        return AppColors.primaryDark;
      case _AftercareStatus.scheduled:
        return AppColors.primary;
      case _AftercareStatus.missed:
        return AppColors.textHint;
    }
  }

  Color get badgeBg {
    switch (this) {
      case _AftercareStatus.completed:
        return AppColors.primaryDark.withOpacity(0.1);
      case _AftercareStatus.scheduled:
        return AppColors.primary.withOpacity(0.1);
      case _AftercareStatus.missed:
        return AppColors.inputBackground;
    }
  }

  Color get badgeFg {
    switch (this) {
      case _AftercareStatus.completed:
        return AppColors.primaryDark;
      case _AftercareStatus.scheduled:
        return AppColors.primary;
      case _AftercareStatus.missed:
        return AppColors.textSecondary;
    }
  }
}

class _AftercareItem {
  final DateTime date;
  final _AftercareStatus status;
  final String? method; // 전화/방문/문자/영상통화
  final String? content;

  const _AftercareItem({
    required this.date,
    required this.status,
    this.method,
    this.content,
  });
}

// ── 상수 ─────────────────────────────────────────────────────

const _contactMethods = ['전화', '방문', '문자', '영상통화'];
const _statusLabels = ['연락됨', '예정', '미연락'];

final _sampleItems = [
  _AftercareItem(
    date: DateTime(2023, 6, 1),
    status: _AftercareStatus.completed,
    method: '전화',
    content: '내담자 안정적 생활 유지 중. 새 거주지 적응 완료, 아동 학교 등록 확인.',
  ),
  _AftercareItem(
    date: DateTime(2023, 12, 15),
    status: _AftercareStatus.completed,
    method: '방문',
    content: '가족 관계 개선 확인. 경제적 지원 추가 필요하여 지역 자활센터 연계 진행.',
  ),
  _AftercareItem(
    date: DateTime(2024, 3, 1),
    status: _AftercareStatus.missed,
    method: '전화',
    content: '3회 시도 후 연락 불가. 다음 분기 재시도 예정.',
  ),
  _AftercareItem(
    date: DateTime(2024, 6, 1),
    status: _AftercareStatus.completed,
    method: '문자',
    content: '자활 프로그램 참여 중. 취업 준비 단계 진입, 정서적으로 안정된 상태.',
  ),
  _AftercareItem(
    date: DateTime(2025, 1, 15),
    status: _AftercareStatus.scheduled,
  ),
  _AftercareItem(
    date: DateTime(2025, 7, 1),
    status: _AftercareStatus.scheduled,
  ),
];

// ── 페이지 ────────────────────────────────────────────────────

class AftercarePage extends StatefulWidget {
  final String clientName;
  const AftercarePage({super.key, this.clientName = '김지수'});

  @override
  State<AftercarePage> createState() => _AftercarePageState();
}

class _AftercarePageState extends State<AftercarePage> {
  late List<_AftercareItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(_sampleItems)
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddAftercareSheet(
        onAdd: (item) => setState(() {
          _items.add(item);
          _items.sort((a, b) => a.date.compareTo(b.date));
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        titleSpacing: 16,
        title: Text('${widget.clientName} · 사후관리',
            style: AppTypography.title),
      ),
      body: _items.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              itemCount: _items.length,
              itemBuilder: (context, i) => _TimelineRow(
                item: _items[i],
                isLast: i == _items.length - 1,
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          '사후관리 기록 추가',
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

// ── 빈 상태 ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_outlined, size: 44, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            '사후관리 기록이 없습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 타임라인 행 ───────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  final _AftercareItem item;
  final bool isLast;

  const _TimelineRow({required this.item, required this.isLast});

  static String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final color = item.status.lineColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 좌측: 점 + 세로선 ────────────────────────────
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 2),
                // 점
                _TimelineDot(status: item.status, color: color),
                // 세로선
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: color.withOpacity(0.3),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // ── 우측: 카드 ────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _TimelineCard(item: item, fmtDate: _fmtDate),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 타임라인 점 ───────────────────────────────────────────────

class _TimelineDot extends StatelessWidget {
  final _AftercareStatus status;
  final Color color;

  const _TimelineDot({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    if (status == _AftercareStatus.scheduled) {
      // 예정: 링 스타일
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
          color: AppColors.backgroundWhite,
        ),
      );
    }
    // 완료/미연락: 솔리드
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppColors.backgroundWhite, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

// ── 타임라인 카드 ─────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  final _AftercareItem item;
  final String Function(DateTime) fmtDate;

  const _TimelineCard({required this.item, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    final s = item.status;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 + 배지 + 방법
          Row(
            children: [
              Text(
                fmtDate(item.date),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              // 상태 배지
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: s.badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  s.label,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: s.badgeFg,
                  ),
                ),
              ),
              if (item.method != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 10, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        item.method!,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // 내용
          if (item.content != null && item.content!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.content!,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ] else if (s == _AftercareStatus.scheduled) ...[
            const SizedBox(height: 8),
            const Text(
              '예정된 사후 연락입니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: AppColors.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 사후관리 기록 추가 시트 ───────────────────────────────────

class _AddAftercareSheet extends StatefulWidget {
  final ValueChanged<_AftercareItem> onAdd;
  const _AddAftercareSheet({required this.onAdd});

  @override
  State<_AddAftercareSheet> createState() => _AddAftercareSheetState();
}

class _AddAftercareSheetState extends State<_AddAftercareSheet> {
  DateTime? _selectedDate;
  String? _selectedMethod;
  String? _selectedStatusLabel; // '연락됨' | '예정' | '미연락'
  final _contentCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  _AftercareStatus _resolveStatus() {
    switch (_selectedStatusLabel) {
      case '연락됨':
        return _AftercareStatus.completed;
      case '미연락':
        return _AftercareStatus.missed;
      default:
        return _AftercareStatus.scheduled;
    }
  }

  bool get _isValid =>
      _selectedDate != null && _selectedStatusLabel != null;

  void _submit() {
    setState(() => _submitted = true);
    if (!_isValid) return;
    widget.onAdd(
      _AftercareItem(
        date: _selectedDate!,
        status: _resolveStatus(),
        method: _selectedMethod,
        content: _contentCtrl.text.trim().isEmpty
            ? null
            : _contentCtrl.text.trim(),
      ),
    );
    Navigator.of(context).pop();
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
            Text('사후관리 기록 추가', style: AppTypography.title),
            const SizedBox(height: 20),

            // 날짜
            _SheetLabel('연락 날짜', required: true),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: _submitted && _selectedDate == null
                      ? Border.all(color: AppColors.red, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? _fmtDate(_selectedDate!)
                            : '날짜를 선택하세요',
                        style: AppTypography.body.copyWith(
                          color: _selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            if (_submitted && _selectedDate == null)
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  '날짜를 선택해주세요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.red,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // 연락 방법
            const _SheetLabel('연락 방법'),
            const SizedBox(height: 8),
            _ChipSelector(
              options: _contactMethods,
              selected: _selectedMethod,
              color: AppColors.primary,
              onSelected: (v) =>
                  setState(() => _selectedMethod = _selectedMethod == v ? null : v),
            ),
            const SizedBox(height: 16),

            // 연락 상태
            _SheetLabel('연락 상태', required: true),
            const SizedBox(height: 8),
            _ChipSelector(
              options: _statusLabels,
              selected: _selectedStatusLabel,
              color: AppColors.primaryDark,
              onSelected: (v) => setState(() => _selectedStatusLabel = v),
              error: _submitted && _selectedStatusLabel == null,
            ),
            const SizedBox(height: 16),

            // 내용
            const _SheetLabel('내용'),
            const SizedBox(height: 6),
            TextField(
              controller: _contentCtrl,
              maxLines: 4,
              style: AppTypography.body,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputBackground,
                hintText: '연락 결과 및 내담자 상태를 기록하세요 (선택)',
                hintStyle:
                    AppTypography.body.copyWith(color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '기록 저장',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 공용 시트 위젯 ────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _SheetLabel(this.text, {this.required = false});

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

class _ChipSelector extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final Color color;
  final ValueChanged<String> onSelected;
  final bool error;

  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.color,
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
            final isOn = selected == opt;
            return GestureDetector(
              onTap: () => onSelected(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isOn
                      ? color.withOpacity(0.1)
                      : AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isOn ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isOn ? color : AppColors.textSecondary,
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
