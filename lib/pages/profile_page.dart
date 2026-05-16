import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import 'login_page.dart';
import 'notification_page.dart';
import 'privacy_settings_page.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _storage = const FlutterSecureStorage();

  bool _isLoading = true;
  String _name = '';
  String _role = '';
  String _orgName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadWorker();
  }

  Future<void> _loadWorker() async {
    try {
      final workerId = await _storage.read(key: 'user_id') ?? '';
      if (workerId.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final result = await WorkerService().getWorker(workerId);
      if (!mounted) return;
      setState(() {
        _name = result['name'] as String? ?? '';
        _role = result['role'] as String? ?? '';
        _orgName = result['org_name'] as String? ?? '';
        _email = result['email'] as String? ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String message = '프로필 정보를 불러오지 못했습니다.';
      if (e is DioException && e.response != null) {
        message = e.response?.data?['message'] as String? ?? message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _onLogout() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token') ?? '';
      await AuthService().logout(refreshToken);
    } catch (_) {
      // 로그아웃 실패해도 로컬 토큰은 clearTokens에서 삭제됨
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  String get _nameInitial => _name.isNotEmpty ? _name.substring(0, 1) : '?';

  String get _roleLabel {
    switch (_role) {
      case 'worker':
        return '사회복지사';
      case 'supervisor':
        return '슈퍼바이저';
      case 'admin':
        return '관리자';
      default:
        return _role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
        title: Text('마이페이지', style: AppTypography.h3),
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 프로필 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _nameInitial,
                              style: AppTypography.h2.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _name,
                          style: AppTypography.h3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_email.isNotEmpty)
                          Text(
                            _email,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (_orgName.isNotEmpty || _roleLabel.isNotEmpty)
                          Text(
                            [if (_orgName.isNotEmpty) _orgName, if (_roleLabel.isNotEmpty) _roleLabel]
                                .join(' · '),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 통계 바
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(child: _StatItem(label: '내담자', value: '47')),
                        Container(width: 1, height: 36, color: AppColors.border),
                        Expanded(child: _StatItem(label: '이번주 상담', value: '128')),
                        Container(width: 1, height: 36, color: AppColors.border),
                        Expanded(child: _StatItem(label: '주사례', value: '12')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 메뉴 리스트
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Column(
                      children: [
                        _MenuItem(
                          icon: Icons.person_outline,
                          title: '프로필 수정',
                          subtitle: '이름, 연락처, 자기소개',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProfileEditPage()),
                          ),
                        ),
                        const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                        _MenuItem(
                          icon: Icons.lock_outline,
                          title: '비밀번호 변경',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PrivacySettingsPage()),
                          ),
                        ),
                        const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                        _MenuItem(
                          icon: Icons.calendar_today_outlined,
                          title: '알림 설정',
                          subtitle: '상담 알림, 게시판 알림',
                          onTap: () {},
                        ),
                        const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                        _MenuItem(
                          icon: Icons.bar_chart,
                          title: '나의 상담 통계',
                          subtitle: '월별 상담, 주사례',
                          onTap: () {},
                        ),
                        const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          title: '환경 설정',
                          subtitle: '테마, 글자 크기, 언어',
                          onTap: () {},
                        ),
                        const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                        _MenuItem(
                          icon: Icons.help_outline,
                          title: '도움말',
                          subtitle: 'FAQ',
                          onTap: () {},
                        ),
                        const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                        _MenuItem(
                          icon: Icons.logout,
                          title: '로그아웃',
                          onTap: _onLogout,
                          isLast: true,
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.h3.copyWith(color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.caption.copyWith(color: AppColors.textHint)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}
