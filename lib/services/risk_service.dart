import 'package:dio/dio.dart';
import 'api_client.dart';

/// 위험요인 평가 (R-1 ~ R-3) — 카테고리 8
/// GET   /sessions/{session_id}/risk  — 조회 (클라이언트 비공개)
/// POST  /sessions/{session_id}/risk  — 등록 (high 시 Push 자동 발송)
/// PATCH /sessions/{session_id}/risk  — 수정
///
/// R-4 (위험 클라이언트 목록): ClientService.list(riskLevel: ...) 사용
class RiskService {
  final Dio _dio = ApiClient().dio;

  /// R-1: 위험요인 평가 조회 (worker·supervisor·admin 전용, 클라이언트 비공개)
  /// - 200 → { risk_id, risk_flag, risk_level, risk_type[], ... }
  Future<Map<String, dynamic>> get(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/risk');
    return res.data as Map<String, dynamic>;
  }

  /// R-2: 위험요인 평가 등록
  /// - risk_level=high → 슈퍼바이저·관리자 Push 자동 발송
  /// - 201 → { risk_id, risk_level, alert_sent }
  Future<Map<String, dynamic>> create(
    String sessionId, {
    required bool riskFlag,
    List<String>? riskType,
    String? riskLevel,
    bool? suicideIdeation,
    bool? selfHarmYn,
    bool? abuseSuspicionYn,
    bool? dvYn,
    bool? substanceUseYn,
    bool? neglectYn,
    String? riskActionTaken,
    bool? reportYn,
    String? reportDate,
    String? reportAgency,
  }) async {
    final res = await _dio.post('/sessions/$sessionId/risk', data: {
      'risk_flag': riskFlag,
      if (riskType != null) 'risk_type': riskType,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (suicideIdeation != null) 'suicide_ideation': suicideIdeation,
      if (selfHarmYn != null) 'self_harm_yn': selfHarmYn,
      if (abuseSuspicionYn != null) 'abuse_suspicion_yn': abuseSuspicionYn,
      if (dvYn != null) 'dv_yn': dvYn,
      if (substanceUseYn != null) 'substance_use_yn': substanceUseYn,
      if (neglectYn != null) 'neglect_yn': neglectYn,
      if (riskActionTaken != null) 'risk_action_taken': riskActionTaken,
      if (reportYn != null) 'report_yn': reportYn,
      if (reportDate != null) 'report_date': reportDate,
      if (reportAgency != null) 'report_agency': reportAgency,
    });
    return res.data as Map<String, dynamic>;
  }

  /// R-3: 위험요인 평가 수정
  /// - 200 → { risk_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch('/sessions/$sessionId/risk', data: data);
    return res.data as Map<String, dynamic>;
  }
}
