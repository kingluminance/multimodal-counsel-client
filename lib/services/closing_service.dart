import 'package:dio/dio.dart';
import 'api_client.dart';

/// 종결 및 사후관리 (CL-1 ~ CL-5) — 카테고리 15
/// GET   /clients/{client_id}/closing          — 종결 정보 조회
/// POST  /clients/{client_id}/closing          — 종결 등록
/// PATCH /clients/{client_id}/closing          — 종결 수정
/// GET   /clients/{client_id}/aftercare        — 사후관리 목록
/// POST  /clients/{client_id}/closing/summary  — 종결 요약 AI 초안 생성 (비동기)
class ClosingService {
  final Dio _dio = ApiClient().dio;

  /// CL-1: 종결 정보 조회
  /// - 200 → { closing_id, closing_date, closing_reason, closing_summary? }
  Future<Map<String, dynamic>> get(String clientId) async {
    final res = await _dio.get('/clients/$clientId/closing');
    return res.data as Map<String, dynamic>;
  }

  /// CL-2: 종결 등록
  /// - 201 → { closing_id }
  Future<Map<String, dynamic>> create(
    String clientId, {
    required String closingDate,
    required String closingReason,
    String? closingSummary,
  }) async {
    final res = await _dio.post('/clients/$clientId/closing', data: {
      'closing_date': closingDate,
      'closing_reason': closingReason,
      if (closingSummary != null) 'closing_summary': closingSummary,
    });
    return res.data as Map<String, dynamic>;
  }

  /// CL-3: 종결 정보 수정
  /// - 200 → { closing_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String clientId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/clients/$clientId/closing', data: data);
    return res.data as Map<String, dynamic>;
  }

  /// CL-4: 사후관리 목록 조회
  /// - 200 → { aftercare: [{ aftercare_id, contact_date, contact_method, note }] }
  Future<Map<String, dynamic>> listAftercare(String clientId) async {
    final res = await _dio.get('/clients/$clientId/aftercare');
    return res.data as Map<String, dynamic>;
  }

  /// CL-5: 종결 요약 AI 초안 생성 (비동기)
  /// - 누적 기록 기반 LLM 자동 작성
  /// - 202 → { draft_id, status: "generating" }
  Future<Map<String, dynamic>> generateSummary(String clientId) async {
    final res = await _dio.post('/clients/$clientId/closing/summary');
    return res.data as Map<String, dynamic>;
  }
}
