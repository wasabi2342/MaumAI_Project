import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';

/// HomeScreen - 스마트 팜 홈 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: 온도, 1: 습도, 2: 조도, 3: EC, 4: Co2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      appBar: CustomTopAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: 393.w,
            height: 759.h,
            child: Stack(
              children: [
                // 상단 기기 정보 섹션 배경
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 393.w,
                    height: 188.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFE3FAE8),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66D3D3D3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),

                // 온도 카드
                Positioned(
                  left: 16.w,
                  top: 211.h,
                  child: _buildSensorCard(
                    width: 114.w,
                    height: 156.h,
                    label: '온도',
                    value: '22 ℃',
                    status: '정상',
                    statusColor: Color(0xFF32C697),
                    optimalLabel: '적정 온도',
                    optimalValue: '22 ℃ ~ 22 ℃',
                  ),
                ),

                // 습도 카드
                Positioned(
                  left: 139.w,
                  top: 211.h,
                  child: _buildSensorCard(
                    width: 115.w,
                    height: 156.h,
                    label: '습도',
                    value: '59 %',
                    status: '위험',
                    statusColor: Color(0xFFEC7243),
                    optimalLabel: '적정 습도',
                    optimalValue: '59 % ~ 59 %',
                  ),
                ),

                // 조도 카드
                Positioned(
                  left: 263.w,
                  top: 211.h,
                  child: _buildSensorCard(
                    width: 114.w,
                    height: 156.h,
                    label: '조도',
                    value: '820 lux',
                    status: '주의',
                    statusColor: Color(0xFFECC043),
                    optimalLabel: '적정 조도',
                    optimalValue: '59 % ~ 59 %',
                    hasIcon: true,
                  ),
                ),

                // Co2 카드
                Positioned(
                  left: 16.w,
                  top: 382.h,
                  child: _buildSmallSensorCard(
                    width: 176.w,
                    height: 75.h,
                    label: 'Co2',
                    value: '430 ppm',
                    status: '정상',
                    statusColor: Color(0xFF32C697),
                    optimalLabel: '적정 Co2',
                    optimalValue: '430 ppm ~ 430 ppm',
                  ),
                ),

                // EC 카드
                Positioned(
                  left: 201.w,
                  top: 382.h,
                  child: _buildSmallSensorCard(
                    width: 176.w,
                    height: 75.h,
                    label: 'EC',
                    value: '13 mS/cm',
                    status: '주의',
                    statusColor: Color(0xFFECC043),
                    optimalLabel: '적정 Co2',
                    optimalValue: '430 ppm ~ 430 ppm',
                  ),
                ),

                // 기기 정보 (오른쪽 상단)
                Positioned(
                  left: 182.w,
                  top: 60.h,
                  child: Container(
                    width: 195.w,
                    height: 82.h,
                    child: Stack(
                      children: [
                        // 기기이름 태그
                        Positioned(
                          left: 12.w,
                          top: 12.h,
                          child: Container(
                            width: 153.w,
                            height: 21.h,
                            decoration: BoxDecoration(
                              color: Color(0xFFD6F6DD),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                '기기이름',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF3B3B3B),
                                  fontSize: 14.fSize,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  height: 1,
                                  letterSpacing: -0.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 식물명 태그
                        Positioned(
                          left: 75.w,
                          top: 49.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Color(0xFF37705E),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '상추추추추...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFEEEEEE),
                                fontSize: 14.fSize,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                height: 1,
                                letterSpacing: -0.35,
                              ),
                            ),
                          ),
                        ),
                        // "현재 재배중" 텍스트
                        Positioned(
                          left: 12.w,
                          top: 54.h,
                          child: Text(
                            '현재 재배중',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF797979),
                              fontSize: 12.fSize,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 1,
                              letterSpacing: -0.30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 식물 변경 버튼
                Positioned(
                  left: 187.w,
                  top: 150.h,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.plantSelectionScreen);
                    },
                    child: Container(
                      width: 185.w,
                      height: 21.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF32C697),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x5B32C697),
                            blurRadius: 4,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '식물 변경',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFDFEFB),
                            fontSize: 14.fSize,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            height: 1.50,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 왼쪽 식물 이미지
                Positioned(
                  left: 16.w,
                  top: 60.h,
                  child: Container(
                    width: 150.w,
                    height: 111.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.h),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: 0.60,
                        child: Icon(
                          Icons.eco,
                          size: 60.h,
                          color: appTheme.teal_400,
                        ),
                      ),
                    ),
                  ),
                ),

                // 24시간 추이 그래프 섹션
                Positioned(
                  left: 16.w,
                  top: 469.h,
                  child: Container(
                    width: 361.w,
                    height: 220.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFFDFEFB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.h),
                        topRight: Radius.circular(20.h),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66D3D3D3),
                          blurRadius: 8,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 탭 바
                        Positioned(
                          left: 10.w,
                          top: 14.h,
                          child: Container(
                            width: 341.w,
                            height: 21.h,
                            decoration: BoxDecoration(
                              color: Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Stack(
                              children: [
                                // 선택된 탭 배경
                                Positioned(
                                  left: 11.w,
                                  top: 0,
                                  child: Container(
                                    width: 46.w,
                                    height: 21.h,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEC7243),
                                      borderRadius: BorderRadius.circular(10.h),
                                    ),
                                  ),
                                ),
                                // 탭 텍스트들
                                Positioned(
                                  left: 22.w,
                                  top: 4.h,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 45.w,
                                    children: [
                                      _buildTabText('온도', true),
                                      _buildTabText('습도', false),
                                      _buildTabText('조도', false),
                                      _buildTabText('EC', false),
                                      _buildTabText('Co2', false),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 그래프 영역
                        Positioned(
                          left: 3.w,
                          top: 61.h,
                          child: Container(
                            width: 355.w,
                            height: 133.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '24시간 추이',
                                  style: TextStyle(
                                    color: Color(0xFF797979),
                                    fontSize: 8.fSize,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    height: 1,
                                    letterSpacing: -0.20,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFD3D3D3),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '그래프 영역',
                                        style: TextStyle(
                                          color: Color(0xFF797979),
                                          fontSize: 12.fSize,
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
        activeRoute: AppRoutes.homeScreen,
      ),
    );
  }

  /// 큰 센서 카드 (온도, 습도, 조도)
  Widget _buildSensorCard({
    required double width,
    required double height,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
    required String optimalLabel,
    required String optimalValue,
    bool hasIcon = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFFFDFEFB),
        borderRadius: BorderRadius.circular(20.h),
        boxShadow: [
          BoxShadow(
            color: Color(0x66D3D3D3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 센서 값
          Positioned(
            left: 13.w,
            top: 20.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5.h,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.35,
                  ),
                ),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 16.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.40,
                  ),
                ),
              ],
            ),
          ),
          // 조도 아이콘 (조도 카드만)
          if (hasIcon)
            Positioned(
              right: 13.w,
              top: 20.h,
              child: Container(
                width: 26.w,
                height: 26.h,
                child: Stack(
                  children: [
                    Positioned(
                      left: 5.10,
                      top: 5.10,
                      child: Container(
                        width: 16.31,
                        height: 16.31,
                        decoration: BoxDecoration(
                          color: Color(0xFFE3FAE8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 상태 배지
          Positioned(
            left: 13.w,
            top: 70.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: statusColor),
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                  letterSpacing: -0.32,
                ),
              ),
            ),
          ),
          // 적정 범위
          Positioned(
            left: 13.w,
            bottom: 11.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  optimalLabel,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 12.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1,
                    letterSpacing: -0.30,
                  ),
                ),
                Text(
                  optimalValue,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 12.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1,
                    letterSpacing: -0.30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 작은 센서 카드 (Co2, EC)
  Widget _buildSmallSensorCard({
    required double width,
    required double height,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
    required String optimalLabel,
    required String optimalValue,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFFFDFEFB),
        borderRadius: BorderRadius.circular(20.h),
        boxShadow: [
          BoxShadow(
            color: Color(0x66D3D3D3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 센서 값
          Positioned(
            left: 13.w,
            top: 9.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.35,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 16.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.40,
                  ),
                ),
              ],
            ),
          ),
          // 상태 배지 (오른쪽)
          Positioned(
            right: 13.w,
            top: 23.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: statusColor),
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                  letterSpacing: -0.32,
                ),
              ),
            ),
          ),
          // 적정 범위
          Positioned(
            left: 13.w,
            bottom: 9.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  optimalLabel,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 10.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1,
                    letterSpacing: -0.25,
                  ),
                ),
                Text(
                  optimalValue,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 10.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1,
                    letterSpacing: -0.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 탭 텍스트
  Widget _buildTabText(String text, bool isSelected) {
    return Text(
      text,
      style: TextStyle(
        color: isSelected ? Color(0xFFFDFEFB) : Color(0xFF3B3B3B),
        fontSize: 14.fSize,
        fontFamily: 'Pretendard',
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        height: 1,
        letterSpacing: -0.35,
      ),
    );
  }
}