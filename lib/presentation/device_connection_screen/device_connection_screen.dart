import 'package:flutter/material.dart';
import 'dart:ui';

import '../../core/app_export.dart';

/// DeviceConnectionScreen - 블루투스 기기 연결 화면
///
/// 기능:
/// - 블루투스 기기 검색
/// - 연결 가이드 표시 (접기/펼치기)
/// - 7개 페이지 인디케이터 (모두 활성화)
/// - 이전/다음 네비게이션
/// - 기기 선택 화면으로 이동
class DeviceConnectionScreen extends StatefulWidget {
  const DeviceConnectionScreen({Key? key}) : super(key: key);

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  bool _isSearching = false;
  bool _isGuideExpanded = true;

  // 연결 가이드 데이터
  final List<GuideStep> _guideSteps = [
    GuideStep(
      title: '1. 블루투스 활성화',
      content: '스마트폰의 설정에서\n블루투스를 켜주세요.\n기기와의 연결이 가능합니다.',
    ),
    GuideStep(
      title: '2. 기기 전원 확인',
      content: '스마트 팜 기기의 전원이\n켜져 있는지 확인해주세요.\nLED가 깜빡이면 준비 완료입니다.',
    ),
    GuideStep(
      title: '3. 기기 검색',
      content: '아래 버튼을 눌러\n주변 기기를 검색합니다.\n잠시만 기다려주세요.',
    ),
  ];

  void _startDeviceSearch() {
    setState(() {
      _isSearching = true;
    });

    // 블루투스 검색 시뮬레이션
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24.h),
            decoration: BoxDecoration(
              color: appTheme.white_A700,
              borderRadius: BorderRadius.circular(20.h),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: appTheme.teal_400,
                ),
                SizedBox(height: 16.h),
                Text(
                  '기기를 검색 중입니다...',
                  style: TextStyle(
                    color: appTheme.gray_800,
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 3초 후 기기 선택 화면으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      
      setState(() {
        _isSearching = false;
      });

      // 기기 선택 화면으로 이동
      Navigator.pushReplacementNamed(context, AppRoutes.deviceSelectionScreen);
    });
  }

  void _goToPreviousScreen() {
    Navigator.pop(context);
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 46.h),
                  child: Column(
                    children: [
                      SizedBox(height: 130.h),
                      _buildBluetoothSection(),
                      SizedBox(height: 30.h),
                      _buildSearchButton(),
                      SizedBox(height: 50.h),
                      _buildConnectionGuide(),
                      SizedBox(height: 50.h),
                    ],
                  ),
                ),
              ),
            ),
            _buildNavigationSection(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  /// 상단 탭 (기기연결)
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
          '기기연결',
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

  /// 블루투스 연결 안내
  Widget _buildBluetoothSection() {
    return Column(
      children: [
        Text(
          '(Bluetooth 연결)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 16.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  /// 기기 검색 버튼
  Widget _buildSearchButton() {
    return Container(
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
      child: InkWell(
        onTap: _isSearching ? null : _startDeviceSearch,
        child: Text(
          '기기검색',
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
    );
  }

  /// 연결 가이드 카드
  Widget _buildConnectionGuide() {
    return Container(
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(20.h),
      ),
      child: Column(
        children: [
          // 가이드 헤더
          InkWell(
            onTap: () {
              setState(() {
                _isGuideExpanded = !_isGuideExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
              decoration: BoxDecoration(
                color: appTheme.white_A700.withOpacity(0.5),
                borderRadius: BorderRadius.circular(50.h),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '연결 가이드',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appTheme.teal_400,
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 8.h),
                  Icon(
                    _isGuideExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: appTheme.teal_400,
                    size: 20.h,
                  ),
                ],
              ),
            ),
          ),
          // 가이드 내용
          if (_isGuideExpanded) ...[
            SizedBox(height: 20.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _guideSteps.map((step) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 22.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        step.content,
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 네비게이션 섹션 (페이지 인디케이터 + 이전/다음 버튼)
  Widget _buildNavigationSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 23.h),
      child: Column(
        children: [
          // 7개 페이지 인디케이터 (모두 활성화)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 11.h),
                width: 8.h,
                height: 8.h,
                decoration: BoxDecoration(
                  color: appTheme.teal_400, // 모두 활성화된 상태
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),
          // 이전/다음 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 이전 버튼
              InkWell(
                onTap: _goToPreviousScreen,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 12.h,
                      color: appTheme.blue_gray_100,
                    ),
                    SizedBox(width: 5.h),
                    Text(
                      '이전',
                      style: TextStyle(
                        color: appTheme.blue_gray_100,
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
                onTap: _startDeviceSearch,
                child: Row(
                  children: [
                    Text(
                      '다음',
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
        ],
      ),
    );
  }
}

/// 가이드 단계 데이터 모델
class GuideStep {
  final String title;
  final String content;

  GuideStep({
    required this.title,
    required this.content,
  });
}
