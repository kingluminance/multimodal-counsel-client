import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
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
  Timer? _debounce;

  bool _isLoading = false;
  List<Map<String, dynamic>> _clients = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await ClientService().list();
      if (!mounted) return;
      setState(() {
        _clients = List<Map<String, dynamic>>.from(result['clients'] ?? []);
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response?.data?['message'] ?? '목록을 불러오지 못했습니다.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '목록을 불러오지 못했습니다.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onSearchChanged(String q) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final trimmed = q.trim();
      if (trimmed.isEmpty) {
        await _loadClients();
        return;
      }
      if (trimmed.length < 2) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final result = await ClientService().search(trimmed);
        if (!mounted) return;
        setState(() {
          _clients = List<Map<String, dynamic>>.from(result['clients'] ?? []);
        });
      } on DioException catch (e) {
        if (!mounted) return;
        setState(() {
          _error = e.response?.data?['message'] ?? '검색에 실패했습니다.';
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = '검색에 실패했습니다.';
        });
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
              onChanged: _onSearchChanged,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Text(
                          _error!,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.danger),
                        ),
                      )
                    : _clients.isEmpty
                        ? Center(
                            child: Text(
                              '검색 결과가 없습니다',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _clients.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) => _ClientCard(
                              client: _clients[i],
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ClientDetailPage(
                                    clientId: (_clients[i]['clientId'] ?? _clients[i]['client_id']) as String,
                                  ),
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ClientRegisterPage()),
          );
          _loadClients();
        },
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
  final Map<String, dynamic> client;
  final VoidCallback onTap;

  const _ClientCard({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = client['status'] as String? ?? '';
    final isScheduled = status == '상담예정' || status == 'SCHEDULED';
    final statusLabel = _statusLabel(status);

    final name = client['name'] as String? ?? '';
    final birthDate = (client['birthDate'] ?? client['birth_date']) as String? ?? '';
    final lastSession = (client['lastSessionDate'] ?? client['last_session_date']) as String? ?? '-';

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
                    Text(name, style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isScheduled ? AppColors.chipScheduledBg : AppColors.chipDoneBg,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        statusLabel,
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
                  '생년월일: ${birthDate.replaceAll('-', '.')}',
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
                  '마지막상담일: ${lastSession.replaceAll('-', '.')}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'SCHEDULED':
        return '상담예정';
      case 'COMPLETED':
        return '상담완료';
      case 'ACTIVE':
        return '진행중';
      default:
        return status;
    }
  }
}
