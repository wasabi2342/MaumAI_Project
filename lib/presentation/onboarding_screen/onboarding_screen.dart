import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_dropdown.dart';
import '../../services/api_service.dart';

/// OnboardingScreen - 첫 로그인 시 개인정보 입력 화면
///
/// 3단계 프로세스:
/// 1. 직업 선택 (학생, 회사원, 주부, 기타)
/// 2. 나이 입력
/// 3. 성별 선택 (남성, 여성, 기타)
///
/// 기능:
/// - PageView를 이용한 단계별 화면 전환
/// - 페이지 인디케이터
/// - 이전/다음 버튼
/// - 입력 검증
/// - 데이터 저장 후 메인 화면 이동
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _ageController = TextEditingController();

  int _currentPage = 0;
  String? _selectedOccupation;
  String? _selectedGender;

  // 직업 목록
  final List<String> _occupations = ['학생', '회사원', '주부', '기타'];

  // 성별 목록
  final List<String> _genders = ['남성', '여성', '기타'];

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToNextPage() {
    if (_currentPage < 2) {
      // 현재 페이지 검증
      if (!_validateCurrentPage()) {
        return;
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 페이지: 온보딩 완료
      _completeOnboarding();
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // 직업 선택
        if (_selectedOccupation == null) {
          _showErrorSnackBar('직업을 선택해주세요');
          return false;
        }
        return true;

      case 1: // 나이 입력
        if (_ageController.text.isEmpty) {
          _showErrorSnackBar('나이를 입력해주세요');
          return false;
        }

        int? age = int.tryParse(_ageController.text);
        if (age == null || age < 1 || age > 120) {
          _showErrorSnackBar('올바른 나이를 입력해주세요 (1-120)');
          return false;
        }
        return true;

      case 2: // 성별 선택
        if (_selectedGender == null) {
          _showErrorSnackBar('성별을 선택해주세요');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appTheme.redCustom,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _completeOnboarding() async {
    // 로그인된 사용자 ID 확인
    if (ApiService.currentUserId == null) {
      _showErrorSnackBar('사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
            (route) => false,
      );
      return;
    }

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
      // API 호출: 프로필 업데이트
      final response = await ApiService.updateProfile(
        userId: ApiService.currentUserId!,
        job: _selectedOccupation,
        age: int.tryParse(_ageController.text),
        gender: _selectedGender,
      );

      print('프로필 업데이트 성공: $response');

      // 로딩 닫기
      Navigator.of(context).pop();

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('프로필 설정이 완료되었습니다!'),
          backgroundColor: appTheme.teal_400,
          duration: const Duration(seconds: 2),
        ),
      );

      // 가이드 화면으로 이동
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.guideScreen,
        );
      });
    } catch (e) {
      // 로딩 닫기
      Navigator.of(context).pop();

      // 에러 메시지
      String errorMessage;
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage = '서버에 연결할 수 없습니다.\n네트워크 연결을 확인해주세요.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = '서버 응답 시간이 초과되었습니다.';
      } else {
        errorMessage = '프로필 업데이트에 실패했습니다.\n잠시 후 다시 시도해주세요.';
      }

      _showErrorSnackBar(errorMessage);
      print('프로필 업데이트 실패: $e');

      // 실패해도 다음 화면으로 진행할지 물어보기
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.h),
          ),
          title: Text(
            '프로필 업데이트 실패',
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 16.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            '프로필 정보 저장에 실패했습니다.\n나중에 마이페이지에서 수정할 수 있습니다.\n\n계속 진행하시겠습니까?',
            style: TextStyle(
              color: Color(0xFF3B3B3B),
              fontSize: 14.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '재시도',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.guideScreen,
                );
              },
              child: Text(
                '계속',
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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const NeverScrollableScrollPhysics(), // 스와이프 비활성화
                children: [
                  _buildOccupationPage(),
                  _buildAgePage(),
                  _buildGenderPage(),
                ],
              ),
            ),
            _buildNavigationSection(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  /// 1단계: 직업 선택 페이지
  Widget _buildOccupationPage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 46.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoSection(),
          SizedBox(height: 90.h),
          Text(
            '직업을 선택해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 26.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 28.h),
          CustomDropdown(
            placeholder: '직업을 선택해 주세요.',
            items: _occupations,
            selectedItem: _selectedOccupation,
            onChanged: (value) {
              setState(() {
                _selectedOccupation = value;
              });
            },
            borderRadius: 20.h,
          ),
          SizedBox(height: 309.h),
        ],
      ),
    );
  }

  /// 2단계: 나이 입력 페이지
  Widget _buildAgePage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 46.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoSection(),
          SizedBox(height: 90.h),
          Text(
            '나이를 입력해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 26.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 28.h),
          SizedBox(
            width: 185.h,
            child: CustomTextFormField(
              controller: _ageController,
              placeholder: '나이를 입력해 주세요.',
              keyboardType: TextInputType.number,
              textStyle: TextStyleHelper.instance.body14RegularPretendard.copyWith(
                color: appTheme.gray_800,
              ),
              fillColor: appTheme.white_A700,
              borderColor: appTheme.color66D3D3,
              focusedBorderColor: appTheme.colorFF66D3,
              borderRadius: 20.h,
              contentPadding: EdgeInsets.symmetric(horizontal: 15.h, vertical: 8.h),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 15.h),
                child: Center(
                  widthFactor: 0.0,
                  child: Text(
                    '세',
                    style: TextStyleHelper.instance.body14RegularPretendard
                        .copyWith(color: appTheme.blue_gray_100),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 200.h),
        ],
      ),
    );
  }

  /// 3단계: 성별 선택 페이지
  Widget _buildGenderPage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 46.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLogoSection(),
          SizedBox(height: 90.h),
          Text(
            '성별을 선택해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 26.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 28.h),
          CustomDropdown(
            placeholder: '성별을 선택해 주세요.',
            items: _genders,
            selectedItem: _selectedGender,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            borderRadius: 20.h,
          ),
          SizedBox(height: 200.h),
        ],
      ),
    );
  }

  /// 로고 섹션 (로고에 이미 "베란다 농부" 텍스트 포함)
  Widget _buildLogoSection() {
    return CustomImageView(
      imagePath: ImageConstant.img,
      height: 63.h,
      width: 280.h,  // 로고 + 텍스트를 포함한 전체 너비
      fit: BoxFit.contain,
    );
  }

  /// 네비게이션 섹션 (이전/다음 버튼, 페이지 인디케이터)
  Widget _buildNavigationSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 23.h),
      child: Column(
        children: [
          // 이전/다음 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 이전 버튼
              InkWell(
                onTap: _currentPage > 0 ? _goToPreviousPage : null,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 12.h,
                      color: _currentPage > 0
                          ? appTheme.blue_gray_100
                          : appTheme.blue_gray_100.withOpacity(0.3),
                    ),
                    SizedBox(width: 5.h),
                    Text(
                      '이전',
                      style: TextStyle(
                        color: _currentPage > 0
                            ? appTheme.blue_gray_100
                            : appTheme.blue_gray_100.withOpacity(0.3),
                        fontSize: 12.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // 다음 버튼
              InkWell(
                onTap: _goToNextPage,
                child: Row(
                  children: [
                    Text(
                      _currentPage < 2 ? '다음' : '완료',
                      style: TextStyle(
                        color: appTheme.teal_400,
                        fontSize: 12.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 5.h),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12.h,
                      color: appTheme.teal_400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.5.h),
          // 페이지 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 11.h),
                width: 8.h,
                height: 8.h,
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? appTheme.teal_400
                      : appTheme.green_200,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}