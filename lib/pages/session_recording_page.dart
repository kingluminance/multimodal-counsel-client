import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_card.dart';
import 'session_ai_review_page.dart';

// ── 샘플 파형 데이터 ──────────────────────────────────────────

const _waveform = [
  0.20, 0.45, 0.70, 0.55, 0.85, 0.40, 0.65, 0.30, 0.75, 0.90,
  0.50, 0.80, 0.35, 0.60, 0.25, 0.88, 0.55, 0.45, 0.92, 0.38,
  0.72, 0.48, 0.83, 0.58, 0.94, 0.42, 0.28, 0.68, 0.52, 0.86,
  0.62, 0.18, 0.95, 0.44, 0.76, 0.36, 0.82, 0.26, 0.66, 0.98,
  0.54, 0.70, 0.40, 0.88, 0.32, 0.64, 0.50, 0.78, 0.22, 0.60,
];

// ── 페이지 ────────────────────────────────────────────────────

class SessionRecordingPage extends StatefulWidget {
  const SessionRecordingPage({super.key});

  @override
  State<SessionRecordingPage> createState() => _SessionRecordingPageState();
}

class _SessionRecordingPageState extends State<SessionRecordingPage> {
  int _step = 0;

  // Step 1 상태
  bool _consentRecording = false;
  bool _consentSensitive = false;

  // Step 2 상태
  String? _sessionType;
  static const _sessionTypes = ['개인', '가족', '위기', '프로그램', '사례관리'];

  // Step 3 상태
  bool _fileSelected = false;
  final String _fileName = '상담녹음_20250510_14시.m4a';
  final String _fileDuration = '48분 32초';

  // Step 4 상태
  double _sttProgress = 0;
  bool _sttDone = false;
  Timer? _sttTimer;

  bool get _step1Valid => _consentRecording && _consentSensitive;
  bool get _step2Valid => _sessionType != null;
  bool get _step3Valid => _fileSelected;

  void _goNext() {
    if (_step < 3) {
      setState(() => _step++);
    }
  }

  void _startStt() {
    setState(() => _sttProgress = 0);
    _sttTimer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _sttProgress = (_sttProgress + 0.02).clamp(0.0, 1.0);
        if (_sttProgress >= 1.0) {
          _sttDone = true;
          t.cancel();
        }
      });
    });
  }

  void _goToReview() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SessionAiReviewPage()),
    );
  }

  @override
  void dispose() {
    _sttTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('녹음 업로드'),
        backgroundColor: AppColors.backgroundWhite,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // 스텝 인디케이터
          _StepIndicator(current: _step, total: 4),
          // 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: [
                _Step1Consent(
                  recording: _consentRecording,
                  sensitive: _consentSensitive,
                  onRecordingChanged: (v) => setState(() => _consentRecording = v),
                  onSensitiveChanged: (v) => setState(() => _consentSensitive = v),
                ),
                _Step2SessionType(
                  selected: _sessionType,
                  onChanged: (t) => setState(() => _sessionType = t),
                ),
                _Step3Upload(
                  fileSelected: _fileSelected,
                  fileName: _fileName,
                  fileDuration: _fileDuration,
                  onFileSelect: () => setState(() => _fileSelected = true),
                ),
                _Step4Stt(
                  progress: _sttProgress,
                  isDone: _sttDone,
                  onStart: _sttDone ? null : _startStt,
                  onGoReview: _goToReview,
                ),
              ][_step],
            ),
          ),
          // 하단 버튼
          if (_step < 3)
            _NextButton(
              enabled: [_step1Valid, _step2Valid, _step3Valid][_step],
              onTap: _goNext,
            ),
        ],
      ),
    );
  }
}

// ── 스텝 인디케이터 ───────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final labels = ['동의 확인', '상담 유형', '파일 업로드', 'STT 전사'];
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        children: List.generate(total, (i) {
          final done = i < current;
          final active = i == current;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.teal
                            : active
                                ? AppColors.primaryBlue
                                : AppColors.inputBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : AppColors.textHint,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10,
                        color: active ? AppColors.primaryBlue : AppColors.textHint,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                if (i < total - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: done ? AppColors.teal : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 1: 동의 확인 ─────────────────────────────────────────

class _Step1Consent extends StatelessWidget {
  final bool recording;
  final bool sensitive;
  final ValueChanged<bool> onRecordingChanged;
  final ValueChanged<bool> onSensitiveChanged;

  const _Step1Consent({
    required this.recording,
    required this.sensitive,
    required this.onRecordingChanged,
    required this.onSensitiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('동의 확인', style: TextStyle(
          fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 4),
        const Text('녹음 업로드를 위해 아래 항목의 동의가 필요합니다.', style: AppTypography.caption),
        const SizedBox(height: 20),
        _ConsentCard(
          icon: Icons.mic,
          title: '녹음 동의',
          desc: '상담 내용의 녹음 및 디지털 분석에 동의합니다.',
          value: recording,
          onChanged: onRecordingChanged,
        ),
        const SizedBox(height: 12),
        _ConsentCard(
          icon: Icons.shield_outlined,
          title: '민감정보 처리 동의',
          desc: '건강·심리 관련 민감정보의 AI 분석 및 보관에 동의합니다.',
          value: sensitive,
          onChanged: onSensitiveChanged,
        ),
        const SizedBox(height: 16),
        if (!recording || !sensitive)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.riskHighBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.riskHighText),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '모든 항목에 동의해야 다음 단계로 진행할 수 있습니다.',
                    style: TextStyle(
                      fontFamily: 'Pretendard', fontSize: 12, color: AppColors.riskHighText,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConsentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.primaryBlue : AppColors.border,
            width: value ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: value ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: value ? AppColors.primaryBlue : AppColors.textHint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.sectionHeader),
                  const SizedBox(height: 2),
                  Text(desc, style: AppTypography.caption),
                ],
              ),
            ),
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: AppColors.border),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: 상담 유형 선택 ────────────────────────────────────

class _Step2SessionType extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const _Step2SessionType({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('상담 유형', style: TextStyle(
          fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 4),
        const Text('이 녹음의 상담 유형을 선택해주세요.', style: AppTypography.caption),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _SessionRecordingPageState._sessionTypes.map((type) {
            final isSelected = selected == type;
            return GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : AppColors.border,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Step 3: 파일 업로드 ───────────────────────────────────────

class _Step3Upload extends StatelessWidget {
  final bool fileSelected;
  final String fileName;
  final String fileDuration;
  final VoidCallback onFileSelect;

  const _Step3Upload({
    required this.fileSelected,
    required this.fileName,
    required this.fileDuration,
    required this.onFileSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('파일 업로드', style: TextStyle(
          fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 4),
        const Text('녹음 파일을 업로드하거나 선택해주세요.', style: AppTypography.caption),
        const SizedBox(height: 20),

        // 업로드 영역
        GestureDetector(
          onTap: fileSelected ? null : onFileSelect,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: fileSelected
                  ? AppColors.primaryBlue.withOpacity(0.04)
                  : AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _DashedBorderPainter(
                color: fileSelected ? AppColors.primaryBlue : AppColors.border,
                radius: 12,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: fileSelected
                    ? _WaveformView(name: fileName, duration: fileDuration)
                    : const _UploadPrompt(),
              ),
            ),
          ),
        ),

        if (fileSelected) ...[
          const SizedBox(height: 16),
          SectionCard(
            child: Row(
              children: [
                const Icon(Icons.audio_file_outlined, color: AppColors.primaryBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fileName, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                      Text(fileDuration, style: AppTypography.caption),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.close, size: 18, color: AppColors.textHint),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _UploadPrompt extends StatelessWidget {
  const _UploadPrompt();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.textHint),
        const SizedBox(height: 10),
        const Text('파일을 선택하세요', style: AppTypography.sectionHeader),
        const SizedBox(height: 4),
        const Text('M4A, MP3, WAV 지원', style: AppTypography.caption),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '파일 선택',
            style: TextStyle(
              fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _WaveformView extends StatelessWidget {
  final String name;
  final String duration;

  const _WaveformView({required this.name, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 64,
          child: CustomPaint(
            painter: _WaveformPainter(data: _waveform, color: AppColors.primaryBlue),
            size: Size(double.infinity, 64),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 14, color: AppColors.teal),
            const SizedBox(width: 4),
            Text('$name · $duration', style: AppTypography.caption),
          ],
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  const _WaveformPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barW = size.width / data.length;
    final midY = size.height / 2;

    for (int i = 0; i < data.length; i++) {
      final x = i * barW + barW / 2;
      final h = data[i] * midY;
      canvas.drawLine(Offset(x, midY - h), Offset(x, midY + h), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => false;
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dash = 6.0;
    const gap = 4.0;
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double dist = 0;
      while (dist < m.length) {
        canvas.drawPath(m.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => false;
}

// ── Step 4: STT 전사 ──────────────────────────────────────────

class _Step4Stt extends StatelessWidget {
  final double progress;
  final bool isDone;
  final VoidCallback? onStart;
  final VoidCallback onGoReview;

  const _Step4Stt({
    required this.progress,
    required this.isDone,
    required this.onStart,
    required this.onGoReview,
  });

  String get _statusText {
    if (isDone) return 'AI 구조화 완료';
    if (progress > 0) {
      if (progress < 0.3) return '음성 파일 분석 중...';
      if (progress < 0.6) return '텍스트 전사 중...';
      return 'AI 구조화 중...';
    }
    return 'STT 전사 준비';
  }

  @override
  Widget build(BuildContext context) {
    final running = progress > 0 && !isDone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STT 전사', style: TextStyle(
          fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        )),
        const SizedBox(height: 4),
        const Text('AI가 녹음을 분석하고 상담 일지를 자동으로 작성합니다.', style: AppTypography.caption),
        const SizedBox(height: 24),

        // 진행 상태 카드
        SectionCard(
          child: Column(
            children: [
              // 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.teal.withOpacity(0.1)
                      : AppColors.purple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check_circle_outline : Icons.auto_awesome,
                  size: 28,
                  color: isDone ? AppColors.teal : AppColors.purple,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _statusText,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDone ? AppColors.teal : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (progress > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.inputBackground,
                    color: isDone ? AppColors.teal : AppColors.purple,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDone ? AppColors.teal : AppColors.purple,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (!isDone)
          PrimaryButton(
            label: running ? 'STT 전사 중...' : 'STT 전사 시작',
            isLoading: running,
            onPressed: running ? null : onStart,
            icon: running ? null : const Icon(Icons.play_arrow, size: 18, color: Colors.white),
          )
        else
          PrimaryButton(
            label: 'AI 초안 검토하기',
            onPressed: onGoReview,
            icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
          ),

        if (isDone) ...[
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 14, color: AppColors.purple),
                const SizedBox(width: 4),
                Text(
                  '5개 섹션 AI 초안이 생성되었습니다.',
                  style: AppTypography.caption.copyWith(color: AppColors.purple),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── 다음 버튼 ─────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _NextButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: PrimaryButton(
        label: '다음',
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}

// sin 함수 참조용 (dart:math 사용)
// ignore: unused_element
double _sin(double x) => math.sin(x);
