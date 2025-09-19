// Tambahkan model ini ke auth_models.dart

/// Response untuk request forgot password
class ForgotPasswordResponse {
  final bool success;
  final String message;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

/// Response untuk reset password
class ResetPasswordResponse {
  final bool success;
  final String message;

  ResetPasswordResponse({
    required this.success,
    required this.message,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

/// Response untuk verifikasi token reset
class VerifyTokenResponse {
  final bool success;
  final String message;
  final bool valid;

  VerifyTokenResponse({
    required this.success,
    required this.message,
    required this.valid,
  });

  factory VerifyTokenResponse.fromJson(Map<String, dynamic> json) {
    return VerifyTokenResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      valid: json['valid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'valid': valid,
    };
  }
}