// 파일 경로: lib/widgets/notification_sidebar.dart

import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// 알림 사이드바 위젯
///
/// 기능:
/// - 우측에서 슬라이드되어 나타남
/// - 알림 목록 표시 (삭제 기능 포함)
/// - 각 알림은 아이콘, 날짜, 메시지, 삭제 버튼 포함
class NotificationSidebar extends StatefulWidget {
  final VoidCallback onClose;

  const NotificationSidebar({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<NotificationSidebar> createState() => _NotificationSidebarState();
}

class _NotificationSidebarState extends State<NotificationSidebar> {
  // [수정] 상태로 관리되는 더미 알림 데이터
  List<NotificationItem> notifications = [
    NotificationItem(
      date: '2025. 10 / 27',
      message: '온도가 정상 범위보다 높아요',
      iconType: NotificationIconType.temperature,
    ),
    NotificationItem(
      date: '2025. 10 / 25',
      message: '양액 교체 시기 입니다.',
      iconType: NotificationIconType.nutrient,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 정확한 높이 값 사용
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = 56.h; // CustomTopAppBar의 preferredSize
    final bottomNavHeight = 70.h; // CustomBottomNavBar의 높이

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 사이드바
            Positioned(
              top: topPadding + appBarHeight,
              right: 0,
              bottom: bottomNavHeight,
              child: GestureDetector(
                onTap: () {}, // 사이드바 내부 클릭 시 닫히지 않도록
                child: Container(
                  width: 263.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFEFB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.h),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(
                        child: _buildNotificationList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 헤더 (알림 타이틀)
  Widget _buildHeader() {
    return Container(
      width: 185.h,
      height: 36.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appTheme.green_200,  // 0xFFA0ECB1
            appTheme.teal_400,   // 0xFF32C697
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
          '알림',
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

  /// 알림 목록 빌더
  Widget _buildNotificationList() {
    if (notifications.isEmpty) {
      return Center(
        child: Text(
          '새로운 알림이 없습니다.',
          style: TextStyle(
            color: appTheme.blue_gray_100,
            fontSize: 14.fSize,
            fontFamily: 'Pretendard',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        top: 31.h,
      ),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        // index를 전달하여 어떤 항목을 삭제할지 식별
        return _buildNotificationCard(notifications[index], index);
      },
    );
  }

  /// 알림 카드
  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 21.h),
      height: 82.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFB),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.h),
          bottomRight: Radius.circular(20.h),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x66D3D3D3),
            blurRadius: 8.h,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.h, vertical: 15.h),
        child: Row(
          children: [
            // 왼쪽: 날짜와 메시지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 날짜
                  Text(
                    notification.date,
                    style: TextStyle(
                      color: const Color(0xFF797979),
                      fontSize: 14.fSize,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.0,
                      letterSpacing: -0.35,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  // 메시지와 아이콘
                  Row(
                    children: [
                      _buildNotificationIcon(notification.iconType),
                      SizedBox(width: 8.h),
                      Expanded(
                        child: Text(
                          notification.message,
                          style: TextStyle(
                            color: const Color(0xFF797979),
                            fontSize: 12.fSize,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                            letterSpacing: -0.30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.h),
            // 오른쪽: 삭제 버튼
            GestureDetector(
              onTap: () {
                // [수정] 삭제 로직 구현
                setState(() {
                  notifications.removeAt(index);
                });

                // (선택사항) 삭제 안내 스낵바 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('알림이 삭제되었습니다.'),
                    duration: Duration(seconds: 1),
                    backgroundColor: appTheme.teal_400,
                  ),
                );
              },
              child: Container(
                width: 24.h,
                height: 24.h,
                color: Colors.transparent, // 터치 영역 확보
                child: Icon(
                  Icons.delete_outline,
                  size: 24.h,
                  color: const Color(0xFFFF6B6B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 알림 아이콘 빌더
  Widget _buildNotificationIcon(NotificationIconType type) {
    switch (type) {
      case NotificationIconType.temperature:
        return _buildTemperatureIcon();
      case NotificationIconType.nutrient:
        return _buildNutrientIcon();
    }
  }

  /// 온도 아이콘
  Widget _buildTemperatureIcon() {
    return Container(
      width: 14.h,
      height: 14.h,
      child: Icon(
        Icons.thermostat,
        size: 14.h,
        color: const Color(0xFF32C697),
      ),
    );
  }

  /// 양액 아이콘 (물방울 모양)
  Widget _buildNutrientIcon() {
    return Container(
      width: 24.h,
      height: 24.h,
      child: CustomPaint(
        painter: NutrientIconPainter(),
      ),
    );
  }
}

/// 양액 아이콘 커스텀 페인터
class NutrientIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF32C697)
      ..style = PaintingStyle.fill;

    // 물병 모양 그리기
    final path = Path();

    // 병 몸통
    path.moveTo(size.width * 0.3, size.height * 0.4);
    path.lineTo(size.width * 0.3, size.height * 0.85);
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.95,
      size.width * 0.4, size.height * 0.95,
    );
    path.lineTo(size.width * 0.6, size.height * 0.95);
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.95,
      size.width * 0.7, size.height * 0.85,
    );
    path.lineTo(size.width * 0.7, size.height * 0.4);

    // 병목
    path.lineTo(size.width * 0.65, size.height * 0.4);
    path.lineTo(size.width * 0.65, size.height * 0.2);
    path.lineTo(size.width * 0.35, size.height * 0.2);
    path.lineTo(size.width * 0.35, size.height * 0.4);
    path.close();

    canvas.drawPath(path, paint);

    // 내용물 (밝은 색)
    final liquidPaint = Paint()
      ..color = const Color(0xFFE3FAE8)
      ..style = PaintingStyle.fill;

    final liquidPath = Path();
    liquidPath.moveTo(size.width * 0.35, size.height * 0.5);
    liquidPath.lineTo(size.width * 0.35, size.height * 0.82);
    liquidPath.quadraticBezierTo(
      size.width * 0.35, size.height * 0.88,
      size.width * 0.42, size.height * 0.88,
    );
    liquidPath.lineTo(size.width * 0.58, size.height * 0.88);
    liquidPath.quadraticBezierTo(
      size.width * 0.65, size.height * 0.88,
      size.width * 0.65, size.height * 0.82,
    );
    liquidPath.lineTo(size.width * 0.65, size.height * 0.5);
    liquidPath.close();

    canvas.drawPath(liquidPath, liquidPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 알림 아이콘 타입
enum NotificationIconType {
  temperature,
  nutrient,
}

/// 알림 아이템 데이터 모델
class NotificationItem {
  final String date;
  final String message;
  final NotificationIconType iconType;

  NotificationItem({
    required this.date,
    required this.message,
    required this.iconType,
  });
}