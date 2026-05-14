import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _inviteCodeController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _organizationController = TextEditingController();

  String? _inviteCodeError;
  String _selectedGender = ''; // 'male' | 'female' | ''

  // 유효하지 않은 초대코드 예시 체크
  static const _invalidCodes = {'INVALID', 'TEST-0000'};

  void _validateInviteCode(String value) {
    setState(() {
      if (value.isEmpty) {
        _inviteCodeError = null;
      } else if (_invalidCodes.contains(value.toUpperCase())) {
        _inviteCodeError = '유효하지 않은 초대코드입니다.';
      } else {
        _inviteCodeError = null;
      }
    });
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1920),
      lastDate: now,
      locale: const Locale('ko'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            '${picked.year}년 ${picked.month.toString().padLeft(2, '0')}월 ${picked.day.toString().padLeft(2, '0')}일';
      });
    }
  }

  void _onSubmit() {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _inviteCodeError = '초대코드를 입력해주세요.');
      return;
    }
    if (_inviteCodeError != null) return;
    // TODO: 가입 완료 처리
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _birthDateController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundGrey,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // 타이틀
              const Text(
                '회원가입 완료',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '초대받은 정보를 입력해주세요',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 32),

              // 1. 초대코드 입력
              const _FieldLabel('초대코드'),
              const SizedBox(height: 6),
              AppTextField(
                controller: _inviteCodeController,
                hint: 'ABC-1234',
                errorText: _inviteCodeError,
                onChanged: _validateInviteCode,
              ),
              const SizedBox(height: 24),

              // 2. 성별 선택
              const _FieldLabel('성별'),
              const SizedBox(height: 6),
              _GenderSelector(
                selected: _selectedGender,
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 24),

              // 3. 생년월일
              const _FieldLabel('생년월일'),
              const SizedBox(height: 6),
              AppTextField(
                controller: _birthDateController,
                hint: '생년월일을 선택해주세요',
                readOnly: true,
                onTap: _pickBirthDate,
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 24),

              // 4. 소속 기관 검색
              const _FieldLabel('소속 기관'),
              const SizedBox(height: 6),
              AppTextField(
                controller: _organizationController,
                hint: '기관명을 검색해주세요',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 40),

              // 가입 완료 버튼
              PrimaryButton(
                label: '가입 완료',
                onPressed: _onSubmit,
              ),
              const SizedBox(height: 32),
            ],
          ),
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
    return Text(
      text,
      style: AppTypography.sectionHeader,
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderOption(
            label: '남성',
            isSelected: selected == 'male',
            onTap: () => onChanged('male'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GenderOption(
            label: '여성',
            isSelected: selected == 'female',
            onTap: () => onChanged('female'),
          ),
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
