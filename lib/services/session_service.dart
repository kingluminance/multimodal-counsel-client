import 'package:dio/dio.dart';
import 'api_client.dart';

/// 상담 회기 (S-1 ~ S-6)
/// GET    /clients/{client_id}/sessions          — 회기 목록
/// POST   /clients/{client_id}/sessions          — 회기 등록 (상담 시작)
/// GET    /sessions/{session_id}                 — 회기 상세
/// PATCH  /sessions/{session_id}                 — 회기 수정
/// DELETE /sessions/{session_id}                 — 회기 삭제
/// GET    /sessions/upcoming?worker_id={id}       — 예정 상담 조회 (캘린더)
class SessionService {
  final Dio _dio = ApiClient().dio;

  /// S-1: 회기 목록 조회
  /// - 200 → { sessions: [{ session_id, session_number, session_date, status }] }
  Future<Map<String, dynamic>> listByClient(String clientId) async {
    final res = await _dio.get('/clients/$clientId/sessions');
    return res.data as Map<String, dynamic>;
  }

  /// S-2: 회기 등록 (상담 시작)
  /// - session_type 에 따라 플로우 자동 결정
  ///   (개인/가족/집단/위기/사례관리/프로그램신청)
  /// - session_method: 대면 | 전화 | 영상 | 방문
  /// - 201 → { session_id, session_number, status: "DRAFT" }
  Future<Map<String, dynamic>> create(
    String clientId, {
    required String sessionDate,
    required String sessionTimeStart,
    required String sessionTimeEnd,
    required String sessionMethod,
    required String sessionType,
    String? sessionLocation,
  }) async {
    final res = await _dio.post('/clients/$clientId/sessions', data: {
      'session_date': sessionDate,
      'session_time_start': sessionTimeStart,
      'session_time_end': sessionTimeEnd,
      'session_method': sessionMethod,
      'session_type': sessionType,
      if (sessionLocation != null) 'session_location': sessionLocation,
    });
    return res.data as Map<String, dynamic>;
  }

  /// S-3: 회기 상세 조회
  /// - 200 → 회기 전체 상세 정보
  Future<Map<String, dynamic>> detail(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId');
    return res.data as Map<String, dynamic>;
  }

  /// S-4: 회기 수정 (변경 필드만)
  /// - 200 → { session_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/sessions/$sessionId', data: data);
    return res.data as Map<String, dynamic>;
  }

  /// S-5: 회기 삭제
  /// - 204
  Future<void> delete(String sessionId) async {
    await _dio.delete('/sessions/$sessionId');
  }

  /// S-6: 예정 상담 일정 조회 (사회복지사 캘린더)
  /// - 200 → { sessions: [{ session_id, client_name, session_date, session_time_start }] }
  Future<Map<String, dynamic>> upcoming(String workerId) async {
    final res = await _dio.get('/sessions/upcoming', queryParameters: {
      'worker_id': workerId,
    });
    return res.data as Map<String, dynamic>;
  }
}
