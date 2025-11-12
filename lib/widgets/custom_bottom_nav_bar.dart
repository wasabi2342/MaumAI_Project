
import 'package:flutter/material.dart';
import '../core/app_export.dart'; // core/app_export.dart 경로

/// 공통 하단 네비게이션 바 위젯
///
/// [activeRoute] 파라미터를 통해 현재 활성화된 탭의 라우트 이름을 받습니다.
class CustomBottomNavBar extends StatelessWidget {
  final String activeRoute;

  const CustomBottomNavBar({
    Key? key,
    required this.activeRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.h),
          topRight: Radius.circular(20.h),
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.color66D3D3,
            blurRadius: 8.h,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(
            context,
            label: '홈',
            icon: Icons.home,
            isSelected: activeRoute == AppRoutes.homeScreen,
            onTap: activeRoute == AppRoutes.homeScreen
                ? null // 이미 해당 화면이면 Tapped 비활성화
                : () =>
                Navigator.pushReplacementNamed(context, AppRoutes.homeScreen),
          ),
          _buildNavItem(
            context,
            label: '다이어리',
            icon: Icons.book,
            isSelected: activeRoute == AppRoutes.diaryScreen,
            onTap: activeRoute == AppRoutes.diaryScreen
                ? null
                : () =>
                Navigator.pushReplacementNamed(context, AppRoutes.diaryScreen),
          ),
          _buildNavItem(
            context,
            label: '진단',
            icon: Icons.medical_services,
            isSelected: activeRoute == AppRoutes.diagnosisScreen,
            onTap: activeRoute == AppRoutes.diagnosisScreen
                ? null
                : () => Navigator.pushReplacementNamed(
                context, AppRoutes.diagnosisScreen),
          ),
          _buildNavItem(
            context,
            label: '제어',
            icon: Icons.settings,
            isSelected: activeRoute == AppRoutes.controlScreen,
            onTap: activeRoute == AppRoutes.controlScreen
                ? null
                : () => Navigator.pushReplacementNamed(
                context, AppRoutes.controlScreen),
          ),
        ],
      ),
    );
  }

  /// 네비게이션 아이템
  Widget _buildNavItem(
      BuildContext context, {
        required String label,
        required IconData icon,
        required bool isSelected,
        VoidCallback? onTap,
      }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 70.h,
          color: appTheme.white_A700, // InkWell 효과를 위해 배경색 유지
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.h,
                color:
                isSelected ? appTheme.blue_gray_700 : appTheme.blue_gray_100,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? appTheme.blue_gray_700
                      : appTheme.blue_gray_100,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}