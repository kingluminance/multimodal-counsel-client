import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/primary_button.dart';

// ── 데이터 모델 ──────────────────────────────────────────────

class _BiometricData {
  final int systolic;
  final int diastolic;
  final int heartRate;
  final int stress;
  final String emotion;

  const _BiometricData({
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.stress,
    required this.emotion,
  });
}

// ── 시뮬레이션 스트림 ─────────────────────────────────────────

const _emotions = ['안정', '집중', '불안', '긴장', '평온', '슬픔'];

// 점진적으로 변화하는 바이오메트릭 시뮬레이션
Stream<_BiometricData> _buildStream() {
  final rng = math.Random();
  int tick = 0;
  int baseSystolic = 118;
  int baseDiastolic = 76;
  int baseHR = 74;
  int baseStress = 62;
  int emotionIdx = 0;

  return Stream.periodic(const Duration(milliseconds: 1500), (_) {
    tick++;
    // 완만한 변동 시뮬레이션
    baseSystolic = (baseSystolic + rng.nextInt(5) - 2).clamp(105, 148);
    baseDiastolic = (baseDiastolic + rng.nextInt(3) - 1).clamp(65, 98);
    baseHR = (baseHR + rng.nextInt(5) - 2).clamp(58, 110);
    baseStress = (baseStress + rng.nextInt(7) - 2).clamp(30, 98);
    if (tick % 6 == 0) emotionIdx = (emotionIdx + 1) % _emotions.length;

    return _BiometricData(
      systolic: baseSystolic,
      diastolic: baseDiastolic,
      heartRate: baseHR,
      stress: baseStress,
      emotion: _emotions[emotionIdx],
    );
  });
}

// ── 진입 확인 ─────────────────────────────────────────────────

/// consent_camera 여부를 확인 후 진입하는 래퍼.
/// hasConsent = false 이면 동의 요청 다이얼로그를 표시한다.
class CameraAnalysisEntryPoint extends StatelessWidget {
  final bool hasConsent;
  const CameraAnalysisEntryPoint({super.key, this.hasConsent = false});

  @override
  Widget build(BuildContext context) {
    return hasConsent ? const CameraAnalysisPage() : const _ConsentGatePage();
  }
}

// ── 동의 요청 게이트 페이지 ───────────────────────────────────

class _ConsentGatePage extends StatelessWidget {
  const _ConsentGatePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('생체 측정'),
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam_off_outlined,
                  size: 36, color: AppColors.amber),
            ),
            const SizedBox(height: 20),
            const Text(
              '카메라 동의가 필요합니다',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '생체 측정 기능은 카메라를 통해 혈압·심박·스트레스를 추정합니다.\n기본정보 탭에서 카메라 동의 후 이용해주세요.',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: '동의하고 시작하기',
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const CameraAnalysisPage(),
                  ),
                );
              },
              icon: const Icon(Icons.videocam_outlined,
                  size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 메인 카메라 분석 페이지 ───────────────────────────────────

class CameraAnalysisPage extends StatefulWidget {
  const CameraAnalysisPage({super.key});

  @override
  State<CameraAnalysisPage> createState() => _CameraAnalysisPageState();
}

class _CameraAnalysisPageState extends State<CameraAnalysisPage> {
  StreamSubscription<_BiometricData>? _streamSub;
  _BiometricData? _data;
  bool _wasHighStress = false;

  // 카메라 상태 (웹에서는 사용 불가)
  dynamic _camController;
  final bool _camReady = false;
  final bool _camError = true;
  final String _camErrorMsg = '웹 브라우저에서는 카메라를 사용할 수 없습니다. PC/모바일 앱을 이용해주세요.';

  bool get _isHighStress => (_data?.stress ?? 0) > 80;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  void _startStream() {
    _streamSub = _buildStream().listen((data) {
      if (!mounted) return;
      setState(() => _data = data);

      // 스트레스 80 초과 → 진동 (임계 최초 진입 시만)
      final isHigh = data.stress > 80;
      if (isHigh && !_wasHighStress) {
        HapticFeedback.heavyImpact();
      }
      _wasHighStress = isHigh;
    });
  }

  Future<void> _endSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '분석 종료',
          style:
              TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          '측정을 종료하고 결과를 저장하시겠습니까?',
          style: TextStyle(fontFamily: 'Pretendard', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소',
                style: TextStyle(
                    fontFamily: 'Pretendard', color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('종료 및 저장',
                style: TextStyle(
                    fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // TODO: 세션 종료 API 호출 + 결과 저장
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('생체 측정'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // ── 경고 배너 (스트레스 초과 시) ──────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _isHighStress
                ? _HighStressBanner(stress: _data?.stress ?? 0)
                : const SizedBox.shrink(),
          ),

          // ── 상단 2/5: 카메라 프리뷰 ──────────────────────────
          SizedBox(
            height: screenH * 0.40,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _CameraViewport(
                  controller: _camController,
                  isReady: _camReady,
                  isError: _camError,
                  errorMsg: _camErrorMsg,
                ),
                // LIVE 인디케이터
                if (_camReady || _camError)
                  const Positioned(
                    top: 12,
                    right: 14,
                    child: _LiveBadge(),
                  ),
              ],
            ),
          ),

          // ── 하단 3/5: 측정 수치 ───────────────────────────────
          Expanded(
            child: Container(
              color: AppColors.backgroundGrey,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                children: [
                  // 2×2 측정 그리드
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.4,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _MetricCard(
                          label: '혈압',
                          icon: Icons.favorite_outline,
                          iconColor: AppColors.red,
                          value: _data != null
                              ? '${_data!.systolic}/${_data!.diastolic}'
                              : '--/--',
                          unit: 'mmHg',
                          valueColor: AppColors.red,
                        ),
                        _MetricCard(
                          label: '심박수',
                          icon: Icons.monitor_heart_outlined,
                          iconColor: AppColors.primaryBlue,
                          value: _data != null ? '${_data!.heartRate}' : '--',
                          unit: 'bpm',
                          valueColor: AppColors.primaryBlue,
                        ),
                        _MetricCard(
                          label: '스트레스',
                          icon: Icons.psychology_outlined,
                          iconColor: _stressColor,
                          value: _data != null ? '${_data!.stress}' : '--',
                          unit: '/ 100',
                          valueColor: _stressColor,
                          highlight: _isHighStress,
                        ),
                        _MetricCard(
                          label: '감정 상태',
                          icon: Icons.sentiment_satisfied_alt_outlined,
                          iconColor: AppColors.purple,
                          value: _data?.emotion ?? '--',
                          unit: '',
                          valueColor: AppColors.purple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 면책 고지
                  _DisclaimerBox(),

                  const SizedBox(height: 12),

                  // 분석 종료 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _endSession,
                      icon: const Icon(Icons.stop_circle_outlined, size: 20),
                      label: const Text(
                        '분석 종료',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _stressColor {
    final s = _data?.stress ?? 0;
    if (s > 80) return AppColors.red;
    if (s > 60) return AppColors.amber;
    return AppColors.teal;
  }
}

// ── 고위험 스트레스 배너 ──────────────────────────────────────

class _HighStressBanner extends StatelessWidget {
  final int stress;
  const _HighStressBanner({required this.stress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.red,
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '스트레스 지수 $stress — 위험 수준 초과. 내담자 상태를 즉시 확인하세요.',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 카메라 뷰포트 ─────────────────────────────────────────────

class _CameraViewport extends StatelessWidget {
  final CameraController? controller;
  final bool isReady;
  final bool isError;
  final String errorMsg;

  const _CameraViewport({
    required this.controller,
    required this.isReady,
    required this.isError,
    required this.errorMsg,
  });

  @override
  Widget build(BuildContext context) {
    if (isError) {
      return _CameraPlaceholder(message: errorMsg, isError: true);
    }
    if (!isReady || controller == null) {
      return const _CameraPlaceholder(message: '카메라 초기화 중...');
    }
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller!.value.previewSize?.height ?? 1,
            height: controller!.value.previewSize?.width ?? 1,
            child: CameraPreview(controller!),
          ),
        ),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  final String message;
  final bool isError;

  const _CameraPlaceholder({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.videocam_off_outlined : Icons.videocam_outlined,
            size: 40,
            color: isError ? AppColors.red : Colors.white38,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: isError ? AppColors.red : Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isError) ...[
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white38,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── LIVE 배지 ─────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: Color.lerp(const Color(0xFF4CAF50),
                    const Color(0xFF81C784), _anim.value),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 측정 수치 카드 ────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final Color valueColor;
  final bool highlight;

  const _MetricCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.valueColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppColors.red : AppColors.border,
          width: highlight ? 1.5 : 0.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 라벨 + 아이콘
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Text(label, style: AppTypography.caption),
              if (highlight)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.warning_amber_rounded,
                      size: 12, color: AppColors.red),
                ),
            ],
          ),
          // 수치
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: value.length > 5 ? 18 : 24,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                  height: 1,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      color: AppColors.textHint,
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

// ── 면책 고지 박스 ────────────────────────────────────────────

class _DisclaimerBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.riskMediumBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.amber.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.riskMediumText),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '카메라 기반 추정값이며 의료적 진단 수치가 아닙니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                color: AppColors.riskMediumText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
