import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import 'session_ai_review_page.dart';

class SessionRecordingPage extends StatefulWidget {
  const SessionRecordingPage({super.key});

  @override
  State<SessionRecordingPage> createState() => _SessionRecordingPageState();
}

class _SessionRecordingPageState extends State<SessionRecordingPage> {
  bool _isRecording = true;
  int _elapsedSeconds = 754; // 00:12:34 시작
  Timer? _timer;

  final List<_ChatMessage> _messages = const [
    _ChatMessage(isLeft: true, text: '안녕하세요. 오늘 어떤 이야기를 나눠볼까요?', time: '14:00'),
    _ChatMessage(isLeft: false, text: '요즘 진로 때문에 많이 고민이 돼요. 취업을 해야 할지, 대학원을 갈지 모르겠어요.', time: '14:01'),
    _ChatMessage(isLeft: true, text: '그런 고민이 생겼군요. 언제부터 이런 생각을 하셨나요?', time: '14:02'),
    _ChatMessage(isLeft: false, text: '졸업이 가까워지면서부터요. 주변 친구들은 다 방향을 정한 것 같은데 저만 모르겠어요.', time: '14:03'),
    _ChatMessage(isLeft: true, text: '비교하는 게 힘드시겠어요. 본인은 어떤 것을 할 때 가장 즐거우신가요?', time: '14:04'),
    _ChatMessage(isLeft: false, text: '뭔가를 분석하고 정리하는 건 재미있어요. 근데 그게 직업이 될 수 있을지는...', time: '14:05'),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isRecording && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeString {
    final h = _elapsedSeconds ~/ 3600;
    final m = (_elapsedSeconds % 3600) ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
        title: Text('김민지 · 진로 상담', style: AppTypography.h4),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SessionAiReviewPage()),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text('상담 완료', style: AppTypography.bodySmall.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 녹음 상태 바
          Container(
            color: AppColors.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_isRecording ? '녹음 중' : '일시정지'} • $_timeString',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 채팅 영역
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _ChatBubble(message: _messages[i]),
            ),
          ),
          // 녹음 컨트롤 바
          Container(
            color: AppColors.backgroundWhite,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: _isRecording ? Icons.pause : Icons.play_arrow,
                  label: _isRecording ? '일시정지' : '재개',
                  color: AppColors.textSecondary,
                  onTap: () => setState(() => _isRecording = !_isRecording),
                ),
                _ControlButton(
                  icon: Icons.stop_circle,
                  label: '중지',
                  color: AppColors.danger,
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SessionAiReviewPage()),
                  ),
                ),
                _ControlButton(
                  icon: Icons.smart_toy_outlined,
                  label: 'AI 분석',
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SessionAiReviewPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool isLeft;
  final String text;
  final String time;

  const _ChatMessage({required this.isLeft, required this.text, required this.time});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: message.isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (message.isLeft) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('👤', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isLeft ? AppColors.backgroundWhite : AppColors.backgroundSubtle,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(message.isLeft ? 0 : 12),
                      bottomRight: Radius.circular(message.isLeft ? 12 : 0),
                    ),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Text(message.text, style: AppTypography.bodySmall),
                ),
                const SizedBox(height: 2),
                Text(
                  message.time,
                  style: AppTypography.caption.copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          if (!message.isLeft) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('😊', style: TextStyle(fontSize: 14))),
            ),
          ],
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
