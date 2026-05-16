import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import 'notification_page.dart';

class SessionHistoryPage extends StatefulWidget {
  final String clientId;
  const SessionHistoryPage({super.key, required this.clientId});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _clientData;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ClientService().detail(widget.clientId),
        SessionService().listByClient(widget.clientId),
      ]);
      if (!mounted) return;
      final raw = List<Map<String, dynamic>>.from(
        (results[1] as Map<String, dynamic>)['sessions'] ?? [],
      );
      raw.sort((a, b) =>
          (b['session_date'] as String? ?? '').compareTo(a['session_date'] as String? ?? ''));
      setState(() {
        _clientData = results[0] as Map<String, dynamic>;
        _sessions = raw;
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

  String _mapStatus(String? s) {
    switch (s) {
      case 'COMPLETED':
      case 'FINAL':
      case 'SIGNED':
        return '상담완료';
      case 'SCHEDULED':
      case 'DRAFT':
        return '상담예정';
      case 'CANCELLED':
        return '취소';
      default:
        return s ?? '-';
    }
  }

  String? _firstSessionDate() {
    if (_sessions.isEmpty) return null;
    final sorted = [..._sessions]
      ..sort((a, b) =>
          (a['session_date'] as String? ?? '').compareTo(b['session_date'] as String? ?? ''));
    return (sorted.first['session_date'] as String? ?? '').replaceAll('-', '.');
  }

  @override
  Widget build(BuildContext context) {
    final clientName = _clientData?['name'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('상담 이력', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.danger),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clientName,
                              style: AppTypography.h2.copyWith(
                                  color: AppColors.white, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '총 상담 ${_sessions.length}회'
                              '${_firstSessionDate() != null ? ' · 최초 상담 ${_firstSessionDate()}' : ''}',
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_sessions.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              '상담 이력이 없습니다.',
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, width: 1),
                          ),
                          child: Column(
                            children: _sessions.asMap().entries.map((entry) {
                              final i = entry.key;
                              final s = entry.value;
                              final date =
                                  (s['session_date'] as String? ?? '').replaceAll('-', '.');
                              final topic = s['topic'] as String? ??
                                  s['session_type'] as String? ??
                                  '-';
                              final status = _mapStatus(s['status'] as String?);
                              final isDone = status == '상담완료';
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          topic,
                                          style: AppTypography.bodyMedium
                                              .copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              date,
                                              style: AppTypography.bodySmall
                                                  .copyWith(color: AppColors.textSecondary),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isDone
                                                    ? AppColors.chipDoneBg
                                                    : AppColors.chipScheduledBg,
                                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                              ),
                                              child: Text(
                                                status,
                                                style: AppTypography.caption.copyWith(
                                                  color: isDone
                                                      ? AppColors.chipDoneFg
                                                      : AppColors.chipScheduledFg,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (i < _sessions.length - 1)
                                    const Divider(
                                        color: AppColors.border,
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
