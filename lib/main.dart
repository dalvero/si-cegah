// Perbarui main.dart dengan route lupa password
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:si_cegah/screens/screen_forget_password.dart';
import 'package:si_cegah/screens/screen_loading.dart';
import 'package:si_cegah/screens/screen_reset_password.dart';
import 'firebase_options.dart';
import 'package:si_cegah/screens/screen_welcome.dart';
import 'package:si_cegah/pages/home.dart';
import 'package:si_cegah/pages/profil.dart';
import 'package:si_cegah/pages/pengaturan.dart';
import 'package:si_cegah/pages/admin/dashboard.dart';
import 'package:si_cegah/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tetap init Firebase untuk Firestore (data video)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      // Tambahkan routes untuk halaman lupa password
      routes: {
        '/forgot-password': (context) => const ForgetPasswordScreen(),
        '/reset-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is String) {
            return ResetPasswordScreen(token: args);
          }
          // Fallback jika tidak ada token
          return const ForgetPasswordScreen();
        },
      },
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
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _role;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Refresh current user data dengan force refresh
        await _authService.refreshCurrentUser(forceRefresh: true);
        final user = _authService.currentUser;

        setState(() {
          _isLoggedIn = true;
          _role = user?.role ?? 'user';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _role = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking auth status: $e');
      setState(() {
        _isLoggedIn = false;
        _role = null;
        _isLoading = false;
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

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: Container(
        height: 70, // Set fixed height untuk navigation item
        alignment: Alignment.center, // Ini yang bikin center tanpa expand
        child: GestureDetector(
          onTap: () => _onItemTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8E97FD) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking auth status
    if (_isLoading) {
      return const LoadingScreen();
    }

    // Show welcome screen if not logged in
    if (!_isLoggedIn) {
      return const WelcomeScreen();
    }

    // Build main app interface for logged in users
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

    final navItems = [
      {'icon': Icons.settings_outlined, 'label': 'Pengaturan'},
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
      if (_role == 'admin')
        {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
    ];

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildNavItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                index: index,
                isSelected: _selectedIndex == index,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}