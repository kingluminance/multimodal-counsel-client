import 'package:dio/dio.dart';
import 'api_client.dart';

/// 차기 계획 (NP-1 ~ NP-3) — 카테고리 13
/// GET   /sessions/{session_id}/next-plan  — 조회
/// POST  /sessions/{session_id}/next-plan  — 등록
/// PATCH /sessions/{session_id}/next-plan  — 수정
class NextPlanService {
  final Dio _dio = ApiClient().dio;

  /// NP-1: 차기 계획 조회
  /// - 200 → { plan_id, next_session_date, next_session_goal,
  ///           action_items[], worker_tasks[] }
  Future<Map<String, dynamic>> get(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/next-plan');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// NP-2: 차기 계획 등록
  /// - 201 → { plan_id }
  Future<Map<String, dynamic>> create(
    String sessionId, {
    String? nextSessionDate,
    String? nextSessionGoal,
    List<String>? actionItems,
    List<String>? workerTasks,
  }) async {
    final res = await _dio.post('/sessions/$sessionId/next-plan', data: {
      if (nextSessionDate != null) 'next_session_date': nextSessionDate,
      if (nextSessionGoal != null) 'next_session_goal': nextSessionGoal,
      if (actionItems != null) 'action_items': actionItems,
      if (workerTasks != null) 'worker_tasks': workerTasks,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// NP-3: 차기 계획 수정
  /// - 200 → { plan_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/sessions/$sessionId/next-plan', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }
}
