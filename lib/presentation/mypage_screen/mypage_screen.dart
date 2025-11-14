// 파일 경로: lib/presentation/mypage_screen/mypage_screen.dart

import 'package:flutter/material.dart';
import '../../core/app_export.dart';

/// 마이페이지 화면
///
/// 기능:
/// - 프로필 정보 표시 (프로필 사진, 이름, 이메일)
/// - 프로필 수정 버튼
/// - 설정 옵션 (푸시 알림, 양액/물교체 알림)
/// - 로그아웃 버튼
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _pushNotification = true;
  bool _nutrientChangeNotification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      appBar: CustomTopAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileSection(),
                    SizedBox(height: 59.h),
                    _buildSettingsSection(),
                    SizedBox(height: 36.h),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: '', // 마이페이지는 하단 네비게이션에 없음
      ),
    );
  }

  /// 프로필 섹션
  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 70.h,
        bottom: 39.h,
      ),
      decoration: BoxDecoration(
        color: appTheme.green_50,
        boxShadow: [
          BoxShadow(
            color: Color(0x66D3D3D3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 마이페이지 타이틀
          Text(
            '마이페이지',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 14.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              height: 1.50,
              letterSpacing: -0.32,
            ),
          ),
          SizedBox(height: 43.h),
          // 프로필 카드
          Container(
            width: 361.w,
            padding: EdgeInsets.symmetric(
              horizontal: 37.w,
              vertical: 25.h,
            ),
            decoration: BoxDecoration(
              color: appTheme.white_A700,
              borderRadius: BorderRadius.circular(20.h),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66D3D3D3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 프로필 사진
                Container(
                  width: 90.h,
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: appTheme.green_50,
                    borderRadius: BorderRadius.circular(200.h),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 50.h,
                    color: appTheme.teal_400,
                  ),
                ),
                SizedBox(width: 28.w),
                // 프로필 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '홍길동',
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          height: 1,
                          letterSpacing: -0.35,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'hansung1234@gmail.com',
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 12.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: -0.30,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // 프로필 수정 버튼
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.profileEditScreen,
                          );
                        },
                        child: Container(
                          width: 148.w,
                          height: 21.h,
                          decoration: BoxDecoration(
                            color: appTheme.teal_400,
                            borderRadius: BorderRadius.circular(50.h),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x5B32C697),
                                blurRadius: 4,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '프로필 수정',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: appTheme.white_A700,
                                fontSize: 14.fSize,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                height: 1.50,
                                letterSpacing: -0.32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 설정 섹션
  Widget _buildSettingsSection() {
    return Container(
      width: 361.w,
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(20.h),
        boxShadow: [
          BoxShadow(
            color: Color(0x66D3D3D3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설정 타이틀
          Text(
            '설정',
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 16.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              height: 1,
              letterSpacing: -0.40,
            ),
          ),
          SizedBox(height: 19.h),
          // 푸시 알림
          _buildSettingItem(
            icon: Icons.notifications_none_outlined,
            title: '푸시 알림',
            value: _pushNotification,
            onChanged: (value) {
              setState(() {
                _pushNotification = value;
              });
            },
          ),
          SizedBox(height: 16.h),
          // 양액/물교체 알림
          _buildSettingItem(
            icon: Icons.water_drop_outlined,
            title: '영약 / 물교체 알림',
            value: _nutrientChangeNotification,
            onChanged: (value) {
              setState(() {
                _nutrientChangeNotification = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 설정 아이템
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.h,
          color: Color(0xFF797979),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Color(0xFF797979),
              fontSize: 16.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: -0.40,
            ),
          ),
        ),
        Text(
          value ? '켜짐' : '꺼짐',
          style: TextStyle(
            color: Color(0xFF797979),
            fontSize: 14.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            height: 1,
            letterSpacing: -0.35,
          ),
        ),
        SizedBox(width: 10.w),
        // 커스텀 토글 스위치
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 33.w,
            height: 14.h,
            decoration: BoxDecoration(
              gradient: value
                  ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFA0ECB1),
                  Color(0xFFE3FAE8),
                ],
              )
                  : null,
              color: value ? null : Color(0xFFD3D3D3),
              borderRadius: BorderRadius.circular(100.h),
            ),
            child: Align(
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                width: 10.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: value ? appTheme.teal_400 : Color(0xFF797979),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 로그아웃 버튼
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        // TODO: 로그아웃 로직 구현
        _showLogoutDialog();
      },
      child: Container(
        width: 301.w,
        height: 38.h,
        decoration: BoxDecoration(
          color: Color(0xFFD3D3D3),
          borderRadius: BorderRadius.circular(20.h),
          boxShadow: [
            BoxShadow(
              color: Color(0x66D3D3D3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '로그아웃',
            style: TextStyle(
              color: Color(0xFF797979),
              fontSize: 14.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 1.20,
              letterSpacing: -0.35,
            ),
          ),
        ),
      ),
    );
  }

  /// 로그아웃 확인 다이얼로그
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그아웃'),
        content: Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 로그인 화면으로 이동 (모든 스택 제거)
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.loginScreen,
                    (route) => false,
              );
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}