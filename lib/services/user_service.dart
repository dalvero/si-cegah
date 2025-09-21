// services/user_service.dart - Service untuk user achievements & progress
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'https://sicegah.vercel.app/api';

  // Get user achievements and stats
  static Future<Map<String, dynamic>?> getUserAchievements(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/achievements'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ? data['data'] : null;
      }
      return null;
    } catch (e) {
      print('Error getting user achievements: $e');
      return null;
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

  // Check if user has completed test for video
  static Future<int> getUserStarRating(String userId, String videoId) async {
    try {
      final progress = await getUserVideoProgress(userId, videoId);
      if (progress != null && progress['isCompleted'] == true) {
        return progress['starRating'] ?? 0;
      }
      return 0; // No stars if not completed
    } catch (e) {
      print('Error getting star rating: $e');
      return 0;
    }
  }
}
