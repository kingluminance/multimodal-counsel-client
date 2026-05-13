import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

// ── 모델 ─────────────────────────────────────────────────────

class _PrivacyItem {
  final String id;
  final String label;
  final String? subtitle;

  const _PrivacyItem({required this.id, required this.label, this.subtitle});
}

class _PrivacySection {
  final String title;
  final IconData icon;
  final List<_PrivacyItem> items;

  const _PrivacySection({
    required this.title,
    required this.icon,
    required this.items,
  });
}

// ── 상수 ─────────────────────────────────────────────────────

const _sections = [
  _PrivacySection(
    title: '기본 정보',
    icon: Icons.person_outline,
    items: [
      _PrivacyItem(id: 'name', label: '이름', subtitle: '내담자 실명 공개 여부'),
      _PrivacyItem(id: 'contact', label: '연락처', subtitle: '전화번호 및 이메일'),
      _PrivacyItem(id: 'address', label: '주소', subtitle: '거주지 주소'),
      _PrivacyItem(id: 'birthdate', label: '생년월일', subtitle: '만 나이 포함'),
      _PrivacyItem(id: 'gender', label: '성별'),
    ],
  ),
  _PrivacySection(
    title: '생체 데이터',
    icon: Icons.monitor_heart_outlined,
    items: [
      _PrivacyItem(id: 'heartrate', label: '심박수', subtitle: '실시간 및 평균치'),
      _PrivacyItem(id: 'bp', label: '혈압', subtitle: '수축기 / 이완기'),
      _PrivacyItem(id: 'stress', label: '스트레스 지수'),
      _PrivacyItem(id: 'sleep', label: '수면 패턴'),
      _PrivacyItem(id: 'emotion', label: '감정 상태 분석', subtitle: 'AI 카메라 분석 결과'),
    ],
  ),
  _PrivacySection(
    title: '평가 항목',
    icon: Icons.assignment_outlined,
    items: [
      _PrivacyItem(id: 'risk', label: '위험도 등급', subtitle: '고·중·저위험 분류'),
      _PrivacyItem(id: 'needs', label: '욕구 목록', subtitle: '개인 복지 욕구 항목'),
      _PrivacyItem(id: 'goals', label: '상담 목표', subtitle: '단·중기 목표'),
      _PrivacyItem(id: 'session_notes', label: '상담 기록', subtitle: '세션 요약 및 AI 초안'),
    ],
  ),
];

const _sampleClients = [
  '김지수',
  '이준혁',
  '박서연',
  '최민준',
  '한소희',
];

// ── 페이지 ────────────────────────────────────────────────────

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  String _selectedClient = _sampleClients[0];
  final Map<String, bool> _switches = {
    for (final section in _sections)
      for (final item in section.items) item.id: true,
  };
  bool _saved = false;

  int get _enabledCount => _switches.values.where((v) => v).length;
  int get _totalCount => _switches.length;

  void _toggleAll(bool value) {
    setState(() {
      for (final key in _switches.keys) {
        _switches[key] = value;
      }
      _saved = false;
    });
  }

  void _save() {
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$_selectedClient님의 공개 항목이 저장되었습니다.',
          style: const TextStyle(fontFamily: 'Pretendard'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.teal,
      ),
    );
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
        title: const Text('공개 항목 설정', style: AppTypography.title),
      ),
      body: Column(
        children: [
          // ── 내담자 선택 + 요약 ─────────────────────────────
          Container(
            color: AppColors.backgroundWhite,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              children: [
                // 내담자 드롭다운
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedClient,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary),
                      style: AppTypography.body,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _selectedClient = v;
                            _saved = false;
                            // 클라이언트 변경 시 스위치 초기화 (실제로는 API로 불러옴)
                            for (final key in _switches.keys) {
                              _switches[key] = true;
                            }
                          });
                        }
                      },
                      items: _sampleClients
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_outline,
                                        size: 16,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(c, style: AppTypography.body),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // 요약 + 전체 토글
                Row(
                  children: [
                    Text(
                      '$_enabledCount/$_totalCount개 항목 공개 중',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _toggleAll(true),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '전체 공개',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                    const Text(
                      '·',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                    TextButton(
                      onPressed: () => _toggleAll(false),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '전체 비공개',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // ── 스위치 리스트 ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding:
                  EdgeInsets.fromLTRB(16, 16, 16, 16 + safeBottom + 70),
              itemCount: _sections.length,
              itemBuilder: (context, si) {
                final section = _sections[si];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _SectionBlock(
                    section: section,
                    switches: _switches,
                    onChanged: (id, value) {
                      setState(() {
                        _switches[id] = value;
                        _saved = false;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // ── 하단 저장 버튼 ────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safeBottom),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _saved ? AppColors.teal : AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _saved ? '저장됨' : '저장',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 섹션 블록 ─────────────────────────────────────────────────

class _SectionBlock extends StatelessWidget {
  final _PrivacySection section;
  final Map<String, bool> switches;
  final void Function(String id, bool value) onChanged;

  const _SectionBlock({
    required this.section,
    required this.switches,
    required this.onChanged,
  });

  bool get _allOn => section.items.every((i) => switches[i.id] == true);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          // 섹션 헤더
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(section.icon,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(section.title,
                    style: AppTypography.sectionHeader),
                const Spacer(),
                // 섹션 전체 토글
                GestureDetector(
                  onTap: () {
                    final newVal = !_allOn;
                    for (final item in section.items) {
                      onChanged(item.id, newVal);
                    }
                  },
                  child: Text(
                    _allOn ? '전체 OFF' : '전체 ON',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _allOn ? AppColors.red : AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 스위치 목록
          ...section.items.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final isLast = i == section.items.length - 1;
            final isOn = switches[item.id] ?? true;

            return Column(
              children: [
                SwitchListTile(
                  value: isOn,
                  onChanged: (v) => onChanged(item.id, v),
                  activeColor: AppColors.teal,
                  title: Text(
                    item.label,
                    style: AppTypography.body.copyWith(
                      color: isOn
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  subtitle: item.subtitle != null
                      ? Text(
                          item.subtitle!,
                          style: AppTypography.caption.copyWith(
                            color: isOn
                                ? AppColors.textSecondary
                                : AppColors.textHint,
                          ),
                        )
                      : null,
                  secondary: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isOn ? AppColors.teal : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                  ),
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                ),
                if (!isLast)
                  const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }
}
