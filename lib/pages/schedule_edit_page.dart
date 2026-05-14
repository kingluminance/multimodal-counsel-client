import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class ScheduleEditPage extends StatefulWidget {
  const ScheduleEditPage({super.key});

  @override
  State<ScheduleEditPage> createState() => _ScheduleEditPageState();
}

class _ScheduleEditPageState extends State<ScheduleEditPage> {
  final _titleController = TextEditingController(text: '김민지 · 진로 상담');
  final _memoController = TextEditingController(text: '진로 적성 검사 결과 함께 검토');

  String _selectedClient = '김민지 (010-1234-5678)';
  String _selectedDate = '2026-05-14';
  String _startTime = '14:00';
  String _endTime = '15:00';
  String _topic = '진로 상담';
  String _reminder = '시작 30분 전';

  final _clients = ['김민지 (010-1234-5678)', '박지현 (010-2345-6789)', '이서연 (010-3456-7890)'];
  final _topics = ['진로 상담', '대인관계', '학업 스트레스', '가족관계', '기타'];
  final _reminders = ['없음', '시작 10분 전', '시작 30분 전', '1시간 전', '1일 전'];

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 5, 14),
      firstDate: DateTime(2026),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('일정 수정', style: AppTypography.h3),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('저장', style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel('제목'),
            _buildTextField(_titleController, '일정 제목'),
            const SizedBox(height: 16),
            _FieldLabel('내담자'),
            _buildDropdown(
              value: _selectedClient,
              items: _clients,
              onChanged: (v) => setState(() => _selectedClient = v!),
            ),
            const SizedBox(height: 16),
            _FieldLabel('날짜'),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSubtle,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_selectedDate, style: AppTypography.bodyMedium),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: const Icon(Icons.calendar_today_outlined, color: AppColors.textHint, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('시작 시간'),
                      _buildDropdown(
                        value: _startTime,
                        items: _timeOptions(),
                        onChanged: (v) => setState(() => _startTime = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('종료 시간'),
                      _buildDropdown(
                        value: _endTime,
                        items: _timeOptions(),
                        onChanged: (v) => setState(() => _endTime = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FieldLabel('주제'),
            _buildDropdown(
              value: _topic,
              items: _topics,
              onChanged: (v) => setState(() => _topic = v!),
            ),
            const SizedBox(height: 16),
            _FieldLabel('알림'),
            _buildDropdown(
              value: _reminder,
              items: _reminders,
              onChanged: (v) => setState(() => _reminder = v!),
            ),
            const SizedBox(height: 16),
            _FieldLabel('메모'),
            TextField(
              controller: _memoController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '메모를 입력하세요.',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.backgroundSubtle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
            const SizedBox(height: 24),
            // 일정 삭제하기 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('일정 삭제하기', style: AppTypography.buttonText.copyWith(color: AppColors.danger)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _timeOptions() {
    final opts = <String>[];
    for (int h = 8; h <= 20; h++) {
      for (int m = 0; m < 60; m += 30) {
        opts.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
      }
    }
    return opts;
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.backgroundSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint, size: 18),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          dropdownColor: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTypography.sectionHeader),
    );
  }
}
