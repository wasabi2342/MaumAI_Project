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
  /// 개발: http://localhost:8080/api
  /// 프로덕션: https://your-server.com/api
  static const String baseUrl = 'http://192.168.0.10:8080/api';

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
  ///
  /// POST /api/users/signup
  ///
  /// [nickname] 닉네임 (필수)
  /// [email] 이메일 (필수)
  /// [password] 비밀번호 (필수)
  /// [passwordConfirm] 비밀번호 확인 (필수)
  /// [job] 직업 (선택)
  /// [age] 나이 (선택)
  /// [gender] 성별 (선택)
  ///
  /// Returns: UserProfileResponse
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
  ///
  /// POST /api/users/login
  ///
  /// [email] 이메일
  /// [password] 비밀번호
  ///
  /// Returns: UserProfileResponse
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
  ///
  /// POST /api/users/logout
  ///
  /// 현재는 클라이언트 측에서만 상태 클리어
  static Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/users/logout')).timeout(timeoutDuration);

      // 클라이언트 측 상태 클리어
      currentUserId = null;
      currentUserEmail = null;
      currentUserNickname = null;
    } catch (e) {
      // 로그아웃 실패해도 클라이언트 상태는 클리어
      currentUserId = null;
      currentUserEmail = null;
      currentUserNickname = null;
    }
  }

  /// 프로필 조회
  ///
  /// GET /api/users/{id}
  ///
  /// [userId] 사용자 ID
  ///
  /// Returns: UserProfileResponse
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
  ///
  /// PUT /api/users/{id}/profile
  ///
  /// [userId] 사용자 ID
  /// [nickname] 닉네임 (선택)
  /// [job] 직업 (선택)
  /// [age] 나이 (선택)
  /// [gender] 성별 (선택)
  ///
  /// Returns: UserProfileResponse
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
  ///
  /// PUT /api/users/{id}/password
  ///
  /// [userId] 사용자 ID
  /// [currentPassword] 현재 비밀번호
  /// [newPassword] 새 비밀번호
  /// [newPasswordConfirm] 새 비밀번호 확인
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
  ///
  /// DELETE /api/users/{id}
  ///
  /// [userId] 사용자 ID
  static Future<void> deleteUser(int userId) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/users/$userId'))
          .timeout(timeoutDuration);

      if (response.statusCode == 204) {
        // 회원탈퇴 성공 시 클라이언트 상태 클리어
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
  ///
  /// GET /api/plants
  ///
  /// 식물 선택 화면에서 사용
  ///
  /// Returns: List<PlantInfoResponse>
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
  ///
  /// GET /api/plants/{plantId}
  ///
  /// [plantId] 식물 ID
  ///
  /// 팝업 상세 정보 표시용
  ///
  /// Returns: PlantInfoResponse
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

  /// 내 식물 등록
  ///
  /// POST /api/user-plants?userId={userId}
  ///
  /// [userId] 사용자 ID
  /// [plantId] 선택한 식물 ID
  /// [nickname] 식물 별칭 (선택)
  /// [startedAt] 재배 시작일 (선택, 기본값: 오늘)
  ///
  /// Returns: UserPlantResponse
  static Future<Map<String, dynamic>> createUserPlant({
    required int userId,
    required int plantId,
    String? nickname,
    DateTime? startedAt,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'plantId': plantId,
      };

      if (nickname != null) requestBody['nickname'] = nickname;
      if (startedAt != null) {
        requestBody['startedAt'] = startedAt.toIso8601String().split('T')[0];
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
  ///
  /// GET /api/diary/calendar?userPlantId={userPlantId}&year={year}&month={month}
  ///
  /// [userPlantId] 사용자 식물 ID
  /// [year] 연도
  /// [month] 월
  ///
  /// Returns: DiaryCalendarResponse
  static Future<Map<String, dynamic>> getDiaryCalendar({
    required int userPlantId,
    required int year,
    required int month,
  }) async {
    try {
      final response = await http
          .get(
        Uri.parse(
            '$baseUrl/diary/calendar?userPlantId=$userPlantId&year=$year&month=$month'),
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
  ///
  /// GET /api/diary?userPlantId={userPlantId}&date={date}
  ///
  /// [userPlantId] 사용자 식물 ID
  /// [date] 날짜
  ///
  /// Returns: DiaryResponse
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
  ///
  /// POST /api/diary (multipart/form-data)
  ///
  /// [userPlantId] 사용자 식물 ID
  /// [diaryDate] 다이어리 날짜
  /// [content] 내용 (선택)
  /// [imagePath] 이미지 파일 경로 (선택)
  ///
  /// Returns: DiaryResponse
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

      // form-data 파라미터
      request.fields['userPlantId'] = userPlantId.toString();
      request.fields['diaryDate'] = diaryDate.toIso8601String().split('T')[0];
      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }

      // 이미지 파일 첨부
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
  ///
  /// PUT /api/diary/{diaryId} (multipart/form-data)
  ///
  /// [diaryId] 다이어리 ID
  /// [content] 수정할 내용 (선택)
  /// [imagePath] 수정할 이미지 파일 경로 (선택)
  ///
  /// Returns: DiaryResponse
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
  ///
  /// DELETE /api/diary/{diaryId}
  ///
  /// [diaryId] 다이어리 ID
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
  ///
  /// GET /api/diary/timeline?userPlantId={userPlantId}
  ///
  /// [userPlantId] 사용자 식물 ID
  ///
  /// 사진이 있는 다이어리만 조회
  ///
  /// Returns: DiaryTimelineResponse
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