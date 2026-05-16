import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'board_detail_page.dart';
import 'board_write_page.dart';
import 'notification_page.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['전체', '공지사항', '자료실', '자료게시판'];

  static const _posts = [
    {'category': '공지사항', 'title': '5월 슈퍼비전 일정 안내', 'author': '관리자', 'date': '05-10', 'likes': '7'},
    {'category': '공지사항', 'title': '신규 상담 매뉴얼 업데이트', 'author': '관리자', 'date': '05-11', 'likes': '13'},
    {'category': '자료실', 'title': '청소년 진로 검사지 양식', 'author': '나순미', 'date': '05-13', 'likes': '9'},
    {'category': '공지사항', 'title': '6월 교육 일정 안내', 'author': '관리자', 'date': '05-08', 'likes': '5'},
    {'category': '자료게시판', 'title': '상담 사례 공유 - 진로 영역', 'author': '이복사', 'date': '05-07', 'likes': '11'},
    {'category': '자료실', 'title': '위기 개입 프로토콜 v2.0', 'author': '관리자', 'date': '05-05', 'likes': '18'},
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
    super.dispose();
  }

  List<Map<String, String>> get _filtered {
    final tabLabel = _tabs[_tabController.index];
    if (tabLabel == '전체') return List.from(_posts);
    return _posts.where((p) => p['category'] == tabLabel).toList();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case '공지사항':
        return AppColors.chipScheduledFg;
      case '자료실':
        return AppColors.chipDoneFg;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _categoryBg(String category) {
    switch (category) {
      case '공지사항':
        return AppColors.chipScheduledBg;
      case '자료실':
        return AppColors.chipDoneBg;
      default:
        return AppColors.backgroundSubtle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        title: Text('게시판', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BoardWritePage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTypography.bodySmall,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Text('게시글이 없습니다', style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final post = filtered[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BoardDetailPage()),
                  ),
                  child: Container(
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
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _categoryBg(post['category']!),
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                post['category']!,
                                style: AppTypography.caption.copyWith(
                                  color: _categoryColor(post['category']!),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                post['title']!,
                                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              post['author']!,
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              post['date']!,
                              style: AppTypography.caption.copyWith(color: AppColors.textHint),
                            ),
                            const Spacer(),
                            const Text('👍', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 2),
                            Text(
                              post['likes']!,
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BoardWritePage()),
        ),
        backgroundColor: AppColors.primary300,
        foregroundColor: AppColors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit_outlined, size: 24),
      ),
    );
  }
}
