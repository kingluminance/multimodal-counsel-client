import 'package:dio/dio.dart';
import 'api_client.dart';

/// 사회복지사 / 기관 (W-1 ~ W-7)
/// GET   /workers                               — 사회복지사 목록
/// GET   /workers/{worker_id}                   — 사회복지사 상세
/// PATCH /workers/{worker_id}                   — 프로필 수정
/// GET   /workers/{worker_id}/cases             — 담당 케이스 목록
/// PATCH /clients/{client_id}/supervisor        — 슈퍼바이저 배정 (슈퍼바이저·관리자)
/// GET   /organization                          — 기관 정보 조회
/// PATCH /organization                          — 기관 정보 수정 (관리자 전용)
class WorkerService {
  final Dio _dio = ApiClient().dio;

  /// W-1: 사회복지사 목록 조회
  /// - 200 → { workers: [{ worker_id, name, role, org_id }] }
  Future<Map<String, dynamic>> listWorkers() async {
    final res = await _dio.get('/workers');
    return res.data as Map<String, dynamic>;
  }

  /// W-2: 사회복지사 상세 조회
  /// - 200 → { worker_id, name, role, org_id, phone, email, ... }
  Future<Map<String, dynamic>> getWorker(String workerId) async {
    final res = await _dio.get('/workers/$workerId');
    return res.data as Map<String, dynamic>;
  }

  /// W-3: 사회복지사 프로필 수정
  /// - 200 → { worker_id, updated_fields }
  Future<Map<String, dynamic>> updateWorker(
    String workerId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/workers/$workerId', data: data);
    return res.data as Map<String, dynamic>;
  }

  /// W-4: 담당 케이스 목록 조회
  /// - 200 → { cases: [{ client_id, name, risk_level, last_session_date }] }
  Future<Map<String, dynamic>> workerCases(String workerId) async {
    final res = await _dio.get('/workers/$workerId/cases');
    return res.data as Map<String, dynamic>;
  }

  /// W-5: 슈퍼바이저 배정 (슈퍼바이저·관리자 전용)
  /// - 200 → { client_id, supervisor_user_id }
  Future<Map<String, dynamic>> assignSupervisor(
    String clientId, {
    required String supervisorUserId,
  }) async {
    final res = await _dio.patch(
      '/clients/$clientId/supervisor',
      data: {'supervisor_user_id': supervisorUserId},
    );
    return res.data as Map<String, dynamic>;
  }

  /// W-6: 기관 정보 조회
  /// - 200 → { org_id, org_name, address, phone, ... }
  Future<Map<String, dynamic>> getOrganization() async {
    final res = await _dio.get('/organization');
    return res.data as Map<String, dynamic>;
  }

  /// W-7: 기관 정보 수정 (관리자 전용)
  /// - 200 → { org_id, updated_fields }
  Future<Map<String, dynamic>> updateOrganization(
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/organization', data: data);
    return res.data as Map<String, dynamic>;
  }
}
