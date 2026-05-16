import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import 'session_ai_review_page.dart';

class SessionRecordingPage extends StatefulWidget {
  final String sessionId;

  const SessionRecordingPage({super.key, required this.sessionId});

  @override
  State<SessionRecordingPage> createState() => _SessionRecordingPageState();
}

class _SessionRecordingPageState extends State<SessionRecordingPage> {
  bool _isRecording = true;
  int _elapsedSeconds = 0;
  Timer? _timer;

  List<_ChatMessage> _messages = [];

  bool _isUploading = false;
  bool _isSttRequesting = false;
  bool _isStructurizing = false;
  bool _isLoadingSttResult = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadSttResult();
  }

  Future<void> _loadSttResult() async {
    try {
      final data = await SpeechAIService().sttResult(widget.sessionId);
      if (!mounted) return;
      final transcript = data['transcript'] as List<dynamic>?;
      if (transcript != null && transcript.isNotEmpty) {
        setState(() {
          _messages = transcript.map((item) {
            final map = item as Map<String, dynamic>;
            final speaker = (map['speaker'] as String?) ?? '';
            final text = (map['text'] as String?) ?? '';
            final isLeft = speaker != 'S2'; // S1 = 상담사 (왼쪽), S2 = 내담자 (오른쪽)
            return _ChatMessage(isLeft: isLeft, text: text, time: '');
          }).toList();
        });
      }
    } catch (_) {
      // STT 결과 없으면 빈 목록 유지
    }
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

  // 파일 업로드 버튼 핸들러
  // 실제 파일 선택은 file_picker 패키지가 필요합니다.
  // 현재는 UI만 제공하며 실제 파일 선택 기능은 주석 처리되어 있습니다.
  Future<void> _handleUpload() async {
    // TODO: file_picker 패키지 추가 후 아래 코드 활성화
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['m4a', 'wav', 'mp3'],
    // );
    // if (result == null || result.files.isEmpty) return;
    // final file = File(result.files.first.path!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('파일 선택 기능은 file_picker 패키지 설치가 필요합니다.'),
      ),
    );
  }

  Future<void> _requestStt() async {
    setState(() => _isSttRequesting = true);
    try {
      await SpeechAIService().requestStt(widget.sessionId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('STT 전사 요청이 완료되었습니다.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'STT 요청에 실패했습니다.'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSttRequesting = false);
    }
  }

  Future<void> _loadSttResultManual() async {
    setState(() => _isLoadingSttResult = true);
    try {
      final data = await SpeechAIService().sttResult(widget.sessionId);
      if (!mounted) return;
      final transcript = data['transcript'] as List<dynamic>?;
      if (transcript != null && transcript.isNotEmpty) {
        setState(() {
          _messages = transcript.map((item) {
            final map = item as Map<String, dynamic>;
            final speaker = (map['speaker'] as String?) ?? '';
            final text = (map['text'] as String?) ?? '';
            final isLeft = speaker != 'S2';
            return _ChatMessage(isLeft: isLeft, text: text, time: '');
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('STT 결과를 불러왔습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아직 STT 결과가 없습니다.')),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'STT 결과 조회에 실패했습니다.'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingSttResult = false);
    }
  }

  Future<void> _structurize() async {
    setState(() => _isStructurizing = true);
    try {
      await SpeechAIService().structurize(
        widget.sessionId,
        sessionType: '개인',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 구조화 요청이 완료되었습니다.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'AI 구조화 요청에 실패했습니다.'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isStructurizing = false);
    }
  }

  void _goToAiReview() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            SessionAiReviewPage(sessionId: widget.sessionId),
      ),
    );
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
        title: Text('상담 녹음', style: AppTypography.h4),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _goToAiReview,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(
                '상담 완료',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 녹음 상태 바
          Container(
            color: AppColors.primaryLight,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          // STT / AI 버튼 행
          Container(
            color: AppColors.backgroundWhite,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 파일 업로드 버튼 (file_picker 패키지 필요)
                  _SmallActionButton(
                    icon: Icons.upload_file,
                    label: '파일 업로드',
                    isLoading: _isUploading,
                    onTap: _handleUpload,
                  ),
                  const SizedBox(width: 8),
                  // STT 전사 요청
                  _SmallActionButton(
                    icon: Icons.transcribe,
                    label: 'STT 전사 요청',
                    isLoading: _isSttRequesting,
                    onTap: _requestStt,
                  ),
                  const SizedBox(width: 8),
                  // STT 결과 조회
                  _SmallActionButton(
                    icon: Icons.refresh,
                    label: 'STT 결과 조회',
                    isLoading: _isLoadingSttResult,
                    onTap: _loadSttResultManual,
                  ),
                  const SizedBox(width: 8),
                  // AI 구조화
                  _SmallActionButton(
                    icon: Icons.smart_toy_outlined,
                    label: 'AI 구조화',
                    isLoading: _isStructurizing,
                    onTap: _structurize,
                  ),
                ],
              ),
            ),
          ),
          // 채팅 영역
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'STT 결과가 없습니다.\n녹음 후 STT 전사를 요청해주세요.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textHint),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, i) =>
                        _ChatBubble(message: _messages[i]),
                  ),
          ),
          // 녹음 컨트롤 바
          Container(
            color: AppColors.backgroundWhite,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: _isRecording ? Icons.pause : Icons.play_arrow,
                  label: _isRecording ? '일시정지' : '재개',
                  color: AppColors.textSecondary,
                  onTap: () =>
                      setState(() => _isRecording = !_isRecording),
                ),
                _ControlButton(
                  icon: Icons.stop_circle,
                  label: '중지',
                  color: AppColors.danger,
                  onTap: _goToAiReview,
                ),
                _ControlButton(
                  icon: Icons.smart_toy_outlined,
                  label: 'AI 분석',
                  color: AppColors.primary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          SessionAiReviewPage(sessionId: widget.sessionId),
                    ),
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

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.purple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border:
              Border.all(color: AppColors.purple.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.purple,
                ),
              )
            else
              Icon(icon, size: 14, color: AppColors.purple),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final bool isLeft;
  final String text;
  final String time;

  const _ChatMessage(
      {required this.isLeft, required this.text, required this.time});
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
        mainAxisAlignment: message.isLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (message.isLeft) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('👤', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isLeft
                        ? AppColors.backgroundWhite
                        : AppColors.backgroundSubtle,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft:
                          Radius.circular(message.isLeft ? 0 : 12),
                      bottomRight:
                          Radius.circular(message.isLeft ? 12 : 0),
                    ),
                    border:
                        Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Text(message.text,
                      style: AppTypography.bodySmall),
                ),
                if (message.time.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    message.time,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textHint),
                  ),
                ],
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
              child: const Center(
                  child: Text('😊', style: TextStyle(fontSize: 14))),
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
          Text(label,
              style: AppTypography.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
