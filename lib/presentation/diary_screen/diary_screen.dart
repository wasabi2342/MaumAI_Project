import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_top_app_bar.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/custom_top_tab.dart'; // [추가] CustomTopTab 임포트

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
    } else if (args is PlantInfo) {
      _userPlantId = args.id;
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

  void _onDateTapped(DateTime date) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final dayData = _calendarDaysMap[dateKey];

    if (dayData != null && dayData.hasDiary) {
      _fetchAndShowDetail(date);
    } else {
      final result = await showDialog(
        context: context,
        barrierColor: Color(0x3FD9D9D9),
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: DiaryCreateDialog(
            date: date,
            userPlantId: _userPlantId,
          ),
        ),
      );

      if (result == true) {
        _fetchMonthData();
      }
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

  /// 타임랩스 화면으로 이동
  void _goToTimelapse() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: appTheme.teal_400)),
    );

    try {
      final timelineData = await ApiService.getTimeline(_userPlantId);
      final timeline = DiaryTimeline.fromJson(timelineData);

      Navigator.pop(context);

      if (timeline.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('타임랩스를 생성할 사진이 없습니다.'),
            backgroundColor: appTheme.teal_400,
          ),
        );
        return;
      }

      List<Map<String, String>> frames = [];
      String baseUrl = ApiService.baseUrl;
      if (baseUrl.endsWith('/api')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 4);
      }

      for (var item in timeline.items) {
        if (item.imageUrl == null || item.imageUrl!.isEmpty) continue;

        String path = item.imageUrl!;
        if (!path.startsWith('http') &&
            !path.startsWith('assets/') &&
            !path.startsWith('file')) {
          if (!path.startsWith('/')) path = '/$path';
          path = '$baseUrl$path';
        }

        String dateStr = '';
        try {
          if (item.diaryDate is DateTime) {
            dateStr =
                DateFormat('yyyy.MM.dd').format(item.diaryDate as DateTime);
          } else {
            DateTime d = DateTime.parse(item.diaryDate.toString());
            dateStr = DateFormat('yyyy.MM.dd').format(d);
          }
        } catch (e) {
          dateStr = item.diaryDate.toString();
        }

        frames.add({
          'url': path,
          'date': dateStr,
        });
      }

      if (frames.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지를 불러올 수 없습니다.')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.8),
        builder: (context) => TimelapsePlayerDialog(frames: frames),
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      print('타임라인 조회 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('타임라인을 불러오는데 실패했습니다.')),
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
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 198.h),
                    child: Container(
                      width: double.infinity,
                      color: appTheme.white_A700,
                      child: Column(
                        children: [
                          SizedBox(height: 30.h),
                          _buildCalendarSection(),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 198.h,
                    decoration: BoxDecoration(
                      color: appTheme.green_50,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20.h,
                          offset: Offset(0, 10.h),
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

class DiaryCreateDialog extends StatefulWidget {
  final DateTime date;
  final int userPlantId;

  const DiaryCreateDialog({
    Key? key,
    required this.date,
    required this.userPlantId,
  }) : super(key: key);

  @override
  State<DiaryCreateDialog> createState() => _DiaryCreateDialogState();
}

class _DiaryCreateDialogState extends State<DiaryCreateDialog> {
  final TextEditingController _contentController = TextEditingController();
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      print('이미지 선택 실패: $e');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.h)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt, color: appTheme.teal_400),
                title: Text('카메라로 촬영'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: appTheme.teal_400),
                title: Text('갤러리에서 선택'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveDiary() async {
    if (_selectedImagePath == null && _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 또는 내용을 입력해주세요.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: appTheme.teal_400),
      ),
    );

    try {
      await ApiService.createDiary(
        userPlantId: widget.userPlantId,
        diaryDate: widget.date,
        content: _contentController.text,
        imagePath: _selectedImagePath,
      );

      Navigator.pop(context);
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('다이어리가 등록되었습니다.'),
          backgroundColor: appTheme.teal_400,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 30.h),
      child: SingleChildScrollView(
        child: Container(
          width: 330.h,
          padding: EdgeInsets.all(24.h),
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
                '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appTheme.teal_400,
                  fontSize: 16.fSize,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 20.h),

              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: appTheme.green_50,
                    borderRadius: BorderRadius.circular(12.h),
                    border: Border.all(
                      color: appTheme.teal_400.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedImagePath != null
                      ? Image.file(
                    File(_selectedImagePath!),
                    fit: BoxFit.cover,
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 40.h,
                        color: appTheme.teal_400,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '사진 추가하기 (선택)',
                        style: TextStyle(
                          color: appTheme.teal_400,
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              CustomTextFormField(
                controller: _contentController,
                placeholder: '오늘의 식물 상태를 기록해보세요.',
                maxLines: 4,
                fillColor: appTheme.green_50.withOpacity(0.5),
                borderColor: appTheme.teal_400.withOpacity(0.3),
                borderRadius: 12.h,
                contentPadding: EdgeInsets.all(12.h),
              ),
              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: Color(0xFF797979),
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.h),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDiary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appTheme.teal_400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.h),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 14.fSize,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
              child: _buildDiaryImage(),
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

  Widget _buildDiaryImage() {
    if (diary.imageUrl == null || diary.imageUrl!.isEmpty) {
      return Center(
        child: Icon(
          Icons.image,
          size: 60.h,
          color: appTheme.teal_400,
        ),
      );
    }

    String path = diary.imageUrl!;

    if (!path.startsWith('http') &&
        (path.startsWith('/') || path.contains(r'\'))) {
      File file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorIcon();
          },
        );
      }
    }

    if (!path.startsWith('http') && !path.startsWith('assets/')) {
      String baseUrl = ApiService.baseUrl;
      if (baseUrl.endsWith('/api')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 4);
      }

      if (!path.startsWith('/')) path = '/$path';
      path = '$baseUrl$path';
    }

    return CustomImageView(
      imagePath: path,
      fit: BoxFit.cover,
      placeHolder: ImageConstant.imgPlaceholder,
    );
  }

  Widget _buildErrorIcon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.grey),
          Text('이미지를 찾을 수 없음', style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

/// [수정됨] 타임랩스 플레이어 팝업
/// - 닫기 버튼을 팝업창 우측 상단 모서리에 배치
class TimelapsePlayerDialog extends StatefulWidget {
  final List<Map<String, String>> frames;

  const TimelapsePlayerDialog({Key? key, required this.frames})
      : super(key: key);

  @override
  State<TimelapsePlayerDialog> createState() => _TimelapsePlayerDialogState();
}

class _TimelapsePlayerDialogState extends State<TimelapsePlayerDialog> {
  int _currentIndex = 0;
  Timer? _timer;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.frames.length;
      });
    });
    setState(() => _isPlaying = true);
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isPlaying = false);
  }

  void _togglePlay() {
    if (_isPlaying) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFrame = widget.frames[_currentIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20.h),
      child: Container(
        width: 330.h,
        // 전체 패딩 제거 (헤더 영역을 꽉 채우기 위해)
        decoration: BoxDecoration(
          color: appTheme.white_A700,
          borderRadius: BorderRadius.circular(20.h),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.h,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // [상단 헤더 영역]
            SizedBox(
              height: 50.h,
              child: Stack(
                children: [
                  // 1. 중앙 탭 (상단 정렬)
                  Align(
                    alignment: Alignment.topCenter,
                    child: CustomTopTab(
                      text: '타임랩스 재생',
                      width: 160.h,
                      height: 36.h,
                    ),
                  ),
                  // 2. 우측 상단 닫기 버튼
                  Positioned(
                    right: 9.h,
                    top: 1.h,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey[700], size: 24.h),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        splashRadius: 20.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // [하단 컨텐츠 영역]
            Padding(
              padding: EdgeInsets.only(left: 20.h, right: 20.h, bottom: 20.h),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 250.h,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20.h),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 800),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: KeyedSubtree(
                            key: ValueKey<String>(currentFrame['url']!),
                            child: CustomImageView(
                              imagePath: currentFrame['url'],
                              fit: BoxFit.contain,
                              placeHolder: ImageConstant.imgPlaceholder,
                            ),
                          ),
                        ),
                      ),
                      // 날짜 텍스트 (Glow 효과)
                      Positioned(
                        bottom: 20.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            currentFrame['date']!,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16.fSize,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Pretendard',
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 0),
                                  blurRadius: 40.0,
                                  color: Colors.white.withOpacity(1.0),
                                ),
                                Shadow(
                                  offset: Offset(0, 0),
                                  blurRadius: 20.0,
                                  color: Colors.white.withOpacity(1.0),
                                ),
                                Shadow(
                                  offset: Offset(0, 0),
                                  blurRadius: 10.0,
                                  color: Colors.white.withOpacity(1.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // 재생 컨트롤
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous,
                            size: 30.h, color: appTheme.teal_400),
                        onPressed: () {
                          _stopTimer();
                          setState(() {
                            _currentIndex = (_currentIndex - 1 + widget.frames.length) %
                                widget.frames.length;
                          });
                        },
                      ),
                      SizedBox(width: 20.h),
                      InkWell(
                        onTap: _togglePlay,
                        child: Container(
                          width: 50.h,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: appTheme.teal_400,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 30.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 20.h),
                      IconButton(
                        icon: Icon(Icons.skip_next,
                            size: 30.h, color: appTheme.teal_400),
                        onPressed: () {
                          _stopTimer();
                          setState(() {
                            _currentIndex =
                                (_currentIndex + 1) % widget.frames.length;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '${_currentIndex + 1} / ${widget.frames.length}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.fSize,
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