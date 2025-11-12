// 파일 경로: lib/widgets/custom_top_app_bar.dart

import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// 공통 상단 앱 바 위젯
///
/// 기능:
/// - 중앙 로고 표시
/// - 알림 아이콘 버튼
/// - 마이페이지(프로필) 아이콘 버튼
class CustomTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTopAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // AppBar 위젯을 사용하면 상태바 영역을 자동으로 처리해줍니다.
    return AppBar(
      elevation: 0, // 그림자 제거
      toolbarHeight: 56.h, // 기본 높이 (조정 가능)
      backgroundColor: appTheme.green_50, // 화면 배경색과 동일하게 설정
      automaticallyImplyLeading: false, // 뒤로가기 버튼 자동 생성 방지

      // 1. 중앙 로고
      // 기존 _buildHeader()의 로직을 그대로 가져옵니다.
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco,
            size: 28.h,
            color: appTheme.teal_400,
          ),
          SizedBox(width: 5.h),
          Text(
            '베란다 농부',
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 13.25.fSize,
              fontFamily: 'Cafe24 Ssurround OTF',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      centerTitle: true, // 제목(로고)을 중앙에 배치

      // 2. 우측 아이콘 버튼 (알림, 마이페이지)
      actions: [
        IconButton(
          onPressed: () {
            // TODO: 알림 화면 이동 로직
            print('알림 아이콘 클릭');
            // 예: Navigator.pushNamed(context, AppRoutes.notificationScreen);
          },
          icon: Icon(
            Icons.notifications_none_outlined,
            color: appTheme.blue_gray_700, // 아이콘 색상은 디자인에 맞게 조정
            size: 28.h,
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: 마이페이지 화면 이동 로직
            print('마이페이지 아이콘 클릭');
            // 예: Navigator.pushNamed(context, AppRoutes.myPageScreen);
          },
          icon: Icon(
            Icons.person_outline,
            color: appTheme.blue_gray_700, // 아이콘 색상은 디자인에 맞게 조정
            size: 28.h,
          ),
        ),
        SizedBox(width: 16.h), // 우측 여백
      ],
    );
  }

  /// AppBar 위젯은 PreferredSizeWidget을 구현해야 합니다.
  @override
  Size get preferredSize => Size.fromHeight(56.h); // 앱 바 높이 설정
}