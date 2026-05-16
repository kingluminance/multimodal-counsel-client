import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../services/services.dart';
import '../widgets/main_scaffold.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();

  Future<void> _onOAuthLogin(String provider) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final result = await AuthService().oauthCallback(
        provider: provider,
        oauthCode: '',
        redirectUri: 'deepcare://callback',
      );
      if (!mounted) return;

      final status = result['status'] as String?;
      if (status == 'new_user') {
        final oauthToken = result['oauth_token'] as String? ?? '';
        await _storage.write(key: 'oauth_token', value: oauthToken);
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SignupPage()),
        );
      } else if (status == 'existing_user') {
        await ApiClient().saveTokens(
          accessToken: result['access_token'] as String? ?? '',
          refreshToken: result['refresh_token'] as String? ?? '',
        );
        if (result['user_id'] != null) {
          await _storage.write(key: 'user_id', value: result['user_id'].toString());
        }
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String message = '로그인 중 오류가 발생했습니다.';
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
