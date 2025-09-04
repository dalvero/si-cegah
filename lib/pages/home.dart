import 'package:flutter/material.dart';
import 'package:si_cegah/widget/video_card.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView( // Agar bisa discroll
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === JUDUL ATAS ===
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
          SizedBox(height: 50),

          // === GREETING ===
          Text(
            'Selamat datang, Pengguna!',
            style: TextStyle(
              fontSize: 25.0,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Semoga harimu menyenangkan!',
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),

          // === BANNER ===
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEFEF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Banner",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "APR 30 • PAUSE PRACTICE",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ====== Video Cards ======
          const VideoCard(
            title: "Judul Satu",
            category: "Pola Makan",
            duration: "5-10 Menit",
            thumbnail: "assets/images/thumb1_1.jpg",
            rating: 5.0,
          ),
          const VideoCard(
            title: "Judul Dua",
            category: "Pola Tidur",
            duration: "5-10 Menit",
            thumbnail: "assets/images/thumb1_1.jpg",
            rating: 4.5,
          ),
          const VideoCard(
            title: "Judul Dua",
            category: "Pola Tidur",
            duration: "5-10 Menit",
            thumbnail: "assets/images/bg1.jpg",
            rating: 4.5,
          ),
        ],
      ),
    ),
  );
}

}
