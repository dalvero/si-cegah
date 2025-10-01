// lib/services/child_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:si_cegah/models/child_model.dart';
import 'package:si_cegah/services/auth_service.dart';

class ChildService {
  static const String baseUrl = 'https://sicegah.vercel.app/api';
  final AuthService _authService = AuthService();

  // Helper method untuk mendapatkan headers dengan authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken(); // Tambah await
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET - Ambil semua data anak
  Future<List<Child>> getChildren() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/children'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final List<dynamic> childrenJson = data['data'];
          return childrenJson.map((json) => Child.fromJson(json)).toList();
        } else {
          throw Exception(data['error'] ?? 'Failed to load children data');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load children data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET - Ambil detail data anak berdasarkan ID
  Future<Child> getChildById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/children/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return Child.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to load child data');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Child data not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to load child data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST - Tambah data anak baru
  Future<Child> createChild(Child child) async {
    try {
      final jsonData = child.toJson();
      print('=== DEBUG CREATE CHILD ===');
      print('JSON yang dikirim: ${json.encode(jsonData)}');
      print('Headers: ${await _getHeaders()}');
      final response = await http.post(
        Uri.parse('$baseUrl/children'),
        headers: await _getHeaders(),
        body: json.encode(child.toJson()),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return Child.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to create child data');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Invalid data provided');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create child data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT - Update data anak
  Future<Child> updateChild(String id, Child child) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/children/$id'),
        headers: await _getHeaders(),
        body: json.encode(child.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return Child.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to update child data');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Child data not found');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Invalid data provided');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update child data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE - Hapus data anak
  Future<void> deleteChild(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/children/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] != true) {
          throw Exception(data['error'] ?? 'Failed to delete child data');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Child data not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to delete child data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper method untuk update data spesifik (misalnya hanya berat/tinggi)
  Future<Child> updateChildPartial(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/children/$id'),
        headers: await _getHeaders(),
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return Child.fromJson(data['data']);
        } else {
          throw Exception(data['error'] ?? 'Failed to update child data');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update child data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
