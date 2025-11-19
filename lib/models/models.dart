// ============================================
// 사용자 관련 모델
// ============================================

/// 사용자 프로필 응답 (UserProfileResponse)
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
      if (job != null) 'job': job,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
    };
  }
}

// ============================================
// 식물 정보 관련 모델
// ============================================

/// 식물 정보 응답 (PlantInfoResponse)
class PlantInfo {
  final int id;
  final String name;
  final String? difficulty; // EASY, MEDIUM, HARD
  final double? tempMin;
  final double? tempMax;
  final double? humidityMin;
  final double? humidityMax;
  final String? lightLevel; // LOW, MEDIUM, HIGH
  final String? ledInfo;
  final double? ecMin;
  final double? ecMax;
  final double? co2Min;
  final double? co2Max;

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
    this.co2Min,
    this.co2Max,
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
      co2Min: json['co2Min']?.toDouble(),
      co2Max: json['co2Max']?.toDouble(),
      ecMin: json['ecMin']?.toDouble(),
      ecMax: json['ecMax']?.toDouble(),

    );
  }

  /// 난이도 한글 변환
  String get difficultyKorean {
    switch (difficulty) {
      case 'EASY':
        return '쉬움';
      case 'MEDIUM':
        return '보통';
      case 'HARD':
        return '어려움';
      default:
        return '알 수 없음';
    }
  }

  /// 조도 한글 변환
  String get lightLevelKorean {
    switch (lightLevel) {
      case 'LOW':
        return '낮음';
      case 'MEDIUM':
        return '중간';
      case 'HIGH':
        return '높음';
      default:
        return '알 수 없음';
    }
  }

  /// 적정 온도 범위 문자열
  String get temperatureRange {
    if (tempMin != null && tempMax != null) {
      return '${tempMin}°C ~ ${tempMax}°C';
    }
    return '-';
  }

  /// 적정 습도 범위 문자열
  String get humidityRange {
    if (humidityMin != null && humidityMax != null) {
      return '${humidityMin}% ~ ${humidityMax}%';
    }
    return '-';
  }
  /// CO2 범위 문자열
  String get co2Range {
    if (co2Min != null && co2Max != null) {
      return '$co2Min ~ $co2Max';
    }
    return '-';
  }
  /// EC 범위 문자열
  String get ecRange {
    if (ecMin != null && ecMax != null) {
      return '$ecMin ~ $ecMax';
    }
    return '-';
  }
}

// ============================================
// 사용자 식물 관련 모델
// ============================================

/// 사용자 식물 응답 (UserPlantResponse)
class UserPlant {
  final int id;
  final String plantName;
  final String? nickname;
  final DateTime startedAt;

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

  /// 재배 일수 계산
  int get daysSincePlanted {
    return DateTime.now().difference(startedAt).inDays + 1;
  }

  /// 표시용 이름 (별칭이 있으면 별칭, 없으면 식물 이름)
  String get displayName => nickname ?? plantName;
}

// ============================================
// 다이어리 관련 모델
// ============================================

/// 다이어리 응답 (DiaryResponse)
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
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// 이미지가 있는지 확인
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

/// 다이어리 달력 일별 정보 (DiaryCalendarDayDto)
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

/// 다이어리 달력 응답 (DiaryCalendarResponse)
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

  /// 식물 표시 이름
  String get displayPlantName => plantNickname ?? plantName ?? '내 식물';
}

/// 타임라인 아이템 (DiaryTimelineItemDto)
class DiaryTimelineItem {
  final int id;
  final DateTime diaryDate;
  final String? imageUrl;
  final String? content;

  DiaryTimelineItem({
    required this.id,
    required this.diaryDate,
    this.imageUrl,
    this.content,
  });

  factory DiaryTimelineItem.fromJson(Map<String, dynamic> json) {
    return DiaryTimelineItem(
      id: json['id'],
      diaryDate: DateTime.parse(json['diaryDate']),
      imageUrl: json['imageUrl'],
      content: json['content'],
    );
  }
}

/// 타임라인 응답 (DiaryTimelineResponse)
class DiaryTimeline {
  final int userPlantId;
  final String? plantNickname;
  final String? plantName;
  final List<DiaryTimelineItem> items;

  DiaryTimeline({
    required this.userPlantId,
    this.plantNickname,
    this.plantName,
    required this.items,
  });

  factory DiaryTimeline.fromJson(Map<String, dynamic> json) {
    return DiaryTimeline(
      userPlantId: json['userPlantId'],
      plantNickname: json['plantNickname'],
      plantName: json['plantName'],
      items: (json['items'] as List)
          .map((item) => DiaryTimelineItem.fromJson(item))
          .toList(),
    );
  }

  /// 식물 표시 이름
  String get displayPlantName => plantNickname ?? plantName ?? '내 식물';
}

// ============================================
// 센서 데이터 관련 모델 (향후 확장용)
// ============================================

/// 센서 로그 데이터
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
}

// ============================================
// 장치 관련 모델 (향후 확장용)
// ============================================

/// 장치 정보
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