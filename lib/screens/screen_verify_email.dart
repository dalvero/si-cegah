import 'dart:async';
import 'package:flutter/material.dart';
import 'package:si_cegah/screens/screen_get_started.dart';
import 'package:si_cegah/services/auth_service.dart';


class VerifyEmailScreen extends StatefulWidget {
  final String userName;
  const VerifyEmailScreen({super.key, required this.userName});


  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  
  final AuthService _authService = AuthService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Kirim email verifikasi saat halaman dimuat
    _authService.currentUser?.sendEmailVerification();
    
    // Periksa status verifikasi setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      checkEmailVerified();
    });
  }

  Future<void> checkEmailVerified() async {
    // PERBARUI STATUS PENGGUNA
    await _authService.currentUser?.reload();
    final user = _authService.currentUser;
    if (user != null && user.emailVerified) {
      _timer?.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email berhasil diverifikasi!')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GetStartedScreen(userName: widget.userName),
          ),
        );      
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _authService.currentUser?.email ?? 'alamat email Anda';
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Verifikasi Email Anda",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Kami telah mengirim tautan verifikasi ke $userEmail. Silakan periksa email Anda dan klik tautan tersebut untuk melanjutkan.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                _authService.currentUser?.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tautan verifikasi telah dikirim ulang!')),
                );
              },
              child: const Text("Kirim ulang email verifikasi"),
            ),
          ],
        ),
      ),
    );
  }
}
