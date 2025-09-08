import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:si_cegah/screens/screen_loading.dart';
import 'firebase_options.dart';
import 'package:si_cegah/screens/screen_welcome.dart';
import 'package:si_cegah/pages/home.dart';
import 'package:si_cegah/pages/profil.dart';
import 'package:si_cegah/pages/pengaturan.dart';
import 'package:si_cegah/pages/admin/dashboard.dart'; 
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
  String? _role; 

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _role = snapshot.data()?['role'] ?? 'user';
      });
    }
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1)); // LOADING SCREEN

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
        color: isSelected
            ? const Color.fromARGB(255, 21, 226, 106)
            : Colors.white,
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
          if (_role == null) {            
            return const LoadingScreen();
          }

          
          final userPages = const [
            Pengaturan(key: ValueKey('PengaturanPage')),
            Home(key: ValueKey('HomePage')),
            Profile(key: ValueKey('ProfilPage')),
          ];
          
          final adminPages = const [
            Pengaturan(key: ValueKey('PengaturanPage')),
            Home(key: ValueKey('HomePage')),
            Profile(key: ValueKey('ProfilPage')),
            Dashboard(key: ValueKey('DashboardPage')), 
          ];

          final pages = _role == 'admin' ? adminPages : userPages;

          return _isLoading
              ? const LoadingScreen()
              : Scaffold(
                  extendBody: true,
                  body: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: pages[_selectedIndex],
                  ),
                  bottomNavigationBar: CurvedNavigationBar(
                    index: _selectedIndex,
                    height: 70,
                    backgroundColor: Colors.transparent,
                    color: Colors.black,
                    animationCurve: Curves.easeInOutCubic,
                    animationDuration: const Duration(milliseconds: 600),
                    items: [
                      _buildAnimatedIcon(Icons.settings, 0),
                      _buildAnimatedIcon(Icons.home, 1),
                      _buildAnimatedIcon(Icons.person, 2),
                      if (_role == 'admin')
                        _buildAnimatedIcon(Icons.dashboard, 3), 
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
