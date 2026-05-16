import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get _canSave =>
      _currentPwController.text.isNotEmpty &&
      _newPwController.text.isNotEmpty &&
      _confirmPwController.text.isNotEmpty &&
      _newPwController.text == _confirmPwController.text;

  @override
  void dispose() {
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
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
        title: Text('비밀번호 변경', style: AppTypography.h3),
        actions: [
          TextButton(
            onPressed: _canSave ? () => Navigator.of(context).pop() : null,
            child: Text(
              '저장',
              style: AppTypography.bodyMedium.copyWith(
                color: _canSave ? AppColors.primary : AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 안내 텍스트
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      '안전을 위해 정기적으로 비밀번호를 변경해주세요.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 현재 비밀번호
                  _FieldLabel('현재 비밀번호'),
                  _buildPasswordField(
                    controller: _currentPwController,
                    hint: '현재 비밀번호를 입력하세요.',
                    obscure: _obscureCurrent,
                    onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  const SizedBox(height: 20),
                  // 새 비밀번호
                  _FieldLabel('새 비밀번호'),
                  _buildPasswordField(
                    controller: _newPwController,
                    hint: '8자 이상, 영문/숫자/특수문자 조합',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  // 새 비밀번호 확인
                  _FieldLabel('새 비밀번호 확인'),
                  _buildPasswordField(
                    controller: _confirmPwController,
                    hint: '새 비밀번호를 다시 입력하세요.',
                    obscure: _obscureConfirm,
                    onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_confirmPwController.text.isNotEmpty &&
                      _newPwController.text != _confirmPwController.text) ...[
                    const SizedBox(height: 6),
                    Text(
                      '비밀번호가 일치하지 않습니다.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.danger),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 8 + MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSave ? () => Navigator.of(context).pop() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSave ? AppColors.primary : AppColors.primaryLight,
                  foregroundColor: _canSave ? AppColors.white : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.primaryLight,
                  disabledForegroundColor: AppColors.primary,
                ),
                child: Text('비밀번호 변경하기', style: AppTypography.buttonText.copyWith(
                  color: _canSave ? AppColors.white : AppColors.primary,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
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
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textHint,
            size: 20,
          ),
          onPressed: onToggle,
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
