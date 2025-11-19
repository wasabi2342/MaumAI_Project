import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

/// 베란다 농부 API 서비스
///
/// 백엔드 Spring Boot API와 통신하는 서비스 클래스
/// 모든 API 엔드포인트를 Flutter 앱에서 사용 가능하도록 래핑
class ApiService {
  // ============================================
  // 설정
  // ============================================

  /// 서버 베이스 URL
  /// TODO: 실제 서버 주소로 변경 필요
  /// 에뮬레이터: http://10.0.2.2:8080/api
  /// 실제 기기: http://192.168.x.x:8080/api (PC의 내부 IP)
  static const String baseUrl = 'http://192.168.0.3:8080/api';

  /// 저장된 사용자 정보 (로그인 후)
  static int? currentUserId;
  static String? currentUserEmail;
  static String? currentUserNickname;

  /// HTTP 타임아웃 설정
  static const Duration timeoutDuration = Duration(seconds: 30);

  // ============================================
  // 1. 사용자 관련 API (UserController)
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
    } on SocketException {
      throw Exception('서버에 연결할 수 없습니다.\n네트워크 연결을 확인해주세요.');
    } on TimeoutException {
      throw Exception('서버 응답 시간이 초과되었습니다.');
    } catch (e) {
      throw Exception('회원가입 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 로그인
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
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
        currentUserId = data['id'];
        currentUserEmail = data['email'];
        currentUserNickname = data['nickname'];
        return data;
      } else {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      }
    } on SocketException {
      throw Exception('서버에 연결할 수 없습니다.\n네트워크 연결을 확인해주세요.');
    } on TimeoutException {
      throw Exception('서버 응답 시간이 초과되었습니다.');
    } catch (e) {
      if (e.toString().contains('이메일') || e.toString().contains('비밀번호')) {
        rethrow;
      }
      throw Exception('로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 로그아웃
  static Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/users/logout')).timeout(timeoutDuration);
      currentUserId = null;
      currentUserEmail = null;
      currentUserNickname = null;
    } catch (e) {
      currentUserId = null;
      currentUserEmail = null;
      currentUserNickname = null;
    }
  }

  /// 프로필 조회
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/$userId'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('프로필 조회 실패');
      }
    } catch (e) {
      throw Exception('프로필 조회 중 오류가 발생했습니다: ${e.toString()}');
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
      throw Exception('프로필 수정 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 비밀번호 변경
  static Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/users/$userId/password'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'newPasswordConfirm': newPasswordConfirm,
        }),
      )
          .timeout(timeoutDuration);

      if (response.statusCode != 200) {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? '비밀번호 변경 실패');
      }
    } catch (e) {
      throw Exception('비밀번호 변경 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 회원탈퇴
  static Future<void> deleteUser(int userId) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/users/$userId'))
          .timeout(timeoutDuration);

      if (response.statusCode == 204) {
        currentUserId = null;
        currentUserEmail = null;
        currentUserNickname = null;
      } else {
        throw Exception('회원탈퇴 실패');
      }
    } catch (e) {
      throw Exception('회원탈퇴 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // ============================================
  // 2. 식물 정보 관련 API (PlantInfoController)
  // ============================================

  /// 전체 식물 리스트 조회
  static Future<List<dynamic>> getAllPlants() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/plants'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('식물 리스트 조회 실패');
      }
    } catch (e) {
      throw Exception('식물 리스트 조회 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 식물 상세 정보 조회
  static Future<Map<String, dynamic>> getPlantDetail(int plantId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/plants/$plantId'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('식물 상세 조회 실패');
      }
    } catch (e) {
      throw Exception('식물 상세 조회 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // ============================================
  // 3. 사용자 식물 관련 API (UserPlantController)
  // ============================================

  /// [추가됨] 사용자 식물 목록 조회
  /// 홈 화면 등에서 로그인한 사용자의 식물을 불러올 때 사용
  static Future<List<dynamic>> getUserPlants(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/user-plants?userId=$userId'))
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        return []; // 실패하거나 식물이 없으면 빈 리스트 반환
      }
    } catch (e) {
      print('사용자 식물 목록 조회 실패: $e');
      return [];
    }
  }

  /// 내 식물 등록
  static Future<Map<String, dynamic>> createUserPlant({
    required int userId,
    required int plantId,
    String? nickname,
    DateTime? startedAt,
    int? deviceId,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'plantId': plantId,
      };

      if (nickname != null) requestBody['nickname'] = nickname;
      if (startedAt != null) {
        requestBody['startedAt'] = startedAt.toIso8601String().split('T')[0];
      }
      if (deviceId != null) {
        requestBody['deviceId'] = deviceId;
      }
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
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? '식물 등록 실패');
      }
    } catch (e) {
      throw Exception('식물 등록 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // ============================================
  // 4. 다이어리 관련 API (DiaryController)
  // ============================================

  /// 달력 화면용 다이어리 조회
  static Future<Map<String, dynamic>> getDiaryCalendar({
    required int userPlantId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/diary/calendar?userPlantId=$userPlantId&year=$year&month=$month'),
      )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('다이어리 달력 조회 실패');
      }
    } catch (e) {
      throw Exception('다이어리 달력 조회 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 특정 날짜의 다이어리 조회
  static Future<Map<String, dynamic>> getDiaryByDate({
    required int userPlantId,
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http
          .get(
        Uri.parse('$baseUrl/diary?userPlantId=$userPlantId&date=$dateStr'),
      )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 404) {
        throw Exception('해당 날짜의 다이어리가 없습니다.');
      } else {
        throw Exception('다이어리 조회 실패');
      }
    } catch (e) {
      throw Exception('다이어리 조회 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 다이어리 생성
  static Future<Map<String, dynamic>> createDiary({
    required int userPlantId,
    required DateTime diaryDate,
    String? content,
    String? imagePath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/diary'),
      );

      request.fields['userPlantId'] = userPlantId.toString();
      request.fields['diaryDate'] = diaryDate.toIso8601String().split('T')[0];
      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('image', imagePath),
          );
        }
      }

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 409) {
        throw Exception('해당 날짜에는 이미 다이어리가 존재합니다.');
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? '다이어리 생성 실패');
      }
    } catch (e) {
      throw Exception('다이어리 생성 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 다이어리 수정
  static Future<Map<String, dynamic>> updateDiary({
    required int diaryId,
    String? content,
    String? imagePath,
  }) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/diary/$diaryId'),
      );

      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('image', imagePath),
          );
        }
      }

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('다이어리 수정 실패');
      }
    } catch (e) {
      throw Exception('다이어리 수정 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 다이어리 삭제
  static Future<void> deleteDiary(int diaryId) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/diary/$diaryId'))
          .timeout(timeoutDuration);

      if (response.statusCode != 204) {
        throw Exception('다이어리 삭제 실패');
      }
    } catch (e) {
      throw Exception('다이어리 삭제 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 타임라인 조회
  static Future<Map<String, dynamic>> getTimeline(int userPlantId) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/diary/timeline?userPlantId=$userPlantId'),
      )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('타임라인 조회 실패');
      }
    } catch (e) {
      throw Exception('타임라인 조회 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // ============================================
  // 5. 유틸리티 메서드
  // ============================================

  /// 현재 로그인 상태 확인
  static bool get isLoggedIn => currentUserId != null;

  /// 현재 사용자 정보 초기화
  static void clearCurrentUser() {
    currentUserId = null;
    currentUserEmail = null;
    currentUserNickname = null;
  }

  /// 서버 연결 테스트
  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl.replaceAll('/api', '')))
          .timeout(Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      return false;
    }
  }
}