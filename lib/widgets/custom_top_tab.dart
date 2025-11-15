import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// CustomTopTab - 재사용 가능한 상단 탭 위젯
///
/// 기능:
/// - 그라데이션 배경 (green_200 -> teal_400)
/// - 둥근 하단 모서리
/// - 그림자 효과
/// - 커스텀 텍스트 표시
///
/// 사용 예시:
/// ```dart
/// CustomTopTab(text: '가이드')
/// CustomTopTab(text: '홈')
/// ```
class CustomTopTab extends StatelessWidget {
  final String text;
  final double? width;
  final double? height;

  const CustomTopTab({
    Key? key,
    required this.text,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 185.h,
      height: height ?? 36.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appTheme.green_200,  // 0% #A0ECB1
            appTheme.teal_400,   // 100% #32C697
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.h),
          bottomRight: Radius.circular(50.h),
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.teal_400.withOpacity(0.36),
            blurRadius: 4.h,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appTheme.white_A700,
            fontSize: 16.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            height: 1.31,
          ),
        ),
      ),
    );
  }
}