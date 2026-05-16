import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import 'notification_page.dart';
import 'session_detail_page.dart';
import 'schedule_add_page.dart';

class SessionListPage extends StatefulWidget {
  final String clientId;

  const SessionListPage({super.key, required this.clientId});

  @override
  State<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  static const _tabs = ['전체', '상담예정', '상담완료', '취소'];

  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await SessionService().listByClient(widget.clientId);
      if (!mounted) return;
      final raw = result['sessions'] as List<dynamic>? ?? [];
      setState(() {
        _sessions = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? '세션 목록을 불러오지 못했습니다.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '세션 목록을 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  String _mapStatus(String? apiStatus) {
    switch (apiStatus) {
      case 'DRAFT':
      case 'SCHEDULED':
        return '상담예정';
      case 'FINAL':
      case 'SIGNED':
        return '상담완료';
      case 'CANCELLED':
        return '취소';
      default:
        return '상담예정';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchController.text.trim();
    final tabLabel = _tabs[_tabController.index];
    return _sessions.where((s) {
      final clientName = (s['client_name'] as String?) ?? '';
      final sessionType = (s['session_type'] as String?) ?? '';
      final status = _mapStatus(s['status'] as String?);
      final matchSearch = q.isEmpty ||
          clientName.contains(q) ||
          sessionType.contains(q);
      final matchTab = tabLabel == '전체' || status == tabLabel;
      return matchSearch && matchTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ScheduleAddPage(preselectedClientId: widget.clientId),
            ),
          );
          _loadSessions();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('전체 상담 목록', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 52),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '내담자 이름으로 검색',
                    hintStyle: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textHint),
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
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textHint, size: 20),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelStyle: AppTypography.bodySmall
                    .copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTypography.bodySmall,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textHint)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadSessions,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }
    final filtered = _filtered;
    if (filtered.isEmpty) {
      return Center(
        child: Text('검색 결과가 없습니다',
            style:
                AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final s = filtered[i];
        return _SessionCard(
          session: s,
          mappedStatus: _mapStatus(s['status'] as String?),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SessionDetailPage(
                sessionId: s['session_id']?.toString() ?? '',
                sessionNumber: (s['session_number'] as num?)?.toInt() ?? 0,
                date: s['session_date']?.toString() ?? '',
                type: s['session_type']?.toString() ?? '',
                method: s['session_method']?.toString() ?? '',
                duration: '',
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final String mappedStatus;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.mappedStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    switch (mappedStatus) {
      case '상담예정':
        bgColor = AppColors.chipScheduledBg;
        fgColor = AppColors.chipScheduledFg;
        break;
      case '상담완료':
        bgColor = AppColors.chipDoneBg;
        fgColor = AppColors.chipDoneFg;
        break;
      default:
        bgColor = AppColors.chipCancelBg;
        fgColor = AppColors.chipCancelFg;
    }

    final clientName = (session['client_name'] as String?) ?? '';
    final sessionType = (session['session_type'] as String?) ?? '';
    final sessionDate = (session['session_date'] as String?) ?? '';
    final sessionTime = (session['session_time_start'] as String?) ?? '';
    final dateDisplay = sessionTime.isNotEmpty
        ? '$sessionDate $sessionTime'
        : sessionDate;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName.isNotEmpty && sessionType.isNotEmpty
                      ? '$clientName · $sessionType'
                      : clientName.isNotEmpty
                          ? clientName
                          : sessionType,
                  style: AppTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  dateDisplay,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                mappedStatus,
                style: AppTypography.caption.copyWith(
                    color: fgColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
