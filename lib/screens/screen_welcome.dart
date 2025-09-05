import 'package:flutter/material.dart';
import 'package:si_cegah/screens/screen_sign_in.dart';
import 'package:si_cegah/screens/screen_sign_up.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo "Si-Cegah Hebat"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Si - Cegah ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(width: 2),
                  Image.asset(
                    "assets/images/baby1.png",
                    width: 50,
                    height: 50,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Hebat",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // GAMBAR ILUSTRASI
              Image.asset(
                "assets/images/welcome_pict1.png",
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 32),

              // JUDUL UTAMA
              Text(
                "Cegah Stunting Sejak Dini",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // SUBJUDUL
              Text(
                "Edukasi gizi & pengasuhan untuk orang tua dan kader posyandu.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // MASUK BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // MENGARAHKAN PENGGUNA KE HALAMAN SIGN IN
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    "Masuk",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: Text(
                  "Belum punya akun? Daftar",                                   
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.blue.shade700,
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
