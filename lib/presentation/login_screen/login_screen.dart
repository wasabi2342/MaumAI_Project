import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_text_form_field.dart';

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
              Color(0xFFE3FAE8),
              appTheme.green_200,
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

  Widget _buildLogoSection(BuildContext context) {
    return CustomImageView(
      imagePath: ImageConstant.img,
      height: 120.h,
      width: 300.h,  // 로고 + 텍스트를 포함한 전체 너비
      fit: BoxFit.contain,
    );
  }

  Widget _buildInputFieldsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.h),
          child: Text(
            '이메일',
            style: TextStyleHelper.instance.body12MediumPretendard
                .copyWith(height: 1.25),
          ),
        ),
        CustomTextFormField(
          controller: emailController,
          placeholder: '이메일을 입력해 주세요.',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 16.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
          margin: EdgeInsets.only(top: 2.h),
        ),
        SizedBox(height: 18.h),
        Padding(
          padding: EdgeInsets.only(left: 10.h),
          child: Text(
            '비밀번호',
            style: TextStyleHelper.instance.body12MediumPretendard
                .copyWith(height: 1.25),
          ),
        ),
        CustomTextFormField(
          controller: passwordController,
          placeholder: '비밀번호를 입력해 주세요.',
          obscureText: true,
          validator: _validatePassword,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 16.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 8.h),
          margin: EdgeInsets.only(top: 2.h),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return CustomButton(
      text: '로그인',
      onPressed: () => _onLoginPressed(context),
      backgroundColor: appTheme.teal_400,
      textColor: appTheme.white_A700,
      width: double.infinity,
      height: 48.h,
      fontSize: 14.fSize,
      fontWeight: FontWeight.w700,
      borderRadius: 18.h,
      padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 10.h),
    );
  }

  Widget _buildForgotPasswordSection(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '아이디 찾기 / ',
              style: TextStyleHelper.instance.body12MediumPretendard
                  .copyWith(height: 1.25),
            ),
            TextSpan(
              text: '회원가입',
              style: TextStyleHelper.instance.body12MediumPretendard
                  .copyWith(
                    height: 1.25,
                    decoration: TextDecoration.underline,
                  ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushNamed(context, AppRoutes.registerScreen);
                },
            ),
          ],
        ),
      ),
    );
  }

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
            height: 48.h,
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
            borderRadius: 18.h,
            padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.h),
          ),
        ),
        SizedBox(width: 22.h),
        Expanded(
          child: CustomButton(
            text: '구글로 시작하기',
            onPressed: () => _onGoogleLoginPressed(context),
            backgroundColor: appTheme.white_A700,
            textColor: appTheme.gray_800,
            leftIcon: ImageConstant.imgGroup61,
            height: 48.h,
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
            borderRadius: 18.h,
            padding: EdgeInsets.symmetric(horizontal: 22.h, vertical: 8.h),
          ),
        ),
      ],
    );
  }

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

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return '비밀번호를 입력해주세요';
    }

    if (value!.length < 6) {
      return '비밀번호는 6자 이상 입력해주세요';
    }

    return null;
  }

  void _onLoginPressed(BuildContext context) {
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

      // Simulate login process
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close loading dialog

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 성공!'),
            backgroundColor: appTheme.teal_400,
            duration: Duration(seconds: 2),
          ),
        );

        // Clear form fields
        emailController.clear();
        passwordController.clear();
      });
    }
  }

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

    // Simulate Kakao login process
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 로그인 성공!'),
          backgroundColor: appTheme.yellow_A400,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

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

    // Simulate Google login process
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog

      // Show success message
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
