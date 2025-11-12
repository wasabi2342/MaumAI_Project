import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';

/// HomeScreen - 스마트 팜 홈 화면
///
/// 기능:
/// - 기기 정보 및 재배 중인 식물 표시
/// - 센서 데이터 실시간 표시 (온도, 습도, 조도, Co2, EC)
/// - 24시간 센서 데이터 추이 그래프
/// - 식물 변경 버튼
/// - 적정 범위 표시 및 상태 알림
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: 온도, 1: 습도, 2: 조도, 3: EC, 4: Co2
  bool _showPlantStatusPopup = true; // 처음 진입 시 팝업 표시

  // 센서 데이터 (실제로는 API에서 가져올 데이터)
  final SensorData _sensorData = SensorData(
    temperature: 22,
    humidity: 59,
    illuminance: 820,
    co2: 430,
    ec: 13,
  );

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 식물 상태 팝업 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showPlantStatusPopup) {
        _showPlantStatusDialog();
      }
    });
  }

  void _showPlantStatusDialog() {
    showDialog(
      context: context,
      barrierColor: Color(0x3FD9D9D9),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: PlantStatusPopup(
          plantName: '상추',
          difficulty: '쉬움',
          onClose: () {
            setState(() {
              _showPlantStatusPopup = false;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 12.h),
                    _buildDeviceInfoSection(),
                    SizedBox(height: 23.h),
                    _buildSensorCardsGrid(),
                    SizedBox(height: 16.h),
                    _buildBottomDataSection(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  /// 상단 헤더
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 48.h,
      color: appTheme.green_50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 28.h,
            color: appTheme.teal_400,
          ),
          SizedBox(width: 5.h),
          Text(
            '베란다 농부',
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 13.25.fSize,
              fontFamily: 'Cafe24 Ssurround OTF',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 기기 정보 섹션
  Widget _buildDeviceInfoSection() {
    return Container(
      width: double.infinity,
      height: 188.h,
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
          // 배경 이미지 영역
          Positioned(
            left: 16.h,
            top: 12.h,
            child: Container(
              width: 150.h,
              height: 111.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.h),
              ),
              child: Opacity(
                opacity: 0.6,
                child: Icon(
                  Icons.grass,
                  size: 60.h,
                  color: appTheme.teal_400,
                ),
              ),
            ),
          ),
          // 기기 정보
          Positioned(
            right: 16.h,
            top: 12.h,
            child: Container(
              width: 195.h,
              height: 82.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFD6F6DD),
                      borderRadius: BorderRadius.circular(50.h),
                    ),
                    child: Text(
                      '기기이름',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appTheme.gray_800,
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text(
                        '현재 재배중',
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 12.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: appTheme.blue_gray_700,
                          borderRadius: BorderRadius.circular(50.h),
                        ),
                        child: Text(
                          '상추',
                          style: TextStyle(
                            color: Color(0xFFEEEEEE),
                            fontSize: 14.fSize,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 식물 변경 버튼
          Positioned(
            right: 16.h,
            bottom: 17.h,
            child: InkWell(
              onTap: () {
                // TODO: 식물 변경 화면으로 이동
                // Navigator.pushNamed(context, AppRoutes.plantSelectionScreen);
              },
              child: Container(
                width: 185.h,
                height: 21.h,
                decoration: BoxDecoration(
                  color: appTheme.teal_400,
                  borderRadius: BorderRadius.circular(50.h),
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
                    '식물 변경',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appTheme.white_A700,
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 센서 카드 그리드 (온도, 습도, 조도)
  Widget _buildSensorCardsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        children: [
          Expanded(child: _buildSensorCard('온도', '${_sensorData.temperature} ℃', '22 ℃ ~ 22 ℃', SensorStatus.normal)),
          SizedBox(width: 9.h),
          Expanded(child: _buildSensorCard('습도', '${_sensorData.humidity} %', '59 % ~ 59 %', SensorStatus.danger)),
          SizedBox(width: 9.h),
          Expanded(child: _buildSensorCard('조도', '${_sensorData.illuminance} lux', '59 % ~ 59 %', SensorStatus.warning)),
        ],
      ),
    );
  }

  /// 개별 센서 카드
  Widget _buildSensorCard(String label, String value, String optimalRange, SensorStatus status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case SensorStatus.normal:
        statusColor = appTheme.teal_400;
        statusText = '정상';
        break;
      case SensorStatus.warning:
        statusColor = Color(0xFFECC043);
        statusText = '주의';
        break;
      case SensorStatus.danger:
        statusColor = Color(0xFFEC7243);
        statusText = '위험';
        break;
    }

    return Container(
      height: 156.h,
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
      child: Padding(
        padding: EdgeInsets.all(13.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 라벨
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            SizedBox(height: 5.h),
            // 값
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            Spacer(),
            // 상태 배지
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
              decoration: BoxDecoration(
                border: Border.all(color: statusColor, width: 1),
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            // 적정 범위
            Text(
              '적정 $label',
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 12.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
            Text(
              optimalRange,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 12.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 하단 데이터 섹션 (Co2, EC, 그래프)
  Widget _buildBottomDataSection() {
    return Container(
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
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 14.h),
          // Co2, EC 데이터
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: Row(
              children: [
                Expanded(child: _buildBottomSensorCard('Co2', '${_sensorData.co2} ppm', '430 ppm ~ 430 ppm', SensorStatus.normal)),
                SizedBox(width: 9.h),
                Expanded(child: _buildBottomSensorCard('EC', '${_sensorData.ec} mS/cm', '430 ppm ~ 430 ppm', SensorStatus.warning)),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // 그래프 섹션
          _buildGraphSection(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  /// 하단 센서 카드 (Co2, EC)
  Widget _buildBottomSensorCard(String label, String value, String optimalRange, SensorStatus status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case SensorStatus.normal:
        statusColor = appTheme.teal_400;
        statusText = '정상';
        break;
      case SensorStatus.warning:
        statusColor = Color(0xFFECC043);
        statusText = '주의';
        break;
      case SensorStatus.danger:
        statusColor = Color(0xFFEC7243);
        statusText = '위험';
        break;
    }

    return Container(
      height: 75.h,
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
      child: Padding(
        padding: EdgeInsets.all(13.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Color(0xFF797979),
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF797979),
                      fontSize: 16.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
              decoration: BoxDecoration(
                border: Border.all(color: statusColor, width: 1),
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Text(
                statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 그래프 섹션
  Widget _buildGraphSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.h),
      child: Column(
        children: [
          // 탭 선택기
          Container(
            height: 21.h,
            decoration: BoxDecoration(
              color: Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(50.h),
            ),
            child: Row(
              children: [
                _buildTab('온도', 0),
                _buildTab('습도', 1),
                _buildTab('조도', 2),
                _buildTab('EC', 3),
                _buildTab('Co2', 4),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          // 그래프 플레이스홀더
          Container(
            height: 133.h,
            padding: EdgeInsets.all(10.h),
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
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: Center(
                    child: Text(
                      '그래프 영역\n(실제 구현 시 차트 라이브러리 사용)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF797979),
                        fontSize: 12.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 그래프 탭
  Widget _buildTab(String label, int index) {
    bool isSelected = _selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          height: 21.h,
          decoration: BoxDecoration(
            color: isSelected ? appTheme.teal_400 : Colors.transparent,
            borderRadius: BorderRadius.circular(10.h),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? appTheme.white_A700 : appTheme.gray_800,
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 하단 네비게이션
  Widget _buildBottomNavigation() {
    return Container(
      height: 70.h,
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
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem('홈', Icons.home, true, null), // 이미 홈 화면이므로 null
          _buildNavItem('다이어리', Icons.book, false, () {
            Navigator.pushReplacementNamed(context, AppRoutes.diaryScreen);
          }),
          _buildNavItem('진단', Icons.medical_services, false, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('진단 기능은 준비중입니다.'),
                backgroundColor: appTheme.teal_400,
                duration: Duration(seconds: 2),
              ),
            );
          }),
          _buildNavItem('제어', Icons.settings, false, () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('제어 기능은 준비중입니다.'),
                backgroundColor: appTheme.teal_400,
                duration: Duration(seconds: 2),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 네비게이션 아이템
  Widget _buildNavItem(String label, IconData icon, bool isSelected, VoidCallback? onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 70.h,
          color: appTheme.white_A700,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.h,
                color: isSelected ? appTheme.blue_gray_700 : appTheme.blue_gray_100,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? appTheme.blue_gray_700 : appTheme.blue_gray_100,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 센서 데이터 모델
class SensorData {
  final int temperature;
  final int humidity;
  final int illuminance;
  final int co2;
  final int ec;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.illuminance,
    required this.co2,
    required this.ec,
  });
}

/// 센서 상태
enum SensorStatus {
  normal,   // 정상
  warning,  // 주의
  danger,   // 위험
}

/// 식물 상태 팝업
class PlantStatusPopup extends StatelessWidget {
  final String plantName;
  final String difficulty;
  final VoidCallback onClose;

  const PlantStatusPopup({
    Key? key,
    required this.plantName,
    required this.difficulty,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 48.h),
      child: Container(
        width: 297.h,
        height: 374.h,
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
        child: Stack(
          children: [
            // 배경 장식
            Positioned(
              right: 0,
              top: 16.h,
              child: Container(
                width: 270.h,
                height: 215.h,
                decoration: BoxDecoration(
                  color: appTheme.green_50.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.h),
                    bottomRight: Radius.circular(20.h),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appTheme.color66D3D3,
                      blurRadius: 8.h,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            // 닫기 버튼
            Positioned(
              right: 16.h,
              top: 16.h,
              child: IconButton(
                icon: Icon(Icons.close, color: Color(0xFF797979)),
                onPressed: onClose,
              ),
            ),
            // 메인 콘텐츠
            Padding(
              padding: EdgeInsets.all(27.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 식물 정보
                  Row(
                    children: [
                      Container(
                        width: 90.h,
                        height: 90.h,
                        decoration: BoxDecoration(
                          color: appTheme.green_50,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.eco,
                            size: 40.h,
                            color: appTheme.teal_400,
                          ),
                        ),
                      ),
                      SizedBox(width: 24.h),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plantName,
                              style: TextStyle(
                                color: Color(0xFF797979),
                                fontSize: 14.fSize,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              '재배 난이도 : $difficulty',
                              style: TextStyle(
                                color: Color(0xFF797979),
                                fontSize: 12.fSize,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 26.h),
                  // 적정 환경 정보
                  _buildOptimalInfo('적정 온도', '22 ℃ ~ 22 ℃'),
                  SizedBox(height: 10.h),
                  _buildOptimalInfo('적정 습도', '59 % ~ 59 %'),
                  SizedBox(height: 10.h),
                  _buildOptimalInfo('적정 조도', '59 % ~ 59 %'),
                  SizedBox(height: 10.h),
                  _buildOptimalInfo('LED', '430 ppm ~ 430 ppm'),
                  SizedBox(height: 10.h),
                  _buildOptimalInfo('양액주기', '430 ppm ~ 430 ppm'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimalInfo(String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 4.h),
          decoration: BoxDecoration(
            color: appTheme.green_50,
            borderRadius: BorderRadius.circular(20.h),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Color(0xFF797979),
              fontSize: 10.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        ),
        SizedBox(width: 20.h),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF797979),
              fontSize: 10.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}