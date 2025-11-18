// 파일 경로: lib/presentation/profile_edit_screen/profile_edit_screen.dart

import 'package:flutter/material.dart';
import '../../core/app_export.dart';

/// 프로필 수정 화면
///
/// 기능:
/// - 프로필 사진, 이름, 이메일 표시
/// - 성별, 나이, 직업 수정
/// - 비밀번호 변경
/// - 저장 버튼
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _ageController = TextEditingController(text: '20');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  String _selectedGender = '남자';
  String? _selectedJob;

  final List<String> _genders = ['남자', '여자', '기타'];
  final List<String> _jobs = [
    '학생',
    '직장인',
    '자영업',
    '주부',
    '프리랜서',
    '무직',
    '기타',
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

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
                    _buildProfileHeader(),
                    SizedBox(height: 29.h),
                    _buildBasicInfoSection(),
                    SizedBox(height: 20.h),
                    _buildPasswordSection(),
                    SizedBox(height: 24.h),
                    _buildSaveButton(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.homeScreen,
      ),
    );
  }

  /// 프로필 헤더 (프로필 사진 + 이름/이메일)
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 59.h,
        bottom: 0,
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
          // 프로필 수정 타이틀
          Text(
            '프로필 수정',
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
          SizedBox(height: 52.h),
          // 프로필 카드
          Container(
            width: 315.w,
            padding: EdgeInsets.only(
              left: 25.w,
              right: 25.w,
              top: 9.h,
              bottom: 16.h,
            ),
            decoration: BoxDecoration(
              color: appTheme.white_A700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.h),
                topRight: Radius.circular(20.h),
              ),
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
                SizedBox(width: 32.w),
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
                      SizedBox(height: 21.h),
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

  /// 기본 정보 섹션 (성별, 나이, 직업)
  Widget _buildBasicInfoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 46.w),
      child: Column(
        children: [
          // 성별과 나이
          Row(
            children: [
              // 성별 드롭다운
              Expanded(
                flex: 137,
                child: Container(
                  height: 34.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      isExpanded: true,
                      icon: SizedBox.shrink(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.20,
                        letterSpacing: -0.35,
                      ),
                      items: _genders.map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedGender = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 9.w),
              // 나이 입력
              Expanded(
                flex: 155,
                child: Container(
                  height: 34.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                      Expanded(
                        child: TextField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: Color(0xFF797979),
                            fontSize: 14.fSize,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 1.20,
                            letterSpacing: -0.35,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Text(
                        '세',
                        style: TextStyle(
                          color: Color(0xFFD3D3D3),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
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
          SizedBox(height: 20.h),
          // 직업 드롭다운
          Container(
            width: double.infinity,
            height: 34.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedJob,
                isExpanded: true,
                hint: Text(
                  '직업을 선택해 주세요.',
                  style: TextStyle(
                    color: Color(0xFFD3D3D3),
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.20,
                    letterSpacing: -0.35,
                  ),
                ),
                icon: SizedBox.shrink(),
                style: TextStyle(
                  color: Color(0xFF797979),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                  letterSpacing: -0.35,
                ),
                items: _jobs.map((job) {
                  return DropdownMenuItem<String>(
                    value: job,
                    child: Text(job),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedJob = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 비밀번호 변경 섹션
  Widget _buildPasswordSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 46.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 비밀번호 변경 라벨
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Text(
              '비밀번호 변경',
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 12.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1,
                letterSpacing: -0.30,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          // 비밀번호 입력
          Container(
            height: 34.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
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
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 1.20,
                letterSpacing: -0.35,
              ),
              decoration: InputDecoration(
                hintText: '비밀번호를 입력해 주세요.',
                hintStyle: TextStyle(
                  color: Color(0xFFD3D3D3),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                  letterSpacing: -0.35,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          SizedBox(height: 34.h),
          // 비밀번호 확인 라벨
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Text(
              '비밀번호 변경 확인',
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 12.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1,
                letterSpacing: -0.30,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          // 비밀번호 확인 입력
          Container(
            height: 34.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
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
            child: TextField(
              controller: _passwordConfirmController,
              obscureText: true,
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 1.20,
                letterSpacing: -0.35,
              ),
              decoration: InputDecoration(
                hintText: '비밀번호를 다시 입력해 주세요.',
                hintStyle: TextStyle(
                  color: Color(0xFFD3D3D3),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                  letterSpacing: -0.35,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 저장 버튼
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveProfile,
      child: Container(
        width: 301.w,
        height: 38.h,
        decoration: BoxDecoration(
          color: appTheme.teal_400,
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
            '저장',
            style: TextStyle(
              color: appTheme.white_A700,
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

  /// 프로필 저장
  void _saveProfile() {
    // 비밀번호 확인
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _passwordConfirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
      }
    }

    // TODO: 실제 저장 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('프로필이 저장되었습니다.')),
    );

    // 이전 화면으로 돌아가기
    Navigator.pop(context);
  }
}