import 'package:flutter/material.dart';
// ============================================
// 사용자 관련 모델
// ============================================

class UserProfile {
  final int id;
  final String nickname;
  final String email;
  final String? job;
  final int? age;
  final String? gender;

  UserProfile({
    required this.id,
    required this.nickname,
    required this.email,
    this.job,
    this.age,
    this.gender,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      nickname: json['nickname'],
      email: json['email'],
      job: json['job'],
      age: json['age'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'email': email,
      'job': job,
      'age': age,
      'gender': gender,
    };
  }
}

// ============================================
// 식물 정보 모델
// ============================================

class PlantInfo {
  final int id;
  final String name;
  final String? difficulty; // "EASY", "MEDIUM", "HARD"
  final double? tempMin;
  final double? tempMax;
  final double? humidityMin;
  final double? humidityMax;
  final String? lightLevel;
  final String? ledInfo;
  final double? ecMin;
  final double? ecMax;

  PlantInfo({
    required this.id,
    required this.name,
    this.difficulty,
    this.tempMin,
    this.tempMax,
    this.humidityMin,
    this.humidityMax,
    this.lightLevel,
    this.ledInfo,
    this.ecMin,
    this.ecMax,
  });

  factory PlantInfo.fromJson(Map<String, dynamic> json) {
    return PlantInfo(
      id: json['id'],
      name: json['name'],
      difficulty: json['difficulty'],
      tempMin: json['tempMin']?.toDouble(),
      tempMax: json['tempMax']?.toDouble(),
      humidityMin: json['humidityMin']?.toDouble(),
      humidityMax: json['humidityMax']?.toDouble(),
      lightLevel: json['lightLevel'],
      ledInfo: json['ledInfo'],
      ecMin: json['ecMin']?.toDouble(),
      ecMax: json['ecMax']?.toDouble(),
    );
  }

  // 난이도를 한글로 변환
  String get difficultyKo {
    switch (difficulty) {
      case 'EASY':
        return '쉬움';
      case 'MEDIUM':
        return '보통';
      case 'HARD':
        return '어려움';
      default:
        return '-';
    }
  }

  // 난이도 색상
  Color get difficultyColor {
    switch (difficulty) {
      case 'EASY':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HARD':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ============================================
// 내 식물 모델
// ============================================

class UserPlant {
  final int id;
  final String plantName; // 식물 종류 이름 (예: 상추)
  final String? nickname; // 사용자가 붙인 별칭
  final DateTime startedAt; // 재배 시작일

  UserPlant({
    required this.id,
    required this.plantName,
    this.nickname,
    required this.startedAt,
  });

  factory UserPlant.fromJson(Map<String, dynamic> json) {
    return UserPlant(
      id: json['id'],
      plantName: json['plantName'],
      nickname: json['nickname'],
      startedAt: DateTime.parse(json['startedAt']),
    );
  }

  // 표시용 이름 (별칭이 있으면 별칭, 없으면 식물 이름)
  String get displayName => nickname ?? plantName;

  // 재배 일수 계산
  int get daysSincePlanted {
    return DateTime.now().difference(startedAt).inDays + 1;
  }
}

// ============================================
// 다이어리 캘린더 모델
// ============================================

class DiaryCalendarDay {
  final DateTime date;
  final bool hasDiary;
  final int? diaryId;
  final String? thumbnailUrl;

  DiaryCalendarDay({
    required this.date,
    required this.hasDiary,
    this.diaryId,
    this.thumbnailUrl,
  });

  factory DiaryCalendarDay.fromJson(Map<String, dynamic> json) {
    return DiaryCalendarDay(
      date: DateTime.parse(json['date']),
      hasDiary: json['hasDiary'],
      diaryId: json['diaryId'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

class DiaryCalendar {
  final int userPlantId;
  final String? plantNickname;
  final String? plantName;
  final DateTime? firstPlantedDate;
  final int daysSincePlanted;
  final int photoCount;
  final int year;
  final int month;
  final List<DiaryCalendarDay> days;

  DiaryCalendar({
    required this.userPlantId,
    this.plantNickname,
    this.plantName,
    this.firstPlantedDate,
    required this.daysSincePlanted,
    required this.photoCount,
    required this.year,
    required this.month,
    required this.days,
  });

  factory DiaryCalendar.fromJson(Map<String, dynamic> json) {
    return DiaryCalendar(
      userPlantId: json['userPlantId'],
      plantNickname: json['plantNickname'],
      plantName: json['plantName'],
      firstPlantedDate: json['firstPlantedDate'] != null
          ? DateTime.parse(json['firstPlantedDate'])
          : null,
      daysSincePlanted: json['daysSincePlanted'],
      photoCount: json['photoCount'],
      year: json['year'],
      month: json['month'],
      days: (json['days'] as List)
          .map((day) => DiaryCalendarDay.fromJson(day))
          .toList(),
    );
  }

  // 특정 날짜의 다이어리 찾기
  DiaryCalendarDay? getDayByDate(DateTime date) {
    try {
      return days.firstWhere(
        (day) =>
            day.date.year == date.year &&
            day.date.month == date.month &&
            day.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }
}

// ============================================
// 다이어리 모델
// ============================================

class Diary {
  final int id;
  final int userPlantId;
  final DateTime diaryDate;
  final String? content;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Diary({
    required this.id,
    required this.userPlantId,
    required this.diaryDate,
    this.content,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      id: json['id'],
      userPlantId: json['userPlantId'],
      diaryDate: DateTime.parse(json['diaryDate']),
      content: json['content'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // 수정 여부
  bool get isEdited => updatedAt != null;

  // 전체 이미지 URL (서버 주소 포함)
  String? getFullImageUrl(String baseUrl) {
    if (imageUrl == null) return null;
    if (imageUrl!.startsWith('http')) return imageUrl;
    return '$baseUrl$imageUrl';
  }
}

// ============================================
// 타임라인 모델
// ============================================

class TimelineItem {
  final int id;
  final DateTime diaryDate;
  final String? imageUrl;
  final String? content;

  TimelineItem({
    required this.id,
    required this.diaryDate,
    this.imageUrl,
    this.content,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      id: json['id'],
      diaryDate: DateTime.parse(json['diaryDate']),
      imageUrl: json['imageUrl'],
      content: json['content'],
    );
  }
}

class Timeline {
  final int userPlantId;
  final String? plantNickname;
  final String? plantName;
  final List<TimelineItem> items;

  Timeline({
    required this.userPlantId,
    this.plantNickname,
    this.plantName,
    required this.items,
  });

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(
      userPlantId: json['userPlantId'],
      plantNickname: json['plantNickname'],
      plantName: json['plantName'],
      items: (json['items'] as List)
          .map((item) => TimelineItem.fromJson(item))
          .toList(),
    );
  }

  // 월별로 그룹화
  Map<String, List<TimelineItem>> groupByMonth() {
    Map<String, List<TimelineItem>> grouped = {};

    for (var item in items) {
      String key = '${item.diaryDate.year}년 ${item.diaryDate.month}월';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }

    return grouped;
  }
}

// ============================================
// 센서 데이터 모델 (추후 백엔드 API 추가 필요)
// ============================================

class SensorLog {
  final int id;
  final int deviceId;
  final double? temperature;
  final double? humidity;
  final double? illuminance;
  final double? co2;
  final double? ec;
  final DateTime createdAt;

  SensorLog({
    required this.id,
    required this.deviceId,
    this.temperature,
    this.humidity,
    this.illuminance,
    this.co2,
    this.ec,
    required this.createdAt,
  });

  factory SensorLog.fromJson(Map<String, dynamic> json) {
    return SensorLog(
      id: json['id'],
      deviceId: json['deviceId'],
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      illuminance: json['illuminance']?.toDouble(),
      co2: json['co2']?.toDouble(),
      ec: json['ec']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // 온도 상태 (적정 범위 기준)
  String getTemperatureStatus(double? optimalMin, double? optimalMax) {
    if (temperature == null || optimalMin == null || optimalMax == null) {
      return '측정 중';
    }
    if (temperature! < optimalMin) return '낮음';
    if (temperature! > optimalMax) return '높음';
    return '적정';
  }

  // 습도 상태
  String getHumidityStatus(double? optimalMin, double? optimalMax) {
    if (humidity == null || optimalMin == null || optimalMax == null) {
      return '측정 중';
    }
    if (humidity! < optimalMin) return '낮음';
    if (humidity! > optimalMax) return '높음';
    return '적정';
  }
}

// ============================================
// 장치 모델 (추후 필요시 사용)
// ============================================

class Device {
  final int id;
  final int? userId;
  final String deviceName;
  final String serialNo;
  final String? location;
  final DateTime createdAt;

  Device({
    required this.id,
    this.userId,
    required this.deviceName,
    required this.serialNo,
    this.location,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      userId: json['userId'],
      deviceName: json['deviceName'],
      serialNo: json['serialNo'],
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
