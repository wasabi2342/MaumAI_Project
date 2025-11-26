import 'package:http/http.dart' as http;
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
  /// [중요] 실행 환경에 따라 주소를 변경하세요.
  static const String baseUrl = 'http://192.168.0.3:8080/api';

  /// 저장된 사용자 정보 (로그인 후)
  static int? currentUserId;
  static String? currentUserEmail;
  static String? currentUserNickname;

  /// HTTP 타임아웃 설정
  static const Duration timeoutDuration = Duration(seconds: 10);

  // ============================================
  // [MOCK] 더미 데이터 설정
  // ============================================
  static bool isMockMode = false;

  // 더미 사용자 프로필 데이터
  static Map<String, dynamic> _mockUserProfile = {
    'id': 999,
    'nickname': '마스터농부',
    'email': '1111@naver.com',
    'job': '개발자',
    'age': 25,
    'gender': '남성',
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
    {
      'id': 3, 'name': '스위트 바질', 'difficulty': 'EASY',
      'tempMin': 20.0, 'tempMax': 25.0,
      'humidityMin': 60.0, 'humidityMax': 80.0,
      'lightLevel': 'HIGH',
    },
    {
      'id': 4, 'name': '청양고추', 'difficulty': 'MEDIUM',
      'tempMin': 25.0, 'tempMax': 30.0,
      'humidityMin': 60.0, 'humidityMax': 70.0,
      'lightLevel': 'HIGH',
    },
    {
      'id': 5, 'name': '애플민트', 'difficulty': 'EASY',
      'tempMin': 15.0, 'tempMax': 25.0,
      'humidityMin': 70.0, 'humidityMax': 90.0,
      'lightLevel': 'MEDIUM',
    },
    {
      'id': 6, 'name': '설향 딸기', 'difficulty': 'HARD',
      'tempMin': 17.0, 'tempMax': 23.0,
      'humidityMin': 50.0, 'humidityMax': 60.0,
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
    if (isMockMode) {
      return {
        'id': 999, 'nickname': nickname, 'email': email, 'job': job, 'age': age, 'gender': gender
      };
    }

    try {
      final response = await http
          .post(
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
      )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
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
      await Future.delayed(Duration(seconds: 1));
      return _mockUserProfile;
    }

    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(timeoutDuration);

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
      if (e.toString().contains('이메일') || e.toString().contains('비밀번호')) {
        rethrow;
      }
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  static Future<void> logout() async {
    if (isMockMode) {
      isMockMode = false;
      currentUserId = null;
      currentUserEmail = null;
      currentUserNickname = null;
      return;
    }
    try {
      await http.post(Uri.parse('$baseUrl/users/logout')).timeout(timeoutDuration);
    } catch (e) {
      // ignore
    } finally {
      currentUserId = null;
      currentUserEmail = null;
      currentUserNickname = null;
    }
  }

  /// 프로필 조회
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    if (isMockMode) {
      await Future.delayed(Duration(milliseconds: 500));
      return _mockUserProfile;
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId')).timeout(timeoutDuration);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('프로필 조회 실패');
      }
    } catch (e) {
      // 서버 연결 실패 시 로컬 테스트를 위해 더미 사용
      print('서버 연결 오류로 더미 프로필 사용: $e');
      isMockMode = true;
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
      await Future.delayed(Duration(seconds: 1));
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

      final response = await http
          .put(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      )
          .timeout(timeoutDuration);

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
    } catch (e) { throw Exception('비밀번호 변경 오류: $e'); }
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
    } catch (e) { throw Exception('회원탈퇴 오류: $e'); }
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
      await Future.delayed(Duration(seconds: 1));
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

      final response = await http
          .post(
        Uri.parse('$baseUrl/user-plants?userId=$userId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      )
          .timeout(timeoutDuration);

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
  // 3. 다이어리 관련 API (누락되었던 메서드 복구)
  // ============================================

  /// 달력용 다이어리 조회
  static Future<Map<String, dynamic>> getDiaryCalendar({
    required int userPlantId,
    required int year,
    required int month,
  }) async {
    if (isMockMode) {
      return {
        'userPlantId': userPlantId, 'year': year, 'month': month,
        'daysSincePlanted': 5, 'photoCount': 0, 'days': []
      };
    }
    try {
      final response = await http.get(Uri.parse('$baseUrl/diary/calendar?userPlantId=$userPlantId&year=$year&month=$month')).timeout(timeoutDuration);
      if(response.statusCode == 200) return jsonDecode(utf8.decode(response.bodyBytes));
    } catch(e) {}
    return {'userPlantId': userPlantId, 'year': year, 'month': month, 'daysSincePlanted': 5, 'photoCount': 0, 'days': []};
  }

  /// 특정 날짜 다이어리 조회
  static Future<Map<String, dynamic>> getDiaryByDate({
    required int userPlantId,
    required DateTime date,
  }) async {
    if (isMockMode) throw Exception('No diary');
    final dateStr = date.toIso8601String().split('T')[0];
    try {
      final response = await http.get(Uri.parse('$baseUrl/diary?userPlantId=$userPlantId&date=$dateStr')).timeout(timeoutDuration);
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
    if (isMockMode) return {};
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
    throw Exception('다이어리 생성 실패');
  }

  /// [복구됨] 다이어리 수정
  static Future<Map<String, dynamic>> updateDiary({
    required int diaryId,
    String? content,
    String? imagePath,
  }) async {
    if (isMockMode) {
      await Future.delayed(Duration(seconds: 1));
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

  /// [복구됨] 다이어리 삭제
  static Future<void> deleteDiary(int diaryId) async {
    if (isMockMode) return;
    try {
      final response = await http.delete(Uri.parse('$baseUrl/diary/$diaryId')).timeout(timeoutDuration);
      if (response.statusCode != 204) {
        throw Exception('다이어리 삭제 실패');
      }
    } catch (e) {
      throw Exception('다이어리 삭제 오류: $e');
    }
  }

  /// [복구됨] 타임라인 조회
  static Future<Map<String, dynamic>> getTimeline(int userPlantId) async {
    if (isMockMode) {
      return {'items': []};
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
  // 5. 센서 데이터 관련 API
  // ============================================

  /// 특정 기기의 최근 24시간 센서 데이터 조회
  static Future<SensorData24h?> getSensorData24h(int deviceId) async {
    // 1. Mock 모드면 바로 가짜 데이터 반환
    if (isMockMode) {
      return _generateMockSensorData(deviceId);
    }

    // 2. 서버 연결 시도
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/devices/$deviceId/sensors/last24h'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return SensorData24h.fromJson(data);
      } else {
        print('센서 데이터 조회 실패 (Code: ${response.statusCode}). 더미 데이터 사용.');
        return _generateMockSensorData(deviceId);
      }
    } catch (e) {
      print('센서 데이터 통신 오류: $e. 더미 데이터 사용.');
      return _generateMockSensorData(deviceId);
    }
  }

  /// [MOCK] 그래프 및 UI 테스트를 위한 가짜 센서 데이터 생성기
  static SensorData24h _generateMockSensorData(int deviceId) {
    DateTime now = DateTime.now();
    DateTime from = now.subtract(Duration(hours: 24));
    Random random = Random();

    List<SensorPoint> generatePoints(double baseValue, double variance) {
      List<SensorPoint> points = [];
      for (int i = 0; i < 24 * 6; i++) { // 144 points
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