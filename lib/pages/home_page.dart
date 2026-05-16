import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'client_page.dart';
import 'notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _weekOffset = 0;

  // 샘플 내담자 데이터
  final List<Map<String, String>> _clients = const [
    {'name': '홍길동', 'status': '상담예정', 'birth': '1982.04.02', 'lastSession': '2025.06.14'},
    {'name': '김민지', 'status': '상담완료', 'birth': '1990.11.15', 'lastSession': '2025.06.10'},
    {'name': '박서연', 'status': '상담예정', 'birth': '1995.07.22', 'lastSession': '2025.06.13'},
  ];

  // 상담 예정 날짜 (요일 인덱스 기준, 0=일 .. 6=토)
  final Set<int> _scheduledDays = {1, 3, 5}; // 월, 수, 금

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyCalendarCard(),
            const SizedBox(height: 20),
            _buildClientListSection(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundWhite,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          const Text('🧸', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text('사회복지사 지원', style: AppTypography.h4),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '1',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendarCard() {
    final now = DateTime.now();
    // 이번주 월요일 계산 (weekOffset 적용)
    final monday = now.subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _weekOffset * 7));
    final weekNum = (monday.day / 7).ceil();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary200,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('홍길동님', style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('한주간 상담 일정을 확인해보세요!',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const Text('📅', style: TextStyle(fontSize: 28)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // 월 헤더 + 전체보기
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _weekOffset--),
                          child: const Icon(Icons.chevron_left, size: 18, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${monday.year}년 ${monday.month}월 ${weekNum}주차',
                          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => setState(() => _weekOffset++),
                          child: const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text('전체보기', style: AppTypography.caption.copyWith(color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 요일 헤더
                Row(
                  children: ['일', '월', '화', '수', '목', '금', '토']
                      .asMap()
                      .entries
                      .map((e) {
                    final isFirst = e.key == 0;
                    final isLast = e.key == 6;
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            e.value,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(
                              color: isFirst
                                  ? AppColors.danger
                                  : isLast
                                      ? AppColors.chipScheduledFg
                                      : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                // 날짜 행 (일요일부터 시작)
                Row(
                  children: List.generate(7, (i) {
                    // 0=일, 1=월..6=토
                    // monday는 weekday=1, so sunday = monday - 1
                    final sunday = monday.subtract(const Duration(days: 1));
                    final date = sunday.add(Duration(days: i));
                    final isToday = date.year == now.year &&
                        date.month == now.month &&
                        date.day == now.day;
                    final hasSchedule = _scheduledDays.contains(i);
                    final isSunday = i == 0;
                    final isSat = i == 6;

                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isToday ? AppColors.primary : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  color: isToday
                                      ? AppColors.white
                                      : isSunday
                                          ? AppColors.danger
                                          : isSat
                                              ? AppColors.chipScheduledFg
                                              : AppColors.textPrimary,
                                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (hasSchedule)
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.chipScheduledFg,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(height: 5),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientListSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('📝', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text('내담자 목록', style: AppTypography.sectionHeader),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClientPage()),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.primary,
              ),
              child: Text('더보기', style: AppTypography.caption.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._clients.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildClientCard(c),
            )),
      ],
    );
  }

  Widget _buildClientCard(Map<String, String> client) {
    final status = client['status']!;
    final isScheduled = status == '상담예정';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(client['name']!, style: AppTypography.h4),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isScheduled ? AppColors.chipScheduledBg : AppColors.chipDoneBg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      status,
                      style: AppTypography.caption.copyWith(
                        color: isScheduled ? AppColors.chipScheduledFg : AppColors.chipDoneFg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('🎂', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                '생년월일: ${client['birth']}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                '마지막상담일: ${client['lastSession']}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // 닫기 버튼
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  _DrawerSection(
                    title: '내담자 관리',
                    items: const ['내담자 목록'],
                    onItemTap: (_) => Navigator.of(context).pop(),
                  ),
                  _DrawerSection(
                    title: '상담 관리',
                    items: const ['전체 상담목록', '오늘의 상담 목록'],
                    onItemTap: (_) => Navigator.of(context).pop(),
                  ),
                  _DrawerSection(
                    title: '게시판',
                    items: const ['공지사항', '프로그램', '자료실'],
                    onItemTap: (_) => Navigator.of(context).pop(),
                  ),
                  _DrawerSection(
                    title: '일정관리',
                    items: const [],
                    onItemTap: (_) {},
                  ),
                  _DrawerSection(
                    title: '마이페이지',
                    items: const [],
                    onItemTap: (_) {},
                  ),
                ],
              ),
            ),
            // 하단 프로필 + 로그아웃
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Text('🧸', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  Text('이복사', style: AppTypography.bodyMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      '로그아웃',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatefulWidget {
  final String title;
  final List<String> items;
  final void Function(String) onItemTap;

  const _DrawerSection({
    required this.title,
    required this.items,
    required this.onItemTap,
  });

  @override
  State<_DrawerSection> createState() => _DrawerSectionState();
}

class _DrawerSectionState extends State<_DrawerSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: AppTypography.sectionHeader),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.items.map((item) => GestureDetector(
                onTap: () => widget.onItemTap(item),
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg, bottom: AppSpacing.md),
                  child: Text(item, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ),
              )),
        const Divider(color: AppColors.border, height: 1),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
