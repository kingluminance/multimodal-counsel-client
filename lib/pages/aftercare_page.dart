import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';

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
  final String? method;
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

// ── 페이지 ────────────────────────────────────────────────────

class AftercarePage extends StatefulWidget {
  final String clientId;
  final String clientName;

  const AftercarePage({
    super.key,
    required this.clientId,
    this.clientName = '',
  });

  @override
  State<AftercarePage> createState() => _AftercarePageState();
}

class _AftercarePageState extends State<AftercarePage> {
  List<_AftercareItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAftercare();
  }

  Future<void> _loadAftercare() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await ClosingService().listAftercare(widget.clientId);
      if (!mounted) return;
      final raw = List<dynamic>.from(result['aftercare'] ?? []);
      final items = raw.map((e) {
        final m = e as Map<String, dynamic>;
        final dateStr = m['contact_date'] as String? ?? '';
        DateTime date;
        try {
          date = DateTime.parse(dateStr);
        } catch (_) {
          date = DateTime.now();
        }
        final note = m['note'] as String?;
        final now = DateTime.now();
        _AftercareStatus status;
        if (date.isAfter(now)) {
          status = _AftercareStatus.scheduled;
        } else if (note != null && note.isNotEmpty) {
          status = _AftercareStatus.completed;
        } else {
          status = _AftercareStatus.missed;
        }
        return _AftercareItem(
          date: date,
          status: status,
          method: m['contact_method'] as String?,
          content: note,
        );
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response?.data?['message'] ?? '데이터를 불러오지 못했습니다.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '데이터를 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
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
    final displayName =
        widget.clientName.isNotEmpty ? widget.clientName : '내담자';
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        titleSpacing: 16,
        title: Text('$displayName · 사후관리', style: AppTypography.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.danger),
                  ),
                )
              : _items.isEmpty
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
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 2),
                _TimelineDot(status: item.status, color: color),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
  String? _selectedStatusLabel;
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
      lastDate: DateTime(2030),
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

  bool get _isValid => _selectedDate != null && _selectedStatusLabel != null;

  void _submit() {
    setState(() => _submitted = true);
    if (!_isValid) return;
    widget.onAdd(
      _AftercareItem(
        date: _selectedDate!,
        status: _resolveStatus(),
        method: _selectedMethod,
        content: _contentCtrl.text.trim().isEmpty ? null : _contentCtrl.text.trim(),
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
                hintStyle: AppTypography.body.copyWith(color: AppColors.textHint),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isOn ? color.withOpacity(0.1) : AppColors.inputBackground,
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
