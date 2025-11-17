import 'package:flutter/material.dart';

import '../../core/app_export.dart';

/// ControlScreen - 환경 제어 화면
///
/// 기능:
/// - 2개 탭: 장치제어, 배터리절약
/// - 자동모드 on/off
/// - 물 순환 펌프 제어
/// - 환기팬 제어
/// - LED 조명 제어 (밝기, 색상)
/// - 배터리 절약 모드
class ControlScreen extends StatefulWidget {
  const ControlScreen({Key? key}) : super(key: key);

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 자동 모드 상태
  bool _isAutoMode = false;

  // 장치 상태
  bool _isPumpOn = true;
  bool _isFanOn = true;
  bool _isLedOn = true;

  // LED 설정
  double _ledBrightness = 0.8; // 80%
  int _selectedColorIndex = 0; // 흰색

  // 배터리 절약 모드
  bool _isBatterySavingMode = true;

  // LED 색상 목록
  final List<Color> _ledColors = [
    Color(0xFFFDFEFB), // 흰색
    Color(0xFFFFF8E1), // 따뜻한 흰색
    Color(0xFFE3FAE8), // 녹색
    Color(0xFFFCD6CC), // 주황색
    Color(0xFFCCEEFC), // 파란색
    Color(0xFFD8CCFC), // 보라색
    Color(0xFFFCCCE7), // 분홍색
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      appBar: CustomTopAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 4.h),
              _buildEnvironmentControlLabel(),
              SizedBox(height: 12.h),
              _buildControlSection(),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.controlScreen,
      ),
    );
  }

  /// 제어 섹션 (자동모드 + 탭바 + 탭 내용 모두 포함)
  Widget _buildControlSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Column(
        children: [
          // 자동모드 카드 + 탭바 (하나의 흰색 카드)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFDFEFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.h),
                topRight: Radius.circular(20.h),
              ),
            ),
            child: Column(
              children: [
                // 자동모드
                Padding(
                  padding: EdgeInsets.fromLTRB(24.h, 15.h, 24.h, 15.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '자동모드',
                        style: TextStyle(
                          color: const Color(0xFF32C697),
                          fontSize: 16.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          letterSpacing: -0.40,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '센서기반 자동제어',
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
                          _buildToggleSwitch(_isAutoMode, (value) {
                            setState(() {
                              _isAutoMode = value;
                            });
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                // 탭바
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabItem('장치제어', 0),
                      ),
                      SizedBox(width: 19.h),
                      Expanded(
                        child: _buildTabItem('배터리절약', 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 탭 내용 (별도 카드들)
          _tabController.index == 0
              ? _buildDeviceControlContent()
              : _buildBatterySavingContent(),
        ],
      ),
    );
  }

  /// 환경제어 라벨
  Widget _buildEnvironmentControlLabel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(top: 4.h, left: 17.h, right: 20.h, bottom: 4.h),
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
              '환경제어',
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

  /// 자동모드 카드
  Widget _buildAutoModeCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.h, 43.h, 16.h, 0),
      width: double.infinity,
      height: 117.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.h),
          topRight: Radius.circular(20.h),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 15.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '자동모드',
              style: TextStyle(
                color: const Color(0xFF32C697),
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.40,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '센서기반 자동제어',
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
                _buildToggleSwitch(_isAutoMode, (value) {
                  setState(() {
                    _isAutoMode = value;
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 탭바
  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.h),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem('장치제어', 0),
          ),
          SizedBox(width: 19.h),
          Expanded(
            child: _buildTabItem('배터리절약', 1),
          ),
        ],
      ),
    );
  }

  /// 탭 아이템
  Widget _buildTabItem(String label, int index) {
    bool isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: Container(
        height: 35.h,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appTheme.green_200,  // 0xFFA0ECB1
              appTheme.teal_400,   // 0xFF32C697
            ],
          )
              : null,
          color: isSelected ? null : const Color(0xFFD3D3D3),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.h),
            topRight: Radius.circular(20.h),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x66D3D3D3),
              blurRadius: 8.h,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFDFEFB) : const Color(0xFF797979),
              fontSize: 14.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 1.0,
              letterSpacing: -0.35,
            ),
          ),
        ),
      ),
    );
  }

  /// 장치제어 탭 내용
  Widget _buildDeviceControlContent() {
    return Column(
      children: [
        SizedBox(height: 16.h),
        _buildDoubleDeviceCard(),
        SizedBox(height: 20.h),
        _buildLedControlCard(),
      ],
    );
  }

  /// 장치제어 탭 (사용 안 함)
  Widget _buildDeviceControlTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildDoubleDeviceCard(),
            SizedBox(height: 20.h),
            _buildLedControlCard(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// 물 순환 펌프 + 환기팬 카드 (2개 나란히)
  Widget _buildDoubleDeviceCard() {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFFFDFEFB),
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
      child: Padding(
        padding: EdgeInsets.all(20.h),
        child: Row(
          children: [
            // 물 순환 펌프
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '물 순환 펌프',
                    style: TextStyle(
                      color: const Color(0xFF32C697),
                      fontSize: 16.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                      letterSpacing: -0.40,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '작동중',
                        style: TextStyle(
                          color: const Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          letterSpacing: -0.35,
                        ),
                      ),
                      SizedBox(width: 50.h),
                      _buildToggleSwitch(_isPumpOn, (value) {
                        setState(() {
                          _isPumpOn = value;
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 60.h),
            // 환기팬
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '환기팬',
                    style: TextStyle(
                      color: const Color(0xFF32C697),
                      fontSize: 16.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                      letterSpacing: -0.40,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '커짐',
                        style: TextStyle(
                          color: const Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          letterSpacing: -0.35,
                        ),
                      ),
                      SizedBox(width: 50.h),
                      _buildToggleSwitch(_isFanOn, (value) {
                        setState(() {
                          _isFanOn = value;
                        });
                      }),
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

  /// LED 조명 제어 카드
  Widget _buildLedControlCard() {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFFFDFEFB),
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
      child: Padding(
        padding: EdgeInsets.all(15.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LED 조명 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LED 조명',
                  style: TextStyle(
                    color: const Color(0xFF32C697),
                    fontSize: 16.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    letterSpacing: -0.40,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _isLedOn ? '켜짐' : '꺼짐',
                      style: TextStyle(
                        color: const Color(0xFF797979),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        letterSpacing: -0.35,
                      ),
                    ),
                    SizedBox(width: 10.h),
                    _buildToggleSwitch(_isLedOn, (value) {
                      setState(() {
                        _isLedOn = value;
                      });
                    }),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30.h),
            // 조명 밝기
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '조명 밝기',
                      style: TextStyle(
                        color: const Color(0xFF797979),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        letterSpacing: -0.35,
                      ),
                    ),
                    Text(
                      '${(_ledBrightness * 100).round()}%',
                      style: TextStyle(
                        color: const Color(0xFF797979),
                        fontSize: 10.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 20.h,
                    activeTrackColor: const Color(0xFFA0ECB1),
                    inactiveTrackColor: const Color(0xFFEEEEEE),
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 8.h,
                    ),
                    thumbColor: const Color(0xFFA0ECB1),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                    trackShape: RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: _ledBrightness,
                    onChanged: (value) {
                      setState(() {
                        _ledBrightness = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 41.h),
            // 조명 색상
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '조명 색상',
                  style: TextStyle(
                    color: const Color(0xFF797979),
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                    letterSpacing: -0.35,
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  children: List.generate(
                    _ledColors.length,
                        (index) => Padding(
                      padding: EdgeInsets.only(right: index < _ledColors.length - 1 ? 15.h : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColorIndex = index;
                          });
                        },
                        child: Container(
                          width: 31.h,
                          height: 31.h,
                          decoration: ShapeDecoration(
                            color: _ledColors[index],
                            shape: OvalBorder(
                              side: _selectedColorIndex == index
                                  ? BorderSide(
                                width: 2.h,
                                color: const Color(0xFFA0ECB1),
                              )
                                  : BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 배터리절약 탭 내용
  Widget _buildBatterySavingContent() {
    return Column(
      children: [
        SizedBox(height: 16.h),
        _buildBatterySavingCard(),
      ],
    );
  }

  /// 배터리절약 탭 (사용 안 함)
  Widget _buildBatterySavingTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildBatterySavingCard(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// 배터리 절약 모드 카드
  Widget _buildBatterySavingCard() {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFFFDFEFB),
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
      child: Padding(
        padding: EdgeInsets.all(15.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '배터리 절약모드',
                  style: TextStyle(
                    color: const Color(0xFF32C697),
                    fontSize: 16.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                    letterSpacing: -0.40,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _isBatterySavingMode ? '켜짐' : '꺼짐',
                      style: TextStyle(
                        color: const Color(0xFF797979),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        letterSpacing: -0.35,
                      ),
                    ),
                    SizedBox(width: 10.h),
                    _buildToggleSwitch(_isBatterySavingMode, (value) {
                      setState(() {
                        _isBatterySavingMode = value;
                      });
                    }),
                  ],
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Text(
              '디스플레이 밝기가 줄어듭니다.',
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
    );
  }

  /// 토글 스위치
  Widget _buildToggleSwitch(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 33.h,
        height: 14.h,
        child: Stack(
          children: [
            // 배경
            Container(
              width: 33.h,
              height: 14.h,
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.00, 0.50),
                  end: Alignment(1.00, 0.50),
                  colors: [
                    const Color(0xFFA0ECB1),
                    const Color(0xFFE3FAE8),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.h),
                ),
              ),
            ),
            // 원형 버튼
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              left: value ? 21.h : 2.h,
              top: 2.h,
              child: Container(
                width: 10.h,
                height: 10.h,
                decoration: ShapeDecoration(
                  color: value ? const Color(0xFF32C697) : const Color(0xFFE3FAE8),
                  shape: OvalBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}