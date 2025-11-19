import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert'; // JSON 처리를 위해 필요

// 프로젝트 구조에 맞춰 경로를 확인해주세요.
import '../../core/app_export.dart';
import '../../widgets/custom_top_tab.dart';
import '../../widgets/custom_top_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../services/api_service.dart'; // ApiService 위치
import '../../models/models.dart'; // PlantInfo 모델 위치

/// PlantSelectionScreen - 재배할 식물 선택 화면
///
/// 기능:
/// - 서버 API로부터 재배 가능한 식물 목록 표시
/// - 각 식물의 이미지, 이름, 난이도 표시
/// - 식물 선택 버튼 -> 홈 화면으로 데이터 전달
class PlantSelectionScreen extends StatefulWidget {
  const PlantSelectionScreen({Key? key}) : super(key: key);

  @override
  State<PlantSelectionScreen> createState() => _PlantSelectionScreenState();
}

class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
  // 서버에서 받아올 식물 목록 Future
  late Future<List<PlantInfo>> _plantListFuture;

  @override
  void initState() {
    super.initState();
    _plantListFuture = _fetchPlants();
  }

  /// 식물 목록 API 호출
  Future<List<PlantInfo>> _fetchPlants() async {
    try {
      final List<dynamic> data = await ApiService.getAllPlants();
      // JSON 데이터를 PlantInfo 모델 리스트로 변환
      return data.map((json) => PlantInfo.fromJson(json)).toList();
    } catch (e) {
      print('식물 목록 로드 실패: $e');
      return []; // 에러 시 빈 리스트 반환
    }
  }

  /// 식물 이름에 따른 이미지 매핑 (API에 이미지 URL이 없을 경우를 대비한 로직)
  String _getPlantImage(String plantName) {
    if (plantName.contains('상추')) return 'assets/images/plant_lettuce.png';
    if (plantName.contains('토마토')) return 'assets/images/plant_tomato.png'; // 예시
    if (plantName.contains('바질')) return 'assets/images/plant_basil.png'; // 예시
    // 기본 이미지
    return 'assets/images/plant_lettuce.png';
  }

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
                '재배 난이도: ${plant.difficultyKorean}',
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
              onPressed: () async {
                if (ApiService.currentUserId != null) {
                  try {
                    // 로딩 표시
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: CircularProgressIndicator(color: appTheme.teal_400),
                      ),
                    );

                    // 서버에 내 식물로 등록 (deviceId: 1 추가)
                    await ApiService.createUserPlant(
                      userId: ApiService.currentUserId!,
                      plantId: plant.id,
                      nickname: plant.name,
                      startedAt: DateTime.now(),
                      deviceId: 1, // [수정] deviceId를 1로 고정하여 전달
                    );

                    Navigator.pop(context); // 로딩 닫기
                    Navigator.of(context).pop(); // 다이얼로그 닫기

                    // 홈 화면으로 이동
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.homeScreen,
                      arguments: plant,
                    );
                  } catch (e) {
                    Navigator.pop(context); // 로딩 닫기
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('식물 등록에 실패했습니다: $e')),
                    );
                  }
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그인 정보가 없습니다.')),
                  );
                }
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
      appBar: CustomTopAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            CustomTopTab(text: '재배할 식물 선택'),
            Expanded(
              // FutureBuilder로 데이터 로딩 상태 처리
              child: FutureBuilder<List<PlantInfo>>(
                future: _plantListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("데이터를 불러오는데 실패했습니다."));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("등록된 식물이 없습니다."));
                  }

                  final plants = snapshot.data!;

                  return ListView.builder(
                    padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      return _buildPlantCard(plants[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.homeScreen,
      ),
    );
  }

  /// 식물 카드 위젯
  Widget _buildPlantCard(PlantInfo plant) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w), // 좌우 여백 추가
      height: 136.h,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.h),
          bottomRight: Radius.circular(20.h),
          topLeft: Radius.circular(20.h), // 전체 둥근 모서리를 위해 추가
          bottomLeft: Radius.circular(20.h),
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.color66D3D3 ?? Color(0xFF66D3D3),
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
                // 로컬 이미지 에셋을 사용하거나 아이콘으로 대체
                // 예시: Image.asset(_getPlantImage(plant.name))
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
                    '재배 난이도 : ${plant.difficultyKorean}', // 한글 난이도
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