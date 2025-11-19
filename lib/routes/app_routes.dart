// 파일 경로: lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../core/app_export.dart';

class AppRoutes {
  // 라우트 경로 상수
  static const String splashScreen = '/splash';
  static const String loginScreen = '/login';
  static const String registerScreen = '/register';
  static const String onboardingScreen = '/onboarding';
  static const String guideScreen = '/guide';
  static const String deviceConnectionScreen = '/device_connection';
  static const String deviceSelectionScreen = '/device_selection';
  static const String plantSelectionScreen = '/plant_selection';
  static const String homeScreen = '/home';
  static const String diaryScreen = '/diary';
  static const String diagnosisScreen = '/diagnosis';
  static const String controlScreen = '/control';
  static const String appNavigationScreen = '/app_navigation';
  static const String myPageScreen = '/mypage';
  static const String profileEditScreen = '/profile_edit';

  // 초기 라우트
  static const String initialRoute = splashScreen;

  // 라우트 맵
  static Map<String, WidgetBuilder> get routes => {
    splashScreen: (context) => SplashScreen(),
    loginScreen: (context) => LoginScreen(),
    registerScreen: (context) => RegisterScreen(),
    onboardingScreen: (context) => OnboardingScreen(),
    guideScreen: (context) => GuideScreen(),
    deviceConnectionScreen: (context) => DeviceConnectionScreen(),
    deviceSelectionScreen: (context) => DeviceSelectionScreen(),
    plantSelectionScreen: (context) => PlantSelectionScreen(),
    homeScreen: (context) => HomeScreen(),
    diaryScreen: (context) => DiaryScreen(), // TODO: 실제 userPlantId 전달
    diagnosisScreen: (context) => DiagnosisScreen(),
    controlScreen: (context) => ControlScreen(),
    appNavigationScreen: (context) => AppNavigationScreen(),
    myPageScreen: (context) => MyPageScreen(),
    profileEditScreen: (context) => ProfileEditScreenWithAPI(),
  };
}