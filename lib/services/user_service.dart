// services/user_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'https://sicegah.vercel.app/api';

  // Get user achievements by calculating from existing test data
  static Future<Map<String, dynamic>?> getUserAchievements(
    String userId,
  ) async {
    try {
      // Get all test attempts for user
      final url = '$baseUrl/test-attempts?userId=$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final attempts = data['data'] as List;

          // Calculate achievements
          final passedTests = attempts.where((attempt) {
            return attempt['isPassed'] == true;
          }).toList();

          final completedVideos = passedTests.length;
          final totalStars = passedTests.fold<int>(0, (sum, attempt) {
            final stars = attempt['starRating'] ?? 0;
            return sum + (stars as int);
          });

          final result = {
            'completedVideos': completedVideos,
            'totalStars': totalStars,
            'passedTests': passedTests.length,
            'totalAttempts': attempts.length,
          };

          return result;
        } else {}
      } else {}

      // Fallback: return zero stats
      final fallback = {
        'completedVideos': 0,
        'totalStars': 0,
        'passedTests': 0,
        'totalAttempts': 0,
      };

      return fallback;
    } catch (e) {
      print('ERROR Achievements - Exception: $e');
      // Return zero stats on error
      return {
        'completedVideos': 0,
        'totalStars': 0,
        'passedTests': 0,
        'totalAttempts': 0,
      };
    }
  }

  // Get user's test results for a specific video (to show star rating)
  static Future<Map<String, dynamic>?> getUserVideoProgress(
    String userId,
    String videoId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/test-attempts?userId=$userId&videoId=$videoId&latest=true',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ? data['data'] : null;
      }
      return null;
    } catch (e) {
      print('Error getting user video progress: $e');
      return null;
    }
  }

  // Check if user PASSED (not just completed) test for video
  static Future<int> getUserStarRating(String userId, String videoId) async {
    try {
      final progress = await getUserVideoProgress(userId, videoId);

      if (progress != null && progress['isPassed'] == true) {
        return progress['starRating'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting star rating: $e');
      return 0;
    }
  }
}
