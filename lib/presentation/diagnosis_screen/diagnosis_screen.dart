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
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 393.h),
            child: Column(
              children: [
                CustomTopTab(text: '진단'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 4.h),
                        _buildTimeAnalysisLabel(),
                        SizedBox(height: 12.h),
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

  /// 사진 분석 라벨
  Widget _buildTimeAnalysisLabel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE3FAE8),
          borderRadius: BorderRadius.circular(4.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              size: 16.h,
              color: const Color(0xFF32C697),
            ),
            SizedBox(width: 4.h),
            Text(
              '사진 분석',
              style: TextStyle(
                color: const Color(0xFF32C697),
                fontSize: 12.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                letterSpacing: -0.30,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// 사진 분석 섹션
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
              Icon(
                Icons.camera_alt,
                size: 40.h,
                color: const Color(0xFF32C697),
              ),
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
          // 헤더 - custom_top_tab과 동일한 그라데이션
          Container(
            width: double.infinity,
            height: 36.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  appTheme.green_200,  // #A0ECB1
                  appTheme.teal_400,   // #32C697
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x66D3D3D3),
                  blurRadius: 8.h,
                  offset: Offset(0, 4.h),
                  spreadRadius: 0,
                ),
              ],
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
          // 내용
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.h, top: 15.h, right: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  4,
                      (index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _diagnosisResult.healthStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          letterSpacing: -0.35,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        _diagnosisResult.healthAdvice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          letterSpacing: -0.35,
                        ),
                      ),
                      if (index < 3) SizedBox(height: 24.h),
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
          // 헤더 - custom_top_tab과 동일한 그라데이션
          Container(
            width: double.infinity,
            height: 36.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  appTheme.green_200,  // #A0ECB1
                  appTheme.teal_400,   // #32C697
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x66D3D3D3),
                  blurRadius: 8.h,
                  offset: Offset(0, 4.h),
                  spreadRadius: 0,
                ),
              ],
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
          // 내용
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16.h, top: 15.h, right: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(
                  3,
                      (index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
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
                              height: 1.0,
                              letterSpacing: -0.35,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _diagnosisResult.pestAdvice,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF797979),
                              fontSize: 14.fSize,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                              letterSpacing: -0.35,
                            ),
                          ),
                        ],
                      ),
                      if (index < 2) SizedBox(height: 24.h),
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
            // 헤더
            Container(
              width: double.infinity,
              height: 36.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE3FAE8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x66D3D3D3),
                    blurRadius: 8.h,
                    offset: Offset(0, 4.h),
                    spreadRadius: 0,
                  ),
                ],
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
                    height: 1.0,
                    letterSpacing: -0.35,
                  ),
                ),
              ),
            ),
            // 내용
            Padding(
              padding: EdgeInsets.only(left: 18.h, top: 15.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 예상 수확일',
                      style: TextStyle(
                        color: const Color(0xFF797979),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        letterSpacing: -0.35,
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
                        height: 1.0,
                        letterSpacing: -0.25,
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

  /// 자주 묻는 질문 섹션
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
              spreadRadius: 0,
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
                color: const Color(0xFFD3D3D3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x66D3D3D3),
                    blurRadius: 8.h,
                    offset: Offset(0, 4.h),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '자주 묻는 질문',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF3B3B3B),
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    letterSpacing: -0.35,
                  ),
                ),
              ),
            ),
            // 질문 목록
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
                        width: 302.h,
                        height: 24.h,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.h, top: 5.h),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _faqItems[index].question,
                                style: TextStyle(
                                  color: const Color(0xFF797979),
                                  fontSize: 14.fSize,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                  letterSpacing: -0.35,
                                ),
                              ),
                            ],
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