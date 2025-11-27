import 'dart:ui';
import 'dart:io'; // 파일 처리를 위해 추가
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 피커 추가

import '../../core/app_export.dart';
import '../../services/api_service.dart'; // API 서비스 추가
import '../../widgets/custom_top_tab.dart';
import '../../widgets/notification_sidebar.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

/// DiagnosisScreen - AI 식물 진단 화면
class DiagnosisScreen extends StatefulWidget {
  // [수정] 기본값을 101에서 1로 변경했습니다.
  final int userPlantId;

  const DiagnosisScreen({
    Key? key,
    this.userPlantId = 1, // [변경됨] ID 1번 식물로 요청
  }) : super(key: key);

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final ImagePicker _picker = ImagePicker(); // 이미지 피커 인스턴스
  bool _isLoading = false; // 로딩 상태 관리
  File? _selectedImage; // [추가] 선택된 이미지 파일을 저장할 변수

  // 진단 결과 데이터 상태 관리
  DiagnosisResult _diagnosisResult = DiagnosisResult(
    healthStatus: '진단이 필요합니다',
    healthAdvice: '사진을 촬영하여\nAI 진단을 받아보세요.',
    pestStatus: '-',
    pestAdvice: '-',
    harvestDate: DateTime.now().add(Duration(days: 30)),
  );

  // 자주 묻는 질문 목록
  final List<FaqItem> _faqItems = [
    FaqItem(question: '언제 수확 하나요?'),
    FaqItem(question: '양액은 언제 넣나요?'),
    FaqItem(question: '잎이 시들면 어떻게 하나요?'),
    FaqItem(question: '햇빛은 얼마나 필요한가요?'),
  ];

  // 1. 카메라/갤러리 선택 다이얼로그
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
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
              Icon(Icons.camera_alt, color: appTheme.teal_400, size: 48.h),
              SizedBox(height: 16.h),
              Text(
                'AI 식물 진단',
                style: TextStyle(
                  color: appTheme.gray_800,
                  fontSize: 18.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '촬영 방법을 선택해주세요.',
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
                _pickImage(ImageSource.camera); // 카메라 실행
              },
              child: Text(
                '카메라',
                style: TextStyle(
                  color: appTheme.teal_400,
                  fontSize: 16.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery); // 갤러리 실행
              },
              child: Text(
                '갤러리',
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

  // 2. 이미지 가져오기 및 분석 요청
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        // [수정] 이미지가 선택되면 상태를 업데이트하여 화면에 표시
        setState(() {
          _selectedImage = File(image.path);
        });
        _analyzeImage(image.path);
      }
    } catch (e) {
      print("이미지 선택 오류: $e");
    }
  }

  // 3. API 호출 및 결과 처리
  Future<void> _analyzeImage(String imagePath) async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    try {
      // API 호출 (widget.userPlantId는 이제 1이 됨)
      final resultData = await ApiService.requestDiagnosis(
        userPlantId: widget.userPlantId,
        imagePath: imagePath,
      );

      // 백엔드 날짜 형식(LocalDate) 처리
      DateTime parsedHarvestDate = DateTime.now();
      if (resultData['harvestPredictionDate'] != null) {
        try {
          parsedHarvestDate = DateTime.parse(resultData['harvestPredictionDate'].toString());
        } catch (e) {
          print("날짜 파싱 오류: $e");
        }
      }

      // UI 업데이트
      setState(() {
        _diagnosisResult = DiagnosisResult(
          healthStatus: resultData['healthSummary'] ?? '상태 정보 없음',
          healthAdvice: resultData['advice'] ?? '제공된 조언이 없습니다.',
          pestStatus: resultData['diseaseStatus'] ?? '정상',
          pestAdvice: resultData['diseaseDetails'] ?? '발견된 특이사항이 없습니다.',
          harvestDate: parsedHarvestDate,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI 진단이 완료되었습니다.")),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("진단 중 오류 발생: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }

  // ... (사이드바 로직 유지) ...
  void _showNotificationSidebar(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Color(0x3FD9D9D9),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return NotificationSidebar(onClose: () => Navigator.of(context).pop());
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.white_A700,
      body: Stack( // 로딩 인디케이터를 띄우기 위해 Stack 사용
        children: [
          SafeArea(
            top: false,
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 393.h),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      floating: true, snap: true, pinned: false, elevation: 0,
                      backgroundColor: appTheme.green_50,
                      automaticallyImplyLeading: false,
                      title: CustomImageView(imagePath: ImageConstant.img, height: 28.h, fit: BoxFit.contain),
                      centerTitle: true,
                      actions: [
                        IconButton(onPressed: () => _showNotificationSidebar(context), icon: Icon(Icons.notifications_none_outlined, color: appTheme.blue_gray_700, size: 28.h)),
                        IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.myPageScreen), icon: Icon(Icons.person_outline, color: appTheme.blue_gray_700, size: 28.h)),
                        SizedBox(width: 16.h),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // 1. 상단 초록색 배경 영역
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: appTheme.green_50,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20.h, offset: Offset(0, 10.h), spreadRadius: 0),
                              ],
                            ),
                            child: Column(
                              children: [
                                CustomTopTab(text: '진단'),
                                SizedBox(height: 12.h),
                                _buildTimeAnalysisLabel(),
                                SizedBox(height: 16.h),
                                _buildPhotoAnalysisSection(), // [수정] 이미지 표시 영역
                              ],
                            ),
                          ),
                          // 2. 하단 흰색 배경 영역
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                SizedBox(height: 30.h),
                                _buildDiagnosisCardsRow(),
                                SizedBox(height: 16.h),
                                _buildHarvestPredictionCard(),
                                SizedBox(height: 16.h),
                                _buildFaqSection(),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 로딩 오버레이
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: appTheme.teal_400),
                    SizedBox(height: 16.h),
                    Text("AI가 식물을 진단중입니다...", style: TextStyle(color: Colors.white, fontSize: 16.fSize, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(activeRoute: AppRoutes.diagnosisScreen),
    );
  }

  Widget _buildTimeAnalysisLabel() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(top: 4.h, left: 17.h, right: 20.h, bottom: 4.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFFDFEFB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topRight: Radius.circular(20.h), bottomRight: Radius.circular(20.h)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('사진분석', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF32C697), fontSize: 16.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w500, height: 1.0, letterSpacing: -0.40)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoAnalysisSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      height: 167.h, // 박스 높이는 167.h로 고정
      clipBehavior: Clip.antiAlias, // 이미지가 둥근 모서리를 넘지 않도록 자름
      decoration: ShapeDecoration(
        color: const Color(0xFFFBFEF9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.h),
            topRight: Radius.circular(20.h),
          ),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x66D3D3D3),
            blurRadius: 8.h,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: _showImageSourceDialog,
        // [수정] 이미지가 있으면 이미지를 표시, 없으면 기존 아이콘 표시
        child: _selectedImage != null
            ? Image.file(
          _selectedImage!,
          height: 167.h, // [수정] 이미지 높이를 박스 높이와 동일하게 설정
          width: double.infinity, // [수정] 가로는 최대한 채움
          fit: BoxFit.fitHeight, // [수정] 높이에 맞춰 축소/확대 (가로는 비율에 따라 잘리거나 여백 생김)
          alignment: Alignment.center, // 중앙 정렬
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 40.h, color: const Color(0xFF32C697)),
              SizedBox(height: 10.h),
              Text(
                '사진 촬영',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF32C697),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  letterSpacing: -0.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisCardsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Row(
        children: [
          Expanded(child: _buildHealthCheckCard()),
          SizedBox(width: 21.h),
          Expanded(child: _buildPestDiagnosisCard()),
        ],
      ),
    );
  }

  Widget _buildHealthCheckCard() {
    return Container(
      width: 142.h,
      height: 300.h, // [수정] 높이 증가 반영
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFBFEF9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.h)),
        shadows: [BoxShadow(color: const Color(0x66D3D3D3), blurRadius: 8.h, offset: Offset(0, 4.h), spreadRadius: 0)],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity, height: 36.h,
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [appTheme.green_200, appTheme.teal_400])),
            child: Center(
              child: Text('건강체크', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFFFDFEFB), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w600, height: 1.0, letterSpacing: -0.35)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 10.h, top: 15.h, right: 10.h, bottom: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        _diagnosisResult.healthStatus,
                        textAlign: TextAlign.justify, // [수정] 양쪽 정렬 유지
                        style: TextStyle(color: const Color(0xFF797979), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w500, height: 1.3)
                    ),
                    SizedBox(height: 24.h),
                    Text(
                        _diagnosisResult.healthAdvice,
                        textAlign: TextAlign.justify, // [수정] 양쪽 정렬 유지
                        style: TextStyle(color: const Color(0xFF797979), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w500, height: 1.3)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPestDiagnosisCard() {
    return Container(
      width: 198.h,
      height: 300.h, // [수정] 높이 증가 반영
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFFBFEF9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.h)),
        shadows: [BoxShadow(color: const Color(0x66D3D3D3), blurRadius: 8.h, offset: Offset(0, 4.h), spreadRadius: 0)],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity, height: 36.h,
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [appTheme.green_200, appTheme.teal_400])),
            child: Center(
              child: Text('병해충 진단', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFFFDFEFB), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w600, height: 1.0, letterSpacing: -0.35)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(left: 16.h, top: 15.h, right: 16.h, bottom: 15.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        _diagnosisResult.pestStatus,
                        textAlign: TextAlign.justify, // [수정] 양쪽 정렬 유지
                        style: TextStyle(color: const Color(0xFF797979), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w500, height: 1.3)
                    ),
                    SizedBox(height: 24.h),
                    Text(
                        _diagnosisResult.pestAdvice,
                        textAlign: TextAlign.justify, // [수정] 양쪽 정렬 유지
                        style: TextStyle(color: const Color(0xFF797979), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w500, height: 1.3)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestPredictionCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Container(
        width: double.infinity, height: 99.h,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFFBFEF9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.h)),
          shadows: [BoxShadow(color: const Color(0x66D3D3D3), blurRadius: 8.h, offset: Offset(0, 4.h))],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity, height: 36.h,
              decoration: BoxDecoration(color: const Color(0xFFE3FAE8)),
              child: Center(
                child: Text('수확시기 예측', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF32C697), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w700)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 18.h, top: 15.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI 예상 수확일', style: TextStyle(color: const Color(0xFF797979), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w700)),
                    SizedBox(height: 4.h),
                    Text('${_diagnosisResult.harvestDate.year}. ${_diagnosisResult.harvestDate.month} / ${_diagnosisResult.harvestDate.day}', style: TextStyle(color: const Color(0xFF797979), fontSize: 10.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h),
      child: Container(
        width: 360.h,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFFBFEF9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20.h), topRight: Radius.circular(20.h))),
          shadows: [BoxShadow(color: const Color(0x66D3D3D3), blurRadius: 8.h, offset: Offset(0, 4.h))],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity, height: 36.h,
              decoration: BoxDecoration(color: const Color(0xFFD3D3D3)),
              child: Center(
                child: Text('자주 묻는 질문', textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF3B3B3B), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(left: 29.h, top: 15.h, right: 29.h),
              itemCount: _faqItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      width: 302.h, height: 24.h,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.h, top: 5.h),
                        child: Text(_faqItems[index].question, style: TextStyle(color: const Color(0xFF797979), fontSize: 14.fSize, fontFamily: 'Pretendard', fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DiagnosisResult {
  final String healthStatus;
  final String healthAdvice;
  final String pestStatus;
  final String pestAdvice;
  final DateTime harvestDate;

  DiagnosisResult({
    required this.healthStatus,
    required this.healthAdvice,
    required this.pestStatus,
    required this.pestAdvice,
    required this.harvestDate,
  });
}

class FaqItem {
  final String question;
  FaqItem({required this.question});
}