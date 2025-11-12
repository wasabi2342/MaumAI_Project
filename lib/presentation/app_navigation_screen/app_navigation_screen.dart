import 'package:flutter/material.dart';

import '../../core/app_export.dart';

class AppNavigationScreen extends StatelessWidget {
  const AppNavigationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0XFFFFFFFF),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    children: [
                      _buildScreenTitle(
                        context,
                        screenTitle: "스플래시",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.splashScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "로그인",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.loginScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "회원가입",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.registerScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "온보딩 (개인정보 입력)",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.onboardingScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "가이드",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.guideScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "기기연결",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.deviceConnectionScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "기기선택",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.deviceSelectionScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "식물 선택",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.plantSelectionScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "홈 (센서 데이터)",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.homeScreen),
                      ),
                      _buildScreenTitle(
                        context,
                        screenTitle: "다이어리 (식물 성장 기록)",
                        onTapScreenTitle: () =>
                            onTapScreenTitle(context, AppRoutes.diaryScreen),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Common widget
  Widget _buildScreenTitle(
      BuildContext context, {
        required String screenTitle,
        Function? onTapScreenTitle,
      }) {
    return GestureDetector(
      onTap: () {
        onTapScreenTitle?.call();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        decoration: BoxDecoration(color: Color(0XFFFFFFFF)),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  screenTitle,
                  textAlign: TextAlign.center,
                  style: TextStyleHelper.instance.title20RegularRoboto
                      .copyWith(color: Color(0XFF000000)),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Color(0XFF343330),
                )
              ],
            ),
            SizedBox(height: 10.h),
            Divider(height: 1.h, thickness: 1.h, color: Color(0XFFD2D2D2)),
          ],
        ),
      ),
    );
  }

  /// Common click event
  void onTapScreenTitle(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// Common click event for bottomsheet
  void onTapBottomSheetTitle(BuildContext context, Widget className) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return className;
      },
      isScrollControlled: true,
      backgroundColor: appTheme.transparentCustom,
    );
  }

  /// Common click event for dialog
  void onTapDialogTitle(BuildContext context, Widget className) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: className,
          backgroundColor: appTheme.transparentCustom,
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }
}