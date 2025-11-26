import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class RegisterScreen extends StatelessWidget {
  // 백엔드 명세에 맞춰 '이름(name)' 컨트롤러 제거
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3FAE8),
              Color(0xFFA0ECB1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 56.h),
                    _buildHeader(),
                    SizedBox(height: 32.h),
                    _buildInputFields(),
                    SizedBox(height: 20.h),
                    _buildRegisterButton(context),
                    SizedBox(height: 16.h),
                    _buildOrDivider(),
                    SizedBox(height: 16.h),
                    _buildSocialLoginSection(context),
                    SizedBox(height: 20.h),
                    _buildLoginLink(context),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomImageView(
          imagePath: ImageConstant.img,
          width: 200.h,
          alignment: Alignment.center,
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [수정] '이름' 입력 필드 제거됨 (백엔드 요청 DTO에 없음)

        // 닉네임
        _buildInputLabel('닉네임'),
        SizedBox(height: 10.h),
        CustomTextFormField(
          controller: nicknameController,
          placeholder: '닉네임을 입력해 주세요.',
          validator: _validateNickname,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 8.h),
          margin: EdgeInsets.zero,
        ),
        SizedBox(height: 18.h),

        // 이메일
        _buildInputLabel('이메일'),
        SizedBox(height: 10.h),
        CustomTextFormField(
          controller: emailController,
          placeholder: '이메일을 입력해 주세요.',
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 8.h),
          margin: EdgeInsets.zero,
        ),
        SizedBox(height: 18.h),

        // 비밀번호
        _buildInputLabel('비밀번호'),
        SizedBox(height: 10.h),
        CustomTextFormField(
          controller: passwordController,
          placeholder: '비밀번호를 입력해 주세요.',
          obscureText: true,
          validator: _validatePassword,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 8.h),
          margin: EdgeInsets.zero,
        ),
        SizedBox(height: 18.h),

        // 비밀번호 확인
        _buildInputLabel('비밀번호 확인'),
        SizedBox(height: 10.h),
        CustomTextFormField(
          controller: confirmPasswordController,
          placeholder: '비밀번호를 다시 입력해 주세요.',
          obscureText: true,
          validator: _validateConfirmPassword,
          fillColor: appTheme.white_A700,
          borderColor: appTheme.color66D3D3,
          focusedBorderColor: appTheme.colorFF66D3,
          borderRadius: 20.h,
          contentPadding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 8.h),
          margin: EdgeInsets.zero,
        ),
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

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: appTheme.color66D3D3,
            thickness: 1.h,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.h),
          child: Text(
            'or',
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
        Expanded(
          child: Divider(
            color: appTheme.color66D3D3,
            thickness: 1.h,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: '카카오로 시작하기',
            onPressed: () => _onKakaoLoginPressed(context),
            backgroundColor: Color(0xFFFFE812),
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

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '이미 계정이 있으신가요? ',
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
              text: '로그인',
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 12.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: -0.30,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pop(context);
                },
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ==================== Validation Methods ====================

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

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (value != passwordController.text) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  // ==================== Button Actions ====================

  /// 회원가입 버튼 클릭
  void _onRegisterPressed(BuildContext context) async {
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
        // [백엔드 연동]
        // UserSignupRequest에 맞춰 nickname, email, password, passwordConfirm 전송
        final result = await ApiService.signup(
          nickname: nicknameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          passwordConfirm: confirmPasswordController.text,
          // job, age, gender는 선택사항이며 이 화면에서는 받지 않음 (null 처리)
        );

        // 결과 파싱
        final userProfile = UserProfile.fromJson(result);

        // 로딩 닫기
        Navigator.of(context).pop();

        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${userProfile.nickname}님, 환영합니다!'),
            backgroundColor: appTheme.teal_400,
            duration: Duration(seconds: 2),
          ),
        );

        // 회원가입 성공 시 온보딩(또는 홈)으로 이동
        // 뒤로가기 방지를 위해 removeUntil 사용
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.onboardingScreen,
              (route) => false,
        );
      } catch (e) {
        // 로딩 닫기
        Navigator.of(context).pop();

        // 에러 처리
        String errorMessage = '회원가입에 실패했습니다.';
        String errorStr = e.toString();

        if (errorStr.contains('이미') || errorStr.contains('exists')) {
          errorMessage = '이미 사용 중인 이메일 또는 닉네임입니다.';
        } else if (errorStr.contains('SocketException')) {
          errorMessage = '서버와 연결할 수 없습니다. 네트워크를 확인해주세요.';
        } else if (errorStr.contains('Timeout')) {
          errorMessage = '서버 응답이 지연되고 있습니다.';
        }

        // 에러 다이얼로그 표시
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.h),
            ),
            title: Text(
              '회원가입 실패',
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              errorMessage,
              style: TextStyle(color: Color(0xFF3B3B3B)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: appTheme.teal_400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  void _onKakaoLoginPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('준비 중인 기능입니다.')),
    );
  }

  void _onGoogleLoginPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('준비 중인 기능입니다.')),
    );
  }
}