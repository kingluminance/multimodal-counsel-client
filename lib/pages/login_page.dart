import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/api_client.dart';
import '../widgets/main_scaffold.dart';
import 'login_page_web.dart' if (dart.library.io) 'login_page_stub.dart' as web_redirect;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _showEmailForm = false;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _storage = const FlutterSecureStorage();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onEmailLogin() async {
    if (_isLoading) return;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력하세요.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dio = ApiClient().dio;
      final res = await dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      await _storage.write(key: 'access_token', value: data['accessToken'] as String);
      await _storage.write(key: 'refresh_token', value: data['refreshToken'] as String);
      await _storage.write(key: 'user_id', value: data['userId'].toString());
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } catch (e) {
      if (!mounted) return;
      String message = '로그인에 실패했습니다.';
      if (e is DioException && e.response != null) {
        message = e.response?.data?['message'] as String? ?? message;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOAuthLogin(String provider) {
    if (_isLoading) return;
    final oauthUrl = '${ApiClient.baseUrl}/oauth2/authorization/$provider';

    if (kIsWeb) {
      web_redirect.redirectToOAuth(oauthUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모바일 OAuth는 준비 중입니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🧸', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '강원대 돌봄케어 솔루션',
                style: AppTypography.h3.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'SNS 계정으로 간편하게 로그인하세요',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: CircularProgressIndicator(),
                ),
              // 이메일 로그인 폼
              if (_showEmailForm) ...[
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: '이메일',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onEmailLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('로그인', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _OAuthButton(
                label: 'Google로 로그인',
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                borderColor: AppColors.border,
                icon: _GoogleIcon(),
                onTap: _isLoading ? null : () => _onOAuthLogin('google'),
              ),
              const SizedBox(height: 12),
              _OAuthButton(
                label: '카카오로 로그인',
                backgroundColor: const Color(0xFFFEE500),
                foregroundColor: const Color(0xFF191919),
                icon: const _KakaoIcon(),
                onTap: _isLoading ? null : () => _onOAuthLogin('kakao'),
              ),
              const SizedBox(height: 12),
              _OAuthButton(
                label: '네이버로 로그인',
                backgroundColor: const Color(0xFF03C75A),
                foregroundColor: Colors.white,
                icon: const _NaverIcon(),
                onTap: _isLoading ? null : () => _onOAuthLogin('naver'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => setState(() => _showEmailForm = !_showEmailForm),
                child: Text(
                  _showEmailForm ? 'SNS 로그인으로 돌아가기' : '이메일로 로그인',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final Widget icon;
  final VoidCallback? onTap;

  const _OAuthButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: borderColor != null
                  ? Border.all(color: borderColor!, width: 1)
                  : null,
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                icon,
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw a simplified G logo
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.3,
      3.9,
      false,
      paint..style = PaintingStyle.stroke..strokeWidth = size.width * 0.2,
    );
    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - size.height * 0.1, radius, size.height * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _KakaoIcon extends StatelessWidget {
  const _KakaoIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Text(
          'K',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF191919),
          ),
        ),
      ),
    );
  }
}

class _NaverIcon extends StatelessWidget {
  const _NaverIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Text(
          'N',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
