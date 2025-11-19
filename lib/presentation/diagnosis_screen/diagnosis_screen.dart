import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_top_tab.dart';
import '../../widgets/notification_sidebar.dart';

/// DiagnosisScreen - AI 식물 진단 화면
///
/// 수정 사항:
/// - 상단 초록색 영역 하단에 그림자(BoxShadow) 추가
/// - 하단 영역의 배경색을 투명으로 변경하여 그림자가 가려지지 않도록 처리 (Scaffold 배경색이 흰색이라 흰색으로 보임)
class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  // 진단 결과 데이터
  final DiagnosisResult _diagnosisResult = DiagnosisResult(
    healthStatus: '식물상태가 양호',
    healthAdvice: '현재환경을 유지하세요',
    pestStatus: '해충이 발견되지 않았습니다',
    pestAdvice: '모든 잎을 제거하세요',
    harvestDate: DateTime(2025, 11, 16),
  );

  // 자주 묻는 질문 목록
  final List<FaqItem> _faqItems = [
    FaqItem(question: '언제 수확 하나요?'),
    FaqItem(question: '양액은 언제 넣나요?'),
    FaqItem(question: '언제 수확 하나요?'),
    FaqItem(question: '언제 수확 하나요?'),
    FaqItem(question: '언제 수확 하나요?'),
    FaqItem(question: '언제 수확 하나요?'),
    FaqItem(question: '언제 수확 하나요?'),
    FaqItem(question: '언제 수확 하나요?'),
  ];

  void _capturePhoto() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: appTheme.white_A700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.h),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt, color: appTheme.teal_400, size: 48.h),
              SizedBox(height: 16.h),
              Text(
                'AI 식물 진단',
                style: TextStyle(
                  color: appTheme.gray_800,
                  fontSize: 18.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '식물의 상태를 촬영하여\nAI 진단을 시작합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF797979),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '확인',
                style: TextStyle(
                  color: appTheme.teal_400,
                  fontSize: 16.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSidebar(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Color(0x3FD9D9D9),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return NotificationSidebar(
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 393.h),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: false,
                  elevation: 0,
                  backgroundColor: appTheme.green_50,
                  automaticallyImplyLeading: false,
                  title: CustomImageView(
                    imagePath: ImageConstant.img,
                    height: 28.h,
                    fit: BoxFit.contain,
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: () => _showNotificationSidebar(context),
                      icon: Icon(
                        Icons.notifications_none_outlined,
                        color: appTheme.blue_gray_700,
                        size: 28.h,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.myPageScreen),
                      icon: Icon(
                        Icons.person_outline,
                        color: appTheme.blue_gray_700,
                        size: 28.h,
                      ),
                    ),
                    SizedBox(width: 16.h),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // 1. 상단 초록색 배경 영역 (사진 촬영까지) + 그림자 추가
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: appTheme.green_50,
                          // [수정] 하단 경계선에 그림자 추가
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05), // 은은한 그림자 색상
                              blurRadius: 20.h, // 그림자 퍼짐 정도
                              offset: Offset(0, 10.h), // 그림자 위치 (아래쪽으로)
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CustomTopTab(text: '진단'),
                            SizedBox(height: 12.h),
                            _buildTimeAnalysisLabel(),
                            SizedBox(height: 16.h),
                            _buildPhotoAnalysisSection(),
                            // 초록색 배경 끝
                          ],
                        ),
                      ),

                      // 2. 하단 흰색 배경 영역 (건강체크부터 끝까지)
                      // [수정] color를 제거하여 투명하게 만듦 (상단 그림자가 보이도록)
                      Container(
                        width: double.infinity,
                        // color: appTheme.white_A700, // <-- 제거됨 (Scaffold 배경이 흰색이므로 투명이어도 흰색으로 보임)
                        child: Column(
                          children: [
                            // 상단 그림자가 보일 수 있도록 충분한 여백
                            SizedBox(height: 30.h),
                            _buildDiagnosisCardsRow(),
                            SizedBox(height: 16.h),
                            _buildHarvestPredictionCard(),
                            SizedBox(height: 16.h),
                            _buildFaqSection(),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.diagnosisScreen,
      ),
    );
  }
  Widget _buildTimeAnalysisLabel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding:
        EdgeInsets.only(top: 4.h, left: 17.h, right: 20.h, bottom: 4.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFFDFEFB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.h),
              bottomRight: Radius.circular(20.h),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '사진분석',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF32C697),
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAnalysisSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      height: 167.h,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFBFEF9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.h),
            topRight: Radius.circular(20.h),
          ),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x66D3D3D3),
            blurRadius: 8.h,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: _capturePhoto,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 40.h, color: const Color(0xFF32C697)),
              SizedBox(height: 10.h),
              Text(
                '사진 촬영',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF32C697),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  letterSpacing: -0.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisCardsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        children: [
          Expanded(child: _buildHealthCheckCard()),
          SizedBox(width: 21.h),
          Expanded(child: _buildPestDiagnosisCard()),
        ],
      ),
    );
  }

  Widget _buildHealthCheckCard() {
    return Container(
      width: 142.h,
      height: 202.h,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFBFEF9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.h),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x66D3D3D3),
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 36.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [appTheme.green_200, appTheme.teal_400],
              ),
            ),
            child: Center(
              child: Text(
                '건강체크',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFFDFEFB),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  letterSpacing: -0.35,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    left: 10.h, top: 15.h, right: 10.h, bottom: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        _diagnosisResult.healthStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: Text(
                        _diagnosisResult.healthAdvice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPestDiagnosisCard() {
    return Container(
      width: 198.h,
      height: 202.h,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFBFEF9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.h),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x66D3D3D3),
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 36.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [appTheme.green_200, appTheme.teal_400],
              ),
            ),
            child: Center(
              child: Text(
                '병해충 진단',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFFDFEFB),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  letterSpacing: -0.35,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    left: 16.h, top: 15.h, right: 16.h, bottom: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _diagnosisResult.pestStatus,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF797979),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      _diagnosisResult.pestAdvice,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF797979),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestPredictionCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Container(
        width: double.infinity,
        height: 99.h,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFFBFEF9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.h),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0x66D3D3D3),
              blurRadius: 8.h,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 36.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE3FAE8),
              ),
              child: Center(
                child: Text(
                  '수확시기 예측',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF32C697),
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 18.h, top: 15.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 예상 수확일',
                      style: TextStyle(
                        color: const Color(0xFF797979),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${_diagnosisResult.harvestDate.year}. ${_diagnosisResult.harvestDate.month} / ${_diagnosisResult.harvestDate.day}',
                      style: TextStyle(
                        color: const Color(0xFF797979),
                        fontSize: 10.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Container(
        width: 360.h,
        height: 330.h,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFFBFEF9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.h),
              topRight: Radius.circular(20.h),
            ),
          ),
          shadows: [
            BoxShadow(
              color: const Color(0x66D3D3D3),
              blurRadius: 8.h,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 36.h,
              decoration: BoxDecoration(color: const Color(0xFFD3D3D3)),
              child: Center(
                child: Text(
                  '자주 묻는 질문',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF3B3B3B),
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(left: 29.h, top: 15.h, right: 29.h),
                itemCount: _faqItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        width: 302.h,
                        height: 24.h,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.h, top: 5.h),
                          child: Text(
                            _faqItems[index].question,
                            style: TextStyle(
                              color: const Color(0xFF797979),
                              fontSize: 14.fSize,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiagnosisResult {
  final String healthStatus;
  final String healthAdvice;
  final String pestStatus;
  final String pestAdvice;
  final DateTime harvestDate;

  DiagnosisResult({
    required this.healthStatus,
    required this.healthAdvice,
    required this.pestStatus,
    required this.pestAdvice,
    required this.harvestDate,
  });
}

class FaqItem {
  final String question;

  FaqItem({required this.question});
}