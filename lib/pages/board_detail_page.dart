import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class BoardDetailPage extends StatefulWidget {
  const BoardDetailPage({super.key});

  @override
  State<BoardDetailPage> createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  final _commentController = TextEditingController();
  int _likes = 8;
  bool _liked = false;

  static const _comments = [
    {'author': '강상영', 'text': '나는 게임', 'date': '05-13'},
    {'author': '이복사', 'text': '일정 확인했습니다. 감사합니다!', 'date': '05-12'},
    {'author': '나순미', 'text': '참석하겠습니다.', 'date': '05-11'},
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('게시글', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 칩
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.chipScheduledBg,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '공지사항',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.chipScheduledFg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 제목
                  Text(
                    '5월 슈퍼비전 일정 안내',
                    style: AppTypography.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  // 작성자 정보
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('🧸', style: TextStyle(fontSize: 14))),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('관리자', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            '2026.03.13 08:20 · 조회 41',
                            style: AppTypography.caption.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),
                  // 본문
                  Text(
                    '안녕하세요. 5월 슈퍼비전 일정을 안내드립니다.\n\n• 일시: 2026년 5월 20일 (수) 오후 2시\n• 장소: 강원대학교 원주캠퍼스 상담센터 3층 회의실\n• 대상: 전체 상담원\n\n이번 슈퍼비전에서는 복합 트라우마 사례와 위기 개입 사례를 중심으로 논의할 예정입니다.\n\n참석 여부는 5월 18일까지 회신 부탁드립니다.',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  // 좋아요/댓글 수
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _liked = !_liked;
                          _likes += _liked ? 1 : -1;
                        }),
                        child: Row(
                          children: [
                            Text(
                              '👍',
                              style: TextStyle(
                                fontSize: 16,
                                color: _liked ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_likes',
                              style: AppTypography.bodySmall.copyWith(
                                color: _liked ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('💬', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '${_comments.length}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 12),
                  // 댓글 섹션
                  Text('댓글 ${_comments.length}', style: AppTypography.sectionHeader),
                  const SizedBox(height: 10),
                  ..._comments.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSubtle,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  c['author']![0],
                                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(c['author']!, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 8),
                                      Text(c['date']!, style: AppTypography.caption.copyWith(color: AppColors.textHint)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(c['text']!, style: AppTypography.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          // 댓글 입력 바
          Container(
            color: AppColors.backgroundWhite,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 8 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요.',
                      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.backgroundSubtle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _commentController.clear();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: AppColors.white, size: 18),
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
