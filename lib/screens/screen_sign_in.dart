import 'package:flutter/material.dart';
import 'package:si_cegah/main.dart';
import 'package:si_cegah/screens/screen_get_started.dart';
import 'package:si_cegah/screens/screen_sign_up.dart';
import 'package:si_cegah/services/auth_service.dart';
import 'package:si_cegah/models/auth_models.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool isPasswordVisible = false;

  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loginResponse = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        // Navigasi ke halaman home setelah berhasil login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GetStartedScreen()),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang, ${loginResponse.user.name}!'),
          ),
        );
      }
    } on AuthError catch (e) {
      if (mounted) {
        String message;
        switch (e.statusCode) {
          case 401:
            message = 'Email atau password salah.';
            break;
          case 404:
            message = 'Pengguna tidak ditemukan.';
            break;
          default:
            message = e.error;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              // TOMBOL BACK
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
              const Text(
                "Selamat Datang!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 84),
              // GARIS ATAU LOGIN DENGAN EMAIL
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.black26)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "LOGIN DENGAN EMAIL",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.black26)),
                ],
              ),
              const SizedBox(height: 20),
              // TEXTFIELD EMAIL
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email address",
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
                decoration: InputDecoration(
                  hintText: "Password",
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
              // TOMBOL MASUK
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _signInWithEmail,
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 20,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              // FORGOT PASSWORD
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Belum punya akun? Daftar",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
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
