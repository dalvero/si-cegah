import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:si_cegah/services/auth_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _userName = "Memuat...";  
  String _peran = "Memuat...";
  String _email = "Memuat...";

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _fetchUserProfile();
  }  

  Future<void> _fetchUserProfile() async {
    if (_user != null) {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userName = doc.data()?['name'] ?? 'Tidak Ditemukan';    
          _email = doc.data()?['email'] ?? 'Tidak Ditemukan';
          _peran = doc.data()?['peran'] ?? 'Tidak Ditemukan';      
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.black87,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),

            // Form Data
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Profil",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nama
                  TextField(
                    controller: TextEditingController(text: _userName),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Nama",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextField(
                    controller: TextEditingController(text: _email),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Peran (sementara statis)
                  TextField(
                    controller: TextEditingController(text: _peran),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Peran",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        await _authService.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed("/login");
                        }
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
