import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/register_screen/register_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/guide_screen/guide_screen.dart';
import '../presentation/device_connection_screen/device_connection_screen.dart';
import '../presentation/device_selection_screen/device_selection_screen.dart';
import '../presentation/plant_selection_screen/plant_selection_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/diary_screen/diary_screen.dart';
import '../presentation/diagnosis_screen/diagnosis_screen.dart';
import '../presentation/control_screen/control_screen.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';

/// Application routes configuration
class AppRoutes {
  /// Initial route when app starts - Splash Screen
  static const String initialRoute = splashScreen;

  /// Route names
  static const String splashScreen = '/splash_screen';
  static const String loginScreen = '/login_screen';
  static const String registerScreen = '/register_screen';
  static const String onboardingScreen = '/onboarding_screen';
  static const String guideScreen = '/guide_screen';
  static const String deviceConnectionScreen = '/device_connection_screen';
  static const String deviceSelectionScreen = '/device_selection_screen';
  static const String plantSelectionScreen = '/plant_selection_screen';
  static const String homeScreen = '/home_screen';
  static const String diaryScreen = '/diary_screen';
  static const String diagnosisScreen = '/diagnosis_screen';
  static const String controlScreen = '/control_screen';
  static const String appNavigationScreen = '/app_navigation_screen';

  /// Route map
  static Map<String, WidgetBuilder> get routes => {
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => LoginScreen(),
    registerScreen: (context) => RegisterScreen(),
    onboardingScreen: (context) => const OnboardingScreen(),
    guideScreen: (context) => const GuideScreen(),
    deviceConnectionScreen: (context) => const DeviceConnectionScreen(),
    deviceSelectionScreen: (context) => const DeviceSelectionScreen(),
    plantSelectionScreen: (context) => const PlantSelectionScreen(),
    homeScreen: (context) => const HomeScreen(),
    diaryScreen: (context) => const DiaryScreen(),
    diagnosisScreen: (context) => const DiagnosisScreen(),
    controlScreen: (context) => const ControlScreen(),
    appNavigationScreen: (context) => const AppNavigationScreen(),
  };
}
