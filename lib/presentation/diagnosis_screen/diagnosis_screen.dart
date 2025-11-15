import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_top_tab.dart';

/// DiagnosisScreen - AI 식물 진단 화면
///
/// 기능:
/// - 사진 촬영을 통한 AI 식물 진단
/// - 건강 체크 결과 표시
/// - 병해충 진단 결과 표시
/// - 수확시기 예측
/// - 자주 묻는 질문 섹션
class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  // 진단 결과 데이터 (실제로는 API에서 가져올 데이터)
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
    // 사진 촬영 기능
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
              Icon(
                Icons.camera_alt,
                color: appTheme.teal_400,
                size: 48.h,
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      appBar: CustomTopAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            CustomTopTab(text: '진단'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPhotoAnalysisSection(),
                    SizedBox(height: 16.h),
                    _buildDiagnosisCardsRow(),
                    SizedBox(height: 16.h),
                    _buildHarvestPredictionCard(),
                    SizedBox(height: 16.h),
                    _buildFaqSection(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
            // _buildBottomNavigation(), // <-- 이 부분이 삭제됩니다.
          ],
        ),
      ),
      // v-- 이 부분이 추가됩니다. --v
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.diagnosisScreen,
      ),
      // ^-- 이 부분이 추가됩니다. --^
    );
  }


  /// 사진 분석 섹션
  Widget _buildPhotoAnalysisSection() {
    return Container(
      width: double.infinity,
      height: 307.h,
      decoration: BoxDecoration(
        color: appTheme.green_50,
        boxShadow: [
          BoxShadow(
            color: appTheme.color66D3D3,
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 사진 분석 라벨
          Positioned(
            left: 0,
            top: 16.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 17.h, vertical: 4.h),
              decoration: BoxDecoration(
                color: appTheme.white_A700,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.h),
                  bottomRight: Radius.circular(20.h),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_search,
                    size: 21.h,
                    color: appTheme.teal_400,
                  ),
                  SizedBox(width: 5.h),
                  Text(
                    '사진 분석',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appTheme.teal_400,
                      fontSize: 16.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 사진 촬영 카드
          Positioned(
            left: 16.h,
            top: 63.h,
            child: Container(
              width: 361.h,
              height: 167.h,
              decoration: BoxDecoration(
                color: appTheme.white_A700,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.h),
                  topRight: Radius.circular(20.h),
                ),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.color66D3D3,
                    blurRadius: 8.h,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: InkWell(
                onTap: _capturePhoto,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 40.h,
                        color: appTheme.teal_400,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        '사진 촬영',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appTheme.teal_400,
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 진단 카드 행 (건강체크, 병해충진단)
  Widget _buildDiagnosisCardsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        children: [
          Expanded(
            child: _buildHealthCheckCard(),
          ),
          SizedBox(width: 21.h),
          Expanded(
            child: _buildPestDiagnosisCard(),
          ),
        ],
      ),
    );
  }

  /// 건강체크 카드
  Widget _buildHealthCheckCard() {
    return Container(
      height: 202.h,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(20.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.color66D3D3,
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            width: double.infinity,
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
                topLeft: Radius.circular(20.h),
                topRight: Radius.circular(20.h),
              ),
              boxShadow: [
                BoxShadow(
                  color: appTheme.color66D3D3,
                  blurRadius: 8.h,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '건강체크',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appTheme.white_A700,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
          ),
          // 내용
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                      (index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _diagnosisResult.healthStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                      if (index < 3) SizedBox(height: 4.h),
                      Text(
                        _diagnosisResult.healthAdvice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                      if (index < 3) SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 병해충 진단 카드
  Widget _buildPestDiagnosisCard() {
    return Container(
      height: 202.h,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(20.h),
        boxShadow: [
          BoxShadow(
            color: appTheme.color66D3D3,
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            width: double.infinity,
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
                topLeft: Radius.circular(20.h),
                topRight: Radius.circular(20.h),
              ),
              boxShadow: [
                BoxShadow(
                  color: appTheme.color66D3D3,
                  blurRadius: 8.h,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '병해충 진단',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appTheme.white_A700,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ),
          ),
          // 내용
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                      (index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _diagnosisResult.pestStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                      if (index < 2) SizedBox(height: 4.h),
                      Text(
                        _diagnosisResult.pestAdvice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                      if (index < 2) SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 수확시기 예측 카드
  Widget _buildHarvestPredictionCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Container(
        width: double.infinity,
        height: 99.h,
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          borderRadius: BorderRadius.circular(20.h),
          boxShadow: [
            BoxShadow(
              color: appTheme.color66D3D3,
              blurRadius: 8.h,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              width: double.infinity,
              height: 36.h,
              decoration: BoxDecoration(
                color: appTheme.green_50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.h),
                  topRight: Radius.circular(20.h),
                ),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.color66D3D3,
                    blurRadius: 8.h,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '수확시기 예측',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appTheme.teal_400,
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            // 내용
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 15.h),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 예상 수확일',
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${_diagnosisResult.harvestDate.year}. ${_diagnosisResult.harvestDate.month} / ${_diagnosisResult.harvestDate.day}',
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 10.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 자주 묻는 질문 섹션
  Widget _buildFaqSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.h),
            topRight: Radius.circular(20.h),
          ),
          boxShadow: [
            BoxShadow(
              color: appTheme.color66D3D3,
              blurRadius: 8.h,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              width: double.infinity,
              height: 36.h,
              decoration: BoxDecoration(
                color: appTheme.blue_gray_100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.h),
                  topRight: Radius.circular(20.h),
                ),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.color66D3D3,
                    blurRadius: 8.h,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '자주 묻는 질문',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appTheme.gray_800,
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            // 질문 목록
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 29.h, vertical: 15.h),
              itemCount: _faqItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index < _faqItems.length - 1 ? 12.h : 0),
                  child: InkWell(
                    onTap: () {
                      // FAQ 상세보기
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_faqItems[index].question),
                          backgroundColor: appTheme.teal_400,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 24.h,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _faqItems[index].question,
                              style: TextStyle(
                                color: Color(0xFF797979),
                                fontSize: 14.fSize,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14.h,
                            color: Color(0xFF797979),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

// v-- _buildBottomNavigation() 및 _buildNavItem() 메서드가 여기서 삭제됩니다. --v
// Widget _buildBottomNavigation() { ... }
// Widget _buildNavItem(String label, IconData icon, bool isSelected, VoidCallback? onTap) { ... }
// ^-- _buildBottomNavigation() 및 _buildNavItem() 메서드가 여기서 삭제됩니다. --^
}

/// 진단 결과 데이터 모델
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

/// FAQ 아이템 모델
class FaqItem {
  final String question;

  FaqItem({required this.question});
}