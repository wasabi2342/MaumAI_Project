import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // TODO: 실제 서버 주소로 변경 필요
  static const String baseUrl = 'http://192.168.0.10:8080/api';

  // 저장된 사용자 정보 (로그인 후)
  static int? currentUserId;
  static String? currentUserEmail;

  // ============================================
  // 1. 회원가입
  // ============================================
  static Future<Map<String, dynamic>> signup({
    required String nickname,
    required String email,
    required String password,
    required String passwordConfirm,
    String? job,
    int? age,
    String? gender,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nickname': nickname,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'job': job,
        'age': age,
        'gender': gender,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      currentUserId = data['id'];
      currentUserEmail = data['email'];
      return data;
    } else {
      throw Exception('회원가입 실패: ${response.body}');
    }
  }

  // ============================================
  // 2. 로그인
  // ============================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      currentUserId = data['id'];
      currentUserEmail = data['email'];
      return data;
    } else {
      throw Exception('로그인 실패: ${response.body}');
    }
  }

  // ============================================
  // 3. 프로필 조회
  // ============================================
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('프로필 조회 실패');
    }
  }

  // ============================================
  // 4. 프로필 수정
  // ============================================
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? nickname,
    String? job,
    int? age,
    String? gender,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (nickname != null) 'nickname': nickname,
        if (job != null) 'job': job,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('프로필 수정 실패');
    }
  }

  // ============================================
  // 5. 비밀번호 변경
  // ============================================
  static Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'newPasswordConfirm': newPasswordConfirm,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('비밀번호 변경 실패');
    }
  }

  // ============================================
  // 6. 식물 정보 조회 (Plant Selection Screen)
  // ============================================
  static Future<List<dynamic>> getAllPlants() async {
    final response = await http.get(
      Uri.parse('$baseUrl/plants'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('식물 리스트 조회 실패');
    }
  }

  // ============================================
  // 7. 식물 상세 정보 (팝업용)
  // ============================================
  static Future<Map<String, dynamic>> getPlantDetail(int plantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/plants/$plantId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('식물 상세 조회 실패');
    }
  }

  // ============================================
  // 8. 내 식물 등록 (선택한 식물 → UserPlant 생성)
  // ============================================
  static Future<Map<String, dynamic>> createUserPlant({
    required int userId,
    required int plantId,
    String? nickname,
    DateTime? startedAt,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user-plants?userId=$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'plantId': plantId,
        if (nickname != null) 'nickname': nickname,
        if (startedAt != null)
          'startedAt': startedAt.toIso8601String().split('T')[0],
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('식물 등록 실패: ${response.body}');
    }
  }

  // ============================================
  // 9. 다이어리 달력 조회 (Diary Screen)
  // ============================================
  static Future<Map<String, dynamic>> getDiaryCalendar({
    required int userPlantId,
    required int year,
    required int month,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/diary/calendar?userPlantId=$userPlantId&year=$year&month=$month'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('다이어리 달력 조회 실패');
    }
  }

  // ============================================
  // 10. 특정 날짜 다이어리 조회
  // ============================================
  static Future<Map<String, dynamic>> getDiaryByDate({
    required int userPlantId,
    required DateTime date,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await http.get(
      Uri.parse('$baseUrl/diary?userPlantId=$userPlantId&date=$dateStr'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('다이어리 조회 실패');
    }
  }

  // ============================================
  // 11. 다이어리 생성 (multipart/form-data)
  // ============================================
  static Future<Map<String, dynamic>> createDiary({
    required int userPlantId,
    required DateTime diaryDate,
    String? content,
    String? imagePath, // 로컬 이미지 경로
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/diary'),
    );

    // form-data 파라미터
    request.fields['userPlantId'] = userPlantId.toString();
    request.fields['diaryDate'] = diaryDate.toIso8601String().split('T')[0];
    if (content != null) {
      request.fields['content'] = content;
    }

    // 이미지 파일 첨부
    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('다이어리 생성 실패: ${response.body}');
    }
  }

  // ============================================
  // 12. 다이어리 수정
  // ============================================
  static Future<Map<String, dynamic>> updateDiary({
    required int diaryId,
    String? content,
    String? imagePath,
  }) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/diary/$diaryId'),
    );

    if (content != null) {
      request.fields['content'] = content;
    }

    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('다이어리 수정 실패');
    }
  }

  // ============================================
  // 13. 다이어리 삭제
  // ============================================
  static Future<void> deleteDiary(int diaryId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/diary/$diaryId'),
    );

    if (response.statusCode != 204) {
      throw Exception('다이어리 삭제 실패');
    }
  }

  // ============================================
  // 14. 타임라인 조회
  // ============================================
  static Future<Map<String, dynamic>> getTimeline(int userPlantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/diary/timeline?userPlantId=$userPlantId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('타임라인 조회 실패');
    }
  }
}
