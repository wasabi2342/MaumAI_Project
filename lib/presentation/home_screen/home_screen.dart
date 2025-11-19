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
/// 기능:
/// 1. 로그인 직후 내 식물 정보가 없으면 서버에서 자동으로 불러옵니다. (검은 화면 방지)
/// 2. 식물 상세 정보(온도, 습도 등)를 화면에 표시합니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: 온도, 1: 습도, 2: 조도, 3: EC, 4: Co2

  // 선택된 식물 정보 (서버에서 가져오거나 이전 화면에서 받음)
  PlantInfo? _selectedPlant;

  // 데이터 로딩 상태 (초기값 true: 데이터를 확인하는 동안 로딩 표시)
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
    // 화면 렌더링 직후 데이터 확인 및 로드 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkArgumentsAndFetchData();
    });
  }

  /// 1. 초기 데이터 확인 및 로드 로직
  void _checkArgumentsAndFetchData() async {
    // 이전 화면(식물 선택 등)에서 넘겨준 데이터가 있는지 확인
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is PlantInfo) {
      // 넘겨받은 데이터가 있다면 그대로 사용 (회원가입 직후 등)
      setState(() {
        _selectedPlant = args;
        _isLoading = false;
      });
      // 가이드 팝업 표시
      _showPlantGuideDialog();
    } else {
      // 넘겨받은 데이터가 없다면(로그인 직후) API로 내 식물 정보 조회
      await _fetchMyPlantData();
    }
  }

  /// 2. 내 식물 정보 API 조회 (로그인 시 실행됨)
  Future<void> _fetchMyPlantData() async {
    // 로그인이 안 된 상태면 로딩 종료
    if (ApiService.currentUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // (1) 내 식물 목록(UserPlant) 가져오기
      // ApiService에 getUserPlants 메서드가 추가되어 있어야 합니다.
      final userPlants = await ApiService.getUserPlants(ApiService.currentUserId!);

      if (userPlants.isNotEmpty) {
        // (2) 첫 번째 식물의 상세 정보(PlantInfo) 가져오기
        // userPlants[0]은 Map 형태이므로, 여기서 plantId를 추출합니다.
        final firstUserPlant = userPlants[0];
        final int plantId = firstUserPlant['plantId']; // API 응답 구조에 따라 키값('plantId') 확인 필요

        // 식물 상세 정보 조회 API 호출
        final plantDetailJson = await ApiService.getPlantDetail(plantId);

        // JSON 데이터를 PlantInfo 모델로 변환
        final plantInfo = PlantInfo.fromJson(plantDetailJson);

        setState(() {
          _selectedPlant = plantInfo;
          _isLoading = false;
        });

        // 정보 로드가 완료되면 가이드 팝업 표시
        _showPlantGuideDialog();
      } else {
        // 등록된 식물이 하나도 없는 경우
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('홈 화면 데이터 로드 실패: $e');
      // 에러가 나더라도 로딩은 풀어주어 빈 화면이라도 보이게 함
      setState(() => _isLoading = false);
    }
  }

  /// 식물 가이드 팝업 표시
  void _showPlantGuideDialog() {
    // 식물 정보가 없으면 팝업을 띄우지 않음
    if (_selectedPlant == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // 블러 배경
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            // 팝업 다이얼로그
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

    // Co2 값 처리 (단위 추가)
    String co2Range = _selectedPlant?.co2Range ?? '-';
    if (co2Range != '-') {
      co2Range = '$co2Range ppm';
    }

    return Container(
      width: 297.h, // .w 대신 .h 사용 (반응형 유틸리티에 따라 조정)
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
          // 배경 장식
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

          // 닫기 버튼
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

          // 식물 정보 섹션
          Positioned(
            left: 27.h,
            top: 36.h,
            child: Row(
              children: [
                // 식물 이미지
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
                // 식물 정보 텍스트
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

          // 적정 온도
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

          // 적정 습도
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

          // 적정 조도
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

          // 적정 CO2
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

          // 적정 EC
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

  /// 가이드 행 위젯
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
      backgroundColor: appTheme.green_50,
      appBar: CustomTopAppBar(),
      body: SafeArea(
        // 로딩 중일 때(API 호출 중)는 로딩 바를 띄워 검은 화면을 방지합니다.
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: appTheme.teal_400))
            : SingleChildScrollView(
          child: Container(
            width: 393.h, // Figma 사이즈 기준
            height: 759.h,
            child: Stack(
              children: [
                // 상단 기기 정보 섹션 배경
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 393.h,
                    height: 188.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFE3FAE8),
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

                // 온도 카드 (데이터 바인딩)
                Positioned(
                  left: 16.h,
                  top: 211.h,
                  child: _buildSensorCard(
                    width: 114.h,
                    height: 156.h,
                    label: '온도',
                    value: '22 ℃', // 실제 센서값 연동 필요 시 수정
                    status: '정상',
                    statusColor: Color(0xFF32C697),
                    optimalLabel: '적정 온도',
                    optimalValue: _selectedPlant?.temperatureRange ?? '-',
                  ),
                ),

                // 습도 카드 (데이터 바인딩)
                Positioned(
                  left: 139.h,
                  top: 211.h,
                  child: _buildSensorCard(
                    width: 115.h,
                    height: 156.h,
                    label: '습도',
                    value: '59 %', // 실제 센서값 연동 필요 시 수정
                    status: '위험',
                    statusColor: Color(0xFFEC7243),
                    optimalLabel: '적정 습도',
                    optimalValue: _selectedPlant?.humidityRange ?? '-',
                  ),
                ),

                // 조도 카드 (데이터 바인딩)
                Positioned(
                  left: 263.h,
                  top: 211.h,
                  child: _buildSensorCard(
                    width: 114.h,
                    height: 156.h,
                    label: '조도',
                    value: '820 lux', // 실제 센서값 연동 필요 시 수정
                    status: '주의',
                    statusColor: Color(0xFFECC043),
                    optimalLabel: '적정 조도',
                    optimalValue: _selectedPlant?.lightLevelKorean ?? '-',
                    hasIcon: true,
                  ),
                ),

                // Co2 카드 (데이터 바인딩)
                Positioned(
                  left: 16.h,
                  top: 382.h,
                  child: _buildSmallSensorCard(
                    width: 176.h,
                    height: 75.h,
                    label: 'Co2',
                    value: '430 ppm', // 실제 센서값 연동 필요 시 수정
                    status: '정상',
                    statusColor: Color(0xFF32C697),
                    optimalLabel: '적정 Co2',
                    optimalValue: _selectedPlant?.co2Range ?? '-',
                  ),
                ),

                // EC 카드 (데이터 바인딩)
                Positioned(
                  left: 201.h,
                  top: 382.h,
                  child: _buildSmallSensorCard(
                    width: 176.h,
                    height: 75.h,
                    label: 'EC',
                    value: '13 mS/cm', // 실제 센서값 연동 필요 시 수정
                    status: '주의',
                    statusColor: Color(0xFFECC043),
                    optimalLabel: '적정 EC',
                    optimalValue: _selectedPlant?.ecRange ?? '-',
                  ),
                ),

                // 기기 정보 (오른쪽 상단)
                Positioned(
                  left: 182.h,
                  top: 60.h,
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
                        // 식물명 태그 (동적 데이터)
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

                // 식물 변경 버튼
                Positioned(
                  left: 187.h,
                  top: 150.h,
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

                // 왼쪽 식물 이미지
                Positioned(
                  left: 16.h,
                  top: 60.h,
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

                // 24시간 추이 그래프 섹션
                Positioned(
                  left: 16.h,
                  top: 469.h,
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
                        // 그래프 영역 (API 연결 전 더미)
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

  /// 탭 버튼
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
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 센서 값
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
          // 조도 아이콘 (조도 카드만)
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
          // 상태 배지
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
          // 적정 범위
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
            blurRadius: 8.h,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 센서 값
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
          // 상태 배지 (오른쪽)
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
          // 적정 범위
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