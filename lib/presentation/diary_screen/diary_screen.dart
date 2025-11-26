import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_top_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

/// DiaryScreen - 식물 성장 다이어리 화면
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
  int _userPlantId = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _userPlantId = args;
    }
    _fetchMonthData();
  }

  Future<void> _fetchMonthData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getDiaryCalendar(
        userPlantId: _userPlantId,
        year: _currentMonth.year,
        month: _currentMonth.month,
      );

      final calendarData = DiaryCalendar.fromJson(response);

      setState(() {
        _diaryCalendarData = calendarData;
        _calendarDaysMap = {
          for (var day in calendarData.days)
            DateFormat('yyyy-MM-dd').format(day.date): day
        };
      });
    } catch (e) {
      print('다이어리 목록 로드 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _fetchMonthData();
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _fetchMonthData();
  }

  void _onDateTapped(DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dayData = _calendarDaysMap[dateKey];

    if (dayData != null && dayData.hasDiary) {
      _fetchAndShowDetail(date);
    } else {
      _showDiaryCreateDialog(date);
    }
  }

  Future<void> _fetchAndShowDetail(DateTime date) async {
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
      Navigator.pop(context);

      final diary = Diary.fromJson(response);
      _showDiaryDetailDialog(diary);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다이어리를 불러오는데 실패했습니다.')),
      );
    }
  }

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

  void _captureDiaryPhoto(DateTime date) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Center(child: CircularProgressIndicator(color: appTheme.teal_400)),
      );

      try {
        await ApiService.createDiary(
          userPlantId: _userPlantId,
          diaryDate: date,
          content: '오늘의 성장 기록',
          imagePath: image.path,
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('다이어리가 등록되었습니다.'),
            backgroundColor: appTheme.teal_400,
          ),
        );
        _fetchMonthData();
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: ${e.toString()}')),
        );
      }
    }
  }

  void _showDiaryDetailDialog(Diary diary) {
    showDialog(
      context: context,
      barrierColor: Color(0x3FD9D9D9),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: DiaryDetailDialog(
          diary: diary,
          onDelete: () async {
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
                Navigator.of(context).pop();
                _fetchMonthData();
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

  void _goToTimelapse() async {
    try {
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
                Icon(Icons.play_circle_outline,
                    color: appTheme.teal_400, size: 48.h),
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
      backgroundColor: appTheme.white_A700,
      body: SafeArea(
        top: false,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: appTheme.teal_400))
            : CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
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
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    color: appTheme.blue_gray_700,
                    size: 28.h,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushNamed(
                      context, AppRoutes.myPageScreen),
                  icon: Icon(
                    Icons.person_outline,
                    color: appTheme.blue_gray_700,
                    size: 28.h,
                  ),
                ),
                SizedBox(width: 16.h),
              ],
            ),
            SliverToBoxAdapter(
              child: Stack(
                // [중요] Stack을 사용하여 겹치는 순서 제어
                children: [
                  // 1. 하단 달력 섹션 (먼저 그려짐 -> 아래에 깔림)
                  Padding(
                    padding: EdgeInsets.only(top: 198.h), // 상단 섹션 높이만큼 아래로 밀기
                    child: Container(
                      width: double.infinity,
                      color: appTheme.white_A700, // 흰색 배경
                      child: Column(
                        children: [
                          SizedBox(height: 30.h),
                          _buildCalendarSection(),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),

                  // 2. 상단 성장 정보 섹션 (나중에 그려짐 -> 위에 올라옴 + 그림자)
                  Container(
                    width: double.infinity,
                    height: 198.h,
                    decoration: BoxDecoration(
                      color: appTheme.green_50,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05), // 은은한 그림자
                          blurRadius: 20.h,
                          offset: Offset(0, 10.h), // 아래쪽으로 떨어지는 그림자
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: _buildGrowthInfoSection(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.diaryScreen,
      ),
    );
  }

  /// 성장 정보 섹션
  Widget _buildGrowthInfoSection() {
    final plantName = _diaryCalendarData?.plantName ?? '-';
    final daysSince = _diaryCalendarData?.daysSincePlanted ?? 0;
    final photoCount = _diaryCalendarData?.photoCount ?? 0;
    final firstDate = _diaryCalendarData?.firstPlantedDate ?? DateTime.now();

    return Container(
      height: 235.h,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 20.h,
            child: Container(
              padding: EdgeInsets.only(
                top: 4.h,
                left: 17.h,
                right: 20.h,
                bottom: 4.h,
              ),
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
                '$plantName 성장 다이어리',
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
          Positioned(
            left: 16.h,
            right: 16.h,
            top: 62.h,
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
          Positioned(
            left: 16.h,
            right: 16.h,
            top: 96.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildFirstPlantingInfo(firstDate)),
                Expanded(child: _buildInfoItem('재배일수', '${daysSince}일')),
                Expanded(child: _buildInfoItem('사진수', '${photoCount}장')),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 170.h,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
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
        SizedBox(height: 11.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.year}',
              style: TextStyle(
                color: const Color(0xFF797979),
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.0,
                letterSpacing: -0.40,
              ),
            ),
            SizedBox(width: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 2.h),
              decoration: ShapeDecoration(
                color: const Color(0xFFE3FAE8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.h),
                ),
              ),
              child: Text(
                '${date.month}/${date.day}',
                style: TextStyle(
                  color: const Color(0xFF797979),
                  fontSize: 14.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                  letterSpacing: -0.40,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
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
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.chevron_left,
                color: const Color(0xFF32C697), size: 22.h),
            onPressed: _goToPreviousMonth,
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
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.chevron_right,
                color: const Color(0xFF32C697), size: 22.h),
            onPressed: _goToNextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader() {
    final weekDays = ['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      children: List.generate(7, (index) {
        return Expanded(
          child: Container(
            height: 43.h,
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

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
    DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
    DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;
    final lastDayOfPrevMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    List<Widget> dayWidgets = [];

    for (int i = firstWeekday - 1; i >= 0; i--) {
      dayWidgets.add(Expanded(
        child: _buildDayCell(
          lastDayOfPrevMonth - i,
          isCurrentMonth: false,
        ),
      ));
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
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