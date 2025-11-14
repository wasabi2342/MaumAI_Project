import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_text_form_field.dart';

/// LoginScreen - 로그인 화면 (Figma 디자인에 정확히 맞춤)
///
/// Figma 디자인 사양:
/// - 그라데이션: Color(0xFFE3FAE8) → Color(0xFFA0ECB1)
/// - 입력 필드 borderRadius: 20
/// - 로그인 버튼: height 38, borderRadius 20
/// - 소셜 로그인 버튼: height 36, borderRadius 100 (완전히 둥근 형태)
/// - 카카오 버튼 색상: Color(0xFFFFE812)
class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginScreen({Key? key}) : super(key: key);

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 46.h, vertical: 46.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogoSection(context),
                  SizedBox(height: 40.h),
                  _buildInputFieldsSection(context),
                  SizedBox(height: 28.h),
                  _buildLoginButton(context),
                  SizedBox(height: 26.h),
                  _buildForgotPasswordSection(context),
                  SizedBox(height: 18.h),
                  _buildSocialLoginSection(context),
                  SizedBox(height: 28.h),
                ],
              ),
            ),
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

  /// 입력 필드 섹션 (이메일, 비밀번호)
  Widget _buildInputFieldsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이메일 라벨
        Padding(
          padding: EdgeInsets.only(left: 10.h),
          child: Text(
            '이메일',
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
        // 이메일 입력 필드
        CustomTextFormField(
          controller: emailController,
          placeholder: '이메일을 입력해 주세요.',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h, // Figma 디자인: 20
          contentPadding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
          margin: EdgeInsets.only(top: 2.h),
        ),
        SizedBox(height: 18.h),
        // 비밀번호 라벨
        Padding(
          padding: EdgeInsets.only(left: 10.h),
          child: Text(
            '비밀번호',
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
        // 비밀번호 입력 필드
        CustomTextFormField(
          controller: passwordController,
          placeholder: '비밀번호를 입력해 주세요.',
          obscureText: true,
          validator: _validatePassword,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h, // Figma 디자인: 20
          contentPadding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
          margin: EdgeInsets.only(top: 2.h),
        ),
      ],
    );
  }

  /// 로그인 버튼
  Widget _buildLoginButton(BuildContext context) {
    return CustomButton(
      text: '로그인',
      onPressed: () => _onLoginPressed(context),
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

  /// 아이디 찾기 / 회원가입 섹션
  Widget _buildForgotPasswordSection(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '아이디 찾기 / ',
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 12.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.30,
              ),
            ),
            TextSpan(
              text: '회원가입',
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 12.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.30,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, AppRoutes.registerScreen);
                },
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
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
            textColor: Color(0xFF3B3B3B),
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
            textColor: Color(0xFF3B3B3B),
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

  /// 이메일 유효성 검사
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

  /// 비밀번호 유효성 검사
  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return '비밀번호를 입력해주세요';
    }

    if (value!.length < 6) {
      return '비밀번호는 6자 이상 입력해주세요';
    }

    return null;
  }

  /// 로그인 버튼 클릭 이벤트
  void _onLoginPressed(BuildContext context) {
    // 마스터 계정 체크
    if (emailController.text == '1111@naver.com' &&
        passwordController.text == '111111') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('마스터 계정으로 로그인합니다.'),
          backgroundColor: appTheme.teal_400,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.homeScreen, (route) => false);
      return;
    }

    // 폼 유효성 검사
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

      // 로그인 프로세스 시뮬레이션
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 성공!'),
            backgroundColor: appTheme.teal_400,
            duration: Duration(seconds: 2),
          ),
        );

        // 입력 필드 초기화
        emailController.clear();
        passwordController.clear();
      });
    }
  }

  /// 카카오 로그인 버튼 클릭 이벤트
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

    // 카카오 로그인 프로세스 시뮬레이션
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 로그인 성공!'),
          backgroundColor: Color(0xFFFFE812),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  /// 구글 로그인 버튼 클릭 이벤트
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

    // 구글 로그인 프로세스 시뮬레이션
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구글 로그인 성공!'),
          backgroundColor: appTheme.blue_A200,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}