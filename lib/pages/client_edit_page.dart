import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import 'notification_page.dart';

class ClientEditPage extends StatefulWidget {
  final String clientId;
  final Map<String, dynamic>? clientData;

  const ClientEditPage({
    super.key,
    required this.clientId,
    this.clientData,
  });

  @override
  State<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _memoController;

  String _gender = 'male';
  String _birthDate = '';

  // 초기값 (변경 감지용)
  String _initName = '';
  String _initEmail = '';
  String _initPhone = '';
  String _initAddress = '';
  String _initMemo = '';
  String _initGender = 'male';
  String _initBirthDate = '';

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _memoController = TextEditingController();

    if (widget.clientData != null) {
      _applyData(widget.clientData!);
    } else {
      _fetchDetail();
    }
  }

  void _applyData(Map<String, dynamic> data) {
    final name = data['name'] as String? ?? '';
    final email = data['email'] as String? ?? '';
    final phone = data['contact_phone'] as String? ?? '';
    final address = data['address'] as String? ?? '';
    final memo = data['memo'] as String? ?? '';
    final gender = data['gender'] as String? ?? 'male';
    final birthDate = data['birth_date'] as String? ?? '';

    _nameController.text = name;
    _emailController.text = email;
    _phoneController.text = phone;
    _addressController.text = address;
    _memoController.text = memo;
    _gender = gender;
    _birthDate = birthDate;

    _initName = name;
    _initEmail = email;
    _initPhone = phone;
    _initAddress = address;
    _initMemo = memo;
    _initGender = gender;
    _initBirthDate = birthDate;
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final data = await ClientService().detail(widget.clientId);
      if (!mounted) return;
      setState(() => _applyData(data));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? '데이터를 불러오지 못했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('데이터를 불러오지 못했습니다.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    DateTime initial;
    try {
      final parts = _birthDate.split('-');
      initial = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      initial = DateTime(1990, 1, 1);
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _birthDate =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _onSave() async {
    final changedFields = <String, dynamic>{};

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final memo = _memoController.text.trim();

    if (name != _initName) changedFields['name'] = name;
    if (email != _initEmail) changedFields['email'] = email;
    if (phone != _initPhone) changedFields['contact_phone'] = phone;
    if (address != _initAddress) changedFields['address'] = address;
    if (memo != _initMemo) changedFields['memo'] = memo;
    if (_gender != _initGender) changedFields['gender'] = _gender;
    if (_birthDate != _initBirthDate) changedFields['birth_date'] = _birthDate;

    if (changedFields.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ClientService().update(widget.clientId, changedFields);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? '저장에 실패했습니다.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했습니다.')),
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
    _addressController.dispose();
    _memoController.dispose();
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
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                                  child: Text(
                                    _birthDate.isEmpty ? '생년월일 선택' : _birthDate,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: _birthDate.isEmpty ? AppColors.textHint : AppColors.textPrimary,
                                    ),
                                  ),
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
                      onPressed: _isSaving ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            )
                          : Text('저장하기', style: AppTypography.buttonText),
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
