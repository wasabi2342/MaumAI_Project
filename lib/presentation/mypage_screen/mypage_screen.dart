import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../models/models.dart'; // UserProfile 모델 사용을 위해 필요
import '../../widgets/custom_top_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

/// 마이페이지 화면
///
/// 기능:
/// - API를 통해 프로필 정보(이름, 이메일) 로드 및 표시
/// - 프로필 수정 화면 이동 (갔다 오면 자동 갱신)
/// - 설정 옵션 (푸시 알림, 양액/물교체 알림)
/// - API 로그아웃 연동
/// - 상단: 뒤로가기 버튼 및 타이틀 (Stack 구조)
/// - 하단: 네비게이션 바 (모두 회색 처리, 애니메이션 제거)
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // 사용자 프로필 데이터
  UserProfile? _userProfile;
  bool _isLoading = true;

  // 설정 상태 변수
  bool _pushNotification = true;
  bool _nutrientChangeNotification = true;

  @override
  void initState() {
    super.initState();
    // 화면 초기화 시 사용자 정보 불러오기
    _fetchUserProfile();
  }

  /// 사용자 프로필 정보 조회 API 호출
  Future<void> _fetchUserProfile() async {
    // 로그인된 사용자 ID가 없으면 로딩 종료
    if (ApiService.currentUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await ApiService.getProfile(ApiService.currentUserId!);
      setState(() {
        _userProfile = UserProfile.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      print('프로필 로드 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: CustomTopAppBar(), // 상단 앱바
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: appTheme.teal_400))
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileSection(),
                    SizedBox(height: 48.h),
                    _buildSettingsSection(),
                    SizedBox(height: 24.h),
                    _buildLogoutButton(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // [수정] 하단 네비게이션 바 설정
      // activeRoute를 myPageScreen으로 설정하여 모든 탭 아이콘을 회색으로 만듦
      // 이를 통해 '홈' 버튼 등 다른 탭을 누를 때 CustomBottomNavBar 내부의
      // _navigateWithoutAnimation이 실행되어 애니메이션 없이 이동함
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.myPageScreen,
      ),
    );
  }

  /// 프로필 섹션 (API 데이터 적용)
  Widget _buildProfileSection() {
    // 데이터가 없으면 기본값 또는 ApiService의 static 변수 사용
    final nickname =
        _userProfile?.nickname ?? ApiService.currentUserNickname ?? '사용자';
    final email = _userProfile?.email ?? ApiService.currentUserEmail ?? '-';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 16.h,
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
          // 타이틀 및 뒤로가기 버튼 (Stack 사용)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 뒤로가기 버튼 (왼쪽 정렬)
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context), // 이전 페이지로 이동
                    child: Container(
                      color: Colors.transparent, // 터치 영역 확보
                      padding: EdgeInsets.all(4.h),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18.h,
                        color: appTheme.teal_400,
                      ),
                    ),
                  ),
                ),
                // 마이페이지 타이틀 (중앙 정렬)
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
              ],
            ),
          ),
          SizedBox(height: 32.h),
          // 프로필 카드
          Container(
            width: 361.w,
            padding: EdgeInsets.only(
              left: 37.w,
              right: 37.w,
              top: 25.h,
              bottom: 25.h,
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
                SizedBox(width: 41.w),
                // 프로필 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname,
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          height: 1,
                          letterSpacing: -0.35,
                        ),
                      ),
                      SizedBox(height: 19.h),
                      Text(
                        email,
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 12.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1,
                          letterSpacing: -0.30,
                        ),
                      ),
                      SizedBox(height: 13.h),
                      // 프로필 수정 버튼
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.profileEditScreen,
                          ).then((result) {
                            // result가 true이면(저장 성공 시) 마이페이지에서 스낵바를 띄웁니다.
                            if (result == true) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('성공적으로 저장되었습니다.'),
                                  backgroundColor: appTheme.teal_400,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                            // 프로필 정보 갱신
                            _fetchUserProfile();
                          });
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
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 18.h,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          SizedBox(height: 35.h),
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
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => AlertDialog(
        backgroundColor: appTheme.white_A700,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.h),
        ),
        title: Text(
          '로그아웃',
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 18.fSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(
            color: Color(0xFF797979),
            fontSize: 14.fSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(
                color: Color(0xFF797979),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                    child: CircularProgressIndicator(color: appTheme.teal_400)),
              );

              try {
                await ApiService.logout();
              } catch (e) {
                print('로그아웃 API 호출 실패: $e');
              } finally {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.loginScreen,
                      (route) => false,
                );
              }
            },
            child: Text(
              '확인',
              style: TextStyle(
                color: appTheme.teal_400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}