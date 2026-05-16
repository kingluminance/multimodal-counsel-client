import 'package:dio/dio.dart';
import 'api_client.dart';

/// 개입 및 연계 (I-1 ~ I-5) — 카테고리 10
/// GET   /sessions/{session_id}/intervention  — 조회
/// POST  /sessions/{session_id}/intervention  — 등록 (AI 자동 추출)
/// PATCH /sessions/{session_id}/intervention  — 수정
/// GET   /agencies?q={keyword}                — 연계 기관 마스터
/// GET   /services?q={keyword}                — 연계 서비스 마스터
class InterventionService {
  final Dio _dio = ApiClient().dio;

  /// I-1: 개입 내용 조회
  /// - 200 → { intervention_id, intervention_type, referral_agency_id?,
  ///           referral_service_id?, intervention_detail? }
  Future<Map<String, dynamic>> get(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/intervention');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// I-2: 개입 내용 등록 (AI 자동 추출 가능)
  /// - 201 → { intervention_id }
  Future<Map<String, dynamic>> create(
    String sessionId, {
    String? interventionType,
    String? referralAgencyId,
    String? referralServiceId,
    String? interventionDetail,
  }) async {
    final res = await _dio.post('/sessions/$sessionId/intervention', data: {
      if (interventionType != null) 'intervention_type': interventionType,
      if (referralAgencyId != null) 'referral_agency_id': referralAgencyId,
      if (referralServiceId != null) 'referral_service_id': referralServiceId,
      if (interventionDetail != null) 'intervention_detail': interventionDetail,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// I-3: 개입 내용 수정
  /// - 200 → { intervention_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/sessions/$sessionId/intervention', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }

  /// I-4: 연계 기관 마스터 조회
  /// - 200 → { agencies: [{ agency_id, name, service_types[] }] }
  Future<Map<String, dynamic>> agencies({String? q}) async {
    final res = await _dio.get('/agencies', queryParameters: {
      if (q != null) 'q': q,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  /// I-5: 연계 서비스 마스터 조회
  /// - 200 → { services: [{ service_id, name, category }] }
  Future<Map<String, dynamic>> services({String? q}) async {
    final res = await _dio.get('/services', queryParameters: {
      if (q != null) 'q': q,
    });
    return res.data['data'] as Map<String, dynamic>;
  }
}
