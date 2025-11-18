import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

/// ProfileEditScreen with API Integration
///
/// 백엔드 프로필 API와 연동:
/// - GET /api/users/{id} : 프로필 조회
/// - PUT /api/users/{id}/profile : 프로필 수정
/// - PUT /api/users/{id}/password : 비밀번호 변경
class ProfileEditScreenWithAPI extends StatefulWidget {
  const ProfileEditScreenWithAPI({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreenWithAPI> createState() =>
      _ProfileEditScreenWithAPIState();
}

class _ProfileEditScreenWithAPIState extends State<ProfileEditScreenWithAPI> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController currentPasswordController =
  TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  String? selectedGender;
  bool isLoading = true;
  bool isChangingPassword = false;
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

  /// 프로필 로드
  Future<void> _loadProfile() async {
    if (ApiService.currentUserId == null) {
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
        nicknameController.text = profile.nickname;
        jobController.text = profile.job ?? '';
        ageController.text = profile.age?.toString() ?? '';
        selectedGender = profile.gender;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('프로필을 불러올 수 없습니다.');
      print('프로필 로드 실패: $e');
    }
  }

  /// 프로필 업데이트
  Future<void> _updateProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.updateProfile(
        userId: ApiService.currentUserId!,
        nickname: nicknameController.text.trim(),
        job: jobController.text.trim().isNotEmpty
            ? jobController.text.trim()
            : null,
        age: int.tryParse(ageController.text.trim()),
        gender: selectedGender,
      );

      final updatedProfile = UserProfile.fromJson(response);

      setState(() {
        currentProfile = updatedProfile;
        isLoading = false;
      });

      _showSuccessSnackBar('프로필이 수정되었습니다.');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('프로필 수정에 실패했습니다.');
      print('프로필 수정 실패: $e');
    }
  }

  /// 비밀번호 변경
  Future<void> _changePassword() async {
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('모든 비밀번호 필드를 입력해주세요.');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showErrorSnackBar('새 비밀번호가 일치하지 않습니다.');
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
        isChangingPassword = false;
      });

      // 비밀번호 필드 초기화
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      _showSuccessSnackBar('비밀번호가 변경되었습니다.');
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage;
      if (e.toString().contains('현재 비밀번호')) {
        errorMessage = '현재 비밀번호가 올바르지 않습니다.';
      } else if (e.toString().contains('일치')) {
        errorMessage = '새 비밀번호가 일치하지 않습니다.';
      } else {
        errorMessage = '비밀번호 변경에 실패했습니다.';
      }

      _showErrorSnackBar(errorMessage);
      print('비밀번호 변경 실패: $e');
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
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appTheme.teal_400),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: appTheme.teal_400,
        ),
      )
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
                _buildPasswordSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey[200],
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
          validator: _validateNickname,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
          margin: EdgeInsets.only(top: 2.h),
        ),
        SizedBox(height: 18.h),

        // 직업
        _buildInputLabel('직업 (선택)'),
        CustomTextFormField(
          controller: jobController,
          placeholder: '직업을 입력해 주세요.',
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
          margin: EdgeInsets.only(top: 2.h),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
          margin: EdgeInsets.only(top: 2.h),
        ),
        SizedBox(height: 18.h),

        // 성별
        _buildInputLabel('성별 (선택)'),
        SizedBox(height: 2.h),
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
          text: '저장',
          onPressed: _updateProfile,
          backgroundColor: appTheme.teal_400,
          textColor: appTheme.white_A700,
          width: double.infinity,
          height: 38.h,
          fontSize: 14.fSize,
          fontWeight: FontWeight.w700,
          borderRadius: 20.h,
          padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 10.h),
        ),
      ],
    );
  }

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
                  '변경',
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
            contentPadding:
            EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
            margin: EdgeInsets.only(top: 2.h),
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
            contentPadding:
            EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
            margin: EdgeInsets.only(top: 2.h),
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
            contentPadding:
            EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
            margin: EdgeInsets.only(top: 2.h),
          ),
          SizedBox(height: 32.h),

          // 비밀번호 변경 버튼
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
                  backgroundColor: Colors.grey[300]!,
                  textColor: Colors.grey[700]!,
                  height: 38.h,
                  fontSize: 14.fSize,
                  fontWeight: FontWeight.w700,
                  borderRadius: 20.h,
                  padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 10.h),
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: CustomButton(
                  text: '변경',
                  onPressed: _changePassword,
                  backgroundColor: appTheme.teal_400,
                  textColor: appTheme.white_A700,
                  height: 38.h,
                  fontSize: 14.fSize,
                  fontWeight: FontWeight.w700,
                  borderRadius: 20.h,
                  padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 10.h),
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
      padding: EdgeInsets.only(left: 10.h),
      child: Text(
        label,
        style: TextStyle(
          color: appTheme.teal_400,
          fontSize: 12.fSize,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w500,
          height: 1.0,
          letterSpacing: -0.30,
        ),
      ),
    );
  }

  String? _validateNickname(String? value) {
    if (value?.isEmpty ?? true) {
      return '닉네임을 입력해주세요';
    }
    if (value!.length < 2) {
      return '닉네임은 2자 이상 입력해주세요';
    }
    if (value.length > 12) {
      return '닉네임은 12자 이하로 입력해주세요';
    }
    return null;
  }
}