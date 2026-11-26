import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      ApiService.autoDetectServer().timeout(const Duration(milliseconds: 1800), onTimeout: () => null),
      Future.delayed(const Duration(milliseconds: 450)),
    ]);
    final restoredUser = await AuthService.restoreSession();
    if (!mounted) return;
    if (restoredUser != null) {
      final destination = switch (restoredUser.role) {
        'LECTURER' || 'GIANGVIEN' => AppRoutes.lecturerMain,
        'SINHVIEN' => AppRoutes.home,
        'GIAOVU' || 'GIAOVUKHOA' => AppRoutes.governanceMain,
        'PHONG_DAO_TAO' || 'PHONGDAOTAO' => AppRoutes.trainingMain,
        'ADMIN' => AppRoutes.adminMain,
        _ => AppRoutes.login,
      };
      Navigator.pushReplacementNamed(context, destination, arguments: restoredUser);
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.groups, size: 50, color: Colors.white),
            ),

            const SizedBox(height: 24),

            const Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(AppConstants.appSubtitle),

            const SizedBox(height: 32),

            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
