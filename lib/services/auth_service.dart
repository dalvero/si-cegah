// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import 'token_storage.dart';

class AuthService {
  static const String baseUrl = 'https://sicegah.netlify.app/api/auth';

  // Current user dari storage
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Constructor - load user saat init
  AuthService() {
    _loadCurrentUser();
  }

  // Load current user dari storage
  Future<void> _loadCurrentUser() async {
    _currentUser = await TokenStorage.getUser();
  }

  // =======================
  // REGISTER
  // =======================
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return RegisterResponse.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthError.fromJson(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(error: 'Network error: ${e.toString()}', statusCode: 0);
    }
  }

  // =======================
  // LOGIN
  // =======================
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        // Simpan user data ke storage dan memory
        _currentUser = loginResponse.user;
        await TokenStorage.saveUser(loginResponse.user);

        // Token disimpan otomatis via cookie dari backend
        // Tapi kita juga bisa extract dari cookie header jika diperlukan
        await _extractAndSaveToken(response);

        return loginResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthError.fromJson(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(error: 'Network error: ${e.toString()}', statusCode: 0);
    }
  }

  // Extract token dari cookie header (opsional, karena backend pakai HTTP-only cookie)
  Future<void> _extractAndSaveToken(http.Response response) async {
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      final tokenMatch = RegExp(r'auth-token=([^;]+)').firstMatch(cookies);
      if (tokenMatch != null) {
        final token = tokenMatch.group(1);
        if (token != null) {
          await TokenStorage.saveToken(token);
        }
      }
    }
  }

  // =======================
  // LOGOUT
  // =======================
  Future<void> logout() async {
    try {
      // Panggil API logout jika ada
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );
    } catch (e) {
      // Tetap lanjut logout meski API error
      print('Logout API error: $e');
    } finally {
      // Clear local data
      _currentUser = null;
      await TokenStorage.clearAuth();
    }
  }

  // =======================
  // UTILITY FUNCTIONS
  // =======================

  // Cek apakah user sudah login
  Future<bool> isLoggedIn() async {
    final hasToken = await TokenStorage.isLoggedIn();
    final hasUser = await TokenStorage.getUser() != null;
    return hasToken && hasUser;
  }

  // Get headers dengan token untuk request yang butuh auth
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Refresh current user data
  Future<void> refreshCurrentUser() async {
    await _loadCurrentUser();
  }

  // Get user role
  String? getUserRole() {
    return _currentUser?.role;
  }

  // Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  // Check if user is admin
  bool isAdmin() {
    return hasRole('admin');
  }

  // Check if user is regular user
  bool isUser() {
    return hasRole('user');
  }
}
