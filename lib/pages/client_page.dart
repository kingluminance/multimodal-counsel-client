import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'client_detail_page.dart';
import 'client_register_page.dart';
import 'notification_page.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final _searchController = TextEditingController();

  final List<Map<String, String>> _clients = const [
    {'name': '홍길동', 'status': '상담예정', 'birth': '1982.04.02', 'lastSession': '2025.06.14'},
    {'name': '김민지', 'status': '상담완료', 'birth': '1990.11.15', 'lastSession': '2025.06.10'},
    {'name': '박서연', 'status': '상담예정', 'birth': '1995.07.22', 'lastSession': '2025.06.13'},
    {'name': '이준혁', 'status': '상담완료', 'birth': '1988.03.05', 'lastSession': '2025.06.08'},
    {'name': '최민준', 'status': '상담예정', 'birth': '1975.09.30', 'lastSession': '2025.06.11'},
  ];

  List<Map<String, String>> get _filtered {
    final q = _searchController.text.trim();
    if (q.isEmpty) return _clients;
    return _clients.where((c) => c['name']!.contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: Text('내담자 목록', style: AppTypography.h3),
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
      body: Column(
        children: [
          // 검색바
          Container(
            color: AppColors.backgroundWhite,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '내담자 이름 또는 상담목적을 입력하세요.',
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
          // 내담자 목록
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('검색 결과가 없습니다', style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ClientCard(
                      client: filtered[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ClientDetailPage()),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ClientRegisterPage()),
        ),
        backgroundColor: AppColors.primary300,
        foregroundColor: AppColors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Map<String, String> client;
  final VoidCallback onTap;

  const _ClientCard({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = client['status']!;
    final isScheduled = status == '상담예정';

    return GestureDetector(
      onTap: onTap,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(client['name']!, style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700)),
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
      ),
    );
  }
}
