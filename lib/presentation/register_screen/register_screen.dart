import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_text_form_field.dart';

/// RegisterScreen - 회원가입 화면 (Figma 디자인에 정확히 맞춤)
///
/// Figma 디자인 사양:
/// - 그라데이션: Color(0xFFE3FAE8) → Color(0xFFA0ECB1)
/// - 입력 필드 borderRadius: 20, height: 34
/// - 필드 간격: 22
/// - 회원가입 버튼: height 38, borderRadius 20
/// - 소셜 로그인 버튼: height 36, borderRadius 100 (완전히 둥근 형태)
/// - 카카오 버튼 색상: Color(0xFFFFE812)
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
              Color(0xFFE3FAE8), // Figma 디자인
              Color(0xFFA0ECB1), // Figma 디자인
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

  /// 로고 섹션
  Widget _buildLogoSection(BuildContext context) {
    return CustomImageView(
      imagePath: ImageConstant.img,
      height: 63.h, // Figma 디자인: height 63
      width: 230.h, // 로고 + 텍스트를 포함한 전체 너비
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
        SizedBox(height: 22.h), // Figma 디자인: 22

        // 닉네임 필드
        _buildInputField(
          label: '닉네임',
          controller: nicknameController,
          placeholder: '닉네임을 입력해 주세요.',
          validator: _validateNickname,
        ),
        SizedBox(height: 22.h), // Figma 디자인: 22

        // 이메일 필드
        _buildInputField(
          label: '이메일',
          controller: emailController,
          placeholder: '이메일을 입력해 주세요.',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        SizedBox(height: 22.h), // Figma 디자인: 22

        // 비밀번호 필드
        _buildInputField(
          label: '비밀번호',
          controller: passwordController,
          placeholder: '비밀번호를 입력해 주세요.',
          obscureText: true,
          validator: _validatePassword,
        ),
        SizedBox(height: 22.h), // Figma 디자인: 22

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
        // 라벨
        Padding(
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
        ),
        SizedBox(height: 2.h),
        // 입력 필드
        CustomTextFormField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h, // Figma 디자인: 20
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
      height: 38.h, // Figma 디자인: 38
      fontSize: 14.fSize,
      fontWeight: FontWeight.w700,
      borderRadius: 20.h, // Figma 디자인: 20
      padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 10.h),
    );
  }

  /// 소셜 로그인 섹션 (카카오, 구글)
  Widget _buildSocialLoginSection(BuildContext context) {
    return Row(
      children: [
        // 카카오 로그인 버튼
        Expanded(
          child: CustomButton(
            text: '카카오로 시작하기',
            onPressed: () => _onKakaoLoginPressed(context),
            backgroundColor: Color(0xFFFFE812), // Figma 디자인: 정확한 카카오 옐로우
            textColor: Color(0xFF3B3B3B), // Figma 디자인
            leftIcon: ImageConstant.imgGroup60,
            height: 36.h, // Figma 디자인: 36
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
            borderRadius: 100.h, // Figma 디자인: 100 (완전히 둥근 형태)
            padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 6.h),
          ),
        ),
        SizedBox(width: 23.h), // Figma 디자인: 23
        // 구글 로그인 버튼
        Expanded(
          child: CustomButton(
            text: '구글로 시작하기',
            onPressed: () => _onGoogleLoginPressed(context),
            backgroundColor: appTheme.white_A700,
            textColor: Color(0xFF3B3B3B), // Figma 디자인
            leftIcon: ImageConstant.imgGroup61,
            height: 36.h, // Figma 디자인: 36
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
            borderRadius: 100.h, // Figma 디자인: 100 (완전히 둥근 형태)
            padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 6.h),
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
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: appTheme.teal_400,
          ),
        ),
      );

      // 회원가입 프로세스 시뮬레이션
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '회원가입이 완료되었습니다! 프로필을 설정해주세요.',
            ),
            backgroundColor: appTheme.teal_400,
            duration: Duration(seconds: 2),
          ),
        );

        // 온보딩 화면으로 이동
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
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFE812),
        ),
      ),
    );

    // 카카오 회원가입 프로세스 시뮬레이션
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 회원가입 성공!'),
          backgroundColor: Color(0xFFFFE812),
          duration: Duration(seconds: 2),
        ),
      );

      // 로그인 화면으로 이동
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
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: appTheme.blue_A200,
        ),
      ),
    );

    // 구글 회원가입 프로세스 시뮬레이션
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구글 회원가입 성공!'),
          backgroundColor: appTheme.blue_A200,
          duration: Duration(seconds: 2),
        ),
      );

      // 로그인 화면으로 이동
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.loginScreen,
              (route) => false,
        );
      });
    });
  }
}