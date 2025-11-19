import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/app_export.dart';

// 모델 및 API 서비스 import
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_top_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

/// HomeScreen - 스마트 팜 홈 화면
///
/// 수정 사항:
/// - Scaffold 배경색을 흰색(appTheme.white_A700)으로 변경하여 하단 영역 배경을 흰색으로 설정
/// - 상단 기기 정보 섹션은 초록색 컨테이너(Color(0xFFE3FAE8))를 유지하여 구분감 형성
/// - UI 요소 위치(top 값) 재조정 (이전 요청 반영)
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: 온도, 1: 습도, 2: 조도, 3: EC, 4: Co2

  // 선택된 식물 정보
  PlantInfo? _selectedPlant;

  // 데이터 로딩 상태
  bool _isLoading = true;

  // 각 탭의 색상 정의
  final List<Color> _tabColors = [
    Color(0xFFEC7243), // 온도 - 빨간색
    Color(0xFF32C697), // 습도 - 민트색
    Color(0xFFECC043), // 조도 - 노란색
    Color(0xFF32C697), // EC - 민트색
    Color(0xFF797979), // Co2 - 회색
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkArgumentsAndFetchData();
    });
  }

  /// 1. 초기 데이터 확인 및 로드 로직
  void _checkArgumentsAndFetchData() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is PlantInfo) {
      setState(() {
        _selectedPlant = args;
        _isLoading = false;
      });
      _showPlantGuideDialog();
    } else {
      await _fetchMyPlantData();
    }
  }

  /// 2. 내 식물 정보 API 조회
  Future<void> _fetchMyPlantData() async {
    if (ApiService.currentUserId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      // 1. 내 식물 목록 조회
      final userPlants = await ApiService.getUserPlants(ApiService.currentUserId!);

      if (userPlants.isNotEmpty) {
        final firstUserPlant = userPlants[0];

        // plantId 찾기 (JSON에 없으면 이름으로 매칭 시도)
        int? plantId = firstUserPlant['plantId'];
        final String plantName = firstUserPlant['plantName'] ?? '';

        if (plantId == null && plantName.isNotEmpty) {
          // plantId가 없으면 전체 식물 목록에서 이름으로 찾기
          final allPlants = await ApiService.getAllPlants();
          // json 데이터에서 name이 일치하는 항목 찾기
          final match = allPlants.firstWhere(
                (json) => json['name'] == plantName,
            orElse: () => null,
          );
          if (match != null) {
            plantId = match['id'];
          }
        }

        if (plantId != null) {
          final plantDetailJson = await ApiService.getPlantDetail(plantId);
          final plantInfo = PlantInfo.fromJson(plantDetailJson);

          setState(() {
            _selectedPlant = plantInfo;
            _isLoading = false;
          });

          // [옵션] 자동 팝업이 불편하면 주석 처리하세요.
          // _showPlantGuideDialog();
        } else {
          // 매칭되는 식물을 못 찾았을 때
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('홈 화면 데이터 로드 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  /// 식물 가이드 팝업 표시
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
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            Center(
              child: _buildPlantGuidePopup(),
            ),
          ],
        );
      },
    );
  }

  /// 식물 가이드 팝업 위젯 구성
  Widget _buildPlantGuidePopup() {
    final name = _selectedPlant?.name ?? '식물을 선택해주세요';
    final difficulty = _selectedPlant?.difficultyKorean ?? '-';
    final tempRange = _selectedPlant?.temperatureRange ?? '-';
    final humidityRange = _selectedPlant?.humidityRange ?? '-';
    final lightLevel = _selectedPlant?.lightLevelKorean ?? '-';
    final ecRange = _selectedPlant?.ecRange ?? '-';

    String co2Range = _selectedPlant?.co2Range ?? '-';
    if (co2Range != '-') {
      co2Range = '$co2Range ppm';
    }

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
                    BoxShadow(
                      color: Color(0x66D3D3D3),
                      blurRadius: 8.h,
                      offset: Offset(0, 0),
                    ),
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
              child: Icon(
                Icons.close,
                size: 24.h,
                color: Color(0xFFD3D3D3),
              ),
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
                    child: Icon(
                      Icons.eco,
                      size: 40.h,
                      color: appTheme.teal_400,
                    ),
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
                child: Icon(
                  Icons.thermostat,
                  size: 20.h,
                  color: Color(0xFF32C697),
                ),
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
                child: Icon(
                  Icons.water_drop,
                  size: 20.h,
                  color: Color(0xFF32C697),
                ),
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
                child: Icon(
                  Icons.wb_sunny,
                  size: 20.h,
                  color: Color(0xFF32C697),
                ),
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
                child: Icon(
                  Icons.lightbulb,
                  size: 20.h,
                  color: Color(0xFF32C697),
                ),
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
                  child: Icon(
                    Icons.opacity,
                    size: 20.h,
                    color: Color(0xFF32C697),
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. 배경색을 흰색으로 변경 (기존 appTheme.green_50 -> appTheme.white_A700)
      backgroundColor: appTheme.white_A700,
      appBar: CustomTopAppBar(),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: appTheme.teal_400))
            : SingleChildScrollView(
          child: Container(
            width: 393.h,
            height: 719.h, // 759 -> 719 (요소들을 위로 올려서 높이 조정)
            child: Stack(
              children: [
                // 2. 상단 기기 정보 섹션 배경 (초록색 유지)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 393.h,
                    height: 148.h, // 188 -> 148
                    decoration: BoxDecoration(
                      color: Color(0xFFE3FAE8), // 초록색 배경 유지
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x66D3D3D3),
                          blurRadius: 8.h,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                  ),
                ),

                // 왼쪽 식물 이미지 (top: 60 -> 20)
                Positioned(
                  left: 16.h,
                  top: 20.h,
                  child: Container(
                    width: 150.h,
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

                // 기기 정보 (top: 60 -> 20)
                Positioned(
                  left: 182.h,
                  top: 20.h,
                  child: Container(
                    width: 195.h,
                    height: 82.h,
                    child: Stack(
                      children: [
                        // 기기이름 태그
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
                          left: 75.h,
                          top: 49.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.h, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Color(0xFF37705E),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              _selectedPlant?.name ?? '식물 없음',
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
                          left: 12.h,
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

                // 식물 변경 버튼 (top: 150 -> 110)
                Positioned(
                  left: 187.h,
                  top: 110.h,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppRoutes.plantSelectionScreen);
                    },
                    child: Container(
                      width: 185.h,
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
                          _selectedPlant == null ? '식물 등록하기' : '식물 변경',
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

                // 온도 카드 (top: 211 -> 171)
                Positioned(
                  left: 16.h,
                  top: 171.h,
                  child: _buildSensorCard(
                    width: 114.h,
                    height: 156.h,
                    label: '온도',
                    value: '22 ℃',
                    status: '정상',
                    statusColor: Color(0xFF32C697),
                    optimalLabel: '적정 온도',
                    optimalValue: _selectedPlant?.temperatureRange ?? '-',
                  ),
                ),

                // 습도 카드 (top: 211 -> 171)
                Positioned(
                  left: 139.h,
                  top: 171.h,
                  child: _buildSensorCard(
                    width: 115.h,
                    height: 156.h,
                    label: '습도',
                    value: '59 %',
                    status: '위험',
                    statusColor: Color(0xFFEC7243),
                    optimalLabel: '적정 습도',
                    optimalValue: _selectedPlant?.humidityRange ?? '-',
                  ),
                ),

                // 조도 카드 (top: 211 -> 171)
                Positioned(
                  left: 263.h,
                  top: 171.h,
                  child: _buildSensorCard(
                    width: 114.h,
                    height: 156.h,
                    label: '조도',
                    value: '820 lux',
                    status: '주의',
                    statusColor: Color(0xFFECC043),
                    optimalLabel: '적정 조도',
                    optimalValue: _selectedPlant?.lightLevelKorean ?? '-',
                    hasIcon: true,
                  ),
                ),

                // Co2 카드 (top: 382 -> 342)
                Positioned(
                  left: 16.h,
                  top: 342.h,
                  child: _buildSmallSensorCard(
                    width: 176.h,
                    height: 75.h,
                    label: 'Co2',
                    value: '430 ppm',
                    status: '정상',
                    statusColor: Color(0xFF32C697),
                    optimalLabel: '적정 Co2',
                    optimalValue: _selectedPlant?.co2Range ?? '-',
                  ),
                ),

                // EC 카드 (top: 382 -> 342)
                Positioned(
                  left: 201.h,
                  top: 342.h,
                  child: _buildSmallSensorCard(
                    width: 176.h,
                    height: 75.h,
                    label: 'EC',
                    value: '13 mS/cm',
                    status: '주의',
                    statusColor: Color(0xFFECC043),
                    optimalLabel: '적정 EC',
                    optimalValue: _selectedPlant?.ecRange ?? '-',
                  ),
                ),

                // 24시간 추이 그래프 섹션 (top: 469 -> 429)
                Positioned(
                  left: 16.h,
                  top: 429.h,
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
                        BoxShadow(
                          color: Color(0x66D3D3D3),
                          blurRadius: 8,
                          offset: Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 탭 바
                        Container(
                          margin: EdgeInsets.only(
                              left: 10.h, right: 10.h, top: 14.h),
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
                        // 그래프 영역
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 13.h,
                                right: 13.h,
                                top: 26.h,
                                bottom: 13.h),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
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

  Widget _buildTabButton(String label, int index) {
    bool isSelected = _selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
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
                height: 1,
                letterSpacing: -0.35,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 13.h,
            top: 20.h,
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
                    height: 1,
                    letterSpacing: -0.35,
                  ),
                ),
                SizedBox(height: 5.h),
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
          if (hasIcon)
            Positioned(
              right: 13.h,
              top: 20.h,
              child: Container(
                width: 26.h,
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
          Positioned(
            left: 13.h,
            top: 70.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
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
          Positioned(
            left: 13.h,
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
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 13.h,
            top: 9.h,
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
                    height: 1,
                    letterSpacing: -0.35,
                  ),
                ),
                SizedBox(height: 2.h),
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
          Positioned(
            right: 13.h,
            top: 23.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
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
          Positioned(
            left: 13.h,
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
}