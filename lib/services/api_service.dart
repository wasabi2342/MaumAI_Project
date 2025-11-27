import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // [추가] MediaType 설정을 위해 필요
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math'; // Random 생성을 위해 필요
import '../models/models.dart';

/// 베란다 농부 API 서비스
class ApiService {
  // ============================================
  // 설정
  // ============================================

  /// 서버 베이스 URL 설정
  /// [중요] 안드로이드 에뮬레이터: 'http://10.0.2.2:8080/api'
  /// [중요] 실제 기기: PC의 내부 IP 주소 (예: 'http://192.168.0.x:8080/api')
  static const String baseUrl = 'http://10.101.238.204:8080/api';

  /// 저장된 사용자 정보 (로그인 후)
  static int? currentUserId;
  static String? currentUserEmail;
  static String? currentUserNickname;

  /// HTTP 타임아웃 설정
  static const Duration timeoutDuration = Duration(seconds: 30); // AI 분석 고려하여 시간 늘림

  // ============================================
  // [MOCK] 더미 데이터 설정
  // ============================================
  static bool isMockMode = false;

  // 더미 사용자 프로필 데이터
  static Map<String, dynamic> _mockUserProfile = {
    'id': 999, 'nickname': '마스터농부', 'email': '1111@naver.com', 'job': '개발자', 'age': 25, 'gender': '남성',
  };

  // 더미 식물 리스트
  static final List<Map<String, dynamic>> _mockAllPlants = [
    {
      'id': 1, 'name': '로메인 상추', 'difficulty': 'EASY',
      'tempMin': 15.0, 'tempMax': 25.0,
      'humidityMin': 50.0, 'humidityMax': 70.0,
      'lightLevel': 'MEDIUM', 'ecMin': 1.0, 'ecMax': 2.0,
      'co2Min': 400.0, 'co2Max': 1000.0,
    },
    {
      'id': 2, 'name': '방울토마토', 'difficulty': 'MEDIUM',
      'tempMin': 20.0, 'tempMax': 30.0,
      'humidityMin': 60.0, 'humidityMax': 80.0,
      'lightLevel': 'HIGH',
    },
  ];

  // 더미 내 식물 리스트
  static List<Map<String, dynamic>> _mockUserPlants = [
    {
      'id': 101,
      'plantId': 1,
      'plantName': '로메인 상추',
      'nickname': '초록이',
      'startedAt': DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
    }
  ];

  // [수정] 더미 다이어리 저장소 (메모리 상에 임시 저장)
  static List<Map<String, dynamic>> _mockDiaries = [];

  // ============================================
  // 1. 사용자 관련 API
  // ============================================

  /// 회원가입
  static Future<Map<String, dynamic>> signup({
    required String nickname,
    required String email,
    required String password,
    required String passwordConfirm,
    String? job,
    int? age,
    String? gender,
  }) async {
    if (isMockMode) return _mockUserProfile;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'nickname': nickname,
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
          if (job != null) 'job': job,
          if (age != null) 'age': age,
          if (gender != null) 'gender': gender,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        currentUserId = data['id'];
        currentUserEmail = data['email'];
        currentUserNickname = data['nickname'];
        return data;
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? '회원가입 실패');
      }
    } catch (e) {
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그인
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

    // [MOCK] 마스터 계정 체크
    if (email == '1111@naver.com' && password == '111111') {
      isMockMode = true;
      currentUserId = _mockUserProfile['id'];
      currentUserEmail = _mockUserProfile['email'];
      currentUserNickname = _mockUserProfile['nickname'];

      // 마스터 계정 로그인 시 기존 더미 데이터 초기화 방지 (필요시)
      // _mockDiaries.clear();

      await Future.delayed(Duration(seconds: 1));
      return _mockUserProfile;
    }


    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        isMockMode = false;
        currentUserId = data['id'];
        currentUserEmail = data['email'];
        currentUserNickname = data['nickname'];
        return data;
      } else {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      }
    } catch (e) {
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  static Future<void> logout() async {
    try {
      if (!isMockMode) {
        await http.post(Uri.parse('$baseUrl/users/logout')).timeout(timeoutDuration);
      }
    } catch (e) {
      // ignore
    } finally {
      currentUserId = null;
      currentUserEmail = null;
      currentUserNickname = null;
      isMockMode = false;
      _mockDiaries.clear(); // 로그아웃 시 더미 데이터 정리
    }
  }

  /// 프로필 조회
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    if (isMockMode) return _mockUserProfile;

    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId')).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('프로필 조회 실패');
      }
    } catch (e) {
      isMockMode = true; // 연결 실패 시 테스트 모드로 전환
      return _mockUserProfile;
    }
  }

  /// 프로필 수정
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? nickname,
    String? job,
    int? age,
    String? gender,
  }) async {
    if (isMockMode) {
      if (nickname != null) _mockUserProfile['nickname'] = nickname;
      if (job != null) _mockUserProfile['job'] = job;
      if (age != null) _mockUserProfile['age'] = age;
      if (gender != null) _mockUserProfile['gender'] = gender;
      if (nickname != null) currentUserNickname = nickname;
      return _mockUserProfile;
    }

    try {
      final requestBody = <String, dynamic>{};
      if (nickname != null) requestBody['nickname'] = nickname;
      if (job != null) requestBody['job'] = job;
      if (age != null) requestBody['age'] = age;
      if (gender != null) requestBody['gender'] = gender;

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (nickname != null) currentUserNickname = nickname;
        return data;
      } else {
        throw Exception('프로필 수정 실패');
      }
    } catch (e) {
      throw Exception('프로필 수정 중 오류: $e');
    }
  }

  /// 비밀번호 변경
  static Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    if (isMockMode) return;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/password'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'newPasswordConfirm': newPasswordConfirm
        }),
      ).timeout(timeoutDuration);

      if (response.statusCode != 200) throw Exception('비밀번호 변경 실패');
    } catch (e) {
      throw Exception('비밀번호 변경 오류: $e');
    }
  }

  /// 회원 탈퇴
  static Future<void> deleteUser(int userId) async {
    if (isMockMode) {
      currentUserId = null;
      isMockMode = false;
      return;
    }
    try {
      await http.delete(Uri.parse('$baseUrl/users/$userId')).timeout(timeoutDuration);
      currentUserId = null;
    } catch (e) {
      throw Exception('회원탈퇴 오류: $e');
    }
  }

  // ============================================
  // 2. 식물 정보, 사용자 식물 API
  // ============================================

  static Future<List<dynamic>> getAllPlants() async {
    if (isMockMode) return _mockAllPlants;
    try {
      final response = await http.get(Uri.parse('$baseUrl/plants')).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {}
    return _mockAllPlants;
  }

  static Future<Map<String, dynamic>> getPlantDetail(int plantId) async {
    if (isMockMode) {
      return _mockAllPlants.firstWhere((e) => e['id'] == plantId, orElse: () => _mockAllPlants[0]);
    }
    try {
      final response = await http.get(Uri.parse('$baseUrl/plants/$plantId')).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {}
    return _mockAllPlants.firstWhere((e) => e['id'] == plantId, orElse: () => _mockAllPlants[0]);
  }

  static Future<List<dynamic>> getUserPlants(int userId) async {
    if (isMockMode) return _mockUserPlants;
    try {
      final response = await http.get(Uri.parse('$baseUrl/user-plants?userId=$userId')).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("서버 연결 실패, 더미 데이터 반환: $e");
    }
    return _mockUserPlants;
  }

  static Future<Map<String, dynamic>> createUserPlant({
    required int userId,
    required int plantId,
    String? nickname,
    DateTime? startedAt,
  }) async {
    if (isMockMode) {
      final newPlant = {
        'id': _mockUserPlants.length + 100,
        'plantId': plantId,
        'plantName': _mockAllPlants.firstWhere((e) => e['id'] == plantId)['name'],
        'nickname': nickname,
        'startedAt': (startedAt ?? DateTime.now()).toIso8601String(),
      };
      _mockUserPlants.add(newPlant);
      return newPlant;
    }

    try {
      final requestBody = <String, dynamic>{'plantId': plantId};
      if (nickname != null) requestBody['nickname'] = nickname;
      if (startedAt != null) requestBody['startedAt'] = startedAt.toIso8601String().split('T')[0];

      final response = await http.post(
        Uri.parse('$baseUrl/user-plants?userId=$userId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('식물 등록 실패');
      }
    } catch (e) {
      throw Exception('식물 등록 중 오류: $e');
    }
  }

  // ============================================
  // 3. 다이어리 관련 API
  // ============================================

  /// 달력용 다이어리 조회
  static Future<Map<String, dynamic>> getDiaryCalendar({
    required int userPlantId,
    required int year,
    required int month,
  }) async {
    // [수정] Mock 모드일 때 _mockDiaries에서 데이터 조회 후 반환
    if (isMockMode) {
      final filteredDays = _mockDiaries.where((diary) {
        DateTime d = DateTime.parse(diary['diaryDate']);
        return diary['userPlantId'] == userPlantId && d.year == year && d.month == month;
      }).map((diary) {
        return {
          'date': diary['diaryDate'],
          'hasDiary': true,
          'diaryId': diary['id'],
          'thumbnailUrl': diary['imageUrl']
        };
      }).toList();

      return {
        'userPlantId': userPlantId,
        'daysSincePlanted': 10,
        'photoCount': filteredDays.length,
        'year': year,
        'month': month,
        'days': filteredDays,
      };
    }

    try {
      final response = await http.get(
          Uri.parse('$baseUrl/diary/calendar?userPlantId=$userPlantId&year=$year&month=$month')
      ).timeout(timeoutDuration);
      if(response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    } catch(e) {}
    // 실패 시 빈 달력
    return {
      'userPlantId': userPlantId,
      'daysSincePlanted': 0,
      'photoCount': 0,
      'year': year,
      'month': month,
      'days': [],
    };
  }

  /// 특정 날짜 다이어리 조회
  static Future<Map<String, dynamic>> getDiaryByDate({
    required int userPlantId,
    required DateTime date,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];

    // [수정] Mock 모드일 때 _mockDiaries에서 검색
    if (isMockMode) {
      final found = _mockDiaries.firstWhere(
            (element) => element['userPlantId'] == userPlantId && element['diaryDate'].startsWith(dateStr),
        orElse: () => {},
      );

      if (found.isNotEmpty) return found;
      throw Exception('No diary found (Mock)');
    }

    try {
      final response = await http.get(
          Uri.parse('$baseUrl/diary?userPlantId=$userPlantId&date=$dateStr')
      ).timeout(timeoutDuration);
      if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {}
    throw Exception('다이어리 조회 실패');
  }

  /// 다이어리 생성
  static Future<Map<String, dynamic>> createDiary({
    required int userPlantId,
    required DateTime diaryDate,
    String? content,
    String? imagePath,
  }) async {
    // [수정] Mock 모드일 때 _mockDiaries에 데이터 추가
    if (isMockMode) {
      final newId = _mockDiaries.length + 1;
      final newDiary = {
        'id': newId,
        'userPlantId': userPlantId,
        'diaryDate': diaryDate.toIso8601String().split('T')[0],
        'content': content ?? '',
        'imageUrl': imagePath ?? '', // 로컬 경로 저장 (실제 URL 아님)
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': null,
      };
      _mockDiaries.add(newDiary);
      await Future.delayed(Duration(milliseconds: 500)); // 통신 흉내
      return newDiary;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/diary'));
      request.fields['userPlantId'] = userPlantId.toString();
      request.fields['diaryDate'] = diaryDate.toIso8601String().split('T')[0];
      if (content != null) request.fields['content'] = content;

      if (imagePath != null && await File(imagePath).exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
      else throw Exception('다이어리 생성 실패 (Code: ${response.statusCode})');
    } catch(e) {
      throw Exception('다이어리 생성 오류: $e');
    }
  }

  /// 다이어리 수정
  static Future<Map<String, dynamic>> updateDiary({
    required int diaryId,
    String? content,
    String? imagePath,
  }) async {
    // [수정] Mock 모드일 때 수정 로직
    if (isMockMode) {
      final index = _mockDiaries.indexWhere((element) => element['id'] == diaryId);
      if (index != -1) {
        if (content != null) _mockDiaries[index]['content'] = content;
        if (imagePath != null) _mockDiaries[index]['imageUrl'] = imagePath;
        _mockDiaries[index]['updatedAt'] = DateTime.now().toIso8601String();
        return _mockDiaries[index];
      }
      return {};
    }

    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/diary/$diaryId'));
      if (content != null) request.fields['content'] = content;

      if (imagePath != null && await File(imagePath).exists()) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('다이어리 수정 실패');
      }
    } catch (e) {
      throw Exception('다이어리 수정 오류: $e');
    }
  }

  /// 다이어리 삭제
  static Future<void> deleteDiary(int diaryId) async {
    // [수정] Mock 모드일 때 삭제 로직
    if (isMockMode) {
      _mockDiaries.removeWhere((element) => element['id'] == diaryId);
      return;
    }

    try {
      final response = await http.delete(Uri.parse('$baseUrl/diary/$diaryId')).timeout(timeoutDuration);
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('다이어리 삭제 실패');
      }
    } catch (e) {
      throw Exception('다이어리 삭제 오류: $e');
    }
  }

  /// 타임라인 조회
  static Future<Map<String, dynamic>> getTimeline(int userPlantId) async {
    // [수정] Mock 모드일 때 타임라인 조회
    if (isMockMode) {
      final items = _mockDiaries
          .where((d) => d['userPlantId'] == userPlantId && d['imageUrl'] != null && d['imageUrl'].isNotEmpty)
          .map((d) => {
        'id': d['id'],
        'diaryDate': d['diaryDate'],
        'imageUrl': d['imageUrl'],
        'content': d['content'],
      }).toList();

      return {
        'userPlantId': userPlantId,
        'items': items,
      };
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/diary/timeline?userPlantId=$userPlantId')).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('타임라인 조회 실패');
      }
    } catch (e) {
      throw Exception('타임라인 조회 오류: $e');
    }
  }

  // ============================================
  // 4. 질병 진단 API (DiagnosisController)
  // ============================================

  /// 모바일 사진으로 질병 진단 요청
  /// Backend: POST /api/diagnosis/mobile
  /// Params: userPlantId (part, json), symptomNote (part, json), image (file)
  static Future<Map<String, dynamic>> requestDiagnosis({
    required int userPlantId,
    String? symptomNote,
    required String imagePath,
  }) async {
    if (isMockMode) {
      await Future.delayed(Duration(seconds: 3));
      return {
        'healthSummary': '잎의 색이 선명하고 생기가 넘칩니다.',
        'diseaseStatus': '정상',
        'diseaseDetails': '특별한 병해충 징후가 보이지 않습니다.',
        'advice': '현재 환경(햇빛, 물주기)을 잘 유지해주세요.',
        'harvestPredictionDate': DateTime.now().add(Duration(days: 20)).toIso8601String().split('T')[0],
        'createdAt': DateTime.now().toIso8601String(),
      };
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/diagnosis/mobile'));

      // [중요] 백엔드 @RequestPart가 'application/json' 타입을 요구할 때를 대비하여
      // fields 대신 files.add(MultipartFile.fromString(... contentType...)) 방식을 사용합니다.

      // 1. userPlantId
      request.files.add(http.MultipartFile.fromString(
        'userPlantId',
        userPlantId.toString(),
        contentType: MediaType('application', 'json'),
      ));

      // 2. symptomNote (선택사항)
      if (symptomNote != null) {
        request.files.add(http.MultipartFile.fromString(
          'symptomNote',
          symptomNote,
          contentType: MediaType('application', 'json'),
        ));
      }

      // 3. image
      File file = File(imagePath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imagePath,
          // 이미지 contentType은 http 패키지가 파일 확장자로 자동 추론하지만,
          // 필요하다면 contentType: MediaType('image', 'jpeg') 등으로 명시 가능
        ));
      } else {
        throw Exception("이미지 파일이 존재하지 않습니다.");
      }

      print("[API] 진단 요청 전송 중...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("[API] 진단 응답 코드: ${response.statusCode}");
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('진단 요청 실패: ${response.statusCode} / ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print("[API Error] $e");
      throw Exception('진단 API 오류: $e');
    }
  }

  // ============================================
  // 5. IoT 기기 및 센서 API
  // ============================================

  /// 내 기기 목록 조회
  static Future<List<dynamic>> getMyDevices(int userId) async {
    if (isMockMode) {
      return [{'id': 1, 'macAddress': 'AA:BB:CC:00:11', 'type': 'R_PI'}];
    }
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices/my?userId=$userId')).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {}
    return [];
  }

  /// 특정 기기의 최근 24시간 센서 데이터 조회
  static Future<SensorData24h?> getSensorData24h(int userPlantId) async {
    if (isMockMode) {
      return _generateMockSensorData(userPlantId);
    }

    final url = Uri.parse('$baseUrl/devices/$userPlantId/sensors/last24h');

    try {
      final response = await http.get(url).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        String jsonString = utf8.decode(response.bodyBytes);
        final data = jsonDecode(jsonString);
        return SensorData24h.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static SensorData24h _generateMockSensorData(int deviceId) {
    DateTime now = DateTime.now();
    DateTime from = now.subtract(Duration(hours: 24));
    Random random = Random();

    List<SensorPoint> generatePoints(double baseValue, double variance) {
      List<SensorPoint> points = [];
      for (int i = 0; i < 24 * 6; i++) {
        DateTime time = from.add(Duration(minutes: i * 10));
        double sineWave = sin(i * 0.1) * (variance * 0.5);
        double noise = (random.nextDouble() * variance) - (variance * 0.5);
        double value = baseValue + sineWave + noise;
        points.add(SensorPoint(timestamp: time, value: double.parse(value.toStringAsFixed(1))));
      }
      return points;
    }

    return SensorData24h(
      deviceId: deviceId,
      from: from,
      to: now,
      temperature: SensorSeries(unit: "°C", points: generatePoints(24.0, 2.0)),
      humidity: SensorSeries(unit: "%", points: generatePoints(60.0, 5.0)),
      illuminance: SensorSeries(unit: "lux", points: generatePoints(800, 100)),
      co2: SensorSeries(unit: "ppm", points: generatePoints(450, 20)),
      ec: SensorSeries(unit: "mS/cm", points: generatePoints(1.2, 0.2)),
    );
  }
}