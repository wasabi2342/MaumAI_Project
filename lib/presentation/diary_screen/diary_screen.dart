import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

/// DiaryScreen with API Integration
///
/// 백엔드 다이어리 API와 연동:
/// - GET /api/diary/calendar : 월별 달력 조회
/// - GET /api/diary : 특정 날짜 다이어리 조회
/// - POST /api/diary : 다이어리 생성
/// - PUT /api/diary/{id} : 다이어리 수정
/// - DELETE /api/diary/{id} : 다이어리 삭제
class DiaryScreenWithAPI extends StatefulWidget {
  final int userPlantId; // 선택된 식물 ID

  const DiaryScreenWithAPI({
    Key? key,
    required this.userPlantId,
  }) : super(key: key);

  @override
  State<DiaryScreenWithAPI> createState() => _DiaryScreenWithAPIState();
}

class _DiaryScreenWithAPIState extends State<DiaryScreenWithAPI> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DiaryCalendar? _calendarData;
  Diary? _selectedDiary;
  bool _isLoading = false;
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadCalendarData();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// 달력 데이터 로드
  Future<void> _loadCalendarData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getDiaryCalendar(
        userPlantId: widget.userPlantId,
        year: _focusedDay.year,
        month: _focusedDay.month,
      );

      setState(() {
        _calendarData = DiaryCalendar.fromJson(response);
        _isLoading = false;
      });

      // 선택된 날짜의 다이어리 로드
      if (_selectedDay != null) {
        _loadDiaryForSelectedDay();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('달력 데이터를 불러올 수 없습니다.');
      print('달력 로드 실패: $e');
    }
  }

  /// 선택된 날짜의 다이어리 로드
  Future<void> _loadDiaryForSelectedDay() async {
    if (_selectedDay == null) return;

    try {
      final response = await ApiService.getDiaryByDate(
        userPlantId: widget.userPlantId,
        date: _selectedDay!,
      );

      setState(() {
        _selectedDiary = Diary.fromJson(response);
        _contentController.text = _selectedDiary?.content ?? '';
      });
    } catch (e) {
      // 다이어리가 없는 날짜
      setState(() {
        _selectedDiary = null;
        _contentController.clear();
        _selectedImage = null;
      });
    }
  }

  /// 다이어리 생성/수정
  Future<void> _saveDiary() async {
    if (_selectedDay == null) return;

    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImage == null) {
      _showErrorSnackBar('내용 또는 사진을 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedDiary == null) {
        // 새 다이어리 생성
        final response = await ApiService.createDiary(
          userPlantId: widget.userPlantId,
          diaryDate: _selectedDay!,
          content: content.isNotEmpty ? content : null,
          imagePath: _selectedImage?.path,
        );

        setState(() {
          _selectedDiary = Diary.fromJson(response);
        });

        _showSuccessSnackBar('다이어리가 저장되었습니다.');
      } else {
        // 기존 다이어리 수정
        final response = await ApiService.updateDiary(
          diaryId: _selectedDiary!.id,
          content: content.isNotEmpty ? content : null,
          imagePath: _selectedImage?.path,
        );

        setState(() {
          _selectedDiary = Diary.fromJson(response);
        });

        _showSuccessSnackBar('다이어리가 수정되었습니다.');
      }

      // 달력 데이터 새로고침
      await _loadCalendarData();
    } catch (e) {
      _showErrorSnackBar('다이어리 저장에 실패했습니다.');
      print('다이어리 저장 실패: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 다이어리 삭제
  Future<void> _deleteDiary() async {
    if (_selectedDiary == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.h),
        ),
        title: Text(
          '다이어리 삭제',
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 16.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '이 다이어리를 삭제하시겠습니까?',
          style: TextStyle(
            color: Color(0xFF3B3B3B),
            fontSize: 14.fSize,
            fontFamily: 'Pretendard',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '삭제',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService.deleteDiary(_selectedDiary!.id);

        setState(() {
          _selectedDiary = null;
          _contentController.clear();
          _selectedImage = null;
        });

        _showSuccessSnackBar('다이어리가 삭제되었습니다.');

        // 달력 데이터 새로고침
        await _loadCalendarData();
      } catch (e) {
        _showErrorSnackBar('다이어리 삭제에 실패했습니다.');
        print('다이어리 삭제 실패: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 이미지 선택
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  /// 성공 스낵바
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: appTheme.teal_400,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 에러 스낵바
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _calendarData?.displayPlantName ?? '다이어리',
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 18.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: appTheme.teal_400,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildCalendarSection(),
            SizedBox(height: 16.h),
            _buildDiarySection(),
          ],
        ),
      ),
    );
  }

  /// 달력 섹션
  Widget _buildCalendarSection() {
    return Container(
      margin: EdgeInsets.all(16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 식물 정보
          if (_calendarData != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('재배일수', '${_calendarData!.daysSincePlanted}일'),
                _buildInfoItem('사진', '${_calendarData!.photoCount}장'),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(color: appTheme.color66D3D3),
            SizedBox(height: 16.h),
          ],

          // 달력
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadDiaryForSelectedDay();
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _loadCalendarData();
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                // 다이어리가 있는 날짜 표시
                final dayData = _calendarData?.days.firstWhere(
                      (day) => isSameDay(day.date, date),
                  orElse: () => DiaryCalendarDay(
                    date: date,
                    hasDiary: false,
                  ),
                );

                if (dayData?.hasDiary == true) {
                  return Positioned(
                    bottom: 2,
                    child: Container(
                      width: 6.h,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: appTheme.teal_400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: appTheme.teal_400,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: appTheme.teal_400.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: appTheme.teal_400,
                fontSize: 16.fSize,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: appTheme.teal_400,
            fontSize: 18.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  /// 다이어리 작성 섹션
  Widget _buildDiarySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 표시
          Text(
            _selectedDay != null
                ? '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일'
                : '날짜를 선택해주세요',
            style: TextStyle(
              color: appTheme.teal_400,
              fontSize: 16.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),

          // 이미지 선택 버튼
          InkWell(
            onTap: _pickImage,
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.h),
                border: Border.all(
                  color: appTheme.color66D3D3,
                  width: 1,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12.h),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
                  : _selectedDiary?.hasImage == true
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12.h),
                child: Image.network(
                  _selectedDiary!.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                ),
              )
                  : _buildImagePlaceholder(),
            ),
          ),
          SizedBox(height: 16.h),

          // 내용 입력
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '오늘 하루를 기록해보세요...',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 14.fSize,
                fontFamily: 'Pretendard',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.h),
                borderSide: BorderSide(
                  color: appTheme.color66D3D3,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.h),
                borderSide: BorderSide(
                  color: appTheme.teal_400,
                  width: 2,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveDiary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.teal_400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    _selectedDiary == null ? '저장' : '수정',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_selectedDiary != null) ...[
                SizedBox(width: 8.h),
                ElevatedButton(
                  onPressed: _deleteDiary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.h),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.h,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    '삭제',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48.h,
            color: Colors.grey,
          ),
          SizedBox(height: 8.h),
          Text(
            '사진 추가',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.fSize,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }
}