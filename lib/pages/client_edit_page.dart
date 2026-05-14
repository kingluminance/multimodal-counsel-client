import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'notification_page.dart';

class ClientEditPage extends StatefulWidget {
  const ClientEditPage({super.key});

  @override
  State<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {
  final _nameController = TextEditingController(text: '홍길동');
  final _emailController = TextEditingController(text: 'abcd@efghi.co.kr');
  final _phoneController = TextEditingController(text: '010-1234-56789');
  final _addressController = TextEditingController(text: '강원도 원주시 세계로 9');
  final _memoController = TextEditingController();

  String _gender = 'male';
  String _birthDate = '1984-03-20';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1984, 3, 20),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _birthDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
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
                  Text('내담자 정보 수정', style: AppTypography.sectionHeader),
                  const SizedBox(height: 16),
                  // 이름 + 중복확인
                  _FieldLabel('이름'),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_nameController, '이름')),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                        ),
                        child: Text('중복확인', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _FieldLabel('이메일'),
                  _buildTextField(_emailController, '이메일', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 18),
                  _FieldLabel('연락처'),
                  _buildTextField(_phoneController, '연락처', keyboardType: TextInputType.phone),
                  const SizedBox(height: 18),
                  _FieldLabel('주소'),
                  _buildTextField(_addressController, '주소'),
                  const SizedBox(height: 18),
                  _FieldLabel('생년월일'),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSubtle,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(_birthDate, style: AppTypography.bodyMedium),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: const Icon(Icons.calendar_today_outlined, color: AppColors.textHint, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _FieldLabel('성별'),
                  Row(
                    children: [
                      _GenderRadio(
                        label: '남자',
                        isSelected: _gender == 'male',
                        onTap: () => setState(() => _gender = 'male'),
                      ),
                      const SizedBox(width: 24),
                      _GenderRadio(
                        label: '여자',
                        isSelected: _gender == 'female',
                        onTap: () => setState(() => _gender = 'female'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _FieldLabel('메모'),
                  TextField(
                    controller: _memoController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '기존 기록에 없는 내용을 상담원이 메모',
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
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 8 + MediaQuery.of(context).padding.bottom),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  elevation: 0,
                ),
                child: Text('저장하기', style: AppTypography.buttonText),
              ),
            ),
          ),
        ],
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

class _GenderRadio extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderRadio({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
