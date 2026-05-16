import 'package:dio/dio.dart';
import 'api_client.dart';

/// 리포트 (RP-1 ~ RP-3)
/// POST /reports                      — 리포트 생성 요청 (비동기)
/// GET  /reports/{report_id}          — 리포트 조회
/// POST /reports/{report_id}/export   — PDF 내보내기
class ReportService {
  final Dio _dio = ApiClient().dio;

  /// RP-1: 리포트 생성 요청 (비동기)
  /// - 202 → { report_id, status: "generating" }
  Future<Map<String, dynamic>> create({
    required String from,
    required String to,
    String? clientId,
    String? reportType,
  }) async {
    final res = await _dio.post('/reports', data: {
      'from': from,
      'to': to,
      if (clientId != null) 'client_id': clientId,
      if (reportType != null) 'report_type': reportType,
    });
    return res.data as Map<String, dynamic>;
  }

  /// RP-2: 리포트 조회
  /// - 200 → { report_id, status: generating|completed|failed, data: {...} }
  Future<Map<String, dynamic>> get(String reportId) async {
    final res = await _dio.get('/reports/$reportId');
    return res.data as Map<String, dynamic>;
  }

  /// RP-3: 리포트 PDF 내보내기
  /// - 200 → { download_url, expires_at }
  Future<Map<String, dynamic>> export(String reportId) async {
    final res = await _dio.post('/reports/$reportId/export');
    return res.data as Map<String, dynamic>;
  }
}
