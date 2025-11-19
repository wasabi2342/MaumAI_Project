import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

/// ProfileEditScreenWithAPI
///
/// 기능:
/// - 내 정보 조회 및 수정 (닉네임, 직업, 나이, 성별)
/// - 비밀번호 변경
/// - API 연동: ApiService.getProfile, updateProfile, changePassword
class ProfileEditScreenWithAPI extends StatefulWidget {
  const ProfileEditScreenWithAPI({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreenWithAPI> createState() =>
      _ProfileEditScreenWithAPIState();
}

class _ProfileEditScreenWithAPIState extends State<ProfileEditScreenWithAPI> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 컨트롤러 정의
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // 비밀번호 변경용 컨트롤러
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? selectedGender;
  bool isLoading = true;
  bool isChangingPassword = false; // 비밀번호 변경 섹션 표시 여부
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
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// [API] 프로필 정보 불러오기
  Future<void> _loadProfile() async {
    if (ApiService.currentUserId == null) {
      // 로그인이 안되어 있다면 화면 종료
      Navigator.pop(context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.getProfile(ApiService.currentUserId!);
      final profile = UserProfile.fromJson(response);

      setState(() {
        currentProfile = profile;
        // 기존 정보로 입력창 채우기
        nicknameController.text = profile.nickname;
        jobController.text = profile.job ?? '';
        ageController.text = profile.age?.toString() ?? '';
        selectedGender = profile.gender; // 예: "남성", "여성"
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('프로필을 불러올 수 없습니다: $e');
      print('프로필 로드 실패: $e');
    }
  }

  /// [API] 프로필 정보 수정하기
  Future<void> _updateProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.updateProfile(
        userId: ApiService.currentUserId!,
        nickname: nicknameController.text.trim(),
        job: jobController.text.trim().isNotEmpty ? jobController.text.trim() : null,
        age: int.tryParse(ageController.text.trim()),
        gender: selectedGender,
      );

      final updatedProfile = UserProfile.fromJson(response);

      setState(() {
        currentProfile = updatedProfile;
        isLoading = false;
      });

      _showSuccessSnackBar('프로필이 성공적으로 수정되었습니다.');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('프로필 수정 실패: $e');
    }
  }

  /// [API] 비밀번호 변경하기
  Future<void> _changePassword() async {
    // 유효성 검사
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('모든 비밀번호 필드를 입력해주세요.');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showErrorSnackBar('새 비밀번호가 서로 일치하지 않습니다.');
      return;
    }

    if (newPasswordController.text.length < 6) {
      _showErrorSnackBar('새 비밀번호는 6자 이상이어야 합니다.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.changePassword(
        userId: ApiService.currentUserId!,
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        newPasswordConfirm: confirmPasswordController.text,
      );

      setState(() {
        isLoading = false;
        isChangingPassword = false; // 변경 완료 후 섹션 닫기
      });

      // 입력 필드 초기화
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      _showSuccessSnackBar('비밀번호가 변경되었습니다.');
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = '비밀번호 변경 실패';
      if (e.toString().contains('현재 비밀번호')) {
        errorMessage = '현재 비밀번호가 올바르지 않습니다.';
      }
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appTheme.teal_400,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appTheme.redCustom,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: AppBar(
        title: Text(
          '프로필 수정',
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 18.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: appTheme.white_A700,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.teal_400),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: appTheme.teal_400))
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(),
                SizedBox(height: 32.h),
                Divider(color: appTheme.blue_gray_100, thickness: 1),
                SizedBox(height: 32.h),
                _buildPasswordSection(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 기본 정보 수정 섹션
  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기본 정보',
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 20.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 24.h),

        // 이메일 (수정 불가)
        _buildInputLabel('이메일'),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 12.h),
          decoration: BoxDecoration(
            color: appTheme.grey200,
            borderRadius: BorderRadius.circular(20.h),
          ),
          child: Text(
            currentProfile?.email ?? '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.fSize,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        SizedBox(height: 18.h),

        // 닉네임
        _buildInputLabel('닉네임'),
        CustomTextFormField(
          controller: nicknameController,
          placeholder: '닉네임을 입력해 주세요.',
          validator: (value) {
            if (value == null || value.isEmpty) return '닉네임을 입력해주세요.';
            if (value.length < 2) return '닉네임은 2자 이상이어야 합니다.';
            return null;
          },
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 12.h),
        ),
        SizedBox(height: 18.h),

        // 직업
        _buildInputLabel('직업 (선택)'),
        CustomDropdown(
          placeholder: '직업을 선택해 주세요.',
          items: ['학생', '회사원', '주부', '기타'],
          selectedItem: _validOccupation(jobController.text) ? jobController.text : null,
          onChanged: (value) {
            setState(() {
              jobController.text = value;
            });
          },
          borderRadius: 20.h,
        ),
        SizedBox(height: 18.h),

        // 나이
        _buildInputLabel('나이 (선택)'),
        CustomTextFormField(
          controller: ageController,
          placeholder: '나이를 입력해 주세요.',
          keyboardType: TextInputType.number,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 12.h),
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
        SizedBox(height: 18.h),

        // 성별
        _buildInputLabel('성별 (선택)'),
        SizedBox(height: 8.h),
        CustomDropdown(
          placeholder: '성별을 선택해 주세요.',
          items: ['남성', '여성', '기타'],
          selectedItem: selectedGender,
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
          borderRadius: 20.h,
        ),
        SizedBox(height: 32.h),

        // 저장 버튼
        CustomButton(
          text: '정보 수정 저장',
          onPressed: _updateProfile,
          backgroundColor: appTheme.teal_400,
          textColor: appTheme.white_A700,
          height: 48.h,
          fontSize: 16.fSize,
          fontWeight: FontWeight.w700,
          borderRadius: 20.h,
        ),
      ],
    );
  }

  /// 비밀번호 변경 섹션
  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '비밀번호 변경',
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 20.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!isChangingPassword)
              TextButton(
                onPressed: () {
                  setState(() {
                    isChangingPassword = true;
                  });
                },
                child: Text(
                  '변경하기',
                  style: TextStyle(
                    color: appTheme.teal_400,
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        if (isChangingPassword) ...[
          SizedBox(height: 24.h),

          // 현재 비밀번호
          _buildInputLabel('현재 비밀번호'),
          CustomTextFormField(
            controller: currentPasswordController,
            placeholder: '현재 비밀번호를 입력해 주세요.',
            obscureText: true,
            fillColor: appTheme.white_A700,
            borderColor: appTheme.color66D3D3,
            focusedBorderColor: appTheme.colorFF66D3,
            borderRadius: 20.h,
          ),
          SizedBox(height: 18.h),

          // 새 비밀번호
          _buildInputLabel('새 비밀번호'),
          CustomTextFormField(
            controller: newPasswordController,
            placeholder: '새 비밀번호를 입력해 주세요.',
            obscureText: true,
            fillColor: appTheme.white_A700,
            borderColor: appTheme.color66D3D3,
            focusedBorderColor: appTheme.colorFF66D3,
            borderRadius: 20.h,
          ),
          SizedBox(height: 18.h),

          // 새 비밀번호 확인
          _buildInputLabel('새 비밀번호 확인'),
          CustomTextFormField(
            controller: confirmPasswordController,
            placeholder: '새 비밀번호를 다시 입력해 주세요.',
            obscureText: true,
            fillColor: appTheme.white_A700,
            borderColor: appTheme.color66D3D3,
            focusedBorderColor: appTheme.colorFF66D3,
            borderRadius: 20.h,
          ),
          SizedBox(height: 32.h),

          // 버튼 영역 (취소 / 변경)
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: '취소',
                  onPressed: () {
                    setState(() {
                      isChangingPassword = false;
                      currentPasswordController.clear();
                      newPasswordController.clear();
                      confirmPasswordController.clear();
                    });
                  },
                  backgroundColor: appTheme.grey200,
                  textColor: appTheme.gray_800,
                  height: 48.h,
                  borderRadius: 20.h,
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: CustomButton(
                  text: '변경 완료',
                  onPressed: _changePassword,
                  backgroundColor: appTheme.teal_400,
                  textColor: appTheme.white_A700,
                  height: 48.h,
                  borderRadius: 20.h,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: 10.h, bottom: 8.h),
      child: Text(
        label,
        style: TextStyle(
          color: appTheme.teal_400,
          fontSize: 12.fSize,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _validOccupation(String? val) {
    if(val == null) return false;
    const validList = ['학생', '회사원', '주부', '기타'];
    return validList.contains(val);
  }
}