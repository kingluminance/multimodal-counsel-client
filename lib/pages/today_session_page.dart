import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import 'notification_page.dart';
import 'session_recording_page.dart';

class TodaySessionPage extends StatefulWidget {
  const TodaySessionPage({super.key});

  @override
  State<TodaySessionPage> createState() => _TodaySessionPageState();
}

class _TodaySessionPageState extends State<TodaySessionPage> {
  List<Map<String, dynamic>> _todaySessions = [];
  bool _isLoading = true;
  String? _errorMessage;

  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadTodaySessions();
  }

  Future<void> _loadTodaySessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final workerId = await _storage.read(key: 'user_id');
      if (!mounted) return;
      if (workerId == null || workerId.isEmpty) {
        setState(() {
          _errorMessage = '로그인 정보를 찾을 수 없습니다.';
          _isLoading = false;
        });
        return;
      }
      final result = await SessionService().upcoming(workerId);
      if (!mounted) return;
      final raw = result['sessions'] as List<dynamic>? ?? [];
      final todayStr = _todayDateString();
      final todayList = raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((s) {
            final sessionDate = (s['session_date'] as String?) ?? '';
            return sessionDate == todayStr;
          })
          .toList();
      setState(() {
        _todaySessions = todayList;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? '오늘 상담 목록을 불러오지 못했습니다.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '오늘 상담 목록을 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _formatTodayHeader() {
    final now = DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    return '${now.year}년 ${now.month}월 ${now.day}일 ($weekday)';
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
        title: Text('오늘의 상담', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textHint)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadTodaySessions,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_formatTodayHeader(), style: AppTypography.h4),
                      const SizedBox(height: 4),
                      Text(
                        '오늘 예정된 상담 ${_todaySessions.length}건',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      if (_todaySessions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: Text(
                              '오늘 예정된 상담이 없습니다.',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textHint),
                            ),
                          ),
                        )
                      else
                        ..._todaySessions.map((s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _TodaySessionCard(
                                session: s,
                                onStart: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SessionRecordingPage(
                                      sessionId:
                                          s['session_id']?.toString() ?? '',
                                    ),
                                  ),
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
    );
  }
}

class _TodaySessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final VoidCallback onStart;

  const _TodaySessionCard({required this.session, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final clientName = (session['client_name'] as String?) ?? '';
    final sessionType = (session['session_type'] as String?) ?? '';
    final timeStart = (session['session_time_start'] as String?) ?? '';
    final timeEnd = (session['session_time_end'] as String?) ?? '';
    final timeDisplay = timeEnd.isNotEmpty
        ? '$timeStart - $timeEnd'
        : timeStart;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이름: $clientName',
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('유형: $sessionType',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.chipScheduledBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '상담예정',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.chipScheduledFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time,
                  color: AppColors.textHint, size: 14),
              const SizedBox(width: 4),
              Text(timeDisplay,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg)),
                elevation: 0,
              ),
              child: Text('상담 시작', style: AppTypography.buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
