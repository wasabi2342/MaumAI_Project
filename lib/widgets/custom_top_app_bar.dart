// 파일 경로: lib/widgets/custom_top_app_bar.dart

import 'package:flutter/material.dart';
import '../core/app_export.dart';
import 'notification_sidebar.dart';

/// 공통 상단 앱 바 위젯
///
/// 기능:
/// - 중앙 로고 표시 (img_.png - 잎 아이콘과 "베란다 농부" 텍스트 포함)
/// - 알림 아이콘 버튼 (알림 사이드바 토글)
/// - 마이페이지(프로필) 아이콘 버튼
class CustomTopAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomTopAppBar({Key? key}) : super(key: key);

  @override
  State<CustomTopAppBar> createState() => _CustomTopAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}

class _CustomTopAppBarState extends State<CustomTopAppBar> {
  /// 알림 사이드바 표시
  void _showNotificationSidebar(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Color(0x3FD9D9D9),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return NotificationSidebar(
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // 오른쪽에서 왼쪽으로 슬라이드
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0, // 그림자 제거
      toolbarHeight: 56.h, // 기본 높이 (조정 가능)
      backgroundColor: appTheme.green_50, // 화면 배경색과 동일하게 설정
      automaticallyImplyLeading: false, // 뒤로가기 버튼 자동 생성 방지

      // 1. 중앙 로고 (img_.png 이미지 - 잎 아이콘 + "베란다 농부" 텍스트 포함)
      title: CustomImageView(
        imagePath: ImageConstant.img,
        height: 28.h,
        fit: BoxFit.contain,
      ),
      centerTitle: true, // 제목(로고)을 중앙에 배치

      // 2. 우측 아이콘 버튼 (알림, 마이페이지)
      actions: [
        // 알림 버튼
        IconButton(
          onPressed: () {
            _showNotificationSidebar(context);
          },
          icon: Icon(
            Icons.notifications_none_outlined,
            color: appTheme.blue_gray_700,
            size: 28.h,
          ),
          tooltip: '알림',
        ),
        // 마이페이지 버튼
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.myPageScreen);
          },
          icon: Icon(
            Icons.person_outline,
            color: appTheme.blue_gray_700,
            size: 28.h,
          ),
          tooltip: '마이페이지',
        ),
        SizedBox(width: 16.h), // 우측 여백
      ],
    );
  }
}