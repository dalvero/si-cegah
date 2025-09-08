import 'package:flutter/material.dart';
import 'package:si_cegah/pages/admin/manage_video.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF42A5F5), // biru soft
                    Color(0xFF15E26A), // hijau fresh
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.only(top: 60, left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Menu Admin",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(2, 2),
                          blurRadius: 6,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ===== MENU BUTTONS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // BUTTON KELOLA VIDEO
                  _buildMenuButton(
                    color: Colors.blueAccent,
                    icon: Icons.video_library,
                    label: "Kelola Video",
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ManageVideoPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // BUTTON KELOLA SOAL
                  _buildMenuButton(
                    color: Colors.deepOrangeAccent,
                    icon: Icons.edit_document,
                    label: "Kelola Soal",
                    onPressed: () {
                      // TODO: Navigasi ke halaman kelola soal
                    },
                  ),
                  const SizedBox(height: 20),

                  // BUTTON ANALISIS JAWABAN
                  _buildMenuButton(
                    color: Colors.deepPurpleAccent,
                    icon: Icons.analytics,
                    label: "Analisis Jawaban",
                    onPressed: () {
                      // TODO: Navigasi ke halaman analisis
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== WIDGET REUSABLE UNTUK BUTTON =====
  Widget _buildMenuButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
          shadowColor: color.withOpacity(0.5),
        ),
        icon: Icon(icon, color: Colors.white, size: 22),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
