// services/quiz_service.dart - Service untuk handle quiz API calls
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizService {
  static const String baseUrl = 'https://sicegah.vercel.app/api';

  // Get test by video ID
  static Future<Map<String, dynamic>?> getTestByVideoId(String videoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tests/by-video/$videoId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ? data['data'] : null;
      }
      return null;
    } catch (e) {
      print('Error getting test: $e');
      return null;
    }
  }

  // Create test attempt
  static Future<String?> createTestAttempt(String userId, String testId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/test-attempts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'testId': testId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] ? data['data']['id'] : null;
      }
      return null;
    } catch (e) {
      print('Error creating test attempt: $e');
      return null;
    }
  }

  // Submit user answer
  static Future<Map<String, dynamic>?> submitAnswer({
    required String userId,
    required String questionId,
    required String testAttemptId,
    required String answer,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-answers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'questionId': questionId,
          'testAttemptId': testAttemptId,
          'answer': answer,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ? data['data'] : null;
      }
      return null;
    } catch (e) {
      print('Error submitting answer: $e');
      return null;
    }
  }

  // Complete test attempt
  static Future<Map<String, dynamic>?> completeTest(
    String attemptId,
    String userId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/test-attempts/$attemptId/complete'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ? data['data'] : null;
      }
      return null;
    } catch (e) {
      print('Error completing test: $e');
      return null;
    }
  }
}
