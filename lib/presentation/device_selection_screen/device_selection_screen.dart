import 'package:flutter/material.dart';
import 'dart:ui';

import '../../core/app_export.dart';

/// DeviceSelectionScreen - 연결된 스마트 팜 기기 선택 화면
///
/// 기능:
/// - 연결된 기기 목록 표시
/// - 각 기기별 이름과 재배 중인 식물 정보 표시
/// - 기기 선택 버튼
/// - 스마트 팜 추가 버튼
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appTheme.green_200,
              appTheme.green_50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopTab(),
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
              _buildAddDeviceButton(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  /// 상단 탭 (기기선택)
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
          '기기선택',
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
          // 기기 정보
          Expanded(
            child: Padding(
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
          ),
          // 선택 버튼 영역
          Container(
            width: 183.h,
            height: 77.h,
            margin: EdgeInsets.only(right: 0, top: 28.h),
            child: Stack(
              children: [
                // 토마토 패턴 (토마토 재배 중일 경우에만 표시)
                if (device.hasTomatoes) _buildTomatoPattern(),
                // 선택하기 버튼
                Positioned(
                  left: 3.h,
                  bottom: 0,
                  child: InkWell(
                    onTap: () => _selectDevice(device),
                    child: Container(
                      width: 177.h,
                      height: 33.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
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

  /// 토마토 패턴 (장식용)
  Widget _buildTomatoPattern() {
    return Positioned(
      left: 32.h,
      top: 0,
      right: 32.h,
      child: SizedBox(
        height: 44.h,
        child: Column(
          children: [
            // 첫 번째 줄
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return Container(
                  width: 3.h,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFEC7243),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            SizedBox(height: 9.h),
            // 두 번째 줄
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return Container(
                  width: 3.h,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFEC7243),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// 스마트 팜 추가 버튼
  Widget _buildAddDeviceButton() {
    return InkWell(
      onTap: _addNewDevice,
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
    );
  }
}

/// 스마트 팜 기기 데이터 모델
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
