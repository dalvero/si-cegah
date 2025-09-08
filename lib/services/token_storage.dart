// lib/services/token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'dart:convert';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Simpan token dan user data
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<void> saveAuth(String token, User user) async {
    await saveToken(token);
    await saveUser(user);
  }

  // Ambil token dan user data
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        return User.fromJson(userData);
      } catch (e) {
        // Jika error parsing, hapus data yang corrupt
        await clearUser();
        return null;
      }
    }
    return null;
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Hapus semua data auth
  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
