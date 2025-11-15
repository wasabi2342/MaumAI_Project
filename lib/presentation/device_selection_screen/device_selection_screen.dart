import 'package:flutter/material.dart';
import 'dart:ui';

import '../../core/app_export.dart';
import '../../widgets/custom_top_tab.dart';

/// DeviceSelectionScreen - 연결된 스마트 팜 기기 선택 화면
///
/// 기능:
/// - 연결된 기기 목록 표시
/// - 각 기기별 이름과 재배 중인 식물 정보 표시
/// - 식물 아이콘 (열매 유무 구분)
/// - 기기 선택 버튼
/// - 스마트 팜 추가 텍스트
/// - 그라디언트 배경
class DeviceSelectionScreen extends StatefulWidget {
  const DeviceSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DeviceSelectionScreen> createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  // 연결된 기기 목록 (임시 데이터)
  final List<SmartFarmDevice> _devices = [
    SmartFarmDevice(
      id: '1',
      name: '상추상추상추상추상추',
      currentCrop: '상추',
      hasTomatoes: false,
    ),
    SmartFarmDevice(
      id: '2',
      name: '상추상추상추상추상추',
      currentCrop: '상추',
      hasTomatoes: false,
    ),
    SmartFarmDevice(
      id: '3',
      name: '상추상추상추상추상추',
      currentCrop: '상추',
      hasTomatoes: false,
    ),
    SmartFarmDevice(
      id: '4',
      name: '상추상추상추상추상추',
      currentCrop: '토마토',
      hasTomatoes: true,
    ),
  ];

  void _selectDevice(SmartFarmDevice device) {
    // 기기 선택 처리
    showDialog(
      context: context,
      barrierColor: Colors.white.withOpacity(0.3),
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
                Icons.check_circle,
                color: appTheme.teal_400,
                size: 48.h,
              ),
              SizedBox(height: 16.h),
              Text(
                '기기 선택 완료',
                style: TextStyle(
                  color: appTheme.gray_800,
                  fontSize: 18.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '${device.name}\n(${device.currentCrop} 재배중)',
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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, AppRoutes.plantSelectionScreen);
              },
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

  void _addNewDevice() {
    // 새 스마트 팜 추가
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('새로운 스마트 팜을 추가합니다'),
        backgroundColor: appTheme.teal_400,
        duration: const Duration(seconds: 2),
      ),
    );

    // 기기 연결 화면으로 돌아가기
    Navigator.pushNamed(context, AppRoutes.deviceConnectionScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      body: SafeArea(
        child: Column(
          children: [
            CustomTopTab(text: '기기선택'),
            SizedBox(height: 55.h),
            _buildMyFarmLabel(),
            SizedBox(height: 10.h),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 20.h),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return _buildDeviceCard(_devices[index]);
                },
              ),
            ),
            SizedBox(height: 20.h),
            _buildAddFarmButton(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  /// 내 농장 라벨
  Widget _buildMyFarmLabel() {
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
          '내농장',
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

  /// 기기 카드
  Widget _buildDeviceCard(SmartFarmDevice device) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      height: 105.h,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
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
      child: Row(
        children: [
          // 왼쪽: 기기 정보
          Padding(
            padding: EdgeInsets.only(left: 13.h, top: 35.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 16.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  '재배중 :  ${device.currentCrop}',
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
          Spacer(),
          // 오른쪽: 식물 아이콘 + 선택 버튼
          Container(
            width: 183.h,
            height: 77.h,
            margin: EdgeInsets.only(top: 28.h, right: 21.h),
            child: Stack(
              children: [
                // 식물 아이콘
                if (device.hasTomatoes)
                  _buildTomatoIcons()
                else
                  _buildPlantIcon(),
                // 선택 하기 버튼
                Positioned(
                  left: 3.h,
                  bottom: 0,
                  child: Container(
                    width: 177.h,
                    height: 33.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.50, 0.00),
                        end: Alignment(0.50, 1.00),
                        colors: [
                          appTheme.blue_gray_700,
                          Color(0xFF977E3A),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.h),
                        topRight: Radius.circular(30.h),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _selectDevice(device),
                      child: Center(
                        child: Text(
                          '선택 하기',
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
          ),
        ],
      ),
    );
  }

  /// 일반 식물 아이콘 (열매 없음)
  Widget _buildPlantIcon() {
    return Positioned(
      left: 26.h,
      top: 0,
      child: Container(
        width: 130.h,
        height: 44.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            return Icon(
              Icons.eco,
              color: appTheme.teal_400,
              size: 20.h,
            );
          }),
        ),
      ),
    );
  }

  /// 토마토 아이콘 (열매 있음)
  Widget _buildTomatoIcons() {
    return Positioned(
      left: 26.h,
      top: 0,
      child: Container(
        width: 156.h,
        height: 44.h,
        child: CustomPaint(
          painter: TomatoDotsPainter(),
        ),
      ),
    );
  }

  /// 스마트 팜 추가 버튼
  Widget _buildAddFarmButton() {
    return InkWell(
      onTap: _addNewDevice,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 50.h, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: appTheme.teal_400,
            width: 2.h,
          ),
          borderRadius: BorderRadius.circular(20.h),
        ),
        child: Text(
          '스마트 팜 추가',
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 16.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// 토마토 점 그리기 (CustomPainter)
class TomatoDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFEC7243)
      ..style = PaintingStyle.fill;

    // 첫 번째 줄 (5개)
    final positions1 = [6, 34, 62, 90, 118];
    for (var x in positions1) {
      canvas.drawCircle(Offset(x.toDouble(), 3), 1.5, paint);
    }

    // 두 번째 줄 (5개)
    final positions2 = [14, 42, 70, 98, 126];
    for (var x in positions2) {
      canvas.drawCircle(Offset(x.toDouble(), 15), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 스마트 팜 기기 모델
class SmartFarmDevice {
  final String id;
  final String name;
  final String currentCrop;
  final bool hasTomatoes;

  SmartFarmDevice({
    required this.id,
    required this.name,
    required this.currentCrop,
    required this.hasTomatoes,
  });
}