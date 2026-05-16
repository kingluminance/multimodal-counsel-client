import 'package:dio/dio.dart';
import 'api_client.dart';

/// 욕구 평가 (N-1 ~ N-3) — 카테고리 9
/// GET   /sessions/{session_id}/needs  — 조회
/// POST  /sessions/{session_id}/needs  — 등록 (AI 자동 분류)
/// PATCH /sessions/{session_id}/needs  — 수정
class NeedsService {
  final Dio _dio = ApiClient().dio;

  /// N-1: 욕구 평가 조회
  /// - 200 → { needs_id, need_priority_1, need_priority_2, need_priority_3,
  ///           need_economic, need_health, need_housing, need_relationship }
  Future<Map<String, dynamic>> get(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/needs');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// N-2: 욕구 평가 등록 (AI 자동 분류 가능)
  /// - 201 → { needs_id }
  Future<Map<String, dynamic>> create(
    String sessionId, {
    String? needPriority1,
    String? needPriority2,
    String? needPriority3,
    bool? needEconomic,
    bool? needHealth,
    bool? needHousing,
    bool? needRelationship,
  }) async {
    final res = await _dio.post('/sessions/$sessionId/needs', data: {
      if (needPriority1 != null) 'need_priority_1': needPriority1,
      if (needPriority2 != null) 'need_priority_2': needPriority2,
      if (needPriority3 != null) 'need_priority_3': needPriority3,
      if (needEconomic != null) 'need_economic': needEconomic,
      if (needHealth != null) 'need_health': needHealth,
      if (needHousing != null) 'need_housing': needHousing,
      if (needRelationship != null) 'need_relationship': needRelationship,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// N-3: 욕구 평가 수정
  /// - 200 → { needs_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/sessions/$sessionId/needs', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }
}
