import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/section_card.dart';
import '../widgets/primary_button.dart';

// ── AI 초안 데이터 ────────────────────────────────────────────

const _draftSections = [
  _DraftSection(
    label: '주제',
    icon: Icons.topic_outlined,
    content: '내담자는 최근 직장 스트레스와 가족 갈등으로 인한 극심한 불안감을 호소하였음. 수면 장애와 식욕 감소 증상이 지속되고 있으며, 사회적 고립감이 심화되는 양상을 보임.',
  ),
  _DraftSection(
    label: '위험',
    icon: Icons.warning_amber_outlined,
    content: '자해 관련 언급 1회 감지됨 (직접적 위협 수준은 아님). 사회적 고립 지속으로 인한 우울 심화. 전반적 위험수준: 중위험.',
  ),
  _DraftSection(
    label: '욕구',
    icon: Icons.favorite_outline,
    content: '정서적 지지 욕구 최우선. 직업 안정 및 경제적 불안 해소. 가족 관계 개선을 통한 지지 체계 강화.',
  ),
  _DraftSection(
    label: '개입',
    icon: Icons.handshake_outlined,
    content: '인지행동치료(CBT) 기반 감정 조절 기법 적용. 호흡 훈련 및 이완 기법 안내. 부정적 자동사고 탐색 및 대안적 사고 방식 훈련 실시.',
  ),
  _DraftSection(
    label: '계획',
    icon: Icons.checklist_outlined,
    content: '주 1회 정기 상담 지속. 다음 회기 전 기분 일지 작성 과제 부여. 필요 시 정신건강복지센터 연계 검토.',
  ),
];

class _DraftSection {
  final String label;
  final IconData icon;
  final String content;
  const _DraftSection({required this.label, required this.icon, required this.content});
}

// ── 페이지 ────────────────────────────────────────────────────

class SessionAiReviewPage extends StatefulWidget {
  const SessionAiReviewPage({super.key});

  @override
  State<SessionAiReviewPage> createState() => _SessionAiReviewPageState();
}

class _SessionAiReviewPageState extends State<SessionAiReviewPage> {
  final Map<String, TextEditingController> _controllers = {
    for (final s in _draftSections) s.label: TextEditingController(text: s.content),
  };
  final Map<String, bool> _editing = {
    for (final s in _draftSections) s.label: false,
  };
  bool _confirming = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleEdit(String label) {
    setState(() => _editing[label] = !(_editing[label] ?? false));
  }

  Future<void> _signConfirm() async {
    setState(() => _confirming = true);
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(),
    );
    setState(() => _confirming = false);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('서명 확정이 완료되었습니다.'),
          backgroundColor: AppColors.teal,
        ),
      );
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Column(
        children: [
          // Purple 배너 (SafeArea 포함)
          _AiBanner(),
          // 섹션 목록
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: _draftSections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final section = _draftSections[i];
                return _DraftCard(
                  section: section,
                  controller: _controllers[section.label]!,
                  isEditing: _editing[section.label] ?? false,
                  onToggleEdit: () => _toggleEdit(section.label),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ReviewBottomBar(
        confirming: _confirming,
        onEdit: () {
          setState(() {
            for (final k in _editing.keys) {
              _editing[k] = true;
            }
          });
        },
        onConfirm: _signConfirm,
      ),
    );
  }
}

// ── Purple 배너 ───────────────────────────────────────────────

class _AiBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      color: AppColors.purple,
      padding: EdgeInsets.fromLTRB(20, top + 12, 20, 14),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'AI 구조화 완료',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  '검토 후 내용을 수정하고 서명 확정해주세요.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
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

// ── 초안 카드 ─────────────────────────────────────────────────

class _DraftCard extends StatelessWidget {
  final _DraftSection section;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const _DraftCard({
    required this.section,
    required this.controller,
    required this.isEditing,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 헤더
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(section.icon, size: 18, color: AppColors.purple),
                const SizedBox(width: 8),
                Text(
                  section.label,
                  style: AppTypography.sectionHeader.copyWith(color: AppColors.purple),
                ),
                const SizedBox(width: 8),
                // AI 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.purple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                // 편집 토글
                GestureDetector(
                  onTap: onToggleEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isEditing
                          ? AppColors.primaryBlue
                          : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isEditing ? Icons.check : Icons.edit_outlined,
                          size: 12,
                          color: isEditing ? Colors.white : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isEditing ? '완료' : '편집',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isEditing ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 내용
          Padding(
            padding: const EdgeInsets.all(14),
            child: isEditing
                ? TextField(
                    controller: controller,
                    maxLines: null,
                    style: AppTypography.body.copyWith(height: 1.6),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.purple.withOpacity(0.04),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.purple.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.purple.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.purple),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  )
                : Text(
                    controller.text,
                    style: AppTypography.body.copyWith(height: 1.6),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── 하단 액션바 ───────────────────────────────────────────────

class _ReviewBottomBar extends StatelessWidget {
  final bool confirming;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;

  const _ReviewBottomBar({
    required this.confirming,
    required this.onEdit,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // 전체 수정 버튼
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.purple),
                label: const Text(
                  '전체 수정',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.purple,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.purple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 서명 확정 버튼
          Expanded(
            flex: 3,
            child: PrimaryButton(
              label: '서명 확정',
              isLoading: confirming,
              onPressed: onConfirm,
              icon: const Icon(Icons.draw_outlined, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 확정 다이얼로그 ───────────────────────────────────────────

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog();

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  final List<Offset?> _points = [];
  bool get _hasSig => _points.any((p) => p != null);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.draw_outlined, size: 18, color: AppColors.purple),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '서명으로 확정',
                      style: TextStyle(
                        fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      ),
                    ),
                    Text('확정 후 내용 수정이 불가합니다.', style: AppTypography.caption),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 서명 패드
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                onPanUpdate: (d) => setState(() => _points.add(d.localPosition)),
                onPanEnd: (_) => setState(() => _points.add(null)),
                child: CustomPaint(
                  painter: _SigPainter(points: _points),
                  child: _points.isEmpty
                      ? const Center(
                          child: Text(
                            '여기에 서명해주세요',
                            style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, color: AppColors.textHint),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() => _points.clear()),
                  child: const Text('초기화', style: TextStyle(fontFamily: 'Pretendard', color: AppColors.textSecondary)),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard', color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _hasSig ? () => Navigator.of(context).pop(true) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('확정', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SigPainter extends CustomPainter {
  final List<Offset?> points;
  const _SigPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_SigPainter old) => old.points != points;
}
