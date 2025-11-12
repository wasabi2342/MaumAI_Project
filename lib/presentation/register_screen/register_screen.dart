import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_text_form_field.dart';

/// RegisterScreen - 회원가입 화면
///
/// 기능:
/// - 이름, 닉네임, 이메일, 비밀번호 입력
/// - 비밀번호 확인 (일치 여부 검증)
/// - 이메일 형식 검증
/// - 회원가입 버튼
/// - 소셜 로그인 (카카오, 구글)
/// - 그라데이션 배경
/// - 반응형 디자인
class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3FAE8),
              appTheme.green_200,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 46.h, vertical: 40.h),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLogoSection(context),
                            SizedBox(height: 34.h),
                            _buildInputFieldsSection(context),
                            SizedBox(height: 24.h),
                            _buildRegisterButton(context),
                            SizedBox(height: 22.h),
                            _buildSocialLoginSection(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 로고 섹션 (로고에 이미 "베란다 농부" 텍스트 포함)
  Widget _buildLogoSection(BuildContext context) {
    return CustomImageView(
      imagePath: ImageConstant.img,
      height: 63.h,
      width: 280.h,  // 로고 + 텍스트를 포함한 전체 너비
      fit: BoxFit.contain,
    );
  }

  /// 입력 필드 섹션
  Widget _buildInputFieldsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이름 필드
        _buildInputField(
          label: '이름',
          controller: nameController,
          placeholder: '이름을 입력해 주세요.',
          validator: _validateName,
        ),
        SizedBox(height: 22.h),

        // 닉네임 필드
        _buildInputField(
          label: '닉네임',
          controller: nicknameController,
          placeholder: '닉네임을 입력해 주세요.',
          validator: _validateNickname,
        ),
        SizedBox(height: 22.h),

        // 이메일 필드
        _buildInputField(
          label: '이메일',
          controller: emailController,
          placeholder: '이메일을 입력해 주세요.',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        SizedBox(height: 22.h),

        // 비밀번호 필드
        _buildInputField(
          label: '비밀번호',
          controller: passwordController,
          placeholder: '비밀번호를 입력해 주세요.',
          obscureText: true,
          validator: _validatePassword,
        ),
        SizedBox(height: 22.h),

        // 비밀번호 확인 필드
        _buildInputField(
          label: '비밀번호 확인',
          controller: passwordConfirmController,
          placeholder: '비밀번호를 다시 입력해 주세요.',
          obscureText: true,
          validator: _validatePasswordConfirm,
        ),
      ],
    );
  }

  /// 개별 입력 필드 빌더 (레이블 + 입력 필드)
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.h),
          child: Text(
            label,
            style: TextStyleHelper.instance.body12MediumPretendard
                .copyWith(height: 1.0),
          ),
        ),
        SizedBox(height: 2.h),
        CustomTextFormField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 9.h),
        ),
      ],
    );
  }

  /// 회원가입 버튼
  Widget _buildRegisterButton(BuildContext context) {
    return CustomButton(
      text: '회원가입',
      onPressed: () => _onRegisterPressed(context),
      backgroundColor: appTheme.teal_400,
      textColor: appTheme.white_A700,
      width: double.infinity,
      height: 38.h,
      fontSize: 14.fSize,
      fontWeight: FontWeight.w700,
      borderRadius: 20.h,
      padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 10.h),
    );
  }

  /// 소셜 로그인 섹션
  Widget _buildSocialLoginSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: '카카오로 시작하기',
            onPressed: () => _onKakaoLoginPressed(context),
            backgroundColor: appTheme.yellow_A400,
            textColor: appTheme.gray_800,
            leftIcon: ImageConstant.imgGroup60,
            height: 36.h,
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
            borderRadius: 100.h,
            padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.h),
          ),
        ),
        SizedBox(width: 23.h),
        Expanded(
          child: CustomButton(
            text: '구글로 시작하기',
            onPressed: () => _onGoogleLoginPressed(context),
            backgroundColor: appTheme.white_A700,
            textColor: appTheme.gray_800,
            leftIcon: ImageConstant.imgGroup61,
            height: 36.h,
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
            borderRadius: 100.h,
            padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.h),
          ),
        ),
      ],
    );
  }

  // ==================== Validation Methods ====================

  /// 이름 검증
  String? _validateName(String? value) {
    if (value?.isEmpty ?? true) {
      return '이름을 입력해주세요';
    }

    if (value!.length < 2) {
      return '이름은 2자 이상 입력해주세요';
    }

    return null;
  }

  /// 닉네임 검증
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

  /// 이메일 검증
  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return '이메일을 입력해주세요';
    }

    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value!)) {
      return '올바른 이메일 형식을 입력해주세요';
    }

    return null;
  }

  /// 비밀번호 검증
  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return '비밀번호를 입력해주세요';
    }

    if (value!.length < 6) {
      return '비밀번호는 6자 이상 입력해주세요';
    }

    if (value.length > 20) {
      return '비밀번호는 20자 이하로 입력해주세요';
    }

    return null;
  }

  /// 비밀번호 확인 검증
  String? _validatePasswordConfirm(String? value) {
    if (value?.isEmpty ?? true) {
      return '비밀번호 확인을 입력해주세요';
    }

    if (value != passwordController.text) {
      return '비밀번호가 일치하지 않습니다';
    }

    return null;
  }

  // ==================== Button Handlers ====================

  /// 회원가입 버튼 핸들러
  void _onRegisterPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // Show loading state
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: appTheme.teal_400,
          ),
        ),
      );

      // Simulate registration process
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '회원가입이 완료되었습니다! 프로필을 설정해주세요.',
            ),
            backgroundColor: appTheme.teal_400,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to onboarding screen
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.onboardingScreen,
          );
        });
      });
    }
  }

  /// 카카오 로그인 버튼 핸들러
  void _onKakaoLoginPressed(BuildContext context) {
    // Show loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: appTheme.yellow_A400,
        ),
      ),
    );

    // Simulate Kakao registration process
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 회원가입 성공!'),
          backgroundColor: appTheme.yellow_A400,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to login screen
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.loginScreen,
              (route) => false,
        );
      });
    });
  }

  /// 구글 로그인 버튼 핸들러
  void _onGoogleLoginPressed(BuildContext context) {
    // Show loading state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: appTheme.blue_A200,
        ),
      ),
    );

    // Simulate Google registration process
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구글 회원가입 성공!'),
          backgroundColor: appTheme.blue_A200,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to login screen
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.loginScreen,
              (route) => false,
        );
      });
    });
  }
}