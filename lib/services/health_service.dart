import 'package:dio/dio.dart';
import 'api_client.dart';

/// 건강·기능 상태 (H-1 ~ H-4) — 카테고리 11
/// GET   /clients/{client_id}/health               — 최근 조회
/// POST  /clients/{client_id}/health               — 등록 (rPPG 포함)
/// PATCH /clients/{client_id}/health/{record_id}   — 수정
/// GET   /clients/{client_id}/health?from=&to=     — 기간별 조회 (차트 데이터)
class HealthService {
  final Dio _dio = ApiClient().dio;

  /// H-1: 건강 상태 최근 조회
  /// - 200 → { record_id, chronic_disease, medication, disability_status,
  ///           functional_level, adl_score, bp_systolic, heart_rate, ... }
  Future<Map<String, dynamic>> get(String clientId) async {
    final res = await _dio.get('/clients/$clientId/health');
    return res.data as Map<String, dynamic>;
  }

  /// H-4: 건강 상태 기간별 조회 (꺾은선 차트 데이터)
  /// - 200 → { data: [{ measured_at, bp_systolic, heart_rate, ... }] }
  Future<Map<String, dynamic>> getRange(
    String clientId, {
    required String from,
    required String to,
  }) async {
    final res = await _dio.get('/clients/$clientId/health', queryParameters: {
      'from': from,
      'to': to,
    });
    return res.data as Map<String, dynamic>;
  }

  /// H-2: 건강 상태 등록 (rPPG 생체 데이터 포함)
  /// - 201 → { record_id }
  Future<Map<String, dynamic>> create(
    String clientId, {
    String? chronicDisease,
    String? medication,
    String? disabilityStatus,
    String? functionalLevel,
    int? adlScore,
    int? bpSystolic,
    int? heartRate,
  }) async {
    final res = await _dio.post('/clients/$clientId/health', data: {
      if (chronicDisease != null) 'chronic_disease': chronicDisease,
      if (medication != null) 'medication': medication,
      if (disabilityStatus != null) 'disability_status': disabilityStatus,
      if (functionalLevel != null) 'functional_level': functionalLevel,
      if (adlScore != null) 'adl_score': adlScore,
      if (bpSystolic != null) 'bp_systolic': bpSystolic,
      if (heartRate != null) 'heart_rate': heartRate,
    });
    return res.data as Map<String, dynamic>;
  }

  /// H-3: 건강 상태 수정
  /// - 200 → { record_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String clientId,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch(
      '/clients/$clientId/health/$recordId',
      data: data,
    );
    return res.data as Map<String, dynamic>;
  }
}
