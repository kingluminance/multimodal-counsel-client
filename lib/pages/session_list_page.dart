import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'notification_page.dart';

class SessionListPage extends StatefulWidget {
  const SessionListPage({super.key});

  @override
  State<SessionListPage> createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  static const _tabs = ['전체', '상담예정', '상담완료', '취소'];

  final List<Map<String, String>> _sessions = const [
    {'name': '김민지', 'topic': '진로 상담', 'date': '2026.05.14 16:00', 'status': '상담예정'},
    {'name': '박지현', 'topic': '대인관계', 'date': '2026.05.14 17:00', 'status': '상담예정'},
    {'name': '최준호', 'topic': '학교생활 적응', 'date': '2026.05.13 14:00', 'status': '상담완료'},
    {'name': '정아연', 'topic': '진로 상담', 'date': '2026.05.12 10:00', 'status': '상담완료'},
    {'name': '강도윤', 'topic': '대인관계', 'date': '2026.05.10 11:00', 'status': '취소'},
    {'name': '윤학준', 'topic': '학업 스트레스', 'date': '2026.05.15 09:00', 'status': '상담예정'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered {
    final q = _searchController.text.trim();
    final tabLabel = _tabs[_tabController.index];
    return _sessions.where((s) {
      final matchSearch = q.isEmpty || s['name']!.contains(q);
      final matchTab = tabLabel == '전체' || s['status'] == tabLabel;
      return matchSearch && matchTab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
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
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
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
                    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
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
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelStyle: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
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
      body: filtered.isEmpty
          ? Center(
              child: Text('검색 결과가 없습니다', style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _SessionCard(session: filtered[i]),
            ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Map<String, String> session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final status = session['status']!;
    Color bgColor;
    Color fgColor;
    switch (status) {
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

    return Container(
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
                '${session['name']} · ${session['topic']}',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                session['date']!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              status,
              style: AppTypography.caption.copyWith(color: fgColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
