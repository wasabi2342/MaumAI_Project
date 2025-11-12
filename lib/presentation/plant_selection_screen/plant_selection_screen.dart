import 'package:flutter/material.dart';
import 'dart:ui';

import '../../core/app_export.dart';

/// PlantSelectionScreen - 재배할 식물 선택 화면
///
/// 기능:
/// - 재배 가능한 식물 목록 표시
/// - 각 식물의 이미지, 이름, 난이도 표시
/// - 식물 선택 버튼
/// - 선택한 식물로 홈 화면 이동
class PlantSelectionScreen extends StatefulWidget {
  const PlantSelectionScreen({Key? key}) : super(key: key);

  @override
  State<PlantSelectionScreen> createState() => _PlantSelectionScreenState();
}

class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
  // 재배 가능한 식물 목록
  final List<PlantInfo> _plants = [
    PlantInfo(
      id: '1',
      name: '상추',
      difficulty: '쉬움',
      imageUrl: 'assets/images/plant_lettuce.png',
    ),
    PlantInfo(
      id: '2',
      name: '토마토',
      difficulty: '보통',
      imageUrl: 'assets/images/plant_tomato.png',
    ),
    PlantInfo(
      id: '3',
      name: '바질',
      difficulty: '쉬움',
      imageUrl: 'assets/images/plant_basil.png',
    ),
    PlantInfo(
      id: '4',
      name: '딸기',
      difficulty: '어려움',
      imageUrl: 'assets/images/plant_strawberry.png',
    ),
  ];

  void _selectPlant(PlantInfo plant) {
    // 식물 선택 확인 다이얼로그
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
                '${plant.name} 선택 완료',
                style: TextStyle(
                  color: appTheme.gray_800,
                  fontSize: 18.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '재배 난이도: ${plant.difficulty}',
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
                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.homeScreen,
                  arguments: plant,
                );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopTab(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 28.h, bottom: 20.h),
                itemCount: _plants.length,
                itemBuilder: (context, index) {
                  return _buildPlantCard(_plants[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상단 탭 (재배할 식물 선택)
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
          '재배할 식물 선택',
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
    );
  }

  /// 식물 카드
  Widget _buildPlantCard(PlantInfo plant) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      height: 136.h,
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 35.h, vertical: 23.h),
        child: Row(
          children: [
            // 식물 이미지
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
            SizedBox(width: 35.h),
            // 식물 정보
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
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
                    '재배 난이도 : ${plant.difficulty}',
                    style: TextStyle(
                      color: Color(0xFF797979),
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // 선택 버튼
                  InkWell(
                    onTap: () => _selectPlant(plant),
                    child: Container(
                      width: 170.h,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 식물 정보 모델
class PlantInfo {
  final String id;
  final String name;
  final String difficulty;
  final String imageUrl;

  PlantInfo({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.imageUrl,
  });
}
