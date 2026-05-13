import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/risk_chip.dart';
import '../widgets/section_card.dart';
import '../widgets/primary_button.dart';
import 'session_recording_page.dart';
import 'session_ai_review_page.dart';

// ── 데이터 모델 ──────────────────────────────────────────────

class _NeedItem {
  final String id;
  final String label;
  bool enabled;

  _NeedItem({required this.id, required this.label, this.enabled = true});
}

// ── 샘플 AI 초안 ─────────────────────────────────────────────

const _aiTopicDraft = '내담자는 최근 직장 스트레스와 가족 갈등으로 인한 극심한 불안감을 호소하였음. 수면 장애와 식욕 감소 증상이 지속되고 있으며, 사회적 고립감이 심화되는 양상을 보임.';
const _aiInterventionDraft = '인지행동치료(CBT) 기반 감정 조절 기법 적용. 호흡 훈련 및 이완 기법 안내. 부정적 자동사고 탐색 및 대안적 사고 방식 훈련 실시.';
const _aiPlanDraft = '주 1회 정기 상담 지속. 다음 회기 전 기분 일지 작성 과제 부여. 필요 시 정신건강복지센터 연계 검토.';

// ── 페이지 ────────────────────────────────────────────────────

class SessionDetailPage extends StatefulWidget {
  final int sessionNumber;
  final String date;
  final String type;
  final String method;
  final String duration;
  final bool initialConfirmed;

  const SessionDetailPage({
    super.key,
    required this.sessionNumber,
    required this.date,
    required this.type,
    required this.method,
    required this.duration,
    this.initialConfirmed = false,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late bool _isConfirmed;

  // 위험 섹션 상태
  RiskLevel _riskLevel = RiskLevel.medium;
  final Set<String> _selectedRiskTypes = {'자살·자해'};

  // 욕구 섹션 상태
  late final List<_NeedItem> _needItems;

  // 텍스트 컨트롤러
  final _topicController = TextEditingController(text: _aiTopicDraft);
  final _topicCommentController = TextEditingController();
  final _interventionController = TextEditingController(text: _aiInterventionDraft);
  final _planController = TextEditingController(text: _aiPlanDraft);
  final _riskNoteController = TextEditingController();

  static const _riskTypes = [
    '자살·자해', '가정폭력', '아동학대', '경제위기', '노숙·주거불안', '정신건강위기', '기타',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _isConfirmed = widget.initialConfirmed;
    _needItems = [
      _NeedItem(id: '1', label: '정서적 지지', enabled: true),
      _NeedItem(id: '2', label: '경제적 지원', enabled: true),
      _NeedItem(id: '3', label: '의료 연계', enabled: false),
      _NeedItem(id: '4', label: '주거 안정', enabled: false),
      _NeedItem(id: '5', label: '취업 지원', enabled: true),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topicController.dispose();
    _topicCommentController.dispose();
    _interventionController.dispose();
    _planController.dispose();
    _riskNoteController.dispose();
    super.dispose();
  }

  void _openRecording() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SessionRecordingPage()),
    );
  }

  void _openAiReview() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SessionAiReviewPage()),
    );
  }

  Future<void> _confirmSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _SignatureDialog(),
    );
    if (confirmed == true && mounted) {
      setState(() => _isConfirmed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text('${widget.sessionNumber}회기'),
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        actions: [
          if (_isConfirmed)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: AppColors.teal),
                  SizedBox(width: 4),
                  Text(
                    '확정',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 세션 정보 헤더
          _SessionHeader(
            date: widget.date,
            type: widget.type,
            method: widget.method,
            duration: widget.duration,
          ),
          // 탭바
          Container(
            color: AppColors.backgroundWhite,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: '주제'),
                Tab(text: '위험'),
                Tab(text: '욕구'),
                Tab(text: '개입'),
                Tab(text: '계획'),
              ],
            ),
          ),
          // 탭 콘텐츠
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TopicTab(controller: _topicController, commentController: _topicCommentController, readOnly: _isConfirmed),
                _RiskTab(
                  riskLevel: _riskLevel,
                  selectedTypes: _selectedRiskTypes,
                  noteController: _riskNoteController,
                  readOnly: _isConfirmed,
                  onRiskChanged: (r) => setState(() => _riskLevel = r),
                  onTypeToggled: (t) => setState(() {
                    if (_selectedRiskTypes.contains(t)) {
                      _selectedRiskTypes.remove(t);
                    } else {
                      _selectedRiskTypes.add(t);
                    }
                  }),
                ),
                _NeedTab(items: _needItems, readOnly: _isConfirmed, onReorder: (o, n) {
                  setState(() {
                    if (n > o) n--;
                    _needItems.insert(n, _needItems.removeAt(o));
                  });
                }),
                _InterventionTab(controller: _interventionController, readOnly: _isConfirmed),
                _PlanTab(controller: _planController, readOnly: _isConfirmed),
              ],
            ),
          ),
        ],
      ),
      // 하단 고정 액션바
      bottomNavigationBar: _BottomActionBar(
        isConfirmed: _isConfirmed,
        onRecording: _openRecording,
        onAiReview: _openAiReview,
        onConfirm: _confirmSession,
      ),
    );
  }
}

// ── 세션 정보 헤더 ────────────────────────────────────────────

class _SessionHeader extends StatelessWidget {
  final String date;
  final String type;
  final String method;
  final String duration;

  const _SessionHeader({
    required this.date,
    required this.type,
    required this.method,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _HeaderPill(Icons.calendar_today_outlined, date),
                _HeaderPill(Icons.chat_bubble_outline, type),
                _HeaderPill(Icons.place_outlined, method),
                _HeaderPill(Icons.schedule_outlined, duration),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeaderPill(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI 초안 배너 ──────────────────────────────────────────────

class _AiDraftBanner extends StatelessWidget {
  final String content;
  const _AiDraftBanner({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.purple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'AI 초안',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '· 검토 후 수정해주세요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: AppColors.purple.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 저장 버튼 ────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final VoidCallback? onSave;
  const _SaveButton({this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton(
          onPressed: onSave,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryBlue),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text(
            '저장',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 탭1: 주제 ─────────────────────────────────────────────────

class _TopicTab extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController commentController;
  final bool readOnly;

  const _TopicTab({
    required this.controller,
    required this.commentController,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AiDraftBanner(content: _aiTopicDraft),
          const Text('상담 주제', style: AppTypography.sectionHeader),
          const SizedBox(height: 8),
          SectionCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: 5,
              style: AppTypography.body,
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
                hintText: '이번 상담의 주요 주제를 기록해주세요.',
                hintStyle: TextStyle(color: AppColors.textHint),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('추가 메모', style: AppTypography.sectionHeader),
          const SizedBox(height: 8),
          SectionCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: commentController,
              readOnly: readOnly,
              maxLines: 3,
              style: AppTypography.body,
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
                hintText: '사회복지사 메모...',
                hintStyle: TextStyle(color: AppColors.textHint),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (!readOnly) _SaveButton(onSave: () {}),
        ],
      ),
    );
  }
}

// ── 탭2: 위험 ─────────────────────────────────────────────────

class _RiskTab extends StatelessWidget {
  final RiskLevel riskLevel;
  final Set<String> selectedTypes;
  final TextEditingController noteController;
  final bool readOnly;
  final ValueChanged<RiskLevel> onRiskChanged;
  final ValueChanged<String> onTypeToggled;

  const _RiskTab({
    required this.riskLevel,
    required this.selectedTypes,
    required this.noteController,
    required this.readOnly,
    required this.onRiskChanged,
    required this.onTypeToggled,
  });

  Color get _riskColor {
    switch (riskLevel) {
      case RiskLevel.high:
        return AppColors.red;
      case RiskLevel.medium:
        return AppColors.amber;
      case RiskLevel.low:
        return AppColors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHigh = riskLevel == RiskLevel.high;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 위험수준
          const Text('위험수준', style: AppTypography.sectionHeader),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              children: [
                SegmentedButton<RiskLevel>(
                  segments: [
                    ButtonSegment(
                      value: RiskLevel.high,
                      label: Text('고', style: TextStyle(color: riskLevel == RiskLevel.high ? Colors.white : AppColors.red)),
                    ),
                    ButtonSegment(
                      value: RiskLevel.medium,
                      label: Text('중', style: TextStyle(color: riskLevel == RiskLevel.medium ? Colors.white : AppColors.amber)),
                    ),
                    ButtonSegment(
                      value: RiskLevel.low,
                      label: Text('저', style: TextStyle(color: riskLevel == RiskLevel.low ? Colors.white : AppColors.teal)),
                    ),
                  ],
                  selected: {riskLevel},
                  onSelectionChanged: readOnly ? null : (s) => onRiskChanged(s.first),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) return _riskColor;
                      return null;
                    }),
                    side: MaterialStateProperty.all(BorderSide(color: _riskColor.withOpacity(0.4))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 위험유형
          const Text('위험유형', style: AppTypography.sectionHeader),
          const SizedBox(height: 10),
          SectionCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _SessionDetailPageState._riskTypes.map((type) {
                final selected = selectedTypes.contains(type);
                return GestureDetector(
                  onTap: readOnly ? null : () => onTypeToggled(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.red : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // 위기개입 버튼 (고위험 시 강조)
          if (isHigh)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.warning_amber_rounded, size: 18),
                label: const Text(
                  '위기개입 프로토콜 실행',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),

          // 위험 메모
          const Text('위험 특이사항', style: AppTypography.sectionHeader),
          const SizedBox(height: 8),
          SectionCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: noteController,
              readOnly: readOnly,
              maxLines: 4,
              style: AppTypography.body,
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
                hintText: '위험 관련 특이사항을 기록해주세요.',
                hintStyle: TextStyle(color: AppColors.textHint),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (!readOnly) _SaveButton(onSave: () {}),
        ],
      ),
    );
  }
}

// ── 탭3: 욕구 ─────────────────────────────────────────────────

class _NeedTab extends StatelessWidget {
  final List<_NeedItem> items;
  final bool readOnly;
  final ReorderCallback onReorder;

  const _NeedTab({
    required this.items,
    required this.readOnly,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!readOnly)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              '우선순위를 드래그하여 정렬하세요.',
              style: AppTypography.caption,
            ),
          ),
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            onReorder: onReorder,
            buildDefaultDragHandles: !readOnly,
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return _NeedItemCard(
                key: ValueKey(item.id),
                item: item,
                priority: i + 1,
                readOnly: readOnly,
              );
            }).toList(),
          ),
        ),
        if (!readOnly)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _SaveButton(onSave: () {}),
          ),
      ],
    );
  }
}

class _NeedItemCard extends StatefulWidget {
  final _NeedItem item;
  final int priority;
  final bool readOnly;

  const _NeedItemCard({
    super.key,
    required this.item,
    required this.priority,
    required this.readOnly,
  });

  @override
  State<_NeedItemCard> createState() => _NeedItemCardState();
}

class _NeedItemCardState extends State<_NeedItemCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // 우선순위 번호
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.item.enabled
                    ? AppColors.primaryBlue
                    : AppColors.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${widget.priority}',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.item.enabled ? Colors.white : AppColors.textHint,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.item.label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.item.enabled
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                  decoration: widget.item.enabled
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
            ),
            if (!widget.readOnly)
              Switch(
                value: widget.item.enabled,
                onChanged: (v) => setState(() => widget.item.enabled = v),
                activeColor: AppColors.primaryBlue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
      ),
    );
  }
}

// ── 탭4: 개입 ─────────────────────────────────────────────────

class _InterventionTab extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;

  const _InterventionTab({required this.controller, required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AiDraftBanner(content: _aiInterventionDraft),
          const Text('개입 내용', style: AppTypography.sectionHeader),
          const SizedBox(height: 8),
          SectionCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: 7,
              style: AppTypography.body,
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
                hintText: '이번 회기의 개입 방법과 내용을 기록해주세요.',
                hintStyle: TextStyle(color: AppColors.textHint),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (!readOnly) _SaveButton(onSave: () {}),
        ],
      ),
    );
  }
}

// ── 탭5: 계획 ─────────────────────────────────────────────────

class _PlanTab extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;

  const _PlanTab({required this.controller, required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AiDraftBanner(content: _aiPlanDraft),
          const Text('다음 계획', style: AppTypography.sectionHeader),
          const SizedBox(height: 8),
          SectionCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: 6,
              style: AppTypography.body,
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: false,
                hintText: '다음 상담까지의 계획과 목표를 기록해주세요.',
                hintStyle: TextStyle(color: AppColors.textHint),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (!readOnly) _SaveButton(onSave: () {}),
        ],
      ),
    );
  }
}

// ── 하단 액션바 ───────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final bool isConfirmed;
  final VoidCallback onRecording;
  final VoidCallback onAiReview;
  final VoidCallback onConfirm;

  const _BottomActionBar({
    required this.isConfirmed,
    required this.onRecording,
    required this.onAiReview,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI 기능 버튼 행
          Row(
            children: [
              Expanded(
                child: _AiActionButton(
                  icon: Icons.mic_outlined,
                  label: '녹음 업로드',
                  onTap: isConfirmed ? null : onRecording,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AiActionButton(
                  icon: Icons.monitor_heart_outlined,
                  label: '생체 측정',
                  onTap: isConfirmed ? null : () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AiActionButton(
                  icon: Icons.preview_outlined,
                  label: 'AI 초안 보기',
                  onTap: onAiReview,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 서명 확정 버튼
          if (isConfirmed)
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 18, color: AppColors.teal),
                  SizedBox(width: 8),
                  Text(
                    '확정 완료',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            )
          else
            PrimaryButton(label: '서명 확정', onPressed: onConfirm),
        ],
      ),
    );
  }
}

class _AiActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _AiActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: disabled ? AppColors.inputBackground : AppColors.purple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: disabled ? Colors.transparent : AppColors.purple.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: disabled ? AppColors.textHint : AppColors.purple,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: disabled ? AppColors.textHint : AppColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 서명 다이얼로그 ───────────────────────────────────────────

class _SignatureDialog extends StatefulWidget {
  const _SignatureDialog();

  @override
  State<_SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<_SignatureDialog> {
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
            const Text(
              '서명으로 확정',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '서명 후 내용을 수정할 수 없습니다.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 16),
            // 서명 영역
            Container(
              height: 180,
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
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 버튼 행
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _points.clear()),
                  child: const Text(
                    '초기화',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _hasSig
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확정',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
      ..color = AppColors.primaryBlue
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
