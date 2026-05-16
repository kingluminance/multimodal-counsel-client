import 'package:dio/dio.dart';
import 'api_client.dart';

/// 상담 주제 (T-1 ~ T-3) — 카테고리 5
/// GET   /sessions/{session_id}/topic  — 조회
/// POST  /sessions/{session_id}/topic  — 등록 (AI 초안 or 수동)
/// PATCH /sessions/{session_id}/topic  — 수정
class TopicService {
  final Dio _dio = ApiClient().dio;

  /// T-1: 상담 주제 조회
  /// - 200 → { topic_id, main_topic, session_goal, client_statement_summary? }
  Future<Map<String, dynamic>> get(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/topic');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// T-2: 상담 주제 등록
  /// - aiDraft: true 이면 AI 자동 추출 초안 사용
  /// - 201 → { topic_id }
  Future<Map<String, dynamic>> create(
    String sessionId, {
    String? mainTopic,
    String? sessionGoal,
    String? clientStatementSummary,
    bool aiDraft = false,
  }) async {
    final res = await _dio.post('/sessions/$sessionId/topic', data: {
      if (mainTopic != null) 'main_topic': mainTopic,
      if (sessionGoal != null) 'session_goal': sessionGoal,
      if (clientStatementSummary != null)
        'client_statement_summary': clientStatementSummary,
      'ai_draft': aiDraft,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// T-3: 상담 주제 수정
  /// - 200 → { topic_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/sessions/$sessionId/topic', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }
}
