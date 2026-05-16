import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/main_scaffold.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // 웹: OAuth 콜백으로 돌아온 경우 URL에서 토큰 추출
    if (kIsWeb) {
      final uri = Uri.base;
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];
      final name = uri.queryParameters['name'];

      if (accessToken != null && accessToken.isNotEmpty) {
        await _storage.write(key: 'access_token', value: accessToken);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _storage.write(key: 'refresh_token', value: refreshToken);
        }
        if (name != null && name.isNotEmpty) {
          await _storage.write(key: 'user_name', value: name);
        }
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
        return;
      }
    }

    final token = await _storage.read(key: 'access_token');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => token != null ? const MainScaffold() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary300,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary300,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: const Center(
                child: Text('🧸', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '강원대 돌봄케어 솔루션',
              style: AppTypography.display.copyWith(
                color: AppColors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'DeepCare · 스마트통합돌봄 플랫폼',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
