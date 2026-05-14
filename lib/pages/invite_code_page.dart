import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/status_badge.dart';
import '../widgets/primary_button.dart';

// ── 역할 ─────────────────────────────────────────────────────

enum _CodeRole { counselor, supervisor, admin }

extension _CodeRoleX on _CodeRole {
  String get label {
    switch (this) {
      case _CodeRole.counselor:
        return '사회복지사';
      case _CodeRole.supervisor:
        return '슈퍼바이저';
      case _CodeRole.admin:
        return '관리자';
    }
  }

  Color get color {
    switch (this) {
      case _CodeRole.counselor:
        return AppColors.primary;
      case _CodeRole.supervisor:
        return AppColors.purple;
      case _CodeRole.admin:
        return AppColors.amber;
    }
  }

  Color get bgColor {
    switch (this) {
      case _CodeRole.counselor:
        return AppColors.primary.withOpacity(0.08);
      case _CodeRole.supervisor:
        return AppColors.purple.withOpacity(0.08);
      case _CodeRole.admin:
        return AppColors.amber.withOpacity(0.08);
    }
  }
}

// ── 모델 ─────────────────────────────────────────────────────

class _InviteCode {
  final String code;
  final _CodeRole role;
  final String org;
  final DateTime expiresAt;
  final int usedCount;
  final int maxCount;
  final String? memo;

  const _InviteCode({
    required this.code,
    required this.role,
    required this.org,
    required this.expiresAt,
    required this.usedCount,
    required this.maxCount,
    this.memo,
  });

  bool get isExpired =>
      DateTime.now().isAfter(expiresAt) || usedCount >= maxCount;
}

// ── 상수 ─────────────────────────────────────────────────────

const _roleLabels = ['사회복지사', '슈퍼바이저', '관리자'];
const _orgLabels = ['행복복지관', '한마음복지관', '희망케어센터', '미래복지원'];

final _sampleCodes = [
  _InviteCode(
    code: 'A1B2-C3D4',
    role: _CodeRole.counselor,
    org: '행복복지관',
    expiresAt: DateTime(2025, 6, 15),
    usedCount: 2,
    maxCount: 5,
    memo: '2팀 신규 채용',
  ),
  _InviteCode(
    code: 'X7Y8-Z9W0',
    role: _CodeRole.supervisor,
    org: '행복복지관',
    expiresAt: DateTime(2025, 5, 1),
    usedCount: 1,
    maxCount: 1,
    memo: null,
  ),
  _InviteCode(
    code: 'P3Q4-R5S6',
    role: _CodeRole.counselor,
    org: '한마음복지관',
    expiresAt: DateTime(2025, 7, 31),
    usedCount: 0,
    maxCount: 3,
    memo: '3분기 확충',
  ),
  _InviteCode(
    code: 'M1N2-O3P4',
    role: _CodeRole.admin,
    org: '희망케어센터',
    expiresAt: DateTime(2025, 12, 31),
    usedCount: 0,
    maxCount: 1,
    memo: '신규 기관 관리자',
  ),
];

// ── 페이지 ────────────────────────────────────────────────────

class InviteCodePage extends StatefulWidget {
  const InviteCodePage({super.key});

  @override
  State<InviteCodePage> createState() => _InviteCodePageState();
}

class _InviteCodePageState extends State<InviteCodePage> {
  List<_InviteCode> _codes = List.from(_sampleCodes);

  void _deleteCode(_InviteCode code) {
    final idx = _codes.indexOf(code);
    setState(() => _codes.remove(code));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '초대코드가 취소되었습니다.',
          style: TextStyle(fontFamily: 'Pretendard'),
        ),
        action: SnackBarAction(
          label: '되돌리기',
          onPressed: () => setState(() => _codes.insert(idx, code)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showIssueSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _IssueCodeSheet(),
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
        title: Text('초대코드 관리', style: AppTypography.title),
      ),
      body: _codes.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _codes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final code = _codes[i];
                return Dismissible(
                  key: ValueKey(code.code),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteCode(code),
                  background: _DismissBackground(),
                  child: _CodeCard(
                    code: code,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: code.code));
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '코드가 복사되었습니다.',
                            style: TextStyle(fontFamily: 'Pretendard'),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showIssueSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          '초대코드 발급',
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
          Icon(Icons.key_off_outlined, size: 44, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            '발급된 초대코드가 없습니다.',
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

// ── 삭제 배경 ─────────────────────────────────────────────────

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 60),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 22),
          SizedBox(height: 2),
          Text(
            '취소',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 코드 카드 ─────────────────────────────────────────────────

class _CodeCard extends StatelessWidget {
  final _InviteCode code;
  final VoidCallback onCopy;

  const _CodeCard({required this.code, required this.onCopy});

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final expired = code.isExpired;

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
          // ── 상단 행: 코드 + 복사 + 배지 ──────────────────
          Row(
            children: [
              // 모노스페이스 코드
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: expired
                      ? AppColors.inputBackground
                      : AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code.code,
                  style: TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: expired
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // 복사 아이콘
              if (!expired)
                GestureDetector(
                  onTap: onCopy,
                  child: const Icon(
                    Icons.copy_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              const Spacer(),
              // 유효/만료 배지
              expired
                  ? const StatusBadge.closed(label: '만료')
                  : const StatusBadge.active(label: '유효'),
            ],
          ),
          const SizedBox(height: 10),

          // ── 하단 행: 역할칩 + 기관 + 만료일 + 사용현황 ──
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // 역할 칩
              _RoleChip(role: code.role),
              // 기관
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.business_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(code.org, style: AppTypography.caption),
                ],
              ),
              // 만료일
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    '${_fmtDate(code.expiresAt)} 까지',
                    style: AppTypography.caption,
                  ),
                ],
              ),
              // 사용 현황
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    '${code.usedCount}/${code.maxCount} 사용',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: code.usedCount >= code.maxCount
                          ? AppColors.red
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 메모
          if (code.memo != null) ...[
            const SizedBox(height: 8),
            Text(
              code.memo!,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
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

// ── 역할 칩 ───────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final _CodeRole role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: role.bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: role.color,
        ),
      ),
    );
  }
}

// ── 초대코드 발급 바텀시트 ────────────────────────────────────

class _IssueCodeSheet extends StatefulWidget {
  const _IssueCodeSheet();

  @override
  State<_IssueCodeSheet> createState() => _IssueCodeSheetState();
}

class _IssueCodeSheetState extends State<_IssueCodeSheet> {
  String? _selectedRole;
  String? _selectedOrg;
  DateTime? _expiresAt;
  final _maxCountCtrl = TextEditingController(text: '5');
  final _memoCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _maxCountCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  bool get _isValid =>
      _selectedRole != null && _selectedOrg != null && _expiresAt != null;

  void _submit() {
    setState(() => _submitted = true);
    if (!_isValid) return;
    Navigator.of(context).pop();
    // TODO: 실제 코드 발급 API
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
            Text('초대코드 발급', style: AppTypography.title),
            const SizedBox(height: 20),

            // 역할 선택
            _SheetLabel('역할', required: true),
            const SizedBox(height: 6),
            _DropdownField(
              value: _selectedRole,
              hint: '역할을 선택하세요',
              items: _roleLabels,
              onChanged: (v) => setState(() => _selectedRole = v),
              error: _submitted && _selectedRole == null ? '역할을 선택해주세요' : null,
            ),
            const SizedBox(height: 16),

            // 기관 선택
            _SheetLabel('기관', required: true),
            const SizedBox(height: 6),
            _DropdownField(
              value: _selectedOrg,
              hint: '기관을 선택하세요',
              items: _orgLabels,
              onChanged: (v) => setState(() => _selectedOrg = v),
              error: _submitted && _selectedOrg == null ? '기관을 선택해주세요' : null,
            ),
            const SizedBox(height: 16),

            // 유효기간
            _SheetLabel('유효기간', required: true),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: _submitted && _expiresAt == null
                      ? Border.all(color: AppColors.red, width: 1)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _expiresAt != null ? _fmtDate(_expiresAt!) : '날짜를 선택하세요',
                        style: AppTypography.body.copyWith(
                          color: _expiresAt != null
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
            if (_submitted && _expiresAt == null)
              const Padding(
                padding: EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  '유효기간을 선택해주세요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.red,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // 최대 사용 횟수
            _SheetLabel('최대 사용 횟수'),
            const SizedBox(height: 6),
            SizedBox(
              height: 44,
              child: TextField(
                controller: _maxCountCtrl,
                keyboardType: TextInputType.number,
                style: AppTypography.body,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  hintText: '예: 5',
                  hintStyle:
                      AppTypography.body.copyWith(color: AppColors.textHint),
                  suffixText: '회',
                  suffixStyle: AppTypography.body
                      .copyWith(color: AppColors.textSecondary),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 메모
            const _SheetLabel('메모'),
            const SizedBox(height: 6),
            TextField(
              controller: _memoCtrl,
              maxLines: 3,
              style: AppTypography.body,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.inputBackground,
                hintText: '메모를 입력하세요 (선택)',
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: '발급하기', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}

// ── 시트 공용 위젯 ────────────────────────────────────────────

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

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? error;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.items,
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
                hint,
                style: AppTypography.body.copyWith(color: AppColors.textHint),
              ),
              style: AppTypography.body,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, style: AppTypography.body),
                      ))
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
