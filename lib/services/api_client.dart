import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 모든 API 서비스가 공유하는 Dio 기반 HTTP 클라이언트.
/// AUTH-TOKEN 헤더 자동 주입 및 401 시 토큰 갱신 인터셉터 포함.
class ApiClient {
  static const String baseUrl = 'http://localhost:8080';
  static const String _tokenKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  late final Dio dio = _buildDio();

  Dio _buildDio() {
    final d = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['AUTH-TOKEN'] = token;
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final token = await _storage.read(key: _tokenKey);
            final opts = error.requestOptions;
            opts.headers['AUTH-TOKEN'] = token;
            try {
              final response = await dio.fetch(opts);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
        }
        handler.next(error);
      },
    ));

    return d;
  }

  Future<bool> _tryRefresh() async {
    final refresh = await _storage.read(key: _refreshKey);
    if (refresh == null) return false;
    try {
      final res = await Dio().post(
        '$baseUrl/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final newToken = res.data['access_token'] as String?;
      if (newToken != null) {
        await _storage.write(key: _tokenKey, value: newToken);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
