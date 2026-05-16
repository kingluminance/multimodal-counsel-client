import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

/// STT / AI 구조화 (AI-1 ~ AI-7)
/// POST /sessions/{session_id}/recording          — 녹음 파일 업로드 (multipart)
/// POST /sessions/{session_id}/stt                — STT 전사 요청 (비동기)
/// GET  /sessions/{session_id}/stt/status         — 전사 상태 확인
/// GET  /sessions/{session_id}/stt/result         — 전사 결과 조회
/// POST /sessions/{session_id}/ai/structurize     — AI 구조화 요청 (비동기)
/// GET  /sessions/{session_id}/ai/draft           — AI 초안 조회
/// POST /sessions/{session_id}/ai/confirm         — AI 초안 확정 (서명)
class SpeechAIService {
  final Dio _dio = ApiClient().dio;

  /// AI-1: 녹음 파일 업로드
  /// - 지원 포맷: .m4a | .wav | .mp3
  /// - 201 → { recording_id, file_size }
  Future<Map<String, dynamic>> uploadRecording(
    String sessionId, {
    required File file,
    void Function(int sent, int total)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'recording_file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
    final res = await _dio.post(
      '/sessions/$sessionId/recording',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onProgress,
    );
    return res.data as Map<String, dynamic>;
  }

  /// AI-2: STT 전사 요청 (비동기)
  /// - 화자 분리 지원 (speakerCount ≥ 2 이면 화자 분리 활성화)
  /// - 202 → { job_id, status: "processing" }
  Future<Map<String, dynamic>> requestStt(
    String sessionId, {
    int? speakerCount,
    String language = 'ko',
  }) async {
    final res = await _dio.post('/sessions/$sessionId/stt', data: {
      if (speakerCount != null) 'speaker_count': speakerCount,
      'language': language,
    });
    return res.data as Map<String, dynamic>;
  }

  /// AI-3: STT 전사 상태 확인
  /// - 200 → { status: processing | completed | failed }
  Future<Map<String, dynamic>> sttStatus(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/stt/status');
    return res.data as Map<String, dynamic>;
  }

  /// AI-4: STT 전사 결과 조회
  /// - 200 → { status: "completed", transcript: [{ speaker: "S1", text: "..." }] }
  Future<Map<String, dynamic>> sttResult(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/stt/result');
    return res.data as Map<String, dynamic>;
  }

  /// AI-5: AI 구조화 요청 (비동기 LLM 호출)
  /// - categories: 자동 초안을 생성할 카테고리 번호 목록 (기본: [5,6,7,8,9,10,13])
  /// - 202 → { draft_id, status: "generating" }
  Future<Map<String, dynamic>> structurize(
    String sessionId, {
    required String sessionType,
    List<int>? categories,
  }) async {
    final res = await _dio.post('/sessions/$sessionId/ai/structurize', data: {
      'session_type': sessionType,
      if (categories != null) 'categories': categories,
    });
    return res.data as Map<String, dynamic>;
  }

  /// AI-6: AI 구조화 초안 조회
  /// - 200 → { draft_id, main_topic, session_goal, need_economic,
  ///           intervention_type, ... (카테고리 5~10·13 필드) }
  Future<Map<String, dynamic>> getDraft(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/ai/draft');
    return res.data as Map<String, dynamic>;
  }

  /// AI-7: AI 초안 확정 (사회복지사 서명)
  /// - 최종 저장: draft → 각 카테고리 테이블 INSERT
  /// - sessions.status → SIGNED
  /// - 200 → { session_id, confirmed: true, signed_at }
  Future<Map<String, dynamic>> confirm(String sessionId) async {
    final res = await _dio.post('/sessions/$sessionId/ai/confirm');
    return res.data as Map<String, dynamic>;
  }
}
