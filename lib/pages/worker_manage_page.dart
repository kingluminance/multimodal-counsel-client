import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/risk_chip.dart';

// ── 모델 ─────────────────────────────────────────────────────

enum _WorkerRole { counselor, supervisor }

extension _WorkerRoleX on _WorkerRole {
  String get label {
    switch (this) {
      case _WorkerRole.counselor:
        return '사회복지사';
      case _WorkerRole.supervisor:
        return '슈퍼바이저';
    }
  }

  Color get color {
    switch (this) {
      case _WorkerRole.counselor:
        return AppColors.primary;
      case _WorkerRole.supervisor:
        return AppColors.purple;
    }
  }

  Color get bgColor {
    switch (this) {
      case _WorkerRole.counselor:
        return AppColors.primary.withOpacity(0.08);
      case _WorkerRole.supervisor:
        return AppColors.purple.withOpacity(0.08);
    }
  }
}

class _CaseItem {
  final String clientName;
  final RiskLevel risk;
  final String lastSession;

  const _CaseItem({
    required this.clientName,
    required this.risk,
    required this.lastSession,
  });
}

class _Worker {
  final String id;
  final String name;
  final _WorkerRole role;
  final String org;
  final String email;
  final String phone;
  final String joinedAt;
  final List<_CaseItem> cases;
  final String? supervisorId;

  const _Worker({
    required this.id,
    required this.name,
    required this.role,
    required this.org,
    required this.email,
    required this.phone,
    required this.joinedAt,
    required this.cases,
    this.supervisorId,
  });

  int get caseCount => cases.length;
}

// ── 샘플 데이터 ───────────────────────────────────────────────

const _sampleWorkers = [
  _Worker(
    id: 'w1',
    name: '김상담사',
    role: _WorkerRole.counselor,
    org: '행복복지관',
    email: 'kim@welfare.kr',
    phone: '010-1234-5678',
    joinedAt: '2022.03.01',
    supervisorId: 'w3',
    cases: [
      _CaseItem(clientName: '김지수', risk: RiskLevel.high, lastSession: '2025.05.10'),
      _CaseItem(clientName: '이준혁', risk: RiskLevel.medium, lastSession: '2025.05.08'),
      _CaseItem(clientName: '박서연', risk: RiskLevel.low, lastSession: '2025.05.06'),
    ],
  ),
  _Worker(
    id: 'w2',
    name: '이사원',
    role: _WorkerRole.counselor,
    org: '행복복지관',
    email: 'lee@welfare.kr',
    phone: '010-2345-6789',
    joinedAt: '2023.09.01',
    supervisorId: 'w3',
    cases: [
      _CaseItem(clientName: '최민준', risk: RiskLevel.medium, lastSession: '2025.05.09'),
      _CaseItem(clientName: '한소희', risk: RiskLevel.low, lastSession: '2025.05.07'),
    ],
  ),
  _Worker(
    id: 'w3',
    name: '박슈퍼',
    role: _WorkerRole.supervisor,
    org: '행복복지관',
    email: 'park@welfare.kr',
    phone: '010-3456-7890',
    joinedAt: '2019.04.01',
    cases: [
      _CaseItem(clientName: '정우성', risk: RiskLevel.high, lastSession: '2025.05.11'),
    ],
  ),
  _Worker(
    id: 'w4',
    name: '최담당',
    role: _WorkerRole.counselor,
    org: '한마음복지관',
    email: 'choi@hanmaeum.kr',
    phone: '010-4567-8901',
    joinedAt: '2021.07.15',
    cases: [
      _CaseItem(clientName: '오지민', risk: RiskLevel.low, lastSession: '2025.05.05'),
      _CaseItem(clientName: '강현우', risk: RiskLevel.medium, lastSession: '2025.05.03'),
    ],
  ),
  _Worker(
    id: 'w5',
    name: '한선생',
    role: _WorkerRole.supervisor,
    org: '한마음복지관',
    email: 'han@hanmaeum.kr',
    phone: '010-5678-9012',
    joinedAt: '2018.02.01',
    cases: [
      _CaseItem(clientName: '윤아영', risk: RiskLevel.medium, lastSession: '2025.05.12'),
      _CaseItem(clientName: '신동혁', risk: RiskLevel.low, lastSession: '2025.05.10'),
    ],
  ),
];

// ── 페이지 ────────────────────────────────────────────────────

class WorkerManagePage extends StatelessWidget {
  const WorkerManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        titleSpacing: 16,
        title: Text('사회복지사 관리', style: AppTypography.title),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleWorkers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final w = _sampleWorkers[i];
          return _WorkerCard(
            worker: w,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _WorkerDetailPage(worker: w),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── 사회복지사 카드 ───────────────────────────────────────────

class _WorkerCard extends StatelessWidget {
  final _Worker worker;
  final VoidCallback onTap;

  const _WorkerCard({required this.worker, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // 아바타
            CircleAvatar(
              radius: 22,
              backgroundColor: worker.role.color.withOpacity(0.12),
              child: Text(
                worker.name[0],
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: worker.role.color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 이름 + 역할칩 + 기관
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(worker.name, style: AppTypography.sectionHeader),
                      const SizedBox(width: 6),
                      _RoleChip(role: worker.role),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(worker.org, style: AppTypography.caption),
                ],
              ),
            ),
            // 담당 케이스 수
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${worker.caseCount}',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  '담당 케이스',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── 역할 칩 ───────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final _WorkerRole role;
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

// ── 상세 페이지 ───────────────────────────────────────────────

class _WorkerDetailPage extends StatefulWidget {
  final _Worker worker;
  const _WorkerDetailPage({required this.worker});

  @override
  State<_WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<_WorkerDetailPage> {
  late String? _supervisorId;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _supervisorId = widget.worker.supervisorId;
  }

  List<_Worker> get _supervisors =>
      _sampleWorkers.where((w) => w.role == _WorkerRole.supervisor).toList();

  String? _supervisorName(String? id) {
    if (id == null) return null;
    try {
      return _sampleWorkers.firstWhere((w) => w.id == id).name;
    } catch (_) {
      return null;
    }
  }

  void _save() {
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _supervisorId != null
              ? '슈퍼바이저가 ${_supervisorName(_supervisorId)}님으로 배정되었습니다.'
              : '슈퍼바이저 배정이 해제되었습니다.',
          style: const TextStyle(fontFamily: 'Pretendard'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.worker;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: Text(w.name, style: AppTypography.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 프로필 카드 ────────────────────────────────
            _Card(
              child: Column(
                children: [
                  // 아바타 + 이름 + 역할
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: w.role.color.withOpacity(0.12),
                        child: Text(
                          w.name[0],
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: w.role.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(w.name, style: AppTypography.title),
                              const SizedBox(width: 8),
                              _RoleChip(role: w.role),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(w.org, style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 14),
                  // 연락처 정보
                  _InfoRow(Icons.email_outlined, w.email),
                  const SizedBox(height: 8),
                  _InfoRow(Icons.phone_outlined, w.phone),
                  const SizedBox(height: 8),
                  _InfoRow(Icons.calendar_today_outlined, '${w.joinedAt} 입사'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── 슈퍼바이저 배정 (counselor만) ─────────────
            if (w.role == _WorkerRole.counselor) ...[
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.supervisor_account_outlined,
                            size: 16, color: AppColors.purple),
                        const SizedBox(width: 6),
                        Text('슈퍼바이저 배정',
                            style: AppTypography.sectionHeader),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _supervisorId,
                          isExpanded: true,
                          hint: Text(
                            '슈퍼바이저를 선택하세요',
                            style: AppTypography.body
                                .copyWith(color: AppColors.textHint),
                          ),
                          style: AppTypography.body,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textSecondary),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('배정 없음',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    color: AppColors.textHint,
                                  )),
                            ),
                            ..._supervisors.map(
                              (s) => DropdownMenuItem(
                                value: s.id,
                                child: Row(
                                  children: [
                                    Text(s.name, style: AppTypography.body),
                                    const SizedBox(width: 6),
                                    _RoleChip(role: s.role),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _supervisorId = v;
                              _saved = false;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _saved
                              ? AppColors.primaryDark
                              : AppColors.purple,
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── 담당 케이스 목록 ───────────────────────────
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.folder_outlined,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        '담당 케이스',
                        style: AppTypography.sectionHeader,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${w.caseCount}건',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (w.cases.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          '담당 케이스가 없습니다.',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    )
                  else
                    ...w.cases.asMap().entries.map((e) {
                      final isLast = e.key == w.cases.length - 1;
                      final c = e.value;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      AppColors.backgroundGrey,
                                  child: Text(
                                    c.clientName[0],
                                    style: const TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(c.clientName,
                                          style: AppTypography.body.copyWith(
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                        '최근 상담: ${c.lastSession}',
                                        style: AppTypography.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                RiskChip(level: c.risk),
                              ],
                            ),
                          ),
                          if (!isLast)
                            const Divider(
                                height: 1, color: AppColors.border),
                        ],
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── 공용 위젯 ─────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(text, style: AppTypography.caption),
      ],
    );
  }
}
