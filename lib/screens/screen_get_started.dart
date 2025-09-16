import 'package:flutter/material.dart';
import 'package:si_cegah/main.dart';

class GetStartedScreen extends StatelessWidget {
  final String? userName;
  const GetStartedScreen({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF81D4FA), // Biru langit cerah
              Color(0xFFFFF9C4), // Kuning pucat, adem
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // ← TAMBAHKAN INI
            child: Column(
              children: [
                const SizedBox(height: 35),

                // === JUDUL ATAS ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Si - Cegah ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 2),
                    Image.asset(
                      "assets/images/baby1.png",
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Hebat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70),

                Text(
                  "Selamat Datang!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "di Si-Cegah Hebat",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Cegah stunting untuk generasi emas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

                // ILUSTRASI
                Image.asset("assets/images/starter.png", height: 400),
                const SizedBox(height: 50),
                // TOMBOL YUK MULAI
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                    },
                    child: const Text(
                      "YUK MULAI!!",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ), // ← TUTUP SingleChildScrollView
        ),
      ),
    );
  }
}
