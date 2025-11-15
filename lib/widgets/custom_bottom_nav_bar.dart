import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// 공통 하단 네비게이션 바 위젯
class CustomBottomNavBar extends StatelessWidget {
  final String activeRoute;

  const CustomBottomNavBar({
    Key? key,
    required this.activeRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 393.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: Color(0xFFFDFEFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.h),
          topRight: Radius.circular(20.h),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66D3D3D3),
            blurRadius: 8,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavItem(
            context,
            label: '홈',
            isSelected: activeRoute == AppRoutes.homeScreen,
            isFirst: true,
            onTap: activeRoute == AppRoutes.homeScreen
                ? null
                : () => Navigator.pushReplacementNamed(context, AppRoutes.homeScreen),
          ),
          _buildNavItem(
            context,
            label: '다이어리',
            isSelected: activeRoute == AppRoutes.diaryScreen,
            onTap: activeRoute == AppRoutes.diaryScreen
                ? null
                : () => Navigator.pushReplacementNamed(context, AppRoutes.diaryScreen),
          ),
          _buildNavItem(
            context,
            label: '진단',
            isSelected: activeRoute == AppRoutes.diagnosisScreen,
            onTap: activeRoute == AppRoutes.diagnosisScreen
                ? null
                : () => Navigator.pushReplacementNamed(context, AppRoutes.diagnosisScreen),
          ),
          _buildNavItem(
            context,
            label: '제어',
            isSelected: activeRoute == AppRoutes.controlScreen,
            isLast: true,
            onTap: activeRoute == AppRoutes.controlScreen
                ? null
                : () => Navigator.pushReplacementNamed(context, AppRoutes.controlScreen),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required String label,
        required bool isSelected,
        bool isFirst = false,
        bool isLast = false,
        VoidCallback? onTap,
      }) {
    return Container(
      width: isLast ? 99.w : 98.w,
      height: 70.h,
      decoration: BoxDecoration(
        color: Color(0xFFFDFEFB),
        borderRadius: isFirst
            ? BorderRadius.only(topLeft: Radius.circular(20.h))
            : isLast
            ? BorderRadius.only(topRight: Radius.circular(20.h))
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              left: (isLast ? 99.w : 98.w) / 2 - 28.w,
              top: 12.h,
              child: Container(
                width: 56.w,
                height: 52.h,
                child: Column(
                  children: [
                    // 아이콘
                    Container(
                      width: 33.w,
                      height: 33.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForLabel(label),
                        size: 24.h,
                        color: isSelected ? Color(0xFF37705E) : Color(0xFFD3D3D3),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // 라벨
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Color(0xFF37705E) : Color(0xFFD3D3D3),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        height: 1.20,
                        letterSpacing: -0.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case '홈':
        return Icons.home;
      case '다이어리':
        return Icons.book;
      case '진단':
        return Icons.medical_services;
      case '제어':
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }
}