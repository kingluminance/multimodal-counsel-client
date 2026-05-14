import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController(text: 'KNU');
  final _emailController = TextEditingController(text: 'kyle.kangwon@gmail.com');
  final _phoneController = TextEditingController(text: '010-1234-5678');
  final _orgController = TextEditingController(text: '강원대학교 원주캠퍼스 컴퓨터공학과');
  final _careerController = TextEditingController(text: '1년');
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _orgController.dispose();
    _careerController.dispose();
    _bioController.dispose();
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
        title: Text('프로필 수정', style: AppTypography.h3),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '저장',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 사진 영역
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'KNU',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.primary300,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: AppColors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '프로필 사진 변경',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // 폼 필드들
            _FieldLabel('이름'),
            _buildTextField(_nameController, '이름'),
            const SizedBox(height: 18),
            _FieldLabel('이메일'),
            _buildTextField(_emailController, '이메일', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 18),
            _FieldLabel('연락처'),
            _buildTextField(_phoneController, '연락처', keyboardType: TextInputType.phone),
            const SizedBox(height: 18),
            _FieldLabel('소속'),
            _buildTextField(_orgController, '소속 기관'),
            const SizedBox(height: 18),
            _FieldLabel('경력'),
            _buildTextField(_careerController, '경력'),
            const SizedBox(height: 18),
            _FieldLabel('자기소개'),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '자기소개를 입력하세요.',
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
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
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
          vertical: AppSpacing.lg,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTypography.sectionHeader),
    );
  }
}
