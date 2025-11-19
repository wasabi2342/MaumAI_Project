import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위해 추가

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_top_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

/// DiaryScreen - 식물 성장 다이어리 화면 (API 연동)
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _currentMonth = DateTime.now();

  // API 데이터 캐싱
  DiaryCalendar? _diaryCalendarData;
  Map<String, DiaryCalendarDay> _calendarDaysMap = {};

  bool _isLoading = false;
  int _userPlantId = 1; // 기본값 1, 실제로는 arguments로 받아야 함

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드는 didChangeDependencies에서 수행
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 라우트 인자에서 userPlantId 가져오기 (없으면 기본값 유지)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _userPlantId = args;
    }
    _fetchMonthData();
  }

  /// 월별 데이터 API 조회
  Future<void> _fetchMonthData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getDiaryCalendar(
        userPlantId: _userPlantId,
        year: _currentMonth.year,
        month: _currentMonth.month,
      );

      // DiaryCalendar 모델 변환
      final calendarData = DiaryCalendar.fromJson(response);

      setState(() {
        _diaryCalendarData = calendarData;
        // 날짜별 빠른 조회를 위해 Map으로 변환 (Key: "yyyy-MM-dd")
        _calendarDaysMap = {
          for (var day in calendarData.days)
            DateFormat('yyyy-MM-dd').format(day.date): day
        };
      });
    } catch (e) {
      print('다이어리 목록 로드 실패: $e');
      // 에러 시 빈 상태 유지
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 이전 달로 이동
  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _fetchMonthData();
  }

  /// 다음 달로 이동
  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _fetchMonthData();
  }

  /// 날짜 클릭 핸들러
  void _onDateTapped(DateTime date) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dayData = _calendarDaysMap[dateKey];

    if (dayData != null && dayData.hasDiary) {
      // 다이어리가 있는 경우 - 상세 조회 API 호출
      _fetchAndShowDetail(date);
    } else {
      // 다이어리가 없는 경우 - 작성 팝업
      _showDiaryCreateDialog(date);
    }
  }

  /// 다이어리 상세 조회 및 팝업 표시
  Future<void> _fetchAndShowDetail(DateTime date) async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: appTheme.teal_400)),
    );

    try {
      final response = await ApiService.getDiaryByDate(
        userPlantId: _userPlantId,
        date: date,
      );
      Navigator.pop(context); // 로딩 닫기

      final diary = Diary.fromJson(response);
      _showDiaryDetailDialog(diary);
    } catch (e) {
      Navigator.pop(context); // 로딩 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다이어리를 불러오는데 실패했습니다.')),
      );
    }
  }

  /// 다이어리 작성 팝업
  void _showDiaryCreateDialog(DateTime date) {
    showDialog(
      context: context,
      barrierColor: Color(0x3FD9D9D9),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: DiaryCreateDialog(
          date: date,
          onPhotoCapture: () {
            Navigator.of(context).pop();
            _captureDiaryPhoto(date);
          },
        ),
      ),
    );
  }

  /// 사진 촬영/선택 및 다이어리 생성 API 호출
  void _captureDiaryPhoto(DateTime date) async {
    final ImagePicker picker = ImagePicker();
    // 갤러리에서 선택 (카메라로 변경하려면 source: ImageSource.camera)
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(child: CircularProgressIndicator(color: appTheme.teal_400)),
      );

      try {
        // API 호출
        await ApiService.createDiary(
          userPlantId: _userPlantId,
          diaryDate: date,
          content: '오늘의 성장 기록', // 초기 기본값
          imagePath: image.path,
        );

        Navigator.pop(context); // 로딩 닫기

        // 성공 메시지 및 새로고침
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('다이어리가 등록되었습니다.'),
            backgroundColor: appTheme.teal_400,
          ),
        );
        _fetchMonthData(); // 목록 갱신
      } catch (e) {
        Navigator.pop(context); // 로딩 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: ${e.toString()}')),
        );
      }
    }
  }

  /// 다이어리 상세보기 팝업
  void _showDiaryDetailDialog(Diary diary) {
    showDialog(
      context: context,
      barrierColor: Color(0x3FD9D9D9),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: DiaryDetailDialog(
          diary: diary,
          onDelete: () async {
            // 삭제 확인
            bool confirm = await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('삭제 확인'),
                content: Text('정말로 이 일기를 삭제하시겠습니까?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('취소')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('삭제')),
                ],
              ),
            ) ??
                false;

            if (confirm) {
              try {
                await ApiService.deleteDiary(diary.id);
                Navigator.of(context).pop(); // 상세 팝업 닫기
                _fetchMonthData(); // 목록 갱신
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('삭제되었습니다.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('삭제 실패: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  /// 타임랩스 화면으로 이동 (API 연동)
  void _goToTimelapse() async {
    try {
      // 타임라인 데이터 조회
      final timelineData = await ApiService.getTimeline(_userPlantId);
      final timeline = DiaryTimeline.fromJson(timelineData);

      if (timeline.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('타임랩스를 생성할 사진이 충분하지 않습니다.'),
            backgroundColor: appTheme.teal_400,
          ),
        );
        return;
      }

      // TODO: 타임랩스 플레이어 화면으로 이동하며 timeline 데이터 전달
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
                Icon(
                  Icons.play_circle_outline,
                  color: appTheme.teal_400,
                  size: 48.h,
                ),
                SizedBox(height: 16.h),
                Text(
                  '타임랩스 재생',
                  style: TextStyle(
                    color: appTheme.gray_800,
                    fontSize: 18.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${timeline.items.length}장의 사진으로\n타임랩스를 재생합니다.',
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
                onPressed: () => Navigator.of(context).pop(),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('타임라인 조회 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      appBar: CustomTopAppBar(),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 393.h),
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? Center(
                      child: CircularProgressIndicator(
                          color: appTheme.teal_400))
                      : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildGrowthInfoSection(),
                        SizedBox(height: 20.h),
                        _buildCalendarSection(),
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
        activeRoute: AppRoutes.diaryScreen,
      ),
    );
  }

  /// 성장 정보 섹션 (API 데이터 바인딩) - Overflow 수정됨
  Widget _buildGrowthInfoSection() {
    // 데이터가 없으면 기본값 표시
    final plantName = _diaryCalendarData?.plantName ?? '-';
    final daysSince = _diaryCalendarData?.daysSincePlanted ?? 0;
    final photoCount = _diaryCalendarData?.photoCount ?? 0;
    final firstDate = _diaryCalendarData?.firstPlantedDate ?? DateTime.now();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      height: 235.h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE3FAE8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x66D3D3D3),
            blurRadius: 8.h,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 식물 성장 다이어리 라벨
          Positioned(
            left: 0,
            top: 57.h,
            child: Container(
              padding: EdgeInsets.only(
                top: 4.h,
                left: 17.h,
                right: 20.h,
                bottom: 4.h,
              ),
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
              child: Text(
                '$plantName 성장 다이어리', // 식물 이름 동적 표시
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
            ),
          ),
          // 정보 카드 배경
          Positioned(
            left: 16.h,
            right: 16.h,
            top: 99.h,
            child: Container(
              height: 136.h,
              decoration: ShapeDecoration(
                color: const Color(0xFFFDFEFB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.h),
                    topRight: Radius.circular(20.h),
                  ),
                ),
              ),
            ),
          ),
          // [수정] 정보 아이템들을 Row로 묶어서 균등 배치 (Overflow 방지)
          Positioned(
            left: 16.h,
            right: 16.h,
            top: 133.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 공간 균등 분배
              children: [
                _buildFirstPlantingInfo(firstDate),
                _buildInfoItem('재배일수', '${daysSince}일'),
                _buildInfoItem('사진수', '${photoCount}장'),
              ],
            ),
          ),
          // 타임랩스 버튼
          Positioned(
            left: 0,
            right: 0,
            top: 207.h,
            child: Center(
              child: InkWell(
                onTap: _goToTimelapse,
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 22.h, vertical: 6.h),
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        appTheme.green_200,
                        appTheme.teal_400,
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.h),
                        topRight: Radius.circular(20.h),
                      ),
                    ),
                  ),
                  child: Text(
                    '타임랩스',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFFDFEFB),
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      height: 1.0,
                      letterSpacing: -0.35,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstPlantingInfo(DateTime date) {
    return SizedBox(
      width: 95.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 95.h,
            child: Text(
              '첫 재배',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF37705E),
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.0,
                letterSpacing: -0.35,
              ),
            ),
          ),
          SizedBox(height: 11.h),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${date.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF797979),
                    fontSize: 16.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                    letterSpacing: -0.40,
                  ),
                ),
                SizedBox(width: 6.h),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.h, vertical: 2.h),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE3FAE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.h),
                    ),
                  ),
                  child: Text(
                    '${date.month}/${date.day}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF797979),
                      fontSize: 16.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      letterSpacing: -0.40,
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF37705E),
            fontSize: 14.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: -0.35,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF797979),
            fontSize: 16.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            height: 1.0,
            letterSpacing: -0.40,
          ),
        ),
      ],
    );
  }

  /// 달력 섹션
  Widget _buildCalendarSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.h),
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
      child: Column(
        children: [
          _buildCalendarHeader(),
          _buildWeekDaysHeader(),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE3FAE8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.h),
          topRight: Radius.circular(20.h),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.h,
            height: 22.h,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.chevron_left,
                  color: const Color(0xFF32C697), size: 22.h),
              onPressed: _goToPreviousMonth,
            ),
          ),
          SizedBox(width: 10.h),
          Text(
            '${_currentMonth.year}년 ${_currentMonth.month}월',
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
          SizedBox(width: 10.h),
          SizedBox(
            width: 16.h,
            height: 22.h,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.chevron_right,
                  color: const Color(0xFF32C697), size: 22.h),
              onPressed: _goToNextMonth,
            ),
          ),
        ],
      ),
    );
  }

  /// 요일 헤더 빌드 (Expanded 사용으로 Overflow 방지)
  Widget _buildWeekDaysHeader() {
    final weekDays = ['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      children: List.generate(7, (index) {
        return Expanded(
          child: Container(
            height: 43.h,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFFE3FAE8),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: const Color(0xFF32C697),
                ),
              ),
            ),
            child: Center(
              child: Text(
                weekDays[index],
                style: TextStyle(
                  color: const Color(0xFF37705E),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: -0.35,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 달력 그리드 빌드 (Expanded 사용으로 Overflow 방지)
  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
    DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
    DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0: 일요일
    final daysInMonth = lastDayOfMonth.day;
    final lastDayOfPrevMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    List<Widget> dayWidgets = [];

    // 이전 달
    for (int i = firstWeekday - 1; i >= 0; i--) {
      dayWidgets.add(Expanded(
        child: _buildDayCell(
          lastDayOfPrevMonth - i,
          isCurrentMonth: false,
        ),
      ));
    }

    // 현재 달
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final dayData = _calendarDaysMap[dateKey];
      final hasDiary = dayData?.hasDiary ?? false;

      dayWidgets.add(Expanded(
        child: _buildDayCell(
          day,
          date: date,
          isCurrentMonth: true,
          hasDiary: hasDiary,
        ),
      ));
    }

    // 다음 달
    final remainingCells = 42 - dayWidgets.length;
    for (int day = 1; day <= remainingCells; day++) {
      dayWidgets.add(Expanded(
        child: _buildDayCell(
          day,
          isCurrentMonth: false,
        ),
      ));
    }

    return Column(
      children: [
        for (int week = 0; week < 6; week++)
          Row(
            children: dayWidgets.sublist(week * 7, (week * 7) + 7),
          ),
      ],
    );
  }

  /// 날짜 셀 빌드
  Widget _buildDayCell(
      int day, {
        DateTime? date,
        bool isCurrentMonth = true,
        bool hasDiary = false,
      }) {
    Color textColor;
    if (!isCurrentMonth) {
      textColor = const Color(0xFFD3D3D3);
    } else if (date?.weekday == DateTime.sunday) {
      textColor = const Color(0xFFEC7243);
    } else if (date?.weekday == DateTime.saturday) {
      textColor = const Color(0xFF32C697);
    } else {
      textColor = const Color(0xFF1B1B1B);
    }

    return InkWell(
      onTap: isCurrentMonth && date != null ? () => _onDateTapped(date) : null,
      child: Container(
        height: 52.h,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFFDFEFB),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: const Color(0xFFD3D3D3)),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: day < 10 ? 4.h : 3.h,
              top: 4.h,
              child: Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                  letterSpacing: -0.35,
                ),
              ),
            ),
            if (hasDiary)
              Positioned(
                right: 4.h,
                bottom: 4.h,
                child: Icon(
                  Icons.eco,
                  size: 16.h,
                  color: const Color(0xFF32C697),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 다이어리 작성 팝업
class DiaryCreateDialog extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPhotoCapture;

  const DiaryCreateDialog({
    Key? key,
    required this.date,
    required this.onPhotoCapture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 48.h),
      child: Container(
        width: 297.h,
        padding: EdgeInsets.all(27.h),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${date.year}   ${date.month}/${date.day}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
            SizedBox(height: 30.h),
            InkWell(
              onTap: onPhotoCapture,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.h),
                decoration: BoxDecoration(
                  color: appTheme.teal_400,
                  borderRadius: BorderRadius.circular(10.h),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_alt,
                        color: appTheme.white_A700, size: 20.h),
                    SizedBox(width: 8.h),
                    Text(
                      '사진 촬영',
                      style: TextStyle(
                        color: appTheme.white_A700,
                        fontSize: 14.fSize,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              '사진을 등록하여\n일기를 작성해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(Icons.close, color: Color(0xFF797979), size: 24.h),
            ),
          ],
        ),
      ),
    );
  }
}

/// 다이어리 상세보기 팝업 (API 데이터 연동)
class DiaryDetailDialog extends StatelessWidget {
  final Diary diary;
  final VoidCallback onDelete;

  const DiaryDetailDialog({
    Key? key,
    required this.diary,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 48.h),
      child: Container(
        width: 297.h,
        padding: EdgeInsets.all(27.h),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${diary.diaryDate.year}   ${diary.diaryDate.month}/${diary.diaryDate.day}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTheme.teal_400,
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
            SizedBox(height: 20.h),
            // 사진 표시 영역
            Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: appTheme.green_50,
                borderRadius: BorderRadius.circular(10.h),
              ),
              clipBehavior: Clip.antiAlias,
              child: diary.imageUrl != null && diary.imageUrl!.isNotEmpty
                  ? CustomImageView(
                imagePath: diary.imageUrl,
                fit: BoxFit.cover,
              )
                  : Center(
                child: Icon(
                  Icons.image,
                  size: 60.h,
                  color: appTheme.teal_400,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 메모 내용
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15.h),
              decoration: BoxDecoration(
                color: appTheme.green_50,
                borderRadius: BorderRadius.circular(10.h),
              ),
              child: Text(
                diary.content ?? '내용 없음',
                style: TextStyle(
                  color: Color(0xFF797979),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // 수정 기능은 추후 구현
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('수정 기능은 준비중입니다.')),
                    );
                  },
                  child: Text(
                    '수정',
                    style: TextStyle(
                      color: appTheme.teal_400,
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onDelete,
                  child: Text(
                    '삭제',
                    style: TextStyle(
                      color: appTheme.redCustom,
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      color: Color(0xFF797979),
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
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
}