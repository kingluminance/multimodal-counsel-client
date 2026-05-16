import 'package:dio/dio.dart';
import 'api_client.dart';

/// 초대코드 관리 (INV-1 ~ INV-4)
/// POST   /invitations              — 초대코드 발급 (관리자 전용)
/// GET    /invitations/{code}/verify — 초대코드 검증 (비로그인 가능)
/// GET    /invitations              — 초대코드 목록 조회 (관리자)
/// DELETE /invitations/{code}       — 초대코드 취소 (관리자)
class InvitationService {
  final Dio _dio = ApiClient().dio;

  /// INV-1: 초대코드 발급 (관리자 전용)
  /// - 201 → { code, role, org_id, expires_at }
  /// - 403 → 권한 오류
  Future<Map<String, dynamic>> issue({
    required String role,
    required String orgId,
    String? memo,
    int? expiresIn,
    int? maxUse,
  }) async {
    final res = await _dio.post('/invitations', data: {
      'role': role,
      'org_id': orgId,
      if (memo != null) 'memo': memo,
      if (expiresIn != null) 'expires_in': expiresIn,
      if (maxUse != null) 'max_use': maxUse,
    });
    return res.data as Map<String, dynamic>;
  }

  /// INV-2: 초대코드 검증 (비로그인 가능)
  /// - 200 유효 → { valid: true, role, org_name, expires_at }
  /// - 200 무효 → { valid: false, reason: expired|already_used|not_found|revoked }
  Future<Map<String, dynamic>> verify(String code) async {
    final res = await _dio.get('/invitations/$code/verify');
    return res.data as Map<String, dynamic>;
  }

  /// INV-3: 초대코드 목록 조회 (관리자)
  /// - 200 → { total, invitations: [{ code, role, used, expires_at }] }
  Future<Map<String, dynamic>> list() async {
    final res = await _dio.get('/invitations');
    return res.data as Map<String, dynamic>;
  }

  /// INV-4: 초대코드 취소 (관리자)
  /// - 204 취소 성공
  /// - 403 → 권한 오류
  Future<void> cancel(String code) async {
    await _dio.delete('/invitations/$code');
  }
}
