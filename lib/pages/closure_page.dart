import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/services.dart';

// ── 상수 ─────────────────────────────────────────────────────

const _closureReasons = [
  '목표달성',
  '자발적종결',
  '기관이전',
  '사망',
  '기타',
];

// ── 페이지 ────────────────────────────────────────────────────

class ClosurePage extends StatefulWidget {
  final String clientName;
  final String clientId;

  const ClosurePage({
    super.key,
    this.clientName = '김지수',
    this.clientId = '',
  });

  @override
  State<ClosurePage> createState() => _ClosurePageState();
}

class _ClosurePageState extends State<ClosurePage> {
  final Set<String> _selectedReasons = {};
  final _riskFactorCtrl = TextEditingController();
  final _aftercareCtrl = TextEditingController();
  final _draftCtrl = TextEditingController();
  DateTime? _contactDate;
  bool _isGenerating = false;
  bool _hasDraft = false;
  bool _isLoading = false;
  String? _existingClosingId;

  @override
  void initState() {
    super.initState();
    if (widget.clientId.isNotEmpty) {
      _loadExistingClosing();
    }
  }

  @override
  void dispose() {
    _riskFactorCtrl.dispose();
    _aftercareCtrl.dispose();
    _draftCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExistingClosing() async {
    setState(() => _isLoading = true);
    try {
      final data = await ClosingService().get(widget.clientId);
      if (!mounted) return;
      setState(() {
        _existingClosingId = data['closing_id']?.toString();
        final reason = data['closing_reason']?.toString();
        if (reason != null && reason.isNotEmpty) {
          _selectedReasons.add(reason);
        }
        final summary = data['closing_summary']?.toString();
        if (summary != null && summary.isNotEmpty) {
          _draftCtrl.text = summary;
          _hasDraft = true;
        }
        final closingDate = data['closing_date']?.toString();
        if (closingDate != null && closingDate.isNotEmpty) {
          try {
            _contactDate = DateTime.parse(closingDate);
          } catch (_) {}
        }
      });
    } on DioException {
      // 종결 정보가 없는 경우(404 등) 무시
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  String _fmtDateApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickContactDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _contactDate = picked);
  }

  Future<void> _generateDraft() async {
    if (widget.clientId.isEmpty) return;
    setState(() => _isGenerating = true);
    try {
      await ClosingService().generateSummary(widget.clientId);
      if (!mounted) return;
      // 202 Accepted → 비동기 생성 중
      // TODO: 실제 완료는 폴링 또는 웹소켓으로 처리 필요
      // 임시로 3초 후 더미 초안 표시
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _hasDraft = true;
        _draftCtrl.text =
            '내담자 ${widget.clientName}님은 2023년 3월부터 2025년 5월까지 총 24회기의 상담을 진행하였습니다. '
            '초기 호소 문제였던 가정폭력 후유 PTSD 증상이 현저히 감소하였으며, 사회적 지지체계 강화 및 자립 역량 향상 목표를 78% 달성하였습니다. '
            '잔여 위험 요인으로는 경제적 불안정 상태가 지속되고 있어 지역 자활센터 연계가 권고됩니다. '
            '사후관리를 통해 6개월 주기로 안부 확인 및 복지서비스 연계를 지속할 예정입니다.';
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  bool get _canSubmit => _selectedReasons.isNotEmpty;

  void _showConfirmDialog() {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('종결 사유를 1개 이상 선택해주세요.',
              style: TextStyle(fontFamily: 'Pretendard')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        clientName: widget.clientName,
        onConfirm: _saveAndClose,
      ),
    );
  }

  Future<void> _saveAndClose() async {
    if (widget.clientId.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    try {
      final closingDate = _contactDate != null
          ? _fmtDateApi(_contactDate!)
          : _fmtDateApi(DateTime.now());
      final closingReason = _selectedReasons.join(',');
      final closingSummary =
          _draftCtrl.text.isNotEmpty ? _draftCtrl.text : null;

      if (_existingClosingId != null) {
        await ClosingService().update(widget.clientId, {
          'closing_date': closingDate,
          'closing_reason': closingReason,
          if (closingSummary != null) 'closing_summary': closingSummary,
        });
      } else {
        await ClosingService().create(
          widget.clientId,
          closingDate: closingDate,
          closingReason: closingReason,
          closingSummary: closingSummary,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(); // dialog
      Navigator.of(context).pop(); // closure page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.clientName}님 케이스가 종결되었습니다.',
            style: const TextStyle(fontFamily: 'Pretendard'),
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        titleSpacing: 16,
        title: Text('${widget.clientName} · 종결 등록',
            style: AppTypography.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.fromLTRB(16, 16, 16, 16 + safeBottom + 64),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 요약 카드 ────────────────────────────
                        _SummaryCard(clientName: widget.clientName),
                        const SizedBox(height: 24),

                        // ── 종결 사유 ────────────────────────────
                        const _SectionLabel('종결 사유', required: true),
                        const SizedBox(height: 10),
                        _ReasonChips(
                          selected: _selectedReasons,
                          onToggle: (r) => setState(() {
                            _selectedReasons.contains(r)
                                ? _selectedReasons.remove(r)
                                : _selectedReasons.add(r);
                          }),
                        ),
                        const SizedBox(height: 24),

                        // ── 잔여 위험 요인 ───────────────────────
                        const _SectionLabel('잔여 위험 요인'),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _riskFactorCtrl,
                          maxLines: 3,
                          hint: '종결 후 남아 있는 위험 요인을 기술하세요.',
                        ),
                        const SizedBox(height: 20),

                        // ── 사후관리 계획 ────────────────────────
                        const _SectionLabel('사후관리 계획'),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _aftercareCtrl,
                          maxLines: 3,
                          hint: '사후관리 방향 및 연계 기관을 기술하세요.',
                        ),
                        const SizedBox(height: 20),

                        // ── 사후 연락 예정일 ─────────────────────
                        const _SectionLabel('사후 연락 예정일'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickContactDate,
                          child: Container(
                            height: 44,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _contactDate != null
                                        ? _fmtDate(_contactDate!)
                                        : '날짜를 선택하세요',
                                    style: AppTypography.body.copyWith(
                                      color: _contactDate != null
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
                        const SizedBox(height: 28),

                        // ── AI 종결 요약 초안 ────────────────────
                        const _SectionLabel('AI 종결 요약'),
                        const SizedBox(height: 10),

                        // AI 생성 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _isGenerating ? null : _generateDraft,
                            icon: _isGenerating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.purple,
                                    ),
                                  )
                                : const Icon(Icons.auto_awesome_outlined,
                                    size: 18, color: AppColors.purple),
                            label: Text(
                              _isGenerating
                                  ? 'AI 초안 생성 중...'
                                  : (_hasDraft ? '초안 재생성' : 'AI 종결 요약 초안 생성'),
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.purple,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.purple, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              disabledForegroundColor:
                                  AppColors.purple.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 초안 텍스트 영역
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          decoration: BoxDecoration(
                            color: _hasDraft
                                ? AppColors.purple.withOpacity(0.03)
                                : AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _hasDraft
                                  ? AppColors.purple.withOpacity(0.5)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              TextField(
                                controller: _draftCtrl,
                                maxLines: 6,
                                style: AppTypography.body,
                                decoration: InputDecoration(
                                  hintText: _hasDraft
                                      ? null
                                      : 'AI 초안 생성 버튼을 눌러 요약 초안을 생성하세요.\n생성 후 직접 수정할 수 있습니다.',
                                  hintStyle: AppTypography.body
                                      .copyWith(color: AppColors.textHint),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(14),
                                ),
                              ),
                              if (_hasDraft)
                                Positioned(
                                  top: 8,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.purple.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.auto_awesome,
                                            size: 10, color: AppColors.purple),
                                        SizedBox(width: 3),
                                        Text(
                                          'AI 초안',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.purple,
                                          ),
                                        ),
                                      ],
                                    ),
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
      // ── 하단 종결 확정 버튼 ────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safeBottom),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_canSubmit)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '종결 사유를 1개 이상 선택해야 합니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _showConfirmDialog,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text(
                  '종결 확정',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _canSubmit ? AppColors.primaryDark : AppColors.primaryDark.withOpacity(0.4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

// ── 요약 카드 ─────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String clientName;
  const _SummaryCard({required this.clientName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, Color(0xFF168262)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_open_outlined,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                '$clientName 님 · 상담 요약',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCol(label: '총 회기수', value: '24', unit: '회'),
              _Divider(),
              _StatCol(label: '상담 기간', value: '26', unit: '개월'),
              _Divider(),
              _StatCol(label: '목표달성률', value: '78', unit: '%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatCol({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3, left: 2),
              child: Text(
                unit,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white24,
    );
  }
}

// ── 종결 사유 칩 ──────────────────────────────────────────────

class _ReasonChips extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _ReasonChips({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: _closureReasons.map((reason) {
        final isOn = selected.contains(reason);
        return GestureDetector(
          onTap: () => onToggle(reason),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isOn
                  ? AppColors.primaryDark.withOpacity(0.09)
                  : AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isOn ? AppColors.primaryDark : AppColors.border,
                width: isOn ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isOn) ...[
                  const Icon(Icons.check_circle,
                      size: 14, color: AppColors.primaryDark),
                  const SizedBox(width: 5),
                ],
                Text(
                  reason,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOn
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── 섹션 레이블 ───────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _SectionLabel(this.text, {this.required = false});

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

// ── 종결 확인 다이얼로그 ──────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final String clientName;
  final Future<void> Function() onConfirm;

  const _ConfirmDialog({
    required this.clientName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 22),
          SizedBox(width: 8),
          Text(
            '종결 확정',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
          children: [
            TextSpan(
              text: '$clientName',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(
              text:
                  '님의 케이스를 종결 처리합니다.\n\n종결 후에는 되돌릴 수 없으며, 케이스는 종결 상태로 기록됩니다. 계속 진행하시겠습니까?',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            '취소',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => onConfirm(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            '종결 확정',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
Widget _unusedPrimaryButton(PrimaryButton w) => w;
