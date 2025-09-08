import 'package:flutter/material.dart';
import 'package:si_cegah/services/auth_service.dart';
import 'package:si_cegah/models/auth_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String? _photoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    _user = _authService.currentUser;
    if (_user != null && mounted) {
      setState(() {
        _userName = _user!.name;
        _email = _user!.email;
        _peran = _getRoleDisplayName(_user!.role);
      });
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
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
      default:
        return 'Pengguna';
    }
  }

  Future<String?> _uploadToCloudinary(String filePath) async {
    const cloudName = "drjk68jes";
    const uploadPreset = "sicegah_uploads";

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    try {
      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final data = json.decode(resStr);
        return data['secure_url'];
      } else {
        debugPrint("Upload gagal: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Error upload: $e");
      return null;
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mengupload foto...')));
      }

      final imageUrl = await _uploadToCloudinary(pickedFile.path);
      if (imageUrl != null) {
        setState(() {
          _photoUrl = imageUrl;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto berhasil diupload!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengupload foto')),
          );
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    // Confirm logout dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Konfirmasi Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          content: const Text(
            "Apakah Anda yakin ingin keluar dari aplikasi?",
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Batal",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.red,
                ),
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
          // Clear all routes and go to login
          Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
        }
      } catch (e) {
        debugPrint("Logout error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: ${e.toString()}'),
              backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER WITH PROFILE PICTURE
            Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF42A5F5),
                    Color.fromARGB(255, 21, 226, 106),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back button
                  Positioned(
                    top: 50,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Profile picture
                  Positioned(
                    bottom: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _photoUrl != null
                                ? NetworkImage(_photoUrl!)
                                : null,
                            child: _photoUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[600],
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // PROFILE INFO SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Profil",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Info Cards
                  _buildInfoCard("Nama Lengkap", _userName, Icons.person),
                  const SizedBox(height: 16),
                  _buildInfoCard("Email", _email, Icons.email),
                  const SizedBox(height: 16),
                  _buildInfoCard("Peran", _peran, Icons.work),

                  const SizedBox(height: 40),

                  // LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _isLoading ? null : _handleLogout,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.logout, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Keluar dari Akun",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
