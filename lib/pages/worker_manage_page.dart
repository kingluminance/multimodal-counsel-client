import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import '../widgets/risk_chip.dart';

// ── 역할 헬퍼 ─────────────────────────────────────────────────

enum _WorkerRole { counselor, supervisor, other }

_WorkerRole _parseRole(String? role) {
  switch (role?.toUpperCase()) {
    case 'SUPERVISOR':
      return _WorkerRole.supervisor;
    case 'SOCIAL_WORKER':
    case 'COUNSELOR':
    case 'WORKER':
      return _WorkerRole.counselor;
    default:
      return _WorkerRole.other;
  }
}

extension _WorkerRoleX on _WorkerRole {
  String get label {
    switch (this) {
      case _WorkerRole.counselor:
        return '사회복지사';
      case _WorkerRole.supervisor:
        return '슈퍼바이저';
      case _WorkerRole.other:
        return '기타';
    }
  }

  Color get color {
    switch (this) {
      case _WorkerRole.counselor:
        return AppColors.primary;
      case _WorkerRole.supervisor:
        return AppColors.purple;
      case _WorkerRole.other:
        return AppColors.textSecondary;
    }
  }

  Color get bgColor {
    switch (this) {
      case _WorkerRole.counselor:
        return AppColors.primary.withOpacity(0.08);
      case _WorkerRole.supervisor:
        return AppColors.purple.withOpacity(0.08);
      case _WorkerRole.other:
        return AppColors.inputBackground;
    }
  }
}

// ── 페이지 ────────────────────────────────────────────────────

class WorkerManagePage extends StatefulWidget {
  const WorkerManagePage({super.key});

  @override
  State<WorkerManagePage> createState() => _WorkerManagePageState();
}

class _WorkerManagePageState extends State<WorkerManagePage> {
  List<Map<String, dynamic>> _workers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await WorkerService().listWorkers();
      if (!mounted) return;
      setState(() {
        _workers = List<Map<String, dynamic>>.from(result['workers'] ?? []);
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response?.data?['message'] ?? '목록을 불러오지 못했습니다.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '목록을 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textHint)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadWorkers,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _workers.isEmpty
                  ? Center(
                      child: Text(
                        '사회복지사가 없습니다.',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textHint),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _workers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final w = _workers[i];
                        final role = _parseRole(w['role'] as String?);
                        final name = w['name'] as String? ?? '-';
                        final workerId = w['worker_id']?.toString() ?? '';
                        return _WorkerCard(
                          name: name,
                          role: role,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _WorkerDetailPage(
                                workerId: workerId,
                                workerName: name,
                              ),
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
  final String name;
  final _WorkerRole role;
  final VoidCallback onTap;

  const _WorkerCard({
    required this.name,
    required this.role,
    required this.onTap,
  });

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
            CircleAvatar(
              radius: 22,
              backgroundColor: role.color.withOpacity(0.12),
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: role.color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: AppTypography.sectionHeader),
                      const SizedBox(width: 6),
                      _RoleChip(role: role),
                    ],
                  ),
                ],
              ),
            ),
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
  final String workerId;
  final String workerName;
  const _WorkerDetailPage({required this.workerId, required this.workerName});

  @override
  State<_WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<_WorkerDetailPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _workerDetail;
  List<Map<String, dynamic>> _cases = [];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        WorkerService().getWorker(widget.workerId),
        WorkerService().workerCases(widget.workerId),
      ]);
      if (!mounted) return;
      setState(() {
        _workerDetail = results[0] as Map<String, dynamic>;
        _cases = List<Map<String, dynamic>>.from(
          (results[1] as Map<String, dynamic>)['cases'] ?? [],
        );
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response?.data?['message'] ?? '데이터를 불러오지 못했습니다.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '데이터를 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  RiskLevel _parseRisk(String? level) {
    switch (level?.toUpperCase()) {
      case 'HIGH':
        return RiskLevel.high;
      case 'MEDIUM':
        return RiskLevel.medium;
      default:
        return RiskLevel.low;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _workerDetail ?? {};
    final name = detail['name'] as String? ?? widget.workerName;
    final role = _parseRole(detail['role'] as String?);
    final email = detail['email'] as String? ?? '-';
    final phone = detail['phone'] as String? ?? '-';
    final joinedAt = (detail['joined_at'] as String? ?? '').replaceAll('-', '.');

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        title: Text(widget.workerName, style: AppTypography.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.danger)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 프로필 카드
                      _Card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: role.color.withOpacity(0.12),
                                  child: Text(
                                    name.isNotEmpty ? name[0] : '?',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: role.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(name, style: AppTypography.title),
                                        const SizedBox(width: 8),
                                        _RoleChip(role: role),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, color: AppColors.border),
                            const SizedBox(height: 14),
                            _InfoRow(Icons.email_outlined, email),
                            const SizedBox(height: 8),
                            _InfoRow(Icons.phone_outlined, phone),
                            if (joinedAt.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _InfoRow(Icons.calendar_today_outlined, '$joinedAt 입사'),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 담당 케이스 목록
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.folder_outlined,
                                    size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text('담당 케이스', style: AppTypography.sectionHeader),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_cases.length}건',
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
                            if (_cases.isEmpty)
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
                              ..._cases.asMap().entries.map((e) {
                                final isLast = e.key == _cases.length - 1;
                                final c = e.value;
                                final clientName = c['name'] as String? ?? '-';
                                final lastSession =
                                    (c['last_session_date'] as String? ?? '-')
                                        .replaceAll('-', '.');
                                final risk = _parseRisk(c['risk_level'] as String?);
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: AppColors.backgroundGrey,
                                            child: Text(
                                              clientName.isNotEmpty ? clientName[0] : '?',
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(clientName,
                                                    style: AppTypography.body.copyWith(
                                                        fontWeight: FontWeight.w600)),
                                                Text(
                                                  '최근 상담: $lastSession',
                                                  style: AppTypography.caption,
                                                ),
                                              ],
                                            ),
                                          ),
                                          RiskChip(level: risk),
                                        ],
                                      ),
                                    ),
                                    if (!isLast)
                                      const Divider(height: 1, color: AppColors.border),
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
