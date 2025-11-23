import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class ProfileEditScreenWithAPI extends StatefulWidget {
  const ProfileEditScreenWithAPI({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreenWithAPI> createState() =>
      _ProfileEditScreenWithAPIState();
}

class _ProfileEditScreenWithAPIState extends State<ProfileEditScreenWithAPI> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 컨트롤러
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // 비밀번호 변경 컨트롤러
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? selectedGender;
  bool isLoading = true;
  UserProfile? currentProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nicknameController.dispose();
    jobController.dispose();
    ageController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// 프로필 정보 로드
  Future<void> _loadProfile() async {
    if (ApiService.currentUserId == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.getProfile(ApiService.currentUserId!);

      if (!mounted) return;

      final profile = UserProfile.fromJson(response);

      setState(() {
        currentProfile = profile;
        nicknameController.text = profile.nickname;
        jobController.text = profile.job ?? '';
        ageController.text = profile.age?.toString() ?? '';
        selectedGender = profile.gender;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnackBar('프로필을 불러올 수 없습니다.', isError: true);
    }
  }

  /// 프로필 업데이트 및 마이페이지로 이동
  Future<void> _updateProfile() async {
    // 키보드 내리기
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      // 1. 프로필 정보 수정 API 호출
      await ApiService.updateProfile(
        userId: ApiService.currentUserId!,
        nickname: nicknameController.text.trim(),
        job: jobController.text.trim().isNotEmpty ? jobController.text.trim() : null,
        age: int.tryParse(ageController.text.trim()),
        gender: selectedGender,
      );

      if (!mounted) return;

      // 2. 비밀번호 변경 (입력된 경우에만)
      if (newPasswordController.text.isNotEmpty) {
        if (newPasswordController.text != confirmPasswordController.text) {
          throw Exception("비밀번호가 일치하지 않습니다.");
        }

        await ApiService.changePassword(
          userId: ApiService.currentUserId!,
          currentPassword: 'dummy_current_password', // 실제 환경에서는 현재 비밀번호 확인 필요
          newPassword: newPasswordController.text,
          newPasswordConfirm: confirmPasswordController.text,
        );

        if (!mounted) return;
      }

      // [성공 시 처리]
      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('성공적으로 저장되었습니다.'),
          backgroundColor: appTheme.teal_400,
          duration: Duration(seconds: 2),
        ),
      );

      // 마이페이지로 이동 (뒤로가기)
      Navigator.pop(context);

    } catch (e) {
      // [실패 시 처리]
      if (!mounted) return;
      setState(() => isLoading = false); // 로딩 상태 해제
      _showSnackBar('저장에 실패했습니다: ${e.toString().replaceAll("Exception: ", "")}', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? appTheme.redCustom : appTheme.teal_400,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: CustomTopAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: appTheme.teal_400))
          : SafeArea(
        top: false, // 상단 헤더 디자인을 위해 false
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(), // 상단 영역
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 46.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30.h),
                        _buildGenderAgeRow(),
                        SizedBox(height: 20.h),
                        _buildJobDropdown(),
                        SizedBox(height: 20.h),
                        _buildPasswordSection(),
                        SizedBox(height: 40.h),
                        _buildSaveButton(),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(activeRoute: AppRoutes.myPageScreen),
    );
  }

  /// 상단 헤더 영역
  Widget _buildHeader() {
    return Container(
      height: 164.h,
      width: double.infinity,
      child: Stack(
        children: [
          // 1. 초록색 배경
          Container(
            height: 164.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFE3FAE8),
            ),
          ),

          // 2. 상단 네비게이션 (뒤로가기, 타이틀)
          Positioned(
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 20.h, color: appTheme.gray_800),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      '프로필 수정',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appTheme.teal_400,
                        fontSize: 16.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 40.h),
                ],
              ),
            ),
          ),

          // 3. 흰색 프로필 카드 (겹쳐짐)
          Positioned(
            left: 39.h,
            right: 39.h,
            bottom: 0,
            child: Container(
              height: 108.h,
              decoration: BoxDecoration(
                color: appTheme.white_A700,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.h),
                  topRight: Radius.circular(20.h),
                  // 하단 모서리 직각 (요청사항 반영)
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66D3D3D3),
                    blurRadius: 8.h,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 프로필 이미지
                  Positioned(
                    left: 25.h,
                    top: 9.h,
                    child: Container(
                      width: 90.h,
                      height: 90.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFE3FAE8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: appTheme.teal_400,
                        size: 30.h,
                      ),
                    ),
                  ),
                  // 이름 입력/표시
                  Positioned(
                    left: 135.h,
                    top: 33.h,
                    right: 20.h,
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            controller: nicknameController,
                            style: TextStyle(
                              color: Color(0xFF797979),
                              fontSize: 14.fSize,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              hintText: '이름 입력',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        ),
                        Icon(Icons.edit, size: 14.h, color: Color(0xFF797979)),
                      ],
                    ),
                  ),
                  // 이메일 표시
                  Positioned(
                    left: 135.h,
                    top: 54.h,
                    right: 10.h,
                    child: Text(
                      currentProfile?.email ?? '',
                      style: TextStyle(
                        color: Color(0xFF797979),
                        fontSize: 12.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 구분선
                  Positioned(
                    left: 135.h,
                    top: 75.h,
                    right: 20.h,
                    child: Container(
                      height: 1,
                      color: Color(0xFFD3D3D3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 성별 및 나이 입력 행
  Widget _buildGenderAgeRow() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: CustomDropdown(
            placeholder: '성별',
            items: ['남성', '여성', '기타'],
            selectedItem: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
            borderRadius: 20.h,
          ),
        ),
        SizedBox(width: 9.h),
        Expanded(
          flex: 5,
          child: CustomTextFormField(
            controller: ageController,
            placeholder: '나이',
            keyboardType: TextInputType.number,
            fillColor: appTheme.white_A700,
            borderColor: appTheme.color66D3D3,
            focusedBorderColor: appTheme.colorFF66D3,
            borderRadius: 20.h,
            contentPadding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 8.h),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: 15.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('세', style: TextStyle(color: appTheme.blue_gray_100)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 직업 선택 드롭다운
  Widget _buildJobDropdown() {
    return CustomDropdown(
      placeholder: '직업을 선택해 주세요.',
      items: ['학생', '회사원', '주부', '기타'],
      selectedItem: jobController.text.isEmpty ? null : jobController.text,
      onChanged: (value) {
        setState(() {
          jobController.text = value;
        });
      },
      borderRadius: 20.h,
    );
  }

  /// 비밀번호 변경 섹션 (그림자 효과 추가)
  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '비밀번호 변경',
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 12.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        // 그림자 효과 추가를 위한 Container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.h),
            boxShadow: [
              BoxShadow(
                color: Color(0x66D3D3D3),
                blurRadius: 8.h,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: CustomTextFormField(
            controller: newPasswordController,
            placeholder: '비밀번호를 입력해 주세요.',
            obscureText: true,
            fillColor: appTheme.white_A700,
            borderColor: appTheme.color66D3D3,
            borderRadius: 20.h,
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          '비밀번호 변경 확인',
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 12.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        // 그림자 효과 추가를 위한 Container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.h),
            boxShadow: [
              BoxShadow(
                color: Color(0x66D3D3D3),
                blurRadius: 8.h,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: CustomTextFormField(
            controller: confirmPasswordController,
            placeholder: '비밀번호를 다시 입력해 주세요.',
            obscureText: true,
            fillColor: appTheme.white_A700,
            borderColor: appTheme.color66D3D3,
            borderRadius: 20.h,
          ),
        ),
      ],
    );
  }

  /// 저장 버튼
  Widget _buildSaveButton() {
    return CustomButton(
      text: '저장',
      onPressed: _updateProfile,
      backgroundColor: appTheme.teal_400,
      textColor: appTheme.white_A700,
      height: 48.h,
      width: double.infinity,
      fontSize: 14.fSize,
      fontWeight: FontWeight.w700,
      borderRadius: 20.h,
    );
  }
}