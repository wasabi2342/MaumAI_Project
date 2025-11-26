import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // [필수] 그래프 패키지
import 'package:intl/intl.dart';       // [필수] 날짜 포맷팅

import '../../core/app_export.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_top_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: 온도, 1: 습도, 2: 조도, 3: EC, 4: Co2

  PlantInfo? _selectedPlant;
  SensorData24h? _sensorData; // 서버 데이터
  bool _isLoading = true;

  // 각 탭(센서)별 그래프 색상 정의
  final List<Color> _tabColors = [
    Color(0xFFEC7243), // 온도 - 주황/빨강
    Color(0xFF32C697), // 습도 - 민트
    Color(0xFFECC043), // 조도 - 노란색
    Color(0xFF32C697), // EC - 민트
    Color(0xFF797979), // Co2 - 회색
  ];

  @override
  void initState() {
    super.initState();
    // 화면이 빌드된 후 초기 데이터 로드 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkArgumentsAndFetchData();
    });
  }

  /// 초기 데이터 확인 및 로드
  void _checkArgumentsAndFetchData() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is PlantInfo) {
      // 1. 식물 선택 화면에서 넘어온 경우
      setState(() {
        _selectedPlant = args;
      });
      // 임시로 1번 데이터를 로드하거나, 등록 직후라면 API를 다시 호출하여 ID를 찾아야 함
      // 우선 사용자 경험을 위해 내 식물 데이터를 다시 갱신하는 방향으로 유도
      await _fetchMyPlantData();
      _showPlantGuideDialog();
    } else {
      // 2. 앱 실행 시 일반적인 진입 (내 식물 조회)
      await _fetchMyPlantData();
    }
  }

  /// 내 식물 정보 조회 및 센서 데이터 로드 (모든 유저가 1번 기기 데이터 공유)
  Future<void> _fetchMyPlantData() async {
    // 로그인이 안되어 있으면 로딩 종료 (단, Mock 모드면 진행)
    if (ApiService.currentUserId == null && !ApiService.isMockMode) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userId = ApiService.currentUserId ?? 999;
      final userPlants = await ApiService.getUserPlants(userId);

      // ============================================================
      // [수정 핵심] 모든 사용자가 1번 기기(UserPlantId: 1)의 데이터를 보게 설정
      // ============================================================

      // 실제 데이터를 조회할 타겟 ID (기기가 하나뿐이므로 1로 고정)
      const int sharedSensorId = 1;

      if (userPlants.isNotEmpty) {
        // 1. 사용자에게 등록된 식물이 있는 경우
        final firstUserPlant = userPlants[0];

        // 내 식물 정보(이름 등)는 내 것을 쓰지만...
        int? plantId = firstUserPlant['plantId'];
        final String plantName = firstUserPlant['plantName'] ?? '';

        // ★ 센서 데이터만큼은 무조건 1번 기기 데이터를 가져옵니다.
        await _fetchSensorData(sharedSensorId);

        // (아래는 식물 상세 정보 매칭 로직 - 기존과 동일)
        if (plantId == null && plantName.isNotEmpty) {
          final allPlants = await ApiService.getAllPlants();
          final match = allPlants.firstWhere(
                (json) => json['name'] == plantName,
            orElse: () => null,
          );
          if (match != null) plantId = match['id'];
        }

        if (plantId != null) {
          final plantDetailJson = await ApiService.getPlantDetail(plantId);
          setState(() {
            _selectedPlant = PlantInfo.fromJson(plantDetailJson);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }

      } else {
        // 2. [중요] 신규 가입해서 등록된 식물이 '아예 없는' 경우
        // 화면이 비어 보이지 않게 '공용 기기' 데이터를 강제로 보여줍니다.

        print("등록된 식물이 없어 공용 기기(ID: 1) 모드로 진입합니다.");

        // 센서 데이터 1번 호출
        await _fetchSensorData(sharedSensorId);

        // 식물 정보도 기본값(예: 로메인 상추)으로 세팅해서 화면에 보여줌
        try {
          // 기본 식물 정보(ID 1: 상추) 가져오기 시도
          final defaultPlantJson = await ApiService.getPlantDetail(1);
          setState(() {
            _selectedPlant = PlantInfo.fromJson(defaultPlantJson);
            _isLoading = false;
          });
        } catch (e) {
          // 그것도 실패하면 로딩만 끝냄
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('홈 화면 데이터 로드 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  /// 센서 데이터 API 호출
  /// [deviceId] 파라미터는 실제로는 UserPlantId입니다.
  Future<void> _fetchSensorData(int userPlantId) async {
    try {
      final data = await ApiService.getSensorData24h(userPlantId);
      setState(() {
        _sensorData = data;
      });
    } catch (e) {
      print("센서 데이터 로드 실패: $e");
    }
  }

  /// 식물 가이드 팝업
  void _showPlantGuideDialog() {
    if (_selectedPlant == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Center(child: _buildPlantGuidePopup()),
          ],
        );
      },
    );
  }

  /// 식물 가이드 팝업 위젯 (기존 디자인 유지)
  Widget _buildPlantGuidePopup() {
    final name = _selectedPlant?.name ?? '식물을 선택해주세요';
    final difficulty = _selectedPlant?.difficultyKorean ?? '-';
    final tempRange = _selectedPlant?.temperatureRange ?? '-';
    final humidityRange = _selectedPlant?.humidityRange ?? '-';
    final lightLevel = _selectedPlant?.lightLevelKorean ?? '-';
    final ecRange = _selectedPlant?.ecRange ?? '-';
    String co2Range = _selectedPlant?.co2Range ?? '-';
    if (co2Range != '-') co2Range = '$co2Range ppm';

    return Container(
      width: 297.h,
      height: 374.h,
      decoration: BoxDecoration(
        color: Color(0xFFFDFEFB),
        borderRadius: BorderRadius.circular(20.h),
        boxShadow: [
          BoxShadow(
            color: Color(0x66D3D3D3),
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 297.h,
            top: 358.h,
            child: Transform(
              transform: Matrix4.rotationZ(3.14),
              child: Container(
                width: 270.h,
                height: 215.h,
                decoration: BoxDecoration(
                  color: Color(0x19E3FAE8),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.h),
                    bottomRight: Radius.circular(20.h),
                  ),
                  boxShadow: [
                    BoxShadow(color: Color(0x66D3D3D3), blurRadius: 8.h, offset: Offset(0, 0)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16.h,
            top: 16.h,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.close, size: 24.h, color: Color(0xFFD3D3D3)),
            ),
          ),
          Positioned(
            left: 27.h,
            top: 36.h,
            child: Row(
              children: [
                Container(
                  width: 90.h,
                  height: 90.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFE3FAE8),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.eco, size: 40.h, color: appTheme.teal_400),
                  ),
                ),
                SizedBox(width: 11.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 142.h,
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          height: 1,
                          letterSpacing: -0.35,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    SizedBox(
                      width: 142.h,
                      child: Text(
                        '재배 난이도 : $difficulty',
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
              ],
            ),
          ),
          Positioned(
            left: 47.5.h,
            top: 152.h,
            child: _buildGuideRow(
              iconWidget: Container(
                width: 11.h,
                height: 22.h,
                child: Icon(Icons.thermostat, size: 20.h, color: Color(0xFF32C697)),
              ),
              label: '적정 온도',
              value: tempRange,
            ),
          ),
          Positioned(
            left: 47.5.h,
            top: 196.h,
            child: _buildGuideRow(
              iconWidget: Container(
                width: 16.h,
                height: 22.h,
                child: Icon(Icons.water_drop, size: 20.h, color: Color(0xFF32C697)),
              ),
              label: '적정 습도',
              value: humidityRange,
            ),
          ),
          Positioned(
            left: 47.5.h,
            top: 240.h,
            child: _buildGuideRow(
              iconWidget: Container(
                width: 22.h,
                height: 22.h,
                child: Icon(Icons.wb_sunny, size: 20.h, color: Color(0xFF32C697)),
              ),
              label: '적정 조도',
              value: lightLevel,
            ),
          ),
          Positioned(
            left: 47.5.h,
            top: 284.h,
            child: _buildGuideRow(
              iconWidget: Container(
                width: 17.h,
                height: 21.h,
                child: Icon(Icons.lightbulb, size: 20.h, color: Color(0xFF32C697)),
              ),
              label: '적정 CO2',
              value: co2Range,
              fontSize: 10.fSize,
            ),
          ),
          Positioned(
            left: 47.5.h,
            top: 327.h,
            child: _buildGuideRow(
              iconWidget: Container(
                width: 24.h,
                height: 24.h,
                child: Transform.rotate(
                  angle: 0.79,
                  child: Icon(Icons.opacity, size: 20.h, color: Color(0xFF32C697)),
                ),
              ),
              label: '적정 EC',
              value: ecRange,
              fontSize: 10.fSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow({
    required Widget iconWidget,
    required String label,
    required String value,
    double? fontSize,
  }) {
    return Row(
      children: [
        iconWidget,
        SizedBox(width: 13.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 4.h),
          decoration: BoxDecoration(
            color: Color(0xFFE3FAE8),
            borderRadius: BorderRadius.circular(20.h),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Color(0xFF797979),
              fontSize: fontSize ?? 12.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: fontSize != null ? -0.25 : -0.30,
            ),
          ),
        ),
        SizedBox(width: 20.h),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF797979),
            fontSize: fontSize ?? 12.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            height: 1,
            letterSpacing: fontSize != null ? -0.25 : -0.30,
          ),
        ),
      ],
    );
  }

  // --- [UI 빌드] ---

  @override
  Widget build(BuildContext context) {
    // 최신 센서 값 가져오기 (데이터 없으면 '-')
    final String currentTemp = _sensorData?.temperature.latestValue?.toStringAsFixed(1) ?? '-';
    final String currentHum = _sensorData?.humidity.latestValue?.toStringAsFixed(1) ?? '-';
    final String currentLux = _sensorData?.illuminance.latestValue?.toStringAsFixed(0) ?? '-';
    final String currentCo2 = _sensorData?.co2.latestValue?.toStringAsFixed(0) ?? '-';
    final String currentEc = _sensorData?.ec.latestValue?.toStringAsFixed(1) ?? '-';

    return Scaffold(
      backgroundColor: appTheme.white_A700,
      appBar: CustomTopAppBar(),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: appTheme.teal_400))
            : SingleChildScrollView(
          child: Container(
            width: 393.h,
            height: 719.h,
            child: Stack(
              children: [
                // 1. 상단 배경 (초록색)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 393.h,
                    height: 148.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFE3FAE8),
                      boxShadow: [
                        BoxShadow(color: Color(0x66D3D3D3), blurRadius: 8.h, offset: Offset(0, 4.h)),
                      ],
                    ),
                  ),
                ),

                // 2. 왼쪽 식물 이미지 (흰색 배경 박스 추가)
                Positioned(
                  left: 16.h,
                  top: 20.h,
                  child: Container(
                    width: 150.h,
                    height: 111.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFFDFEFB), // 흰색 배경
                      borderRadius: BorderRadius.circular(20.h),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66D3D3D3),
                          blurRadius: 8.h,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: 0.60,
                        child: Icon(Icons.eco, size: 60.h, color: appTheme.teal_400),
                      ),
                    ),
                  ),
                ),

                // 3. 기기 정보 (흰색 배경 박스 추가)
                Positioned(
                  left: 182.h,
                  top: 20.h,
                  child: Container(
                    width: 195.h,
                    height: 82.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFFDFEFB), // 흰색 배경
                      borderRadius: BorderRadius.circular(20.h),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66D3D3D3),
                          blurRadius: 8.h,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 12.h,
                          top: 12.h,
                          child: Container(
                            width: 153.h,
                            height: 21.h,
                            decoration: BoxDecoration(
                              color: Color(0xFFD6F6DD),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                '스마트 팜 1호',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF3B3B3B),
                                  fontSize: 14.fSize,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 75.h,
                          top: 42.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Color(0xFF37705E),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              _selectedPlant?.name ?? '식물 없음',
                              style: TextStyle(
                                color: Color(0xFFEEEEEE),
                                fontSize: 14.fSize,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12.h,
                          top: 47.h,
                          child: Text(
                            '현재 재배중',
                            style: TextStyle(
                              color: Color(0xFF797979),
                              fontSize: 12.fSize,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. 식물 변경 버튼
                Positioned(
                  left: 187.h,
                  top: 110.h,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.plantSelectionScreen);
                    },
                    child: Container(
                      width: 185.h,
                      height: 21.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF32C697),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          _selectedPlant == null ? '식물 등록하기' : '식물 변경',
                          style: TextStyle(
                            color: Color(0xFFFDFEFB),
                            fontSize: 14.fSize,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 5. 온도 카드
                Positioned(
                  left: 16.h,
                  top: 171.h,
                  child: _buildSensorCard(
                    width: 114.h,
                    height: 156.h,
                    label: '온도',
                    value: '$currentTemp ℃',
                    status: _getSensorStatus(currentTemp, _selectedPlant?.tempMin, _selectedPlant?.tempMax),
                    statusColor: _getStatusColor(currentTemp, _selectedPlant?.tempMin, _selectedPlant?.tempMax),
                    optimalLabel: '적정 온도',
                    optimalValue: _selectedPlant?.temperatureRange ?? '-',
                  ),
                ),

                // 6. 습도 카드
                Positioned(
                  left: 139.h,
                  top: 171.h,
                  child: _buildSensorCard(
                    width: 115.h,
                    height: 156.h,
                    label: '습도',
                    value: '$currentHum %',
                    status: _getSensorStatus(currentHum, _selectedPlant?.humidityMin, _selectedPlant?.humidityMax),
                    statusColor: _getStatusColor(currentHum, _selectedPlant?.humidityMin, _selectedPlant?.humidityMax),
                    optimalLabel: '적정 습도',
                    optimalValue: _selectedPlant?.humidityRange ?? '-',
                  ),
                ),

                // 7. 조도 카드
                Positioned(
                  left: 263.h,
                  top: 171.h,
                  child: _buildSensorCard(
                    width: 114.h,
                    height: 156.h,
                    label: '조도',
                    value: '$currentLux lux',
                    status: '측정중',
                    statusColor: Color(0xFFECC043),
                    optimalLabel: '적정 조도',
                    optimalValue: _selectedPlant?.lightLevelKorean ?? '-',
                    hasIcon: true,
                  ),
                ),

                // 8. Co2 카드
                Positioned(
                  left: 16.h,
                  top: 342.h,
                  child: _buildSmallSensorCard(
                    width: 176.h,
                    height: 95.h,
                    label: 'Co2',
                    value: '$currentCo2 ppm',
                    status: _getSensorStatus(currentCo2, _selectedPlant?.co2Min, _selectedPlant?.co2Max),
                    statusColor: _getStatusColor(currentCo2, _selectedPlant?.co2Min, _selectedPlant?.co2Max),
                    optimalLabel: '적정 Co2',
                    optimalValue: _selectedPlant?.co2Range ?? '-',
                  ),
                ),

                // 9. EC 카드
                Positioned(
                  left: 201.h,
                  top: 342.h,
                  child: _buildSmallSensorCard(
                    width: 176.h,
                    height: 95.h,
                    label: 'EC',
                    value: '$currentEc mS/cm',
                    status: _getSensorStatus(currentEc, _selectedPlant?.ecMin, _selectedPlant?.ecMax),
                    statusColor: _getStatusColor(currentEc, _selectedPlant?.ecMin, _selectedPlant?.ecMax),
                    optimalLabel: '적정 EC',
                    optimalValue: _selectedPlant?.ecRange ?? '-',
                  ),
                ),

                // 10. 24시간 추이 그래프
                Positioned(
                  left: 16.h,
                  top: 455.h,
                  child: Container(
                    width: 361.h,
                    height: 220.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFFDFEFB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.h),
                        topRight: Radius.circular(20.h),
                      ),
                      boxShadow: [
                        BoxShadow(color: Color(0x66D3D3D3), blurRadius: 8, offset: Offset(0, -4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 탭 버튼
                        Container(
                          margin: EdgeInsets.only(left: 10.h, right: 10.h, top: 14.h),
                          height: 21.h,
                          decoration: BoxDecoration(
                            color: Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              _buildTabButton('온도', 0),
                              _buildTabButton('습도', 1),
                              _buildTabButton('조도', 2),
                              _buildTabButton('EC', 3),
                              _buildTabButton('Co2', 4),
                            ],
                          ),
                        ),

                        // 차트 영역
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 13.h, right: 20.h, top: 26.h, bottom: 13.h),
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
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Expanded(child: _buildChart()), // 차트 그리기
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
      bottomNavigationBar: CustomBottomNavBar(activeRoute: AppRoutes.homeScreen),
    );
  }

  // --- Helper Methods ---

  /// 센서 상태(정상/주의/위험) 판별
  String _getSensorStatus(String currentValueStr, double? min, double? max) {
    if (currentValueStr == '-' || min == null || max == null) return '-';
    double? val = double.tryParse(currentValueStr.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (val == null) return '-';

    if (val >= min && val <= max) return '정상';
    double range = max - min;
    // 범위에서 조금 벗어나면 주의, 많이 벗어나면 위험
    if (val < min - (range * 0.2) || val > max + (range * 0.2)) return '위험';
    return '주의';
  }

  Color _getStatusColor(String currentValueStr, double? min, double? max) {
    String status = _getSensorStatus(currentValueStr, min, max);
    if (status == '정상') return Color(0xFF32C697);
    if (status == '주의') return Color(0xFFECC043);
    return Color(0xFFEC7243);
  }

  /// 차트 빌드 메서드 (fl_chart)
  Widget _buildChart() {
    if (_sensorData == null) {
      return Center(child: Text('데이터 로딩 중 또는 없음', style: TextStyle(fontSize: 12, color: Colors.grey)));
    }

    SensorSeries? targetSeries;
    switch (_selectedTab) {
      case 0: targetSeries = _sensorData!.temperature; break;
      case 1: targetSeries = _sensorData!.humidity; break;
      case 2: targetSeries = _sensorData!.illuminance; break;
      case 3: targetSeries = _sensorData!.ec; break;
      case 4: targetSeries = _sensorData!.co2; break;
    }

    if (targetSeries == null || targetSeries.points.isEmpty) {
      return Center(child: Text('표시할 데이터가 없습니다.', style: TextStyle(fontSize: 12, color: Colors.grey)));
    }

    // 데이터 포인트를 차트용 Spot으로 변환 (X축: 인덱스)
    List<FlSpot> spots = [];
    for (int i = 0; i < targetSeries.points.length; i++) {
      spots.add(FlSpot(i.toDouble(), targetSeries.points[i].value));
    }

    // Y축 범위 계산
    double minY = targetSeries.points.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    double maxY = targetSeries.points.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    double margin = (maxY - minY) * 0.2;
    if (margin == 0) margin = 5;

    Color lineColor = _tabColors[_selectedTab];

    return LineChart(
      LineChartData(
        minY: (minY - margin).floorToDouble(),
        maxY: (maxY + margin).ceilToDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4 == 0 ? 1 : (maxY - minY) / 4,
          getDrawingHorizontalLine: (value) => FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: Color(0xFFC4C4C4), fontSize: 10, fontFamily: 'Pretendard'),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (targetSeries.points.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= targetSeries!.points.length) return Container();
                DateTime time = targetSeries.points[index].timestamp;
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    DateFormat('HH:mm').format(time),
                    style: TextStyle(color: Color(0xFFC4C4C4), fontSize: 10, fontFamily: 'Pretendard'),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: lineColor.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 2.h, vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected ? _tabColors[index] : Colors.transparent,
            borderRadius: BorderRadius.circular(10.h),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Color(0xFFFDFEFB) : Color(0xFF3B3B3B),
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 카드 위젯 (기존 코드 유지)
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
          BoxShadow(color: Color(0x66D3D3D3), blurRadius: 8.h, offset: Offset(0, 4.h)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 13.h, top: 20.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Color(0xFF797979), fontSize: 14.fSize, fontWeight: FontWeight.w700, fontFamily: 'Pretendard')),
                SizedBox(height: 5.h),
                Text(value, style: TextStyle(color: Color(0xFF797979), fontSize: 16.fSize, fontWeight: FontWeight.w700, fontFamily: 'Pretendard')),
              ],
            ),
          ),
          if (hasIcon)
            Positioned(right: 13.h, top: 20.h, child: Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 24.h)),
          Positioned(
            left: 13.h, top: 70.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: statusColor),
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 14.fSize, fontWeight: FontWeight.w700, fontFamily: 'Pretendard')),
            ),
          ),
          Positioned(
            left: 13.h, bottom: 11.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(optimalLabel, style: TextStyle(color: Color(0xFF797979), fontSize: 12.fSize, fontWeight: FontWeight.w500, fontFamily: 'Pretendard')),
                Text(optimalValue, style: TextStyle(color: Color(0xFF797979), fontSize: 12.fSize, fontWeight: FontWeight.w500, fontFamily: 'Pretendard')),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          BoxShadow(color: Color(0x66D3D3D3), blurRadius: 8.h, offset: Offset(0, 4.h)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 13.h, top: 9.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Color(0xFF797979), fontSize: 14.fSize, fontWeight: FontWeight.w700, fontFamily: 'Pretendard')),
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(color: Color(0xFF797979), fontSize: 16.fSize, fontWeight: FontWeight.w700, fontFamily: 'Pretendard')),
              ],
            ),
          ),
          Positioned(
            right: 13.h, top: 23.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: statusColor),
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 14.fSize, fontWeight: FontWeight.w700, fontFamily: 'Pretendard')),
            ),
          ),
          Positioned(
            left: 13.h, bottom: 9.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(optimalLabel, style: TextStyle(color: Color(0xFF797979), fontSize: 10.fSize, fontWeight: FontWeight.w500, fontFamily: 'Pretendard')),
                Text(optimalValue, style: TextStyle(color: Color(0xFF797979), fontSize: 10.fSize, fontWeight: FontWeight.w500, fontFamily: 'Pretendard')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}