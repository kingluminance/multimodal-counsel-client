import 'package:dio/dio.dart';
import 'api_client.dart';

/// 가족 구성 (F-1 ~ F-4)
/// GET    /clients/{client_id}/family               — 목록 조회
/// POST   /clients/{client_id}/family               — 구성원 등록
/// PATCH  /clients/{client_id}/family/{member_id}   — 구성원 수정
/// DELETE /clients/{client_id}/family/{member_id}   — 구성원 삭제
class FamilyService {
  final Dio _dio = ApiClient().dio;

  /// F-1: 가족 구성원 목록 조회
  /// - 200 → { members: [{ family_member_id, name, relation, age, cohabitation_status }] }
  Future<Map<String, dynamic>> list(String clientId) async {
    final res = await _dio.get('/clients/$clientId/family');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// F-2: 가족 구성원 등록
  /// - 201 → { family_member_id }
  Future<Map<String, dynamic>> register(
    String clientId, {
    String? name,
    String? relation,
    int? age,
    String? cohabitationStatus,
  }) async {
    final res = await _dio.post('/clients/$clientId/family', data: {
      if (name != null) 'name': name,
      if (relation != null) 'relation': relation,
      if (age != null) 'age': age,
      if (cohabitationStatus != null) 'cohabitation_status': cohabitationStatus,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// F-3: 가족 구성원 수정
  /// - 200 → { family_member_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String clientId,
    String memberId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/clients/$clientId/family/$memberId', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }

  /// F-4: 가족 구성원 삭제
  /// - 204
  Future<void> delete(String clientId, String memberId) async {
    await _dio.delete('/clients/$clientId/family/$memberId');
  }
}
