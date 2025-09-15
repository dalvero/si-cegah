// lib/models/auth_models.dart
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class LoginResponse {
  final String message;
  final String? token;
  final User user;

  LoginResponse({required this.message, this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

class RegisterResponse {
  final String message;
  final User user;

  RegisterResponse({required this.message, required this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}

class AuthError {
  final String error;
  final int statusCode;

  AuthError({required this.error, required this.statusCode});

  factory AuthError.fromJson(Map<String, dynamic> json, int statusCode) {
    return AuthError(
      error: json['error'] ?? 'Unknown error',
      statusCode: statusCode,
    );
  }
}
