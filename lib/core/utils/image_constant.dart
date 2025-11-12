// lib/core/utils/image_constant.dart
class ImageConstant {
  // Base path for all assets
  static String _basePath = 'assets/images/';

  // Placeholder image for fallback
  static String imgPlaceholder = '${_basePath}placeholder.png';

  // Splash Screen & Login Screen Logo
  // Note: img는 로그인 화면과 스플래시 화면 모두에서 사용되는 로고입니다
  static String img = '${_basePath}img_.png';

  // Social Login Icons
  // 카카오 로그인 아이콘
  static String imgKakaoIcon = '${_basePath}img_kakao_icon.png';
  // 기존 이름도 지원 (하위 호환성)
  static String imgGroup60 = '${_basePath}img_kakao_icon.png';
  
  // 구글 로그인 아이콘
  static String imgGoogleIcon = '${_basePath}img_google_icon.png';
  // 기존 이름도 지원 (하위 호환성)
  static String imgGroup61 = '${_basePath}img_google_icon.png';

  // Custom Image View Screen
  static String imgImageNotFound = '${_basePath}image_not_found.png';
}
