// ignore_for_file: unused_import, unused_local_variable

import 'package:flutter/material.dart';
import 'package:si_cegah/services/auth_service.dart';
import 'package:si_cegah/models/auth_models.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _roleController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool isPasswordVisible = false;
  bool agree = false;

  // SUCCES POP UP
  Future<void> _showSuccessDialog(String message) async {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Success",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 60,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Pendaftaran Berhasil!",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup pop-up
                          Navigator.of(context).pop(); // Kembali ke login
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ERROR POP UP
  Future<void> _showErrorDialog(String title, String message) async {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Error",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 60,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // VALIDASI FORM
  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog("Error", "Nama tidak boleh kosong.");
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog("Error", "Email tidak boleh kosong.");
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorDialog("Error", "Password tidak boleh kosong.");
      return false;
    }

    if (_passwordController.text.length < 6) {
      _showErrorDialog("Error", "Password minimal 6 karakter.");
      return false;
    }

    if (_roleController == null) {
      _showErrorDialog("Error", "Silakan pilih peran Anda.");
      return false;
    }

    if (!agree) {
      _showErrorDialog("Error", "Anda harus menyetujui kebijakan privasi.");
      return false;
    }

    return true;
  }

  Future<void> _signUp() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final registerResponse = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        role: _roleController ?? "BIDAN",
      );

      if (mounted) {
        _showSuccessDialog(
          "Akun Anda berhasil dibuat. Silakan login untuk melanjutkan.",
        );
      }
    } on AuthError catch (e) {
      String message;
      switch (e.statusCode) {
        case 409:
          message = 'Email sudah terdaftar. Silakan gunakan email lain.';
          break;
        case 400:
          message = 'Data tidak valid. Periksa kembali input Anda.';
          break;
        case 422:
          message = 'Format data tidak sesuai. Periksa email dan password.';
          break;
        case 500:
          message = 'Server sedang bermasalah. Silakan coba lagi nanti.';
          break;
        default:
          message = e.error.isNotEmpty
              ? e.error
              : 'Terjadi kesalahan pada server.';
      }
      _showErrorDialog("Gagal Mendaftar", message);
    } catch (e) {
      _showErrorDialog(
        "Kesalahan Jaringan",
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TOMBOL KEMBALI
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // JUDUL
              Text(
                "Buat Akun Baru",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 64),

              // GARIS ATAU DENGAN EMAIL
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.black26)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "DAFTAR DENGAN EMAIL",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.black26)),
                ],
              ),

              const SizedBox(height: 20),

              // TEXTFIELD NAMA
              TextField(
                controller: _nameController,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Nama Lengkap",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // === DROPDOWN PERAN (Untuk UI saja, backend menggunakan default "user") ===
              DropdownButtonFormField<String>(
                value: _roleController,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                decoration: InputDecoration(
                  hintText: "Pilih Peran (Opsional untuk Profile)",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "IBU", child: Text("Ibu")),
                  DropdownMenuItem(value: "AYAH", child: Text("Ayah")),
                  DropdownMenuItem(
                    value: "TENAGA_KESEHATAN",
                    child: Text("Tenaga Kesehatan"),
                  ),
                  DropdownMenuItem(value: "KADER", child: Text("Kader")),
                  DropdownMenuItem(value: "BIDAN", child: Text("Bidan")),
                ],
                onChanged: (value) {
                  setState(() {
                    _roleController = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Peran wajib dipilih" : null,
              ),

              const SizedBox(height: 16),

              // TEXTFIELD EMAIL
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Email Address",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // TEXTFIELD PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: !isPasswordVisible,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: "Password (Min. 6 karakter)",
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // CHECKBOX
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: agree,
                    activeColor: Colors.blue,
                    onChanged: (val) {
                      setState(() {
                        agree = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        children: [
                          TextSpan(text: "Saya telah membaca dan menyetujui "),
                          TextSpan(
                            text: "Kebijakan Privasi",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // TOMBOL DAFTAR
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: agree
                              ? Colors.lightBlueAccent
                              : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: agree ? _signUp : null,
                        child: Text(
                          "Daftar Sekarang",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              // DEBUG INFO (hapus di production)
              if (_isLoading)
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Menghubungi server: ${AuthService().toString().split('@')[0]}...",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
