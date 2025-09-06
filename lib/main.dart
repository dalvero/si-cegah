import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:si_cegah/screens/screen_loading.dart';
import 'firebase_options.dart';
import 'package:si_cegah/screens/screen_welcome.dart';
import 'package:si_cegah/pages/home.dart';
import 'package:si_cegah/pages/profil.dart';
import 'package:si_cegah/pages/pengaturan.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const AppSwitcher(),
    );
  }
}

class AppSwitcher extends StatefulWidget {
  const AppSwitcher({super.key});

  @override
  State<AppSwitcher> createState() => _AppSwitcherState();
}

class _AppSwitcherState extends State<AppSwitcher> {
  int _selectedIndex = 1;
  bool _isLoading = false;

  final List<Widget> _pages = const [
    Pengaturan(key: ValueKey('PengaturanPage')),
    Home(key: ValueKey('HomePage')),
    Profile(key: ValueKey('ProfilPage')),
  ];

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2)); // LOADING SCREEN

    setState(() {
      _selectedIndex = index;
      _isLoading = false;
    });
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return AnimatedScale(
      scale: isSelected ? 1.3 : 1.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? Colors.blue : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        if (snapshot.hasData) {
          return _isLoading
              ? const LoadingScreen()
              : Scaffold(
                  extendBody: true,
                  appBar: _selectedIndex == 1
                      ? null
                      : AppBar(
                          title: Text(
                            _selectedIndex == 0
                                ? "Pengaturan"
                                : "Profil Saya",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              fontSize: 20,
                            ),
                          ),
                          centerTitle: true,
                          backgroundColor: Colors.white,
                          elevation: 0,
                          flexibleSpace: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                  body: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: _pages[_selectedIndex],
                  ),
                  bottomNavigationBar: CurvedNavigationBar(
                    index: _selectedIndex,
                    height: 60,
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
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
    );
  }
}
