import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _orgController = TextEditingController();
  final _careerController = TextEditingController();
  final _bioController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _isSaving = false;
  String _workerId = '';

  @override
  void initState() {
    super.initState();
    _loadWorker();
  }

  Future<void> _loadWorker() async {
    setState(() => _isLoading = true);
    try {
      final workerId = await _storage.read(key: 'user_id') ?? '';
      _workerId = workerId;
      if (workerId.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final result = await WorkerService().getWorker(workerId);
      if (!mounted) return;
      _nameController.text = result['name'] as String? ?? '';
      _emailController.text = result['email'] as String? ?? '';
      _phoneController.text = result['phone'] as String? ?? '';
      _orgController.text = result['org_name'] as String? ?? '';
      _careerController.text = result['career'] as String? ?? '';
      _bioController.text = result['bio'] as String? ?? '';
      setState(() => _isLoading = false);
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

  Future<void> _onSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final data = <String, dynamic>{};
      if (_nameController.text.isNotEmpty) data['name'] = _nameController.text.trim();
      if (_emailController.text.isNotEmpty) data['email'] = _emailController.text.trim();
      if (_phoneController.text.isNotEmpty) data['phone'] = _phoneController.text.trim();
      if (_orgController.text.isNotEmpty) data['org_name'] = _orgController.text.trim();
      if (_careerController.text.isNotEmpty) data['career'] = _careerController.text.trim();
      if (_bioController.text.isNotEmpty) data['bio'] = _bioController.text.trim();

      await WorkerService().updateWorker(_workerId, data);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      String message = '저장 중 오류가 발생했습니다.';
      if (e is DioException && e.response != null) {
        message = e.response?.data?['message'] as String? ?? message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
            onPressed: (_isSaving || _isLoading) ? null : _onSave,
            child: Text(
              _isSaving ? '저장 중...' : '저장',
              style: AppTypography.bodyMedium.copyWith(
                color: (_isSaving || _isLoading) ? AppColors.textHint : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text.substring(0, 1)
                                      : '?',
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
