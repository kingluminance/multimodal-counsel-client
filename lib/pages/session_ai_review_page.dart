import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import 'notification_page.dart';

class SessionAiReviewPage extends StatefulWidget {
  final String sessionId;

  const SessionAiReviewPage({super.key, required this.sessionId});

  @override
  State<SessionAiReviewPage> createState() => _SessionAiReviewPageState();
}

class _SessionAiReviewPageState extends State<SessionAiReviewPage> {
  Map<String, dynamic>? _draft;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isConfirming = false;

  // 세션 헤더 정보 (세션 상세에서 전달받을 수 없으므로 draft에서 추출)
  String _headerTitle = '';
  String _headerDate = '';

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await SpeechAIService().getDraft(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _draft = data;
        _headerTitle = (data['session_type'] as String?) ?? '상담 요약';
        _headerDate = (data['session_date'] as String?) ?? '';
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? 'AI 초안을 불러오지 못했습니다.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'AI 초안을 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _confirm() async {
    setState(() => _isConfirming = true);
    try {
      await SpeechAIService().confirm(widget.sessionId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다')),
      );
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? '확정에 실패했습니다.'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  String _safeStr(String? key) {
    if (_draft == null) return '';
    return (_draft![key] as String?) ?? '';
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
        title: Text('상담 요약', style: AppTypography.h3),
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
                      Text(
                        _errorMessage!,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textHint),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadDraft,
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
                      // 헤더 정보
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.border, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _headerTitle.isNotEmpty
                                  ? _headerTitle
                                  : 'AI 초안',
                              style: AppTypography.h4.copyWith(
                                  fontWeight: FontWeight.w700),
                            ),
                            if (_headerDate.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _headerDate,
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // AI 요약 카드
                      if (_safeStr('summary').isNotEmpty ||
                          _safeStr('main_topic').isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSubtle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('🤖',
                                      style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text('AI 요약',
                                      style: AppTypography.sectionHeader),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _safeStr('summary').isNotEmpty
                                    ? _safeStr('summary')
                                    : _safeStr('main_topic'),
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 주상담주제
                      if (_safeStr('main_topic').isNotEmpty) ...[
                        _InfoSection(
                            label: '주상담주제',
                            value: _safeStr('main_topic')),
                        const SizedBox(height: 12),
                      ],

                      // 상담 목표
                      if (_safeStr('session_goal').isNotEmpty) ...[
                        _InfoSection(
                            label: '상담 목표',
                            value: _safeStr('session_goal')),
                        const SizedBox(height: 12),
                      ],

                      // 개입 유형
                      if (_safeStr('intervention_type').isNotEmpty) ...[
                        _InfoSection(
                            label: '개입 유형',
                            value: _safeStr('intervention_type')),
                        const SizedBox(height: 12),
                      ],

                      // 경제적 욕구
                      if (_draft?['need_economic'] != null) ...[
                        _InfoSection(
                          label: '경제적 욕구',
                          value: (_draft!['need_economic'] == true)
                              ? '있음'
                              : '없음',
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 다음 상담 계획
                      if (_safeStr('next_session_goal').isNotEmpty) ...[
                        _InfoSection(
                            label: '다음 상담 계획',
                            value: _safeStr('next_session_goal')),
                        const SizedBox(height: 12),
                      ],

                      // 다음 회기 목표 (next_session_date)
                      if (_safeStr('next_session_date').isNotEmpty) ...[
                        _InfoSection(
                            label: '다음 회기 예정일',
                            value: _safeStr('next_session_date')),
                        const SizedBox(height: 12),
                      ],

                      const SizedBox(height: 12),

                      // 버튼
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textSecondary,
                                side: const BorderSide(
                                    color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: Text(
                                '소개하기',
                                style: AppTypography.buttonText.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isConfirming ? null : _confirm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                elevation: 0,
                              ),
                              child: _isConfirming
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text('확정하기',
                                      style: AppTypography.buttonText),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String label;
  final String value;

  const _InfoSection({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.bodySmall
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
