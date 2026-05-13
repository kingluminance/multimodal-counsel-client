import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/section_card.dart';
import 'invite_code_page.dart';
import 'org_stats_page.dart';
import 'worker_manage_page.dart';
import 'privacy_settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfileHeader(),
            const SizedBox(height: 24),
            _StatsRow(),
            const SizedBox(height: 24),
            const Text('설정', style: AppTypography.sectionHeader),
            const SizedBox(height: 12),
            const SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingRow(icon: Icons.notifications_outlined, label: '알림 설정'),
                  Divider(height: 1),
                  _SettingRow(icon: Icons.lock_outline, label: '보안 및 개인정보'),
                  Divider(height: 1),
                  _SettingRow(icon: Icons.smart_toy_outlined, label: 'AI 분석 설정', iconColor: AppColors.purple),
                  Divider(height: 1),
                  _SettingRow(icon: Icons.palette_outlined, label: '화면 설정'),
                  Divider(height: 1),
                  _SettingRow(icon: Icons.help_outline, label: '도움말 및 지원'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('관리자', style: AppTypography.sectionHeader),
            const SizedBox(height: 12),
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.key_outlined,
                    label: '초대코드 관리',
                    iconColor: AppColors.teal,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const InviteCodePage()),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    icon: Icons.bar_chart_outlined,
                    label: '기관 통계',
                    iconColor: AppColors.primaryBlue,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const OrgStatsPage()),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    icon: Icons.people_outline,
                    label: '사회복지사 관리',
                    iconColor: AppColors.purple,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const WorkerManagePage()),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingRow(
                    icon: Icons.visibility_outlined,
                    label: '공개 항목 설정',
                    iconColor: AppColors.amber,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PrivacySettingsPage()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('계정', style: AppTypography.sectionHeader),
            const SizedBox(height: 12),
            const SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingRow(icon: Icons.sync_outlined, label: '데이터 동기화'),
                  Divider(height: 1),
                  _SettingRow(
                    icon: Icons.logout,
                    label: '로그아웃',
                    labelColor: AppColors.red,
                    iconColor: AppColors.red,
                    showChevron: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'v1.0.0 · Multimodal Counsel Client',
              style: AppTypography.caption.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
            child: const Text(
              '김',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('김상담사', style: AppTypography.title),
                const SizedBox(height: 4),
                Text(
                  '임상심리사 1급',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'counselor@hospital.kr',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _StatItem(label: '담당 내담자', value: '24'),
          _Divider(),
          const _StatItem(label: '총 세션', value: '312'),
          _Divider(),
          const _StatItem(label: '이번 달', value: '28'),
        ],
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
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.border);
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final bool showChevron;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(
                    color: labelColor ?? AppColors.textPrimary,
                  ),
                ),
              ),
              if (showChevron)
                const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
