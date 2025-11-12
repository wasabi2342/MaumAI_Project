import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';

/// SplashScreen - 앱 시작 시 표시되는 스플래시 화면
///
/// 기능:
/// - 앱 로고 및 브랜드명 표시
/// - 2초 후 자동으로 로그인 화면으로 이동
/// - 그라데이션 배경
/// - 반응형 디자인
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  /// 2초 후 로그인 화면으로 자동 이동
  void _navigateToLogin() {
    Timer(
      const Duration(seconds: 2),
          () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3FAE8),
              appTheme.green_200,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _buildLogoSection(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return CustomImageView(
      imagePath: ImageConstant.img,
      height: 280.h,  // 크기 증가
      width: 120.h,
      fit: BoxFit.contain,
    );
  }
}