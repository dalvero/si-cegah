// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import 'token_storage.dart';

class AuthService {
  static const String baseUrl = 'https://sicegah.vercel.app/api/auth';

  // MENGAMBIL USER SAAT INI DARI STORAGE
  User? _currentUser;
  User? get currentUser => _currentUser;

  // KONSTRUKTOR CLASS UNTUK LOAD USER SAAT INIT
  AuthService() {
    _loadCurrentUser();
  }

  // LOAD USER SAAT INI DARI STORAGE
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await TokenStorage.getUser();
    } catch (e) {
      print('Error loading current user: $e');
      _currentUser = null;
    }
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

  Future<Map<String, dynamic>> sendResetCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim()}),
      );

      print('Send reset code status: ${response.statusCode}');
      print('Send reset code body: ${response.body}'); // DEBUG

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'email': data['data']['email'],
          'expiresIn': data['data']['expiresIn'],
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to send reset code');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Method 2: Verify reset code
  Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String resetCode,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'resetCode': resetCode.trim(),
        }),
      );

      print('Verify reset code status: ${response.statusCode}');
      print('Verify reset code body: ${response.body}'); // DEBUG

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'tempToken': data['data']['tempToken'],
          'email': data['data']['email'],
          'expiresIn': data['data']['expiresIn'],
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to verify reset code');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Method 3: Reset password dengan password baru
  Future<Map<String, dynamic>> resetPasswordWithCode({
    required String email,
    required String tempToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'tempToken': tempToken,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      print('Reset password final status: ${response.statusCode}');
      print('Reset password final body: ${response.body}'); // DEBUG

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'email': data['data']['email'],
          'name': data['data']['name'],
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to reset password');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // DEBUG

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        // MENYIMPAN USER DATA
        _currentUser = loginResponse.user;
        await TokenStorage.saveUser(loginResponse.user);

        // PERBAIKAN: MENGAMBIL TOKEN LANGSUNG DARI RESPONSE
        if (data['token'] != null) {
          await TokenStorage.saveToken(data['token']);
          print(
            'Token berhasil disimpan: ${data['token'].toString().substring(0, 20)}...',
          ); // DEBUG
        } else {
          print('Token tidak ditemukan di response!'); // DEBUG
        }

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

  // =======================
  // UPDATE PROFILE
  // =======================
  Future<void> updateProfile({
    required String name,
    String? phone,
    String? role,
    String? province,
    String? city,
    String? address,
  }) async {
    try {
      final body = <String, dynamic>{'name': name};

      // MENAMAHKAN FIELD OPSIONAL JIKA ADA
      if (phone != null) body['phone'] = phone;
      if (role != null) body['role'] = role;
      if (province != null) body['province'] = province;
      if (city != null) body['city'] = city;
      if (address != null) body['address'] = address;

      final response = await http.put(
        Uri.parse('https://sicegah.vercel.app/api/users/profile'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // MENGUPDATE USER SAAT INI
          _currentUser = User.fromJson(data['data']);
          await TokenStorage.saveUser(_currentUser!);

          // PERBAIKAN: PAKSA REFRESH DARI SERVER SETELAH UPDATE
          await Future.delayed(const Duration(milliseconds: 300));
          await forceRefreshFromServer();
        } else {
          throw Exception(data['error'] ?? 'Failed to update profile');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // =======================
  // FORGOT PASSWORD
  // =======================
  // REQUEST PASSWORD RESET - KIRIM EMAIL DENGAN LINK RESET
  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('Reset password response status: ${response.statusCode}');
      print('Reset password response body: ${response.body}'); // DEBUG

      if (response.statusCode == 200) {
        // BERHASIL MENGIRIM EMAIL RESET
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal mengirim email reset');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthError.fromJson(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(error: 'Network error: ${e.toString()}', statusCode: 0);
    }
  }

  // RESET PASSWORD DENGAN TOKEN DARI EMAIL
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'password': newPassword}),
      );

      print('Reset password confirm status: ${response.statusCode}');
      print('Reset password confirm body: ${response.body}'); // DEBUG

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Gagal mereset password');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthError.fromJson(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError(error: 'Network error: ${e.toString()}', statusCode: 0);
    }
  }

  /// VEFIGIKASI TOKEN RESET PASSWORD (OPSIONAL - UNTUK CEK VALIDITAS TOKEN)
  Future<bool> verifyResetToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-reset-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true && data['valid'] == true;
      }
      return false;
    } catch (e) {
      print('Error verifying reset token: $e');
      return false;
    }
  }

  // MENGEKSTRAK TOKEN DARI COOKIE HEADER (opsional, karena backend pakai HTTP-only cookie)
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
      // MEMANGGIL API LOGOUT JIKA ADA
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );
    } catch (e) {
      // TETAP LANJUT LOGOUT MESKI API ERROR
      print('Logout API error: $e');
    } finally {
      // CLEAR LOCAL DATA
      _currentUser = null;
      await TokenStorage.clearAuth();
    }
  }

  // =======================
  // UTILITY FUNCTIONS
  // =======================
  // MENGECEK APAKAH USER SUDAH LOGIN
  Future<bool> isLoggedIn() async {
    try {
      final hasToken = await TokenStorage.isLoggedIn();
      final hasUser = await TokenStorage.getUser() != null;
      return hasToken && hasUser;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // MENDAPATKAN HEADERS DENGAN TOKEN UNTUK REQUEST YANG BUTUH AUTH
  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await TokenStorage.getToken();
      return {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('Error getting headers: $e');
      return {'Content-Type': 'application/json'};
    }
  }

  // MENDAPATKAN USER ROLE
  String? getUserRole() {
    return _currentUser?.role;
  }

  Future<String?> getToken() async {
    try {
      return await TokenStorage.getToken();
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // MENGECEK APAKAH USER MEMILIKI ROLE YANG SPESIFIK
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  // MENGECEK APAKAH USER ADMIN?
  bool isAdmin() {
    return hasRole('ADMIN');
  }

  // MENGECEK APAKAH USER ADALAH USER BIASA?
  bool isUser() {
    return hasRole('user');
  }

  // =======================
  // REFRESH USER FROM SERVER
  // =======================
  Future<void> refreshCurrentUser({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        // MEMBERSIHKAN CACHE LOCAL TERLEBIH DAHULU
        _currentUser = null;
      }

      // FETCH DATA TERBARU DARI SERVER
      final response = await http.get(
        Uri.parse('https://sicegah.vercel.app/api/users/profile'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // MENGUPDATE USER SAAT INI DENGAN DATA TERBARU DARI SERVER
          _currentUser = User.fromJson(data['data']);
          await TokenStorage.saveUser(_currentUser!);
        } else {
          // FALLBACK KE DATA DARI STORAGE JIKA API GAGAL
          await _loadCurrentUser();
        }
      } else {
        // FALLBACK KE DATA DARI STORAGE JIKA API GAGAL
        await _loadCurrentUser();
      }
    } catch (e) {
      print('Error refreshing user: $e');
      // FALLBACK KE DATA DARI STORAGE JIKA ERROR
      await _loadCurrentUser();
    }
  }

  // =======================
  // CLEAR CACHE
  // =======================
  Future<void> clearUserCache() async {
    _currentUser = null;
  }

  // =======================
  // FORCE REFRESH DATA
  // =======================
  Future<void> forceRefreshFromServer() async {
    try {
      final response = await http.get(
        Uri.parse('https://sicegah.vercel.app/api/users/profile'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _currentUser = User.fromJson(data['data']);
          await TokenStorage.saveUser(_currentUser!);
        }
      }
    } catch (e) {
      print('Error force refreshing user: $e');
      // TIDAK THROW ERROR AGAR TIDAK CRASH APP
    }
  }
}
