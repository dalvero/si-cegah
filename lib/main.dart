import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:si_cegah/pages/home.dart';
import 'package:si_cegah/pages/pengaturan.dart';
import 'package:si_cegah/pages/profil.dart';
import 'package:si_cegah/screens/screen_welcome.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 1;

  final List<Widget> _pages = const [
    Pengaturan(),
    Home(),
    Profil(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// ambil warna dari background gradient sesuai waktu (bagian bawah)
  Color getBottomNavColor() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return const Color(0xFFFFB07C); // pagi → oranye pastel
    } else if (hour >= 11 && hour < 15) {
      return const Color(0xFF2575FC); // siang → biru
    } else if (hour >= 15 && hour < 18) {
      return const Color(0xFFFAD0C4); // sore → peach
    } else {
      return const Color(0xFF2575FC); // malam → biru
    }
  }

  /// widget untuk icon animasi
  Widget _buildAnimatedIcon(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return AnimatedScale(
      scale: isSelected ? 1.3 : 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      child: Icon(
        icon,
        size: 28,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return Scaffold(
              extendBody: true,
              // IndexedStack menjaga halaman tetap di memori → no flicker
              body: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
              bottomNavigationBar: CurvedNavigationBar(
                index: _selectedIndex,
                height: 60,
                backgroundColor: Colors.transparent,
                color: getBottomNavColor(),
                animationCurve: Curves.easeInOutCubic,
                animationDuration: const Duration(milliseconds: 600),
                items: [
                  _buildAnimatedIcon(Icons.settings, 0),
                  _buildAnimatedIcon(Icons.home, 1),
                  _buildAnimatedIcon(Icons.person, 2),
                ],
                onTap: _onItemTapped,
              ),
            );
          }
          return const WelcomeScreen();
        },
      ),
    );
  }
}
