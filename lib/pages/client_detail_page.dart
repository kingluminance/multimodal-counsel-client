import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import 'notification_page.dart';
import 'client_edit_page.dart';

class ClientDetailPage extends StatefulWidget {
  final String clientId;

  const ClientDetailPage({super.key, required this.clientId});

  @override
  State<ClientDetailPage> createState() => _ClientDetailPageState();
}

class _ClientDetailPageState extends State<ClientDetailPage> {
  final _searchController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _clientData;
  List<Map<String, dynamic>> _sessions = [];
  String? _error;

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
      setState(() {
        _clientData = results[0] as Map<String, dynamic>;
        _sessions = List<Map<String, dynamic>>.from(
          (results[1] as Map<String, dynamic>)['sessions'] ?? [],
        );
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response?.data?['message'] ?? '데이터를 불러오지 못했습니다.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '데이터를 불러오지 못했습니다.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('내담자 삭제', style: AppTypography.h4),
        content: Text('정말 삭제하시겠습니까?', style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('삭제', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ClientService().delete(widget.clientId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? '삭제에 실패했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제에 실패했습니다.')),
      );
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.danger),
                  ),
                )
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final client = _clientData ?? {};
    final name = client['name'] as String? ?? '-';
    final email = client['email'] as String? ?? '-';
    final phone = client['contact_phone'] as String? ?? '-';
    final address = client['address'] as String? ?? '-';

    final q = _searchController.text.trim();
    final filteredSessions = q.isEmpty
        ? _sessions
        : _sessions
            .where((s) => (s['topic'] as String? ?? '').contains(q))
            .toList();

    return SingleChildScrollView(
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
                _InfoRow(label: '이름', value: name),
                const Divider(color: AppColors.border, height: 20),
                _InfoRow(label: '이메일', value: email),
                const Divider(color: AppColors.border, height: 20),
                _InfoRow(label: '연락처', value: phone),
                const Divider(color: AppColors.border, height: 20),
                _InfoRow(label: '주소', value: address),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 버튼 행
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _onDelete,
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
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClientEditPage(
                          clientId: widget.clientId,
                          clientData: _clientData,
                        ),
                      ),
                    );
                    _loadData();
                  },
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
          if (filteredSessions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '상담 이력이 없습니다.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
                ),
              ),
            )
          else
            ...filteredSessions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SessionHistoryItem(session: s),
                )),
        ],
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
  final Map<String, dynamic> session;

  const _SessionHistoryItem({required this.session});

  @override
  Widget build(BuildContext context) {
    final status = session['status'] as String? ?? '';
    final isDone = status == '상담완료' || status == 'COMPLETED';
    final statusLabel = _statusLabel(status);
    final topic = session['topic'] as String? ?? '-';
    final date = (session['session_date'] as String? ?? '').replaceAll('-', '.');

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
          Text(topic, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          Row(
            children: [
              Text(
                date,
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
                  statusLabel,
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

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED':
        return '상담완료';
      case 'SCHEDULED':
        return '상담예정';
      case 'DRAFT':
        return '작성중';
      default:
        return status;
    }
  }
}
