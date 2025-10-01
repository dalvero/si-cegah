// ignore_for_file: unused_field, deprecated_member_use, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:si_cegah/services/auth_service.dart';
import 'package:si_cegah/services/user_service.dart';
import 'package:si_cegah/models/auth_models.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();
  User? _user;

  String _userName = "Memuat...";
  String _peran = "user";
  String _email = "Memuat...";
  String _phone = "-";
  String _province = "-";
  String _city = "-";
  String _address = "-";
  bool _isLoading = false;
  bool _isProfileLoading = true;

  // Achievement data
  Map<String, dynamic>? _achievements;
  bool _isAchievementsLoading = true;
  int _completedVideos = 0;
  int _totalStars = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchUserAchievements();
  }

  Future<void> _fetchUserAchievements() async {
    if (_authService.currentUser == null) return;

    setState(() {
      _isAchievementsLoading = true;
    });

    try {
      final achievements = await UserService.getUserAchievements(
        _authService.currentUser!.id,
      );
      if (mounted && achievements != null) {
        setState(() {
          _achievements = achievements;
          _completedVideos = achievements['completedVideos'] ?? 0;
          _totalStars = achievements['totalStars'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error fetching achievements: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAchievementsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isProfileLoading = true;
    });

    try {
      await _authService.refreshCurrentUser();
      _user = _authService.currentUser;

      if (_user != null && mounted) {
        setState(() {
          _userName = _user!.name;
          _email = _user!.email;
          _phone = _user!.phone ?? "-";
          _province = _user!.province ?? "-";
          _city = _user!.city ?? "-";
          _address = _user!.address ?? "-";
          _peran = _getRoleDisplayName(_user!.role);
        });
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat profil: ${e.toString()}'),
            backgroundColor: const Color(0xFFE53E3E),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProfileLoading = false;
        });
      }
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toUpperCase()) {
      case 'IBU':
        return 'Ibu';
      case 'AYAH':
        return 'Ayah';
      case 'BIDAN':
        return 'Bidan';
      case 'TENAGA_KESEHATAN':
        return 'Tenaga Kesehatan';
      case 'KADER':
        return 'Kader';
      case 'PENGASUH':
        return 'Pengasuh';
      case 'ADMIN':
        return 'Admin';
      default:
        return 'Pengguna';
    }
  }

  // Achievement badge logic dengan warna yang lebih soft
  Map<String, dynamic> _getCurrentBadge() {
    if (_completedVideos >= 5) {
      return {
        'title': 'Expert',
        'subtitle': 'Semua Video Selesai',
        'icon': Icons.military_tech,
        'color': const Color(0xFF2D3748),
        'bgColor': const Color(0xFFF7FAFC),
        'accentColor': const Color(0xFF4299E1),
      };
    } else if (_completedVideos >= 3) {
      return {
        'title': 'Advanced',
        'subtitle': '$_completedVideos dari 5 Video',
        'icon': Icons.school,
        'color': const Color(0xFF2D3748),
        'bgColor': const Color(0xFFF7FAFC),
        'accentColor': const Color(0xFF48BB78),
      };
    } else if (_completedVideos >= 1) {
      return {
        'title': 'Explorer',
        'subtitle': '$_completedVideos dari 5 Video',
        'icon': Icons.explore,
        'color': const Color(0xFF2D3748),
        'bgColor': const Color(0xFFF7FAFC),
        'accentColor': const Color(0xFFED8936),
      };
    } else {
      return {
        'title': 'Starter',
        'subtitle': 'Mulai Belajar',
        'icon': Icons.rocket_launch,
        'color': const Color(0xFF2D3748),
        'bgColor': const Color(0xFFF7FAFC),
        'accentColor': const Color(0xFF718096),
      };
    }
  }

  double _getProgressPercentage() {
    return (_completedVideos / 5).clamp(0.0, 1.0);
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFE53E3E), size: 20),
              SizedBox(width: 8),
              Text(
                "Konfirmasi Logout",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin keluar dari aplikasi?",
            style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Batal",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF718096),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.logout();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
        }
      } catch (e) {
        debugPrint("Logout error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Gagal logout: ${e.toString()}')),
                ],
              ),
              backgroundColor: const Color(0xFFE53E3E),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleRefresh() async {
    await Future.wait([_fetchUserProfile(), _fetchUserAchievements()]);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: RefreshIndicator(
        color: const Color(0xFF4299E1),
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),

              // Achievement Badge - compact design
              if (!_isAchievementsLoading) _buildCompactAchievementBadge(),

              const SizedBox(height: 24),

              if (_isProfileLoading)
                _buildLoadingSection()
              else
                _buildProfileInfo(),

              const SizedBox(height: 24),
              _buildLogoutButton(),
              SizedBox(height: bottomPadding + 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAchievementBadge() {
    final badge = _getCurrentBadge();
    final progress = _getProgressPercentage();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: badge['bgColor'],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: badge['accentColor'].withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: badge['accentColor'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(badge['icon'], color: badge['accentColor'], size: 24),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: badge['color'],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    badge['subtitle'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            Container(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: badge['accentColor'].withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        badge['accentColor'],
                      ),
                    ),
                  ),
                  Text(
                    '$_completedVideos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: badge['color'],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Stars
            Row(
              children: [
                Icon(Icons.star, color: badge['accentColor'], size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_totalStars',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: badge['color'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final initial = _userName.isNotEmpty && _userName != "Memuat..."
        ? _userName[0].toUpperCase()
        : '?';

    return Container(
      height: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [          
          // Profile info
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4299E1),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _peran,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi Profil",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLoadingCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 10,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi Profil",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            "Nama Lengkap",
            _userName,
            Icons.person_outline,
            const Color(0xFF4299E1),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            "Email",
            _email,
            Icons.email_outlined,
            const Color(0xFF48BB78),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            "Telepon",
            _phone,
            Icons.phone_outlined,
            const Color(0xFFED8936),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            "Peran",
            _peran,
            Icons.badge_outlined,
            const Color(0xFF9F7AEA),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            "Provinsi",
            _province,
            Icons.location_city_outlined,
            const Color(0xFF38B2AC),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            "Kota",
            _city,
            Icons.location_on_outlined,
            const Color(0xFF3182CE),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            "Alamat",
            _address,
            Icons.home_outlined,
            const Color(0xFF718096),
            isAddress: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53E3E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: _isLoading ? null : _handleLogout,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Keluar dari Akun",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color iconColor, {
    bool isAddress = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: isAddress
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: isAddress ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
