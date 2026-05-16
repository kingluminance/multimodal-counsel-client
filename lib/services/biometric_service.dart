import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

/// 카메라 / 생체 데이터 (BIO-1 ~ BIO-6)
/// POST /sessions/{session_id}/camera/start   — 카메라 세션 시작 (consent_camera=Y 필수)
/// POST /sessions/{session_id}/camera/stop    — 카메라 세션 종료
/// GET  /sessions/{session_id}/camera/stream  — 실시간 생체 스트림 (SSE)
/// POST /sessions/{session_id}/biometric      — 생체 데이터 저장
/// GET  /sessions/{session_id}/biometric      — 단일 회기 조회
/// GET  /clients/{client_id}/biometric        — 기간별 조회
class BiometricService {
  final Dio _dio = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  /// BIO-1: 카메라 분석 세션 시작
  /// - X-Consent-Camera: Y 헤더 필수 (동의 없으면 403)
  /// - 200 → { camera_session_id, started_at }
  Future<Map<String, dynamic>> startCamera(String sessionId) async {
    final res = await _dio.post(
      '/sessions/$sessionId/camera/start',
      options: Options(headers: {'X-Consent-Camera': 'Y'}),
    );
    return res.data as Map<String, dynamic>;
  }

  /// BIO-2: 카메라 분석 세션 종료
  /// - 200 → { camera_session_id, ended_at }
  Future<Map<String, dynamic>> stopCamera(String sessionId) async {
    final res = await _dio.post('/sessions/$sessionId/camera/stop');
    return res.data as Map<String, dynamic>;
  }

  /// BIO-3: 실시간 생체 스트림 (Server-Sent Events)
  /// - 1초 간격으로 { bp_systolic, heart_rate, stress_index } 수신
  /// - 반환: StreamController — 스트림 구독 후 dispose() 필수
  ///
  /// 사용 예:
  ///   final stream = await biometricService.streamBiometric(sessionId);
  ///   stream.listen((data) { ... });
  Stream<Map<String, dynamic>> streamBiometric(String sessionId) {
    final controller = StreamController<Map<String, dynamic>>();

    _openSseStream(sessionId, controller);

    return controller.stream;
  }

  Future<void> _openSseStream(
    String sessionId,
    StreamController<Map<String, dynamic>> controller,
  ) async {
    final token = await _storage.read(key: 'access_token');
    try {
      final response = await _dio.get<ResponseBody>(
        '/sessions/$sessionId/camera/stream',
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            if (token != null) 'AUTH-TOKEN': token,
          },
        ),
      );

      response.data!.stream
          .transform(StreamTransformer<List<int>, String>.fromHandlers(
            handleData: (data, sink) =>
                sink.add(const Utf8Decoder().convert(data)),
          ))
          .listen(
        (line) {
          if (line.startsWith('data:')) {
            final json = line.substring(5).trim();
            if (json.isNotEmpty) {
              controller.add(jsonDecode(json) as Map<String, dynamic>);
            }
          }
        },
        onDone: controller.close,
        onError: controller.addError,
      );
    } catch (e) {
      controller.addError(e);
      await controller.close();
    }
  }

  /// BIO-4: 생체 데이터 저장
  /// - disclaimerShown: true 필수 (미설정 시 400 오류)
  /// - stressIndex ≥ 80 → 자동 Push 알림 발송
  /// - 201 → { biometric_id, stress_warning? }
  Future<Map<String, dynamic>> saveBiometric(
    String sessionId, {
    required int bpSystolic,
    required int bpDiastolic,
    required int heartRate,
    required int stressIndex,
    required String measuredAt,
    required bool disclaimerShown,
    Map<String, dynamic>? emotionData,
    int? eyeContactFreq,
  }) async {
    final res = await _dio.post(
      '/sessions/$sessionId/biometric',
      data: {
        'bp_systolic': bpSystolic,
        'bp_diastolic': bpDiastolic,
        'heart_rate': heartRate,
        'stress_index': stressIndex,
        'measured_at': measuredAt,
        'disclaimer_shown': disclaimerShown,
        if (emotionData != null) 'emotion_data': emotionData,
        if (eyeContactFreq != null) 'eye_contact_freq': eyeContactFreq,
      },
      options: Options(headers: {'X-Consent-Camera': 'Y'}),
    );
    return res.data as Map<String, dynamic>;
  }

  /// BIO-5: 생체 데이터 조회 (단일 회기)
  /// - 200 → { biometric_id, bp_systolic, bp_diastolic, heart_rate,
  ///           stress_index, emotion_data, measured_at }
  Future<Map<String, dynamic>> getBiometric(String sessionId) async {
    final res = await _dio.get('/sessions/$sessionId/biometric');
    return res.data as Map<String, dynamic>;
  }

  /// BIO-6: 생체 데이터 기간별 조회
  /// - 200 → { data: [{ session_id, measured_at, bp_systolic, heart_rate, stress_index }] }
  Future<Map<String, dynamic>> getBiometricRange(
    String clientId, {
    required String from,
    required String to,
  }) async {
    final res = await _dio.get(
      '/clients/$clientId/biometric',
      queryParameters: {'from': from, 'to': to},
    );
    return res.data as Map<String, dynamic>;
  }
}
