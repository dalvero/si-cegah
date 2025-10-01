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
              // NUANSA WARNA
              Color(0xFF81D4FA), // Biru langit cerah
              Color(0xFFFFF9C4), // Kuning pucat, adem
            ],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 35),

                // === JUDUL ATAS ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Si - Cegah Hebat",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3.0,
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
                    color: Colors.black,
                  ),
                ),
                Text(
                  "di Si-Cegah Hebat",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Edukasi gizi & pengasuhan untuk orang tua dan kader posyandu.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                    },
                    child: const Text(
                      "Yuk Mulai Belajar!!",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 20,
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
