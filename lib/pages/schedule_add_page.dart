import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';

class ScheduleAddPage extends StatefulWidget {
  final String? preselectedClientId;
  const ScheduleAddPage({super.key, this.preselectedClientId});

  @override
  State<ScheduleAddPage> createState() => _ScheduleAddPageState();
}

class _ScheduleAddPageState extends State<ScheduleAddPage> {
  final _memoController = TextEditingController();

  Map<String, dynamic>? _selectedClient;
  String _selectedDate = '';
  String _startTime = '09:00';
  String _endTime = '10:00';
  String _sessionType = '개인상담';
  String _sessionMethod = '대면';
  bool _isLoading = false;
  bool _isSaving = false;

  List<Map<String, dynamic>> _clients = [];

  static const _sessionTypes = ['개인상담', '가족상담', '집단상담', '위기상담', '사례관리'];
  static const _sessionMethods = ['대면', '전화', '영상', '방문'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _loadClients();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final result = await ClientService().list();
      if (!mounted) return;
      setState(() {
        _clients = List<Map<String, dynamic>>.from(result['clients'] ?? []);
        if (widget.preselectedClientId != null) {
          _selectedClient = _clients.firstWhere(
            (c) => (c['clientId'] ?? c['client_id']) == widget.preselectedClientId,
            orElse: () => _clients.isNotEmpty ? _clients.first : {},
          );
        } else if (_clients.isNotEmpty) {
          _selectedClient = _clients.first;
        }
        _isLoading = false;
      });
    } on DioException catch (_) {
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_selectedDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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

  Future<void> _onSave() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내담자를 선택해주세요.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final clientId = (_selectedClient!['clientId'] ?? _selectedClient!['client_id']) as String? ?? '';
      await SessionService().create(
        clientId,
        sessionDate: _selectedDate,
        sessionTimeStart: _startTime,
        sessionTimeEnd: _endTime,
        sessionMethod: _sessionMethod,
        sessionType: _sessionType,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? '일정 저장에 실패했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('일정 저장에 실패했습니다.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        title: Text('일정 추가', style: AppTypography.h3),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _onSave,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '저장',
                    style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel('내담자'),
                  _buildClientDropdown(),
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
                        child: const Icon(Icons.calendar_today_outlined,
                            color: AppColors.textHint, size: 22),
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
                  _FieldLabel('상담 유형'),
                  _buildDropdown(
                    value: _sessionType,
                    items: _sessionTypes,
                    onChanged: (v) => setState(() => _sessionType = v!),
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('상담 방법'),
                  _buildDropdown(
                    value: _sessionMethod,
                    items: _sessionMethods,
                    onChanged: (v) => setState(() => _sessionMethod = v!),
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
                ],
              ),
            ),
    );
  }

  Widget _buildClientDropdown() {
    if (_clients.isEmpty) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.backgroundSubtle,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('내담자 없음', style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
        ),
      );
    }
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedClient,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textHint, size: 18),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          dropdownColor: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          items: _clients
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      '${c['name'] ?? ''}'
                      '${c['contact_phone'] != null ? ' (${c['contact_phone']})' : ''}',
                    ),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedClient = v),
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
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textHint, size: 18),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          dropdownColor: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
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
