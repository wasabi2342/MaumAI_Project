
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';

/// DiaryScreen - 식물 성장 다이어리 화면
///
/// 기능:
/// - 월별 달력 표시
/// - 다이어리 작성한 날짜에 아이콘 표시
/// - 다이어리 없는 날짜 클릭 시 작성 팝업
/// - 다이어리 있는 날짜 클릭 시 상세보기 팝업
/// - 타임랩스 기능 (한 달 사진 모음)
/// - 재배 정보 표시 (첫 재배일, 재배일수, 사진수)
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, DiaryEntry> _diaryEntries = {}; // 다이어리 데이터

  // 재배 정보
  final String _plantName = '상추';
  final DateTime _firstPlantDate = DateTime(2025, 9, 5);

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
  }

  /// 다이어리 데이터 로드 (실제로는 API나 로컬 DB에서)
  void _loadDiaryEntries() {
    // 샘플 데이터
    setState(() {
      _diaryEntries = {
        DateTime(2025, 11, 8): DiaryEntry(
          date: DateTime(2025, 11, 8),
          photoPath: 'sample_photo_1.jpg',
          note: '첫 잎이 나왔어요!',
        ),
        DateTime(2025, 11, 15): DiaryEntry(
          date: DateTime(2025, 11, 15),
          photoPath: 'sample_photo_2.jpg',
          note: '잎이 더 커졌어요.',
        ),
        DateTime(2025, 11, 22): DiaryEntry(
          date: DateTime(2025, 11, 22),
          photoPath: 'sample_photo_3.jpg',
          note: '건강하게 자라고 있어요.',
        ),
      };
    });
  }

  /// 재배 일수 계산
  int get _cultivationDays {
    return DateTime.now().difference(_firstPlantDate).inDays;
  }

  /// 사진 수 계산
  int get _photoCount {
    return _diaryEntries.length;
  }

  /// 이전 달로 이동
  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  /// 다음 달로 이동
  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  /// 날짜 클릭 핸들러
  void _onDateTapped(DateTime date) {
    // 날짜 정규화 (시간 제거)
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (_diaryEntries.containsKey(normalizedDate)) {
      // 다이어리가 있는 경우 - 상세보기 팝업
      _showDiaryDetailDialog(normalizedDate);
    } else {
      // 다이어리가 없는 경우 - 작성 팝업
      _showDiaryCreateDialog(normalizedDate);
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

  /// 사진 촬영 및 다이어리 작성
  void _captureDiaryPhoto(DateTime date) {
    // TODO: 실제 카메라 기능 구현
    // 임시로 다이어리 추가
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
                Icons.camera_alt,
                color: appTheme.teal_400,
                size: 48.h,
              ),
              SizedBox(height: 16.h),
              Text(
                '사진 촬영 기능',
                style: TextStyle(
                  color: appTheme.gray_800,
                  fontSize: 18.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '카메라 기능은 실제 앱에서 구현됩니다.',
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
                // 샘플 다이어리 추가
                setState(() {
                  _diaryEntries[date] = DiaryEntry(
                    date: date,
                    photoPath: 'new_photo.jpg',
                    note: '새로운 기록',
                  );
                });
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

  /// 다이어리 상세보기 팝업
  void _showDiaryDetailDialog(DateTime date) {
    final entry = _diaryEntries[date];
    if (entry == null) return;

    showDialog(
      context: context,
      barrierColor: Color(0x3FD9D9D9),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: DiaryDetailDialog(
          entry: entry,
          onDelete: () {
            Navigator.of(context).pop();
            setState(() {
              _diaryEntries.remove(date);
            });
          },
        ),
      ),
    );
  }

  /// 타임랩스 화면으로 이동
  void _goToTimelapse() {
    // 현재 월의 다이어리만 필터링
    final monthEntries = _diaryEntries.entries
        .where((entry) =>
    entry.key.year == _currentMonth.year &&
        entry.key.month == _currentMonth.month)
        .map((e) => e.value)
        .toList();

    if (monthEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이번 달에 작성한 다이어리가 없습니다.'),
          backgroundColor: appTheme.teal_400,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // TODO: 타임랩스 화면으로 이동
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
                '${monthEntries.length}장의 사진으로\n타임랩스를 생성합니다.',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.green_50,
      appBar: CustomTopAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildGrowthInfoSection(),
                    SizedBox(height: 20.h),
                    _buildCalendarSection(),
                  ],
                ),
              ),
            ),
            // _buildBottomNavigation(), // <-- 이 부분이 삭제됩니다.
          ],
        ),
      ),
      // v-- 이 부분이 추가됩니다. --v
      bottomNavigationBar: CustomBottomNavBar(
        activeRoute: AppRoutes.diaryScreen,
      ),
      // ^-- 이 부분이 추가됩니다. --^
    );
  }


  /// 성장 정보 섹션
  Widget _buildGrowthInfoSection() {
    return Container(
      width: double.infinity,
      height: 235.h,
      decoration: BoxDecoration(
        color: appTheme.green_50,
        boxShadow: [
          BoxShadow(
            color: appTheme.color66D3D3,
            blurRadius: 8.h,
            offset: Offset(0, 0),
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
              padding: EdgeInsets.symmetric(horizontal: 17.h, vertical: 4.h),
              decoration: BoxDecoration(
                color: appTheme.white_A700,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.h),
                  bottomRight: Radius.circular(20.h),
                ),
              ),
              child: Text(
                '식물 성장 다이어리',
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
          ),
          // 정보 카드 배경
          Positioned(
            left: 16.h,
            top: 99.h,
            child: Container(
              width: 361.h,
              height: 136.h,
              decoration: BoxDecoration(
                color: appTheme.white_A700,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.h),
                  topRight: Radius.circular(20.h),
                ),
              ),
            ),
          ),
          // 정보 항목들
          Positioned(
            left: 37.h,
            top: 133.h,
            child: _buildInfoItem(
              '첫 재배',
              DateFormat('yyyy\n9/5').format(_firstPlantDate),
            ),
          ),
          Positioned(
            left: 197.h,
            top: 133.h,
            child: _buildInfoItem(
              '재배일수',
              '$_cultivationDays일',
            ),
          ),
          Positioned(
            left: 302.h,
            top: 133.h,
            child: _buildInfoItem(
              '사진수',
              '$_photoCount장',
            ),
          ),
          // 타임랩스 버튼
          Positioned(
            left: 145.h,
            top: 207.h,
            child: InkWell(
              onTap: _goToTimelapse,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.h, vertical: 6.h),
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
                    topLeft: Radius.circular(20.h),
                    topRight: Radius.circular(20.h),
                  ),
                ),
                child: Text(
                  '타임랩스',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appTheme.white_A700,
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 항목 위젯
  Widget _buildInfoItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: appTheme.blue_gray_700,
            fontSize: 14.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF797979),
            fontSize: 16.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            height: 1.0,
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

  /// 달력 헤더 (년월 선택)
  Widget _buildCalendarHeader() {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: appTheme.green_50,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.h),
          topRight: Radius.circular(20.h),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: appTheme.teal_400),
            onPressed: _goToPreviousMonth,
          ),
          Text(
            '${_currentMonth.year}년 ${_currentMonth.month}월',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 16.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: appTheme.teal_400),
            onPressed: _goToNextMonth,
          ),
        ],
      ),
    );
  }

  /// 요일 헤더
  Widget _buildWeekDaysHeader() {
    final weekDays = ['일', '월', '화', '수', '목', '금', '토'];
    return Container(
      height: 43.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: appTheme.teal_400, width: 1),
        ),
      ),
      child: Row(
        children: weekDays.map((day) {
          final isWeekend = day == '일' || day == '토';
          return Expanded(
            child: Container(
              height: 43.h,
              decoration: BoxDecoration(
                color: appTheme.green_50,
                border: Border(
                  right: BorderSide(color: appTheme.teal_400, width: 1),
                ),
              ),
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: appTheme.blue_gray_700,
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 달력 그리드
  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
    DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth =
    DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0: 일요일, 6: 토요일
    final daysInMonth = lastDayOfMonth.day;

    // 이전 달 마지막 날짜
    final lastDayOfPrevMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    List<Widget> dayWidgets = [];

    // 이전 달 날짜들
    for (int i = firstWeekday - 1; i >= 0; i--) {
      dayWidgets.add(_buildDayCell(
        lastDayOfPrevMonth - i,
        isCurrentMonth: false,
      ));
    }

    // 현재 달 날짜들
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final hasDiary = _diaryEntries.containsKey(date);
      final isWeekend = date.weekday == DateTime.sunday ||
          date.weekday == DateTime.saturday;

      dayWidgets.add(_buildDayCell(
        day,
        date: date,
        isCurrentMonth: true,
        isWeekend: isWeekend,
        hasDiary: hasDiary,
      ));
    }

    // 다음 달 날짜들
    final remainingCells = 42 - dayWidgets.length; // 6주 * 7일
    for (int day = 1; day <= remainingCells; day++) {
      dayWidgets.add(_buildDayCell(
        day,
        isCurrentMonth: false,
      ));
    }

    return Column(
      children: [
        for (int week = 0; week < 6; week++)
          Row(
            children: [
              for (int day = 0; day < 7; day++) dayWidgets[week * 7 + day],
            ],
          ),
      ],
    );
  }

  /// 날짜 셀
  Widget _buildDayCell(
      int day, {
        DateTime? date,
        bool isCurrentMonth = true,
        bool isWeekend = false,
        bool hasDiary = false,
      }) {
    Color textColor;
    if (!isCurrentMonth) {
      textColor = appTheme.blue_gray_100;
    } else if (isWeekend && date?.weekday == DateTime.sunday) {
      textColor = Color(0xFFEC7243); // 일요일 빨간색
    } else if (isWeekend && date?.weekday == DateTime.saturday) {
      textColor = appTheme.teal_400; // 토요일 청록색
    } else {
      textColor = Color(0xFF1B1B1B);
    }

    return Expanded(
      child: InkWell(
        onTap: isCurrentMonth && date != null ? () => _onDateTapped(date) : null,
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: appTheme.white_A700,
            border: Border.all(color: appTheme.blue_gray_100, width: 1),
          ),
          child: Stack(
            children: [
              // 날짜 텍스트
              Positioned(
                left: 4.h,
                top: 4.h,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
              // 다이어리 아이콘
              if (hasDiary)
                Positioned(
                  right: 4.h,
                  bottom: 4.h,
                  child: Icon(
                    Icons.eco,
                    size: 16.h,
                    color: appTheme.teal_400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

// v-- _buildBottomNavigation() 및 _buildNavItem() 메서드가 여기서 삭제됩니다. --v
// Widget _buildBottomNavigation() { ... }
// Widget _buildNavItem(String label, IconData icon, bool isSelected, VoidCallback? onTap) { ... }
// ^-- _buildBottomNavigation() 및 _buildNavItem() 메서드가 여기서 삭제됩니다. --^
}

/// 다이어리 데이터 모델
class DiaryEntry {
  final DateTime date;
  final String photoPath;
  final String note;

  DiaryEntry({
    required this.date,
    required this.photoPath,
    required this.note,
  });
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
            // 날짜 표시
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
            // 사진 촬영 버튼
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
                    Icon(
                      Icons.camera_alt,
                      color: appTheme.white_A700,
                      size: 20.h,
                    ),
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
            // 안내 문구
            Text(
              '메모를 작아주세요.\n메모를 작아주세요.\n메모를 작아주세요.',
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
            // 닫기 버튼
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.close,
                color: Color(0xFF797979),
                size: 24.h,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 다이어리 상세보기 팝업
class DiaryDetailDialog extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onDelete;

  const DiaryDetailDialog({
    Key? key,
    required this.entry,
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
            // 날짜 표시
            Text(
              '${entry.date.year}   ${entry.date.month}/${entry.date.day}',
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
              child: Center(
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
                entry.note,
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
                    Navigator.of(context).pop();
                    // TODO: 수정 기능
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