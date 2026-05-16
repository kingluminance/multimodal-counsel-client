import 'package:dio/dio.dart';
import 'api_client.dart';

/// 알림 (NT-1 ~ NT-5)
/// GET    /notifications                              — 목록 조회
/// PATCH  /notifications/{notification_id}/read      — 읽음 처리
/// PATCH  /notifications/read-all                    — 전체 읽음
/// POST   /notifications/risk-alert                  — 위험 신호 Push 발송
/// POST   /notifications/fcm-token                   — FCM 토큰 등록
class NotificationService {
  final Dio _dio = ApiClient().dio;

  /// NT-1: 알림 목록 조회
  /// - 200 → { notifications: [{ notification_id, type, message, is_read, created_at }] }
  Future<Map<String, dynamic>> list() async {
    final res = await _dio.get('/notifications');
    return res.data as Map<String, dynamic>;
  }

  /// NT-2: 알림 읽음 처리
  /// - 200 → { notification_id, is_read: true, read_at }
  Future<Map<String, dynamic>> markRead(String notificationId) async {
    final res = await _dio.patch('/notifications/$notificationId/read');
    return res.data as Map<String, dynamic>;
  }

  /// NT-3: 전체 알림 읽음 처리
  /// - 200 → { updated_count }
  Future<Map<String, dynamic>> markAllRead() async {
    final res = await _dio.patch('/notifications/read-all');
    return res.data as Map<String, dynamic>;
  }

  /// NT-4: 위험 신호 Push 발송 (슈퍼바이저·관리자 자동 수신)
  /// - 201 → { notification_ids: [] }
  Future<Map<String, dynamic>> riskAlert({
    required String sessionId,
    required String riskLevel,
    String? message,
  }) async {
    final res = await _dio.post('/notifications/risk-alert', data: {
      'session_id': sessionId,
      'risk_level': riskLevel,
      if (message != null) 'message': message,
    });
    return res.data as Map<String, dynamic>;
  }

  /// NT-5: FCM 토큰 등록
  /// - deviceType: ios | android
  /// - 200 → { registered: true }
  Future<Map<String, dynamic>> registerFcmToken({
    required String fcmToken,
    required String deviceType,
  }) async {
    final res = await _dio.post('/notifications/fcm-token', data: {
      'fcm_token': fcmToken,
      'device_type': deviceType,
    });
    return res.data as Map<String, dynamic>;
  }
}
