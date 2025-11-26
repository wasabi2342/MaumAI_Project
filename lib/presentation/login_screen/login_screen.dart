import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async'; // TimeoutException 처리를 위해 필요

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

/// LoginScreen - 로그인 화면
///
/// 기능:
/// - 이메일/비밀번호 입력
/// - 로그인 API 연동 (ApiService.login)
/// - 로그인 성공 시:
///   1. 등록된 식물(기기)이 있는지 확인 (getUserPlants)
///   2. 없으면 -> 기기 선택 화면(DeviceSelectionScreen)으로 이동
///   3. 있으면 -> 홈 화면(HomeScreen)으로 이동
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
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3FAE8), // Figma 디자인 색상
              Color(0xFFA0ECB1), // Figma 디자인 색상
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 46.h, vertical: 46.h),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 100.h), // 상단 여백
                    _buildLogoSection(context),
                    SizedBox(height: 48.h),
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
      ),
    );
  }

  /// 로고 섹션
  Widget _buildLogoSection(BuildContext context) {
    return CustomImageView(
      imagePath: ImageConstant.img,
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
        SizedBox(height: 8.h),
        // 이메일 입력 필드
        CustomTextFormField(
          controller: emailController,
          placeholder: '이메일을 입력해 주세요.',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
          margin: EdgeInsets.only(top: 2.h),
        ),
        SizedBox(height: 12.h),
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
        SizedBox(height: 8.h),
        // 비밀번호 입력 필드
        CustomTextFormField(
          controller: passwordController,
          placeholder: '비밀번호를 입력해 주세요.',
          obscureText: true,
          validator: _validatePassword,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
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
      height: 38.h,
      fontSize: 14.fSize,
      fontWeight: FontWeight.w700,
      borderRadius: 20.h,
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
            backgroundColor: Color(0xFFFFE812), // 카카오 옐로우
            textColor: Color(0xFF3B3B3B),
            leftIcon: ImageConstant.imgGroup60,
            height: 36.h,
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
            borderRadius: 100.h,
            padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 6.h),
          ),
        ),
        SizedBox(width: 23.h),
        // 구글 로그인 버튼
        Expanded(
          child: CustomButton(
            text: '구글로 시작하기',
            onPressed: () => _onGoogleLoginPressed(context),
            backgroundColor: appTheme.white_A700,
            textColor: Color(0xFF3B3B3B),
            leftIcon: ImageConstant.imgGroup61,
            height: 36.h,
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
            borderRadius: 100.h,
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

  /// [수정됨] 로그인 버튼 클릭 이벤트
  void _onLoginPressed(BuildContext context) async {
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

      try {
        // 1. 로그인 API 호출
        final result = await ApiService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        // 응답 데이터를 UserProfile 모델로 변환
        final userProfile = UserProfile.fromJson(result);

        // 2. [시나리오 반영] 등록된 기기(식물) 여부 확인
        // 로그인 직후 사용자의 식물 목록을 조회하여 분기 처리
        final userPlants = await ApiService.getUserPlants(userProfile.id);

        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${userProfile.nickname}님, 환영합니다!'),
            backgroundColor: appTheme.teal_400,
            duration: Duration(seconds: 2),
          ),
        );

        if (userPlants.isEmpty) {
          // CASE A: 등록된 기기가 없음 -> 기기 선택 화면으로 이동 (Device Unregistered User)
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.deviceSelectionScreen, (route) => false);
        } else {
          // CASE B: 등록된 기기가 있음 -> 홈 화면으로 이동 (Existing User)
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.homeScreen, (route) => false);
        }

      } catch (e) {
        // 로딩 다이얼로그 닫기 (에러 발생 시)
        Navigator.of(context).pop();

        // 에러 메시지 변환
        String errorMessage;
        String errorStr = e.toString();

        if (errorStr.contains('이메일') || errorStr.contains('비밀번호') || errorStr.contains('Bad credentials')) {
          errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
        } else if (errorStr.contains('SocketException') ||
            errorStr.contains('Connection refused') ||
            errorStr.contains('Failed host lookup')) {
          errorMessage = '서버에 연결할 수 없습니다.\n네트워크 연결을 확인해주세요.';
        } else if (errorStr.contains('TimeoutException')) {
          errorMessage = '서버 응답 시간이 초과되었습니다.';
        } else {
          errorMessage = '로그인에 실패했습니다.\n잠시 후 다시 시도해주세요.';
        }

        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 카카오 로그인 버튼 클릭 이벤트 (더미)
  void _onKakaoLoginPressed(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFE812),
        ),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 로그인 기능은 준비 중입니다.'),
          backgroundColor: Color(0xFFFFE812),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  /// 구글 로그인 버튼 클릭 이벤트 (더미)
  void _onGoogleLoginPressed(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: appTheme.blue_A200,
        ),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('구글 로그인 기능은 준비 중입니다.'),
          backgroundColor: appTheme.blue_A200,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}