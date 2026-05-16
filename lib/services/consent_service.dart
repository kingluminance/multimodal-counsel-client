import 'package:dio/dio.dart';
import 'api_client.dart';

/// 동의 관리 (CON-1 ~ CON-3)
/// GET   /clients/{client_id}/consents                   — 동의 정보 조회
/// POST  /clients/{client_id}/consents                   — 동의 등록
/// PATCH /clients/{client_id}/consents/{consent_id}      — 동의 수정 / 철회
class ConsentService {
  final Dio _dio = ApiClient().dio;

  /// CON-1: 동의 정보 조회
  /// - 200 → { consent_id, consent_recording, consent_sensitive,
  ///           consent_third_party, consent_camera, consent_date,
  ///           consent_withdraw_yn, consent_withdraw_date? }
  Future<Map<String, dynamic>> list(String clientId) async {
    final res = await _dio.get('/clients/$clientId/consents');
    return res.data as Map<String, dynamic>;
  }

  /// CON-2: 동의 등록
  /// - 201 → { consent_id, consent_date }
  Future<Map<String, dynamic>> register(
    String clientId, {
    required bool consentRecording,
    required bool consentSensitive,
    required bool consentThirdParty,
    required bool consentCamera,
    bool? guardianConsentYn,
    String? guardianName,
  }) async {
    final res = await _dio.post('/clients/$clientId/consents', data: {
      'consent_recording': consentRecording,
      'consent_sensitive': consentSensitive,
      'consent_third_party': consentThirdParty,
      'consent_camera': consentCamera,
      if (guardianConsentYn != null) 'guardian_consent_yn': guardianConsentYn,
      if (guardianName != null) 'guardian_name': guardianName,
    });
    return res.data as Map<String, dynamic>;
  }

  /// CON-3: 동의 수정 / 철회
  /// - consent_withdraw_yn: true 시 withdraw_date 자동 기록
  /// - 200 → { consent_id, updated_fields }
  Future<Map<String, dynamic>> update(
    String clientId,
    String consentId,
    Map<String, dynamic> data,
  ) async {
    final res = await _dio.patch(
      '/clients/$clientId/consents/$consentId',
      data: data,
    );
    return res.data as Map<String, dynamic>;
  }
}
