import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:si_cegah/model/video_item.dart';

class VideoService {
  static const String baseUrl = 'https://sicegah.vercel.app/api';

  // Mendapatkan daftar semua video dari API
  Future<List<VideoItem>> getVideos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VideoItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }

  // Stream untuk kompatibilitas dengan kode existing
  Stream<List<VideoItem>> getVideosStream() async* {
    try {
      final videos = await getVideos();
      yield videos;
    } catch (e) {
      throw Exception('Stream error: $e');
    }
  }

  // Mendapatkan video berdasarkan ID
  Future<VideoItem> getVideoById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return VideoItem.fromJson(data);
      } else {
        throw Exception('Failed to load video: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching video: $e');
    }
  }

  // Mendapatkan video berdasarkan kategori
  Future<List<VideoItem>> getVideosByCategory(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final allVideos = data.map((json) => VideoItem.fromJson(json)).toList();
        return allVideos
            .where((video) => video.categoryId == categoryId)
            .toList();
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching videos by category: $e');
    }
  }

  // Mendapatkan statistik video
  Future<Map<String, dynamic>> getVideoStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load video stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching video stats: $e');
    }
  }
}
