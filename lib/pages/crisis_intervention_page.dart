import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/primary_button.dart';

// ── 결과 모델 ─────────────────────────────────────────────────

class CrisisResult {
  final Set<String> selectedTypes;
  final List<String> completedActions;
  final bool supervisorNotified;

  const CrisisResult({
    required this.selectedTypes,
    required this.completedActions,
    required this.supervisorNotified,
  });
}

// ── 체크리스트 아이템 ─────────────────────────────────────────

class _CheckItem {
  final String id;
  final String label;
  final bool triggersAlert; // 체크 시 API 호출
  bool checked;

  _CheckItem({
    required this.id,
    required this.label,
    this.triggersAlert = false,
    this.checked = false,
  });
}

// ── 상수 ──────────────────────────────────────────────────────

const _crisisTypes = [
  '자살·자해',
  '가정폭력',
  '아동학대',
  '아동방임',
  '경제위기',
];

const _supervisorName = '이상훈';

// ── 진입 헬퍼 ─────────────────────────────────────────────────

Future<CrisisResult?> showCrisisIntervention(BuildContext context) {
  return Navigator.of(context).push<CrisisResult>(
    MaterialPageRoute(
      builder: (_) => const CrisisInterventionPage(),
      fullscreenDialog: true,
    ),
  );
}

// ── 페이지 ────────────────────────────────────────────────────

class CrisisInterventionPage extends StatefulWidget {
  const CrisisInterventionPage({super.key});

  @override
  State<CrisisInterventionPage> createState() => _CrisisInterventionPageState();
}

class _CrisisInterventionPageState extends State<CrisisInterventionPage> {
  final Set<String> _selectedTypes = {};

  late final List<_CheckItem> _checklist = [
    _CheckItem(id: 'safety', label: '안전 여부 확인'),
    _CheckItem(id: 'supervisor', label: '슈퍼바이저 알림 발송', triggersAlert: true),
    _CheckItem(id: 'report', label: '신고 기관 연계'),
    _CheckItem(id: 'guardian', label: '보호자 연락'),
  ];

  bool _notified = false;
  bool _notifying = false;

  bool get _canComplete => _selectedTypes.isNotEmpty;

  Future<void> _handleCheck(_CheckItem item, bool value) async {
    setState(() => item.checked = value);

    if (item.triggersAlert && value && !_notified) {
      // 슈퍼바이저 알림 API 시뮬레이션
      setState(() => _notifying = true);
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() {
          _notifying = false;
          _notified = true;
        });
      }
    }
  }

  void _complete() {
    final completed =
        _checklist.where((c) => c.checked).map((c) => c.label).toList();

    final result = CrisisResult(
      selectedTypes: Set.from(_selectedTypes),
      completedActions: completed,
      supervisorNotified: _notified,
    );

    HapticFeedback.heavyImpact();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          // ── 최상단 Red 배너 ──────────────────────────────────
          _RedBanner(safeTop: safeTop),

          // ── 스크롤 영역 ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 위기 유형 선택
                  const _SectionLabel('위기 유형 선택'),
                  const SizedBox(height: 10),
                  _CrisisTypeGrid(
                    selected: _selectedTypes,
                    onToggle: (t) => setState(() {
                      _selectedTypes.contains(t)
                          ? _selectedTypes.remove(t)
                          : _selectedTypes.add(t);
                    }),
                  ),
                  const SizedBox(height: 24),

                  // 체크리스트
                  const _SectionLabel('조치 체크리스트'),
                  const SizedBox(height: 10),
                  _Checklist(
                    items: _checklist,
                    onChanged: _handleCheck,
                    notifying: _notifying,
                    notified: _notified,
                  ),

                  // 슈퍼바이저 알림 확인 배너
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: _notified
                        ? const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: _NotifiedBanner(name: _supervisorName),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ── 하단 버튼 ─────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safeBottom),
            decoration: const BoxDecoration(
              color: AppColors.backgroundWhite,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_canComplete)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '위기 유형을 1개 이상 선택해야 기록할 수 있습니다.',
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
                    onPressed: _canComplete ? _complete : null,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      '조치 완료 기록',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.red.withOpacity(0.4),
                      disabledForegroundColor: Colors.white60,
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
        ],
      ),
    );
  }
}

// ── Red 배너 헤더 ─────────────────────────────────────────────

class _RedBanner extends StatelessWidget {
  final double safeTop;
  const _RedBanner({required this.safeTop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.red,
      padding: EdgeInsets.fromLTRB(16, safeTop + 12, 16, 14),
      child: Row(
        children: [
          // 닫기 버튼
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          // 경고 아이콘 + 텍스트
          const Icon(Icons.warning_amber_rounded,
              color: Colors.white, size: 22),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '위기개입 프로토콜 활성화',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  '내담자의 즉각적 안전을 확인하고 조치를 취하세요.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 레이블 ───────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.sectionHeader);
  }
}

// ── 위기 유형 칩 그리드 ───────────────────────────────────────

class _CrisisTypeGrid extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _CrisisTypeGrid({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: _crisisTypes.map((type) {
        final isSelected = selected.contains(type);
        return GestureDetector(
          onTap: () => onToggle(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.red.withOpacity(0.08)
                  : AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.red : AppColors.border,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_circle,
                      size: 14, color: AppColors.red),
                  const SizedBox(width: 5),
                ],
                Text(
                  type,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.red : AppColors.textSecondary,
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

// ── 체크리스트 ────────────────────────────────────────────────

class _Checklist extends StatelessWidget {
  final List<_CheckItem> items;
  final Future<void> Function(_CheckItem, bool) onChanged;
  final bool notifying;
  final bool notified;

  const _Checklist({
    required this.items,
    required this.onChanged,
    required this.notifying,
    required this.notified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;

          Widget trailing;
          if (item.triggersAlert && notifying && !notified) {
            trailing = const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryBlue,
              ),
            );
          } else {
            trailing = const SizedBox.shrink();
          }

          return Column(
            children: [
              CheckboxListTile(
                value: item.checked,
                title: Row(
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.checked
                            ? AppColors.teal
                            : AppColors.textPrimary,
                        decoration: item.checked
                            ? TextDecoration.none
                            : TextDecoration.none,
                      ),
                    ),
                    if (item.triggersAlert && notified) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '발송됨',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                secondary: trailing,
                onChanged: (item.triggersAlert && notifying)
                    ? null
                    : (v) => onChanged(item, v ?? false),
                checkColor: Colors.white,
                activeColor: AppColors.teal,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: item.checked ? AppColors.teal : AppColors.border,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
              if (!isLast)
                const Divider(height: 1, thickness: 1, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── 슈퍼바이저 알림 확인 배너 ────────────────────────────────

class _NotifiedBanner extends StatelessWidget {
  final String name;
  const _NotifiedBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.teal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              size: 18, color: AppColors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: AppColors.teal,
                ),
                children: [
                  const TextSpan(text: '슈퍼바이저 '),
                  TextSpan(
                    text: '$name님',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: '께 알림이 발송되었습니다.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
Widget _unused(PrimaryButton w) => w;
