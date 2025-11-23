import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';

import '../../core/app_export.dart';
import '../../widgets/custom_top_tab.dart';
// import '../../widgets/custom_top_app_bar.dart'; // SliverAppBar 직접 구현으로 제거
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/notification_sidebar.dart'; // 알림 사이드바 추가
import '../../services/api_service.dart';
import '../../models/models.dart';

/// PlantSelectionScreen - 재배할 식물 선택 화면
///
/// 수정 사항:
/// - CustomScrollView + SliverAppBar 적용 (스크롤 시 상단 앱바 숨김 처리)
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
      return data.map((json) => PlantInfo.fromJson(json)).toList();
    } catch (e) {
      print('식물 목록 로드 실패: $e');
      return [];
    }
  }

  /// 알림 사이드바 표시 (CustomTopAppBar 기능을 직접 구현)
  void _showNotificationSidebar(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Color(0x3FD9D9D9),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation animation,
          Animation secondaryAnimation) {
        return NotificationSidebar(
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _selectPlant(PlantInfo plant) {
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
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: CircularProgressIndicator(color: appTheme.teal_400),
                      ),
                    );

                    await ApiService.createUserPlant(
                      userId: ApiService.currentUserId!,
                      plantId: plant.id,
                      nickname: plant.name,
                      startedAt: DateTime.now(),
                      deviceId: 1,
                    );

                    Navigator.pop(context); // 로딩 닫기
                    Navigator.of(context).pop(); // 다이얼로그 닫기

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
      // appBar 제거 (SliverAppBar 사용)
      body: SafeArea(
        child: FutureBuilder<List<PlantInfo>>(
          future: _plantListFuture,
          builder: (context, snapshot) {
            // 1. 로딩 중
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: appTheme.teal_400));
            }
            // 2. 에러 발생
            else if (snapshot.hasError) {
              return Center(child: Text("데이터를 불러오는데 실패했습니다."));
            }

            final plants = snapshot.data ?? [];

            // 3. 데이터 로드 완료 -> CustomScrollView 반환
            return CustomScrollView(
              slivers: [
                // [1] 스크롤 시 사라지는 상단 앱바
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: false, // 스크롤 시 완전히 사라짐 (DiagnosisScreen과 동일)
                  elevation: 0,
                  backgroundColor: appTheme.green_50,
                  automaticallyImplyLeading: false,
                  title: CustomImageView(
                    imagePath: ImageConstant.img,
                    height: 28.h,
                    fit: BoxFit.contain,
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: () => _showNotificationSidebar(context),
                      icon: Icon(
                        Icons.notifications_none_outlined,
                        color: appTheme.blue_gray_700,
                        size: 28.h,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.myPageScreen),
                      icon: Icon(
                        Icons.person_outline,
                        color: appTheme.blue_gray_700,
                        size: 28.h,
                      ),
                    ),
                    SizedBox(width: 16.h),
                  ],
                ),

                // [2] 탭 제목 (SliverToBoxAdapter 사용)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      CustomTopTab(text: '재배할 식물 선택'),
                      // 식물이 없을 경우 처리
                      if (plants.isEmpty)
                        Container(
                          height: 400.h,
                          alignment: Alignment.center,
                          child: Text(
                            "등록된 식물이 없습니다.",
                            style: TextStyle(
                              color: appTheme.gray_800,
                              fontSize: 16.fSize,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // [3] 식물 목록 리스트 (SliverList 사용)
                if (plants.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return _buildPlantCard(plants[index]);
                        },
                        childCount: plants.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.homeScreen,
      ),
    );
  }

  /// 식물 카드 위젯 (기존 유지)
  Widget _buildPlantCard(PlantInfo plant) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
      height: 136.h,
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.circular(20.h),
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
                    '재배 난이도 : ${plant.difficultyKorean}',
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