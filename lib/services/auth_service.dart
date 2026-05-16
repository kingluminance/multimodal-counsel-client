import 'package:dio/dio.dart';
import 'api_client.dart';

/// 인증 (A-1 ~ A-7)
/// POST /auth/oauth/callback   — OAuth 로그인·가입 콜백
/// POST /users/worker          — 사회복지사 가입 완료
/// POST /auth/client-link      — 내담자 OAuth 연동
/// POST /auth/refresh          — 토큰 갱신
/// POST /auth/logout           — 로그아웃
/// DELETE /users               — 회원 탈퇴
/// GET  /health                — 서버 상태 확인
class AuthService {
  final Dio _dio = ApiClient().dio;

  /// A-1: OAuth 로그인·가입 콜백
  /// - 기존 유저 → access_token, refresh_token 반환 (status: "existing_user")
  /// - 신규 유저 → oauth_token, email, name 반환 (status: "new_user")
  Future<Map<String, dynamic>> oauthCallback({
    required String provider,
    required String oauthCode,
    required String redirectUri,
  }) async {
    final res = await _dio.post('/auth/oauth/callback', data: {
      'provider': provider,
      'oauth_code': oauthCode,
      'redirect_uri': redirectUri,
    });
    return res.data as Map<String, dynamic>;
  }

  /// A-2: 사회복지사 가입 완료
  /// - oauth_token + invite_code → role·org 자동 결정
  /// - 201 → { user_id, role, org_id, org_name, access_token, refresh_token }
  /// - 400 → invite_code 오류, 409 → 중복 이메일
  Future<Map<String, dynamic>> workerSignUp({
    required String oauthToken,
    required String inviteCode,
    required String gender,
    required String birthday,
  }) async {
    final res = await _dio.post('/users/worker', data: {
      'oauth_token': oauthToken,
      'invite_code': inviteCode,
      'gender': gender,
      'birthday': birthday,
    });
    return res.data as Map<String, dynamic>;
  }

  /// A-3: 내담자 앱 OAuth 연동
  /// - link_token + OAuth 완료 → client_id 연결
  /// - 201 → { status: "linked", client_id, role: "client", access_token }
  Future<Map<String, dynamic>> clientOauthLink({
    required String linkToken,
    required String provider,
    required String oauthCode,
    required String redirectUri,
  }) async {
    final res = await _dio.post('/auth/client-link', data: {
      'link_token': linkToken,
      'provider': provider,
      'oauth_code': oauthCode,
      'redirect_uri': redirectUri,
    });
    return res.data as Map<String, dynamic>;
  }

  /// A-4: 토큰 갱신
  /// - 200 → { access_token }
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final res = await _dio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return res.data as Map<String, dynamic>;
  }

  /// A-5: 로그아웃 — Refresh Token 무효화
  /// - 204
  Future<void> logout(String refreshToken) async {
    await _dio.post('/auth/logout', data: {'refresh_token': refreshToken});
    await ApiClient().clearTokens();
  }

  /// A-6: 회원 탈퇴 — 소프트 삭제 + 개인정보 익명화
  /// - 204
  Future<void> withdraw() async {
    await _dio.delete('/users');
    await ApiClient().clearTokens();
  }

  /// A-7: 서버 상태 확인
  /// - 200 → { status: "ok" }
  Future<Map<String, dynamic>> health() async {
    final res = await _dio.get('/health');
    return res.data as Map<String, dynamic>;
  }
}
