import 'package:dio/dio.dart';
import 'api_client.dart';

/// 클라이언트 관리 (C-1 ~ C-8)
/// GET    /clients                          — 목록 조회 (필터: worker_id, risk_level, status)
/// POST   /clients                          — 등록 (사회복지사만)
/// GET    /clients/{client_id}              — 상세 조회
/// PATCH  /clients/{client_id}              — 정보 수정
/// DELETE /clients/{client_id}              — 비활성화 (소프트 삭제)
/// GET    /clients/search?q={keyword}       — 이름·연락처 검색
/// POST   /clients/{client_id}/app-access   — 내담자 앱 링크 발송
/// GET    /clients/{client_id}/app-access   — 링크 상태 조회
class ClientService {
  final Dio _dio = ApiClient().dio;

  /// C-1: 클라이언트 목록 조회
  /// - risk_level: high | medium | low
  /// - status: ACTIVE | CLOSED | DELETED
  /// - 200 → { total, clients: [...] }
  Future<Map<String, dynamic>> list({
    String? workerId,
    String? riskLevel,
    String? status,
  }) async {
    final res = await _dio.get('/clients', queryParameters: {
      if (workerId != null) 'worker_id': workerId,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (status != null) 'status': status,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// C-2: 클라이언트 등록 (사회복지사만)
  /// - 201 → { client_id, name }
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await _dio.post('/clients', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }

  /// C-3: 클라이언트 상세 조회
  /// - field_visibility 기반 필드 필터링 적용됨
  /// - 200 → 클라이언트 상세 정보
  Future<Map<String, dynamic>> detail(String clientId) async {
    final res = await _dio.get('/clients/$clientId');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// C-4: 클라이언트 정보 수정 (변경 필드만)
  /// - 200 → { client_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String clientId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/clients/$clientId', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }

  /// C-5: 클라이언트 비활성화 (소프트 삭제)
  /// - 204
  Future<void> delete(String clientId) async {
    await _dio.delete('/clients/$clientId');
  }

  /// C-6: 클라이언트 검색 (이름·연락처)
  /// - 200 → { total, clients: [...] }
  Future<Map<String, dynamic>> search(String keyword) async {
    final res = await _dio.get('/clients/search', queryParameters: {'q': keyword});
    return res.data['data'] as Map<String, dynamic>;
  }

  /// C-7: 내담자 앱 접근 링크 발송 (SMS/이메일)
  /// - sendMethod: sms | email
  /// - 201 → { link_id, expires_at, sent_to }
  Future<Map<String, dynamic>> sendAppAccess(
    String clientId, {
    required String sendMethod,
    String? phone,
    String? email,
    int? expiresIn,
  }) async {
    final res = await _dio.post('/clients/$clientId/app-access', data: {
      'send_method': sendMethod,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (expiresIn != null) 'expires_in': expiresIn,
    });
    return res.data as Map<String, dynamic>;
  }

  /// C-8: 내담자 앱 접근 링크 상태 조회
  /// - 200 → { status: pending|joined|expired, sent_at, joined_at? }
  Future<Map<String, dynamic>> appAccessStatus(String clientId) async {
    final res = await _dio.get('/clients/$clientId/app-access');
    return res.data as Map<String, dynamic>;
  }
}
