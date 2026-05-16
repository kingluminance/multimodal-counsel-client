import 'package:dio/dio.dart';
import 'api_client.dart';

/// 대시보드 (DB-1 ~ DB-8)
/// GET /clients/{client_id}/dashboard              — 클라이언트 요약
/// GET /clients/{client_id}/dashboard/vitals       — 혈압·심박 추이
/// GET /clients/{client_id}/dashboard/emotions     — 감정 변화 추이
/// GET /clients/{client_id}/dashboard/stress       — 스트레스 지수 변화
/// GET /clients/{client_id}/dashboard/goals        — 상담 목표 달성률
/// GET /clients/{client_id}/dashboard/referrals    — 서비스 연계 타임라인
/// GET /clients/{client_id}/dashboard/risk-history — 위험 신호 이력
/// GET /dashboard/organization                     — 기관 전체 통계 (admin)
class DashboardService {
  final Dio _dio = ApiClient().dio;

  /// DB-1: 클라이언트 대시보드 요약
  /// - 200 → { client_id, name, risk_level, total_sessions, last_session_date, ... }
  Future<Map<String, dynamic>> clientSummary(String clientId) async {
    final res = await _dio.get('/clients/$clientId/dashboard');
    return res.data as Map<String, dynamic>;
  }

  /// DB-2: 혈압·심박 변화 추이 (꺾은선 차트)
  /// - unit: session | week | month | quarter
  /// - 200 → { unit, data: [{ period, bp_systolic_avg, bp_diastolic_avg, heart_rate_avg }] }
  Future<Map<String, dynamic>> vitals(
    String clientId, {
    String unit = 'month',
    String? from,
    String? to,
  }) async {
    final res = await _dio.get(
      '/clients/$clientId/dashboard/vitals',
      queryParameters: {
        'unit': unit,
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  /// DB-3: 감정 변화 추이 (영역 차트)
  /// - 200 → { unit, data: [{ period, joy, sadness, anger, fear, neutral }] }
  Future<Map<String, dynamic>> emotions(
    String clientId, {
    String unit = 'month',
  }) async {
    final res = await _dio.get(
      '/clients/$clientId/dashboard/emotions',
      queryParameters: {'unit': unit},
    );
    return res.data as Map<String, dynamic>;
  }

  /// DB-4: 스트레스 지수 변화 (막대 차트)
  /// - threshold: 80 (위험 신호 기준선)
  /// - 200 → { unit, data: [{ period, stress_avg, stress_max }], threshold: 80 }
  Future<Map<String, dynamic>> stress(
    String clientId, {
    String unit = 'month',
  }) async {
    final res = await _dio.get(
      '/clients/$clientId/dashboard/stress',
      queryParameters: {'unit': unit},
    );
    return res.data as Map<String, dynamic>;
  }

  /// DB-5: 상담 목표 달성률 (도넛 차트)
  /// - 200 → { total_goals, achieved, progress_pct, trend }
  Future<Map<String, dynamic>> goals(String clientId) async {
    final res = await _dio.get('/clients/$clientId/dashboard/goals');
    return res.data as Map<String, dynamic>;
  }

  /// DB-6: 서비스 연계 타임라인
  /// - 200 → { referrals: [{ referral_date, agency_name, service_name, status }] }
  Future<Map<String, dynamic>> referrals(String clientId) async {
    final res = await _dio.get('/clients/$clientId/dashboard/referrals');
    return res.data as Map<String, dynamic>;
  }

  /// DB-7: 위험 신호 발생 이력 (달력 뷰)
  /// - 200 → { events: [{ date, risk_level, session_id }] }
  Future<Map<String, dynamic>> riskHistory(String clientId) async {
    final res = await _dio.get('/clients/$clientId/dashboard/risk-history');
    return res.data as Map<String, dynamic>;
  }

  /// DB-8: 기관 전체 통계 (관리자 전용)
  /// - 200 → { total_clients, active_cases, high_risk, avg_sessions }
  Future<Map<String, dynamic>> organization() async {
    final res = await _dio.get('/dashboard/organization');
    return res.data as Map<String, dynamic>;
  }
}
