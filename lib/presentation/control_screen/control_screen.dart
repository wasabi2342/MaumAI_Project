

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
        child: Column(
          children: [
            _buildEnvironmentControlLabel(),
            _buildAutoModeCard(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDeviceControlTab(),
                  _buildBatterySavingTab(),
                ],
              ),
            ),
            // _buildBottomNavigation(), // <-- 이 부분이 삭제됩니다.
          ],
        ),
      ),
      // v-- 이 부분이 추가됩니다. --v
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.controlScreen,
      ),
      // ^-- 이 부분이 추가됩니다. --^
    );
  }


  /// 환경제어 라벨
  Widget _buildEnvironmentControlLabel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 17.h, vertical: 4.h),
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.h),
            bottomRight: Radius.circular(20.h),
          ),
        ),
        child: Text(
          '환경제어',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 16.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            height: 1.0,
          ),
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
        color: appTheme.white_A700,
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
                color: appTheme.teal_400,
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
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
                    color: Color(0xFF797979),
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.0,
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
              appTheme.green_200,
              appTheme.green_200.withOpacity(0),
            ],
          )
              : null,
          color: isSelected ? null : appTheme.blue_gray_100,
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
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? appTheme.white_A700 : Color(0xFF797979),
              fontSize: 14.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  /// 장치제어 탭
  Widget _buildDeviceControlTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.h),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildDeviceCard(
              '물 순환 펌프',
              _isPumpOn ? '작동중' : '정지',
              _isPumpOn,
                  (value) {
                setState(() {
                  _isPumpOn = value;
                });
              },
            ),
            SizedBox(height: 0),
            _buildDeviceCard(
              '환기팬',
              _isFanOn ? '켜짐' : '꺼짐',
              _isFanOn,
                  (value) {
                setState(() {
                  _isFanOn = value;
                });
              },
            ),
            SizedBox(height: 20.h),
            _buildLedControlCard(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// 장치 카드 (펌프, 환기팬)
  Widget _buildDeviceCard(
      String title,
      String status,
      bool isOn,
      Function(bool) onChanged,
      ) {
    return Container(
      width: double.infinity,
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
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 19.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: appTheme.teal_400,
                      fontSize: 16.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    status,
                    style: TextStyle(
                      color: Color(0xFF797979),
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            _buildToggleSwitch(isOn, onChanged),
          ],
        ),
      ),
    );
  }

  /// LED 제어 카드
  Widget _buildLedControlCard() {
    return Container(
      width: double.infinity,
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
                    color: appTheme.teal_400,
                    fontSize: 16.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _isLedOn ? '켜짐' : '꺼짐',
                      style: TextStyle(
                        color: Color(0xFF797979),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.0,
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
            // 밝기 조절
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '밝기',
                      style: TextStyle(
                        color: Color(0xFF797979),
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '${(_ledBrightness * 100).toInt()}%',
                      style: TextStyle(
                        color: Color(0xFF797979),
                        fontSize: 10.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: appTheme.green_200,
                    inactiveTrackColor: Color(0xFFEEEEEE),
                    thumbColor: appTheme.green_200,
                    overlayColor: appTheme.green_200.withOpacity(0.3),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.h),
                    trackHeight: 20.h,
                  ),
                  child: Slider(
                    value: _ledBrightness,
                    onChanged: _isLedOn
                        ? (value) {
                      setState(() {
                        _ledBrightness = value;
                      });
                    }
                        : null,
                    min: 0,
                    max: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            // 조명 색상
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '조명 색상',
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    _ledColors.length,
                        (index) => GestureDetector(
                      onTap: _isLedOn
                          ? () {
                        setState(() {
                          _selectedColorIndex = index;
                        });
                      }
                          : null,
                      child: Container(
                        width: 31.h,
                        height: 31.h,
                        decoration: BoxDecoration(
                          color: _ledColors[index],
                          shape: BoxShape.circle,
                          border: _selectedColorIndex == index
                              ? Border.all(
                            color: appTheme.green_200,
                            width: 2,
                          )
                              : null,
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

  /// 배터리절약 탭
  Widget _buildBatterySavingTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
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
                          color: appTheme.teal_400,
                          fontSize: 16.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _isBatterySavingMode ? '켜짐' : '꺼짐',
                            style: TextStyle(
                              color: Color(0xFF797979),
                              fontSize: 14.fSize,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 1.0,
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
                  SizedBox(height: 14.h),
                  Text(
                    '디스플레이 밝기가 줄어듭니다.',
                    style: TextStyle(
                      color: Color(0xFF797979),
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: value
                ? [appTheme.green_200, appTheme.green_50]
                : [appTheme.blue_gray_100, appTheme.blue_gray_100],
          ),
          borderRadius: BorderRadius.circular(100.h),
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 10.h,
            height: 10.h,
            margin: EdgeInsets.symmetric(horizontal: 2.h),
            decoration: BoxDecoration(
              color: value ? appTheme.teal_400 : appTheme.white_A700,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}