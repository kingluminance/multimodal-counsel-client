import 'package:dio/dio.dart';
import 'api_client.dart';

/// 권한 관리 (PM-1 ~ PM-3)
/// GET   /clients/{client_id}/permissions   — 클라이언트 공개 항목 조회
/// PATCH /clients/{client_id}/permissions   — 공개 항목 설정 (사회복지사 전용)
/// GET   /roles/{role}/permissions          — 역할별 접근 권한 조회
class PermissionService {
  final Dio _dio = ApiClient().dio;

  /// PM-1: 클라이언트 공개 항목 조회
  /// - 200 → { permissions: { field_key: bool, ... } }
  Future<Map<String, dynamic>> getClientPermissions(String clientId) async {
    final res = await _dio.get('/clients/$clientId/permissions');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// PM-2: 클라이언트 공개 항목 설정 (사회복지사 전용)
  /// - permissions: { 'health': true, 'economic': false, ... }
  /// - 200 → { client_id, updated_fields }
  /// - 403 → 사회복지사만 설정 가능
  Future<Map<String, dynamic>> setClientPermissions(
    String clientId,
    Map<String, bool> permissions,
  ) async {
    final res = await _dio.patch(
      '/clients/$clientId/permissions',
      data: {'permissions': permissions},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  /// PM-3: 역할별 접근 권한 조회
  /// - role: admin | worker | supervisor | client
  /// - 200 → { role, accessible_fields: [] }
  Future<Map<String, dynamic>> getRolePermissions(String role) async {
    final res = await _dio.get('/roles/$role/permissions');
    return res.data['data'] as Map<String, dynamic>;
  }
}
