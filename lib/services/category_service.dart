import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String baseUrl = 'https://sicegah.vercel.app/api';

  // Mendapatkan daftar semua kategori
  Future<List<VideoCategory>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/video-categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VideoCategory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Mendapatkan kategori dengan statistik
  Future<List<VideoCategory>> getCategoriesWithStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/video-categories/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => VideoCategory.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load category stats: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching category stats: $e');
    }
  }

  // Mendapatkan kategori berdasarkan ID
  Future<VideoCategory> getCategoryById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/video-categories/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return VideoCategory.fromJson(data);
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching category: $e');
    }
  }
}

class VideoCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? videoCount;
  final int? totalViews;

  VideoCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.videoCount,
    this.totalViews,
  });

  factory VideoCategory.fromJson(Map<String, dynamic> json) {
    return VideoCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#000000',
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      videoCount: json['videoCount'],
      totalViews: json['totalViews'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (videoCount != null) 'videoCount': videoCount,
      if (totalViews != null) 'totalViews': totalViews,
    };
  }
}
