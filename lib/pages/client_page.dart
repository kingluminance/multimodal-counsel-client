import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/risk_chip.dart';
import '../widgets/section_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'client_detail_page.dart';

// ── 데이터 모델 ──────────────────────────────────────────────

enum ClientStatus { active, closed }

class _ClientData {
  final String name;
  final String gender; // '남' / '여'
  final int age;
  final RiskLevel risk;
  final String lastSession;
  final int sessionCount;
  final String sessionType;
  final ClientStatus status;

  const _ClientData({
    required this.name,
    required this.gender,
    required this.age,
    required this.risk,
    required this.lastSession,
    required this.sessionCount,
    required this.sessionType,
    required this.status,
  });
}

enum _FilterType { all, active, high, medium, low, closed }

extension _FilterTypeX on _FilterType {
  String get label {
    switch (this) {
      case _FilterType.all:
        return '전체';
      case _FilterType.active:
        return '진행중';
      case _FilterType.high:
        return '고위험';
      case _FilterType.medium:
        return '중위험';
      case _FilterType.low:
        return '저위험';
      case _FilterType.closed:
        return '종결';
    }
  }

  bool matches(_ClientData c) {
    switch (this) {
      case _FilterType.all:
        return true;
      case _FilterType.active:
        return c.status == ClientStatus.active;
      case _FilterType.high:
        return c.risk == RiskLevel.high;
      case _FilterType.medium:
        return c.risk == RiskLevel.medium;
      case _FilterType.low:
        return c.risk == RiskLevel.low;
      case _FilterType.closed:
        return c.status == ClientStatus.closed;
    }
  }
}

// ── 샘플 데이터 ───────────────────────────────────────────────

const _sampleClients = [
  _ClientData(
    name: '김지수',
    gender: '여',
    age: 28,
    risk: RiskLevel.high,
    lastSession: '2일 전',
    sessionCount: 12,
    sessionType: '개인 상담',
    status: ClientStatus.active,
  ),
  _ClientData(
    name: '이준혁',
    gender: '남',
    age: 35,
    risk: RiskLevel.medium,
    lastSession: '5일 전',
    sessionCount: 7,
    sessionType: '위기 개입',
    status: ClientStatus.active,
  ),
  _ClientData(
    name: '박서연',
    gender: '여',
    age: 22,
    risk: RiskLevel.low,
    lastSession: '어제',
    sessionCount: 4,
    sessionType: '개인 상담',
    status: ClientStatus.active,
  ),
  _ClientData(
    name: '최민준',
    gender: '남',
    age: 41,
    risk: RiskLevel.medium,
    lastSession: '1주 전',
    sessionCount: 18,
    sessionType: '집단 상담',
    status: ClientStatus.active,
  ),
  _ClientData(
    name: '정하은',
    gender: '여',
    age: 19,
    risk: RiskLevel.high,
    lastSession: '3일 전',
    sessionCount: 3,
    sessionType: '초기 상담',
    status: ClientStatus.active,
  ),
  _ClientData(
    name: '강도윤',
    gender: '남',
    age: 55,
    risk: RiskLevel.low,
    lastSession: '2주 전',
    sessionCount: 25,
    sessionType: '개인 상담',
    status: ClientStatus.closed,
  ),
  _ClientData(
    name: '오수빈',
    gender: '여',
    age: 31,
    risk: RiskLevel.medium,
    lastSession: '4일 전',
    sessionCount: 9,
    sessionType: '개인 상담',
    status: ClientStatus.closed,
  ),
];

// ── 페이지 ────────────────────────────────────────────────────

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final _searchController = TextEditingController();
  _FilterType _filter = _FilterType.all;

  List<_ClientData> get _filtered {
    final q = _searchController.text.trim();
    return _sampleClients.where((c) {
      final matchSearch = q.isEmpty || c.name.contains(q);
      final matchFilter = _filter.matches(c);
      return matchSearch && matchFilter;
    }).toList();
  }

  void _openRegisterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ClientRegisterSheet(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('내담자'),
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // 상단 검색 + 필터
          Container(
            color: AppColors.backgroundWhite,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              children: [
                AppTextField(
                  hint: '이름, 연락처 검색',
                  controller: _searchController,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _FilterType.values.map((f) {
                      final isFirst = f == _FilterType.values.first;
                      return Padding(
                        padding: EdgeInsets.only(left: isFirst ? 0 : 8),
                        child: _FilterChip(
                          label: f.label,
                          isSelected: _filter == f,
                          onTap: () => setState(() => _filter = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // 내담자 목록
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _ClientCard(client: filtered[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openRegisterSheet,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// ── 필터 칩 ───────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── 내담자 카드 ───────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  final _ClientData client;
  const _ClientCard({required this.client});

  Color get _avatarBg {
    switch (client.risk) {
      case RiskLevel.high:
        return AppColors.riskHighBg;
      case RiskLevel.medium:
        return AppColors.riskMediumBg;
      case RiskLevel.low:
        return AppColors.riskLowBg;
    }
  }

  Color get _avatarFg {
    switch (client.risk) {
      case RiskLevel.high:
        return AppColors.riskHighText;
      case RiskLevel.medium:
        return AppColors.riskMediumText;
      case RiskLevel.low:
        return AppColors.riskLowText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClientDetailPage(
              client: ClientDetail(
                name: client.name,
                gender: client.gender,
                age: client.age,
                riskLevel: client.risk,
                birthDate: '정보 없음',
                phone: '정보 없음',
                address: '정보 없음',
                intakeDate: '정보 없음',
                caseWorker: '김민지',
                sessionType: client.sessionType,
                sessionCount: client.sessionCount,
              ),
            ),
          ),
        );
      },
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 아바타 + 정보 + RiskChip
          Row(
            children: [
              // 이니셜 아바타 (40px)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _avatarBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    client.name[0],
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _avatarFg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 이름·성별·나이 + 상담유형·N회기
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${client.name} · ${client.gender} · ${client.age}세',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${client.sessionType} · ${client.sessionCount}회기',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              RiskChip(level: client.risk),
            ],
          ),
          // 구분선
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, thickness: 1, color: AppColors.border),
          ),
          // 하단: 마지막 상담일
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 12,
                color: AppColors.textHint,
              ),
              const SizedBox(width: 4),
              Text(
                '마지막 상담 ${client.lastSession}',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHint,
                ),
              ),
              if (client.status == ClientStatus.closed) ...[
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '종결',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── 빈 상태 ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 48, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 내담자 등록 바텀시트 ──────────────────────────────────────

class _ClientRegisterSheet extends StatefulWidget {
  const _ClientRegisterSheet();

  @override
  State<_ClientRegisterSheet> createState() => _ClientRegisterSheetState();
}

class _ClientRegisterSheetState extends State<_ClientRegisterSheet> {
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _safeTimeController = TextEditingController();
  final _addressController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _referralController = TextEditingController();

  String _gender = '';
  String? _housingType;
  bool _hasDisability = false;
  String? _socialWorker;

  String? _nameError;
  String? _phoneError;

  static const _housingOptions = ['자가', '전세', '월세', '사회주택', '쉼터', '노숙', '기타'];
  static const _workerOptions = ['김민지', '이상훈', '박지영', '최우진'];
  static const _referralOptions = ['자의뢰', '가족', '병원', '법원', '학교', '지역사회', '기타'];

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx)
              .colorScheme
              .copyWith(primary: AppColors.primaryBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _birthController.text =
            '${picked.year}년 ${picked.month.toString().padLeft(2, '0')}월 ${picked.day.toString().padLeft(2, '0')}일';
      });
    }
  }

  void _submit() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? '이름을 입력해주세요.' : null;
      _phoneError = _phoneController.text.trim().isEmpty ? '연락처를 입력해주세요.' : null;
    });
    if (_nameError != null || _phoneError != null) return;
    // TODO: 등록 API 호출
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    _safeTimeController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // 타이틀
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '내담자 등록',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          // 폼 영역
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름 (필수)
                  const _Label('이름', required: true),
                  AppTextField(
                    controller: _nameController,
                    hint: '내담자 이름',
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) setState(() => _nameError = null);
                    },
                  ),
                  const SizedBox(height: 20),

                  // 생년월일
                  const _Label('생년월일'),
                  AppTextField(
                    controller: _birthController,
                    hint: '생년월일 선택',
                    readOnly: true,
                    onTap: _pickBirth,
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 성별
                  const _Label('성별'),
                  Row(
                    children: [
                      Expanded(
                        child: _GenderOption(
                          label: '남성',
                          isSelected: _gender == 'male',
                          onTap: () => setState(() => _gender = 'male'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _GenderOption(
                          label: '여성',
                          isSelected: _gender == 'female',
                          onTap: () => setState(() => _gender = 'female'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 연락처 (필수)
                  const _Label('연락처', required: true),
                  AppTextField(
                    controller: _phoneController,
                    hint: '010-0000-0000',
                    keyboardType: TextInputType.phone,
                    errorText: _phoneError,
                    onChanged: (_) {
                      if (_phoneError != null) setState(() => _phoneError = null);
                    },
                  ),
                  const SizedBox(height: 20),

                  // 안전연락가능시간
                  const _Label('안전 연락 가능 시간'),
                  AppTextField(
                    controller: _safeTimeController,
                    hint: '예: 오전 10시 ~ 오후 6시',
                  ),
                  const SizedBox(height: 20),

                  // 주소
                  const _Label('주소'),
                  AppTextField(
                    controller: _addressController,
                    hint: '거주지 주소',
                  ),
                  const SizedBox(height: 20),

                  // 주거형태
                  const _Label('주거형태'),
                  _DropdownField(
                    hint: '주거형태 선택',
                    value: _housingType,
                    items: _housingOptions,
                    onChanged: (v) => setState(() => _housingType = v),
                  ),
                  const SizedBox(height: 20),

                  // 국적
                  const _Label('국적'),
                  AppTextField(
                    controller: _nationalityController,
                    hint: '예: 한국',
                  ),
                  const SizedBox(height: 20),

                  // 장애여부
                  const _Label('장애여부'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _hasDisability ? '장애 있음' : '장애 없음',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Switch(
                          value: _hasDisability,
                          onChanged: (v) =>
                              setState(() => _hasDisability = v),
                          activeColor: AppColors.primaryBlue,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 담당 사회복지사
                  const _Label('담당 사회복지사'),
                  _DropdownField(
                    hint: '담당자 선택',
                    value: _socialWorker,
                    items: _workerOptions,
                    onChanged: (v) => setState(() => _socialWorker = v),
                  ),
                  const SizedBox(height: 20),

                  // 의뢰경로
                  const _Label('의뢰경로'),
                  _DropdownField(
                    hint: '의뢰경로 선택',
                    value: _referralController.text.isEmpty
                        ? null
                        : _referralController.text,
                    items: _referralOptions,
                    onChanged: (v) =>
                        setState(() => _referralController.text = v ?? ''),
                  ),
                  const SizedBox(height: 32),

                  // 등록 완료 버튼
                  PrimaryButton(
                    label: '등록 완료',
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 폼 공통 위젯 ─────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final bool required;

  const _Label(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(text, style: AppTypography.sectionHeader),
          if (required)
            const Text(
              ' *',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
        ],
      ),
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
          color: isSelected ? AppColors.primaryBlue : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(8),
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

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textHint),
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          dropdownColor: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(8),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
