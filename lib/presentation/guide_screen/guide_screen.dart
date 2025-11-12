import 'package:flutter/material.dart';

import '../../core/app_export.dart';

/// GuideScreen - 앱 사용 가이드 화면
///
/// 기능:
/// - 7페이지 가이드 슬라이드
/// - PageView를 통한 스와이프 네비게이션
/// - 페이지 인디케이터
/// - 이전/다음 버튼
/// - 각 페이지별 가이드 콘텐츠 표시
class GuideScreen extends StatefulWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // 가이드 페이지 데이터
  final List<GuidePageData> _guidePages = [
    GuidePageData(
      title: 'AI를 이용한 식물관리',
      description: '인공지능 기술로 식물의 상태를 분석하고\n최적의 관리 방법을 제안합니다.\n건강한 식물 재배를 경험해보세요.',
    ),
    GuidePageData(
      title: '스마트 센서 연동',
      description: '온도, 습도, 조도 센서가\n식물의 생육 환경을 실시간으로 모니터링합니다.\n언제 어디서나 확인하세요.',
    ),
    GuidePageData(
      title: '자동 물주기',
      description: '토양 수분 센서와 연동하여\n필요할 때 자동으로 물을 공급합니다.\n더 이상 물주기를 잊지 마세요.',
    ),
    GuidePageData(
      title: '성장 일지',
      description: '식물의 성장 과정을 사진과 함께\n기록하고 관리할 수 있습니다.\n나만의 재배 일지를 만들어보세요.',
    ),
    GuidePageData(
      title: '커뮤니티',
      description: '다른 사용자들과 재배 노하우를 공유하고\n질문과 답변을 통해 함께 성장합니다.\n베란다 농부 커뮤니티에 참여하세요.',
    ),
    GuidePageData(
      title: '식물 진단',
      description: '잎의 상태를 사진으로 촬영하면\nAI가 질병과 해충을 진단합니다.\n빠른 대처로 식물을 지키세요.',
    ),
    GuidePageData(
      title: '재배 가이드',
      description: '각 식물별 최적의 재배 환경과\n관리 방법을 상세히 안내합니다.\n초보자도 쉽게 시작할 수 있습니다.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _goToNextPage() {
    if (_currentPage < _guidePages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 페이지: 기기 연결 화면으로 이동
      Navigator.pushReplacementNamed(context, AppRoutes.deviceConnectionScreen);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopTab(),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _guidePages.length,
                      itemBuilder: (context, index) {
                        return _buildGuidePage(_guidePages[index]);
                      },
                    ),
                  ),
                  _buildNavigationSection(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상단 탭 (가이드)
  Widget _buildTopTab() {
    return Container(
      width: 185.h,
      height: 36.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appTheme.green_200,
            appTheme.green_200.withOpacity(0),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.h),
          bottomRight: Radius.circular(50.h),
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.teal_400.withOpacity(0.36),
            blurRadius: 4.h,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '가이드',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appTheme.white_A700,
            fontSize: 16.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            height: 1.31,
          ),
        ),
      ),
    );
  }

  /// 가이드 페이지 콘텐츠
  Widget _buildGuidePage(GuidePageData data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 46.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 80.h),
          // 페이지 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_guidePages.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8.h),
                width: 8.h,
                height: 8.h,
                decoration: BoxDecoration(
                  color: index <= _currentPage
                      ? appTheme.teal_400
                      : appTheme.green_200,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          SizedBox(height: 20.h),
          // 가이드 제목 버튼
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
            decoration: BoxDecoration(
              color: appTheme.white_A700,
              borderRadius: BorderRadius.circular(50.h),
              boxShadow: [
                BoxShadow(
                  color: appTheme.color66D3D3,
                  blurRadius: 8.h,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
          ),
          SizedBox(height: 35.h),
          // 가이드 설명
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF797979),
              fontSize: 16.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  /// 네비게이션 섹션 (이전/다음 버튼)
  Widget _buildNavigationSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 23.h),
      child: Row(
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
                  _currentPage < _guidePages.length - 1 ? '다음' : '완료',
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
    );
  }
}

/// 가이드 페이지 데이터 모델
class GuidePageData {
  final String title;
  final String description;

  GuidePageData({
    required this.title,
    required this.description,
  });
}
