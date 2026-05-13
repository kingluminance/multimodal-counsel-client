import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/risk_chip.dart';
import '../widgets/section_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_badge.dart';
import 'client_detail_dashboard_tab.dart';
import 'session_detail_page.dart';

// ── 데이터 모델 ──────────────────────────────────────────────

class ClientDetail {
  final String name;
  final String gender;
  final int age;
  final RiskLevel riskLevel;
  final String birthDate;
  final String phone;
  final String address;
  final String intakeDate;
  final String caseWorker;
  final String sessionType;
  final int sessionCount;
  final bool isSupervisor;

  const ClientDetail({
    required this.name,
    required this.gender,
    required this.age,
    required this.riskLevel,
    required this.birthDate,
    required this.phone,
    required this.address,
    required this.intakeDate,
    required this.caseWorker,
    required this.sessionType,
    required this.sessionCount,
    this.isSupervisor = false,
  });
}

class _FamilyMember {
  final String name;
  final String relation;
  final int age;
  final bool liveTogether;

  const _FamilyMember({
    required this.name,
    required this.relation,
    required this.age,
    required this.liveTogether,
  });
}

enum _AiStatus { aiDone, signPending, confirmed }

class _SessionRecord {
  final int session;
  final String date;
  final String type;
  final String method;
  final String duration;
  final RiskLevel risk;
  final _AiStatus aiStatus;

  const _SessionRecord({
    required this.session,
    required this.date,
    required this.type,
    required this.method,
    required this.duration,
    required this.risk,
    required this.aiStatus,
  });
}

class _ReportItem {
  final String title;
  final String period;
  final String createdAt;

  const _ReportItem({
    required this.title,
    required this.period,
    required this.createdAt,
  });
}

// ── 샘플 데이터 ───────────────────────────────────────────────


const _familyMembers = [
  _FamilyMember(name: '김철수', relation: '부', age: 58, liveTogether: false),
  _FamilyMember(name: '박영희', relation: '모', age: 55, liveTogether: true),
];

const _sessions = [
  _SessionRecord(
    session: 12,
    date: '2025.05.10',
    type: '위기 개입',
    method: '대면',
    duration: '50분',
    risk: RiskLevel.high,
    aiStatus: _AiStatus.signPending,
  ),
  _SessionRecord(
    session: 11,
    date: '2025.04.26',
    type: '정기 상담',
    method: '대면',
    duration: '50분',
    risk: RiskLevel.high,
    aiStatus: _AiStatus.confirmed,
  ),
  _SessionRecord(
    session: 10,
    date: '2025.04.12',
    type: '정기 상담',
    method: '비대면',
    duration: '50분',
    risk: RiskLevel.medium,
    aiStatus: _AiStatus.confirmed,
  ),
  _SessionRecord(
    session: 9,
    date: '2025.03.29',
    type: '정기 상담',
    method: '대면',
    duration: '80분',
    risk: RiskLevel.medium,
    aiStatus: _AiStatus.aiDone,
  ),
  _SessionRecord(
    session: 8,
    date: '2025.03.15',
    type: '전화 상담',
    method: '전화',
    duration: '20분',
    risk: RiskLevel.low,
    aiStatus: _AiStatus.confirmed,
  ),
];

const _reports = [
  _ReportItem(
    title: '1분기 종합 리포트',
    period: '2025.01 ~ 2025.03',
    createdAt: '2025.04.01',
  ),
  _ReportItem(
    title: '초기 상담 요약 리포트',
    period: '2024.03 ~ 2024.06',
    createdAt: '2024.07.05',
  ),
];

// ── 페이지 ────────────────────────────────────────────────────

class ClientDetailPage extends StatefulWidget {
  final ClientDetail client;

  const ClientDetailPage({super.key, required this.client});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final count = widget.client.isSupervisor ? 5 : 4;
    _tabController = TabController(length: count, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    final tabs = [
      const Tab(text: '기본정보'),
      const Tab(text: '회기'),
      const Tab(text: '대시보드'),
      const Tab(text: '리포트'),
      if (client.isSupervisor) const Tab(text: '관리'),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 118,
            backgroundColor: AppColors.backgroundWhite,
            foregroundColor: AppColors.textPrimary,
            scrolledUnderElevation: 0,
            elevation: 0,
            title: Text(
              client.name,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 22),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.backgroundWhite,
                padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        RiskChip(level: client.riskLevel),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '접수일 ${client.intakeDate}  ·  담당 ${client.caseWorker}',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: tabs,
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryBlue,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              isScrollable: client.isSupervisor,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _BasicInfoTab(client: client),
            const _SessionTab(),
            const ClientDetailDashboardTab(),
            const _ReportTab(),
            if (client.isSupervisor) const _ManagementTab(),
          ],
        ),
      ),
    );
  }
}

// ── 공통 소위젯 ───────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionTitle(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.sectionHeader),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: AppTypography.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 탭1: 기본정보 ─────────────────────────────────────────────

class _BasicInfoTab extends StatelessWidget {
  final ClientDetail client;
  const _BasicInfoTab({required this.client});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // 기본 프로필
        const _SectionTitle('기본 프로필'),
        SectionCard(
          child: Column(
            children: [
              _InfoRow(label: '이름', value: '${client.name} (${client.gender})'),
              _InfoRow(label: '생년월일', value: client.birthDate),
              _InfoRow(label: '나이', value: '${client.age}세'),
              _InfoRow(label: '연락처', value: client.phone),
              _InfoRow(label: '주소', value: client.address),
              _InfoRow(label: '접수일', value: client.intakeDate),
              _InfoRow(label: '담당자', value: client.caseWorker),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 가족 구성원
        _SectionTitle(
          '가족 구성원',
          trailing: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16, color: AppColors.primaryBlue),
            label: const Text(
              '추가',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.primaryBlue,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        SectionCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(child: Text('이름', style: AppTypography.caption)),
                    SizedBox(width: 48, child: Text('관계', style: AppTypography.caption, textAlign: TextAlign.center)),
                    SizedBox(width: 40, child: Text('나이', style: AppTypography.caption, textAlign: TextAlign.center)),
                    SizedBox(width: 52, child: Text('동거', style: AppTypography.caption, textAlign: TextAlign.center)),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              ..._familyMembers.map((m) => _FamilyRow(member: m)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 동의 현황
        const _SectionTitle('동의 현황'),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ConsentRow(label: '녹음 동의', agreed: true),
              const SizedBox(height: 10),
              const _ConsentRow(label: '민감정보 동의', agreed: true),
              const SizedBox(height: 10),
              const _ConsentRow(label: '카메라 동의', agreed: false),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.riskMediumBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.riskMediumText),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '카메라 동의 없으면 생체측정 기능이 비활성화됩니다.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          color: AppColors.riskMediumText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 건강 상태
        _SectionTitle(
          '건강 상태',
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SectionCard(
          child: Column(
            children: [
              _InfoRow(label: '건강 상태', value: '주의 관찰'),
              _InfoRow(label: '만성 질환', value: '우울증, 불안장애'),
              _InfoRow(label: '복약 여부', value: '복약 중 (항우울제)'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 경제 상태 (사회복지사만 열람)
        const _SectionTitle('경제 상태'),
        Stack(
          children: [
            const SectionCard(
              child: Column(
                children: [
                  _InfoRow(label: '소득 유형', value: '근로소득'),
                  _InfoRow(label: '수급 여부', value: '기초생활수급자'),
                  _InfoRow(label: '월 소득', value: '80만원 미만'),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '사회복지사 전용',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FamilyRow extends StatelessWidget {
  final _FamilyMember member;
  const _FamilyRow({required this.member});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              member.name,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(member.relation,
                style: AppTypography.body, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 40,
            child: Text('${member.age}세',
                style: AppTypography.caption, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 52,
            child: Center(
              child: Icon(
                member.liveTogether ? Icons.check_circle : Icons.remove,
                size: 18,
                color: member.liveTogether
                    ? AppColors.teal
                    : AppColors.textHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final String label;
  final bool agreed;
  const _ConsentRow({required this.label, required this.agreed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body),
        agreed
            ? const StatusBadge.active(label: '동의')
            : const StatusBadge.closed(label: '미동의'),
      ],
    );
  }
}

// ── 탭2: 회기 ─────────────────────────────────────────────────

class _SessionTab extends StatelessWidget {
  const _SessionTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 새 상담 시작
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: PrimaryButton(
            label: '새 상담 시작',
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ),
        // 회기 리스트
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
            itemCount: _sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) =>
                _SessionCard(record: _sessions[i]),
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final _SessionRecord record;
  const _SessionCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SessionDetailPage(
              sessionNumber: record.session,
              date: record.date,
              type: record.type,
              method: record.method,
              duration: record.duration,
              initialConfirmed: record.aiStatus == _AiStatus.confirmed,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${record.session}회기',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(record.date, style: AppTypography.caption),
              const Spacer(),
              _AiStatusChip(status: record.aiStatus),
              const SizedBox(width: 6),
              RiskChip(level: record.risk),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TagPill(record.type),
              const SizedBox(width: 6),
              _TagPill(record.method),
              const SizedBox(width: 6),
              _TagPill(record.duration),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiStatusChip extends StatelessWidget {
  final _AiStatus status;
  const _AiStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _AiStatus.aiDone:
        return const StatusBadge.pending(label: 'AI완료');
      case _AiStatus.signPending:
        return const StatusBadge.pending(label: '서명대기');
      case _AiStatus.confirmed:
        return const StatusBadge.active(label: '확정완료');
    }
  }
}

class _TagPill extends StatelessWidget {
  final String text;
  const _TagPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── 탭4: 리포트 ───────────────────────────────────────────────

class _ReportTab extends StatefulWidget {
  const _ReportTab();

  @override
  State<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<_ReportTab> {
  void _openGenerateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _GenerateReportSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: PrimaryButton(
            label: '리포트 생성',
            onPressed: _openGenerateSheet,
            icon: const Icon(Icons.description_outlined,
                size: 18, color: Colors.white),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
            itemCount: _reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _ReportCard(item: _reports[i]),
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final _ReportItem item;
  const _ReportCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined,
                size: 22, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text('${item.period}  ·  생성 ${item.createdAt}',
                    style: AppTypography.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined,
                size: 20, color: AppColors.textSecondary),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _GenerateReportSheet extends StatefulWidget {
  const _GenerateReportSheet();

  @override
  State<_GenerateReportSheet> createState() => _GenerateReportSheetState();
}

class _GenerateReportSheetState extends State<_GenerateReportSheet> {
  final Map<String, bool> _items = {
    '회기 요약': true,
    '위험도 변화': true,
    '생체 측정 데이터': false,
    '감정 분석': true,
    '목표 달성률': true,
    '서비스 연계 현황': false,
  };
  bool _generating = false;
  String _period = '전체 기간';

  void _generate() async {
    setState(() => _generating = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _generating = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '리포트 생성',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const Divider(height: 20, color: AppColors.border),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('기간', style: AppTypography.sectionHeader),
                  const SizedBox(height: 10),
                  // 기간 선택 칩
                  Wrap(
                    spacing: 8,
                    children: ['전체 기간', '최근 3개월', '최근 6개월', '직접 설정'].map(
                      (p) => ChoiceChip(
                        label: Text(p),
                        selected: _period == p,
                        onSelected: (_) => setState(() => _period = p),
                        selectedColor: AppColors.primaryBlue,
                        labelStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          color: _period == p ? Colors.white : AppColors.textSecondary,
                        ),
                        backgroundColor: AppColors.inputBackground,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('포함 항목', style: AppTypography.sectionHeader),
                  const SizedBox(height: 8),
                  ..._items.entries.map(
                    (e) => CheckboxListTile(
                      value: e.value,
                      title: Text(e.key, style: AppTypography.body),
                      onChanged: (v) =>
                          setState(() => _items[e.key] = v ?? false),
                      activeColor: AppColors.primaryBlue,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: '생성',
                    isLoading: _generating,
                    onPressed: _generate,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 탭5: 관리 (슈퍼바이저) ───────────────────────────────────

class _ManagementTab extends StatelessWidget {
  const _ManagementTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('관리 탭 (슈퍼바이저/관리자 전용)',
          style: AppTypography.caption),
    );
  }
}
