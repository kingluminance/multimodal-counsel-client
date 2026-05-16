import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'notification_page.dart';
import 'client_edit_page.dart';

class ClientDetailPage extends StatefulWidget {
  const ClientDetailPage({super.key});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _sessions = const [
    {'topic': '대인관계', 'date': '2025.04.28', 'status': '상담완료'},
    {'topic': '진로 상담', 'date': '2025.03.14', 'status': '상담완료'},
    {'topic': '학업 스트레스', 'date': '2025.02.20', 'status': '상담완료'},
    {'topic': '가족관계', 'date': '2025.01.15', 'status': '상담완료'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
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
        title: Text('내담자 정보', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Text('내담자 상세', style: AppTypography.sectionHeader),
            const SizedBox(height: 8),
            // 정보 카드
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  _InfoRow(label: '이름', value: '홍길순'),
                  const Divider(color: AppColors.border, height: 20),
                  _InfoRow(label: '이메일', value: 'abcd@efghi.co.kr'),
                  const Divider(color: AppColors.border, height: 20),
                  _InfoRow(label: '연락처', value: '010-1234-3678'),
                  const Divider(color: AppColors.border, height: 20),
                  _InfoRow(label: '주소', value: '강원도 원주시 세계로 9'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 버튼 행
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('내담자 삭제', style: AppTypography.h4),
                          content: Text('정말 삭제하시겠습니까?', style: AppTypography.bodyMedium),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text('삭제', style: TextStyle(color: AppColors.danger)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('삭제하기', style: AppTypography.buttonText.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ClientEditPage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: Text('수정하기', style: AppTypography.buttonText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 상담 이력 섹션
            Text('상담 이력', style: AppTypography.sectionHeader),
            const SizedBox(height: 8),
            // 검색바
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요.',
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
            const SizedBox(height: 12),
            // 상담 이력 리스트
            ..._sessions.map((s) {
              final q = _searchController.text.trim();
              if (q.isNotEmpty && !s['topic']!.contains(q)) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SessionHistoryItem(session: s),
              );
            }),
          ],
        ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SessionHistoryItem extends StatelessWidget {
  final Map<String, String> session;

  const _SessionHistoryItem({required this.session});

  @override
  Widget build(BuildContext context) {
    final status = session['status']!;
    final isDone = status == '상담완료';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(session['topic']!, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          Row(
            children: [
              Text(
                session['date']!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDone ? AppColors.chipDoneBg : AppColors.chipScheduledBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  status,
                  style: AppTypography.caption.copyWith(
                    color: isDone ? AppColors.chipDoneFg : AppColors.chipScheduledFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
