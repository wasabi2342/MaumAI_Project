// 파일 경로: lib/widgets/notification_sidebar.dart

import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// 알림 사이드바 위젯
///
/// 기능:
/// - 우측에서 슬라이드되어 나타남
/// - 알림 목록 표시
/// - 각 알림은 아이콘, 날짜, 메시지 포함
class NotificationSidebar extends StatelessWidget {
  final VoidCallback onClose;

  const NotificationSidebar({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // 사이드바 내부 클릭 시 닫히지 않도록
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 263.w,
              height: double.infinity,
              decoration: BoxDecoration(
                color: appTheme.white_A700,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.h),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66D3D3D3),
                    blurRadius: 8,
                    offset: Offset(0, 0),
                  ),
                ],
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
      ),
    );
  }

  /// 헤더 (알림 타이틀)
  Widget _buildHeader() {
    return Container(
      width: 185.w,
      height: 36.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFA0ECB1),
            Color(0x0032C697),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50.h),
          bottomRight: Radius.circular(50.h),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x5B32C697),
            blurRadius: 4,
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
            fontSize: 14.fSize,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            height: 1.50,
            letterSpacing: -0.32,
          ),
        ),
      ),
    );
  }

  /// 알림 목록
  Widget _buildNotificationList() {
    // 임시 알림 데이터
    final notifications = [
      NotificationItem(
        date: '2025. 10 / 27',
        message: '온도가 정상 범위보다 높아요',
        icon: Icons.thermostat_outlined,
      ),
      NotificationItem(
        date: '2025. 10 / 25',
        message: '양액 교체 시기 입니다.',
        icon: Icons.water_drop_outlined,
        iconColor: Color(0xFF32C697),
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.only(
        left: 26.w,
        right: 26.w,
        top: 31.h,
      ),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(notifications[index]);
      },
    );
  }

  /// 알림 카드
  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 21.h),
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 15.h,
      ),
      decoration: BoxDecoration(
        color: appTheme.white_A700,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.h),
          bottomRight: Radius.circular(20.h),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x66D3D3D3),
            blurRadius: 8,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜
          Text(
            notification.date,
            style: TextStyle(
              color: Color(0xFF797979),
              fontSize: 14.fSize,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: -0.35,
            ),
          ),
          SizedBox(height: 14.h),
          // 메시지와 아이콘
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.message,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xFF797979),
                    fontSize: 12.fSize,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: -0.30,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Icon(
                notification.icon,
                size: 24.h,
                color: notification.iconColor ?? Color(0xFF797979),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 알림 아이템 데이터 모델
class NotificationItem {
  final String date;
  final String message;
  final IconData icon;
  final Color? iconColor;

  NotificationItem({
    required this.date,
    required this.message,
    required this.icon,
    this.iconColor,
  });
}