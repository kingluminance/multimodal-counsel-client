import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'notification_page.dart';

class ClientRegisterPage extends StatefulWidget {
  const ClientRegisterPage({super.key});

  @override
  State<ClientRegisterPage> createState() => _ClientRegisterPageState();
}

class _ClientRegisterPageState extends State<ClientRegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _memoController = TextEditingController();

  String _gender = 'male';
  int _birthYear = 1990;
  int _birthMonth = 1;
  int _birthDay = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _onRegister() {
    Navigator.of(context).pop();
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
        title: Text('내담자 등록', style: AppTypography.h3),
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
                  // 이름 + 중복확인
                  _FieldLabel('이름'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(_nameController, '이름을 입력하세요.'),
                      ),
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
                  // 이메일
                  _FieldLabel('이메일'),
                  _buildTextField(_emailController, '이메일을 입력하세요.', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 18),
                  // 연락처
                  _FieldLabel('연락처'),
                  _buildTextField(_phoneController, '010-0000-0000', keyboardType: TextInputType.phone),
                  const SizedBox(height: 18),
                  // 주소
                  _FieldLabel('주소'),
                  _buildTextField(_addressController, '주소를 입력하세요.'),
                  const SizedBox(height: 18),
                  // 생년월일
                  _FieldLabel('생년월일'),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildDropdown(
                          value: _birthYear.toString(),
                          items: List.generate(80, (i) => (1940 + i).toString()),
                          onChanged: (v) => setState(() => _birthYear = int.parse(v!)),
                          hint: '연도',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildDropdown(
                          value: _birthMonth.toString(),
                          items: List.generate(12, (i) => (i + 1).toString()),
                          onChanged: (v) => setState(() => _birthMonth = int.parse(v!)),
                          hint: '월',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildDropdown(
                          value: _birthDay.toString(),
                          items: List.generate(31, (i) => (i + 1).toString()),
                          onChanged: (v) => setState(() => _birthDay = int.parse(v!)),
                          hint: '일',
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today_outlined, color: AppColors.textHint, size: 20),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // 성별
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
                  // 메모
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
          // 등록하기 버튼
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              8 + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                  elevation: 0,
                ),
                child: Text('등록하기', style: AppTypography.buttonText),
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

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: AppTypography.bodyMedium.copyWith(color: AppColors.textHint)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint, size: 18),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          dropdownColor: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
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
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
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
