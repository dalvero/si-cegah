// home.dart (modifikasi untuk API)
// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:si_cegah/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:si_cegah/services/auth_service.dart';
import 'package:si_cegah/widget/banner.dart';
import 'package:si_cegah/widget/video_card.dart';
import 'package:si_cegah/model/video_item.dart';
import 'package:si_cegah/services/video_service.dart';
import 'package:si_cegah/screens/screen_video_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final VideoService _videoService = VideoService();

  // MENDAPATKAN USER NAME
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _userName = "Memuat...";

  // State untuk videos
  List<VideoItem> _videos = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _fetchUserProfile();
    _loadVideos(); // Load videos once
  }

  Future<void> _fetchUserProfile() async {
    if (_user != null) {
      setState(() {
        _userName = _user!.name;
      });
    } else {
      setState(() {
        _userName = "Pengguna";
      });
    }
  }

  // Load videos from API
  Future<void> _loadVideos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final videos = await _videoService.getVideos();
      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Refresh videos
  Future<void> _refreshVideos() async {
    await _loadVideos();
  }

  // === GREETING BERDASARKAN WAKTU ===
  Map<String, dynamic> getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      return {
        "text": "Selamat Pagi",
        "message": "Semangat ya hari ini!",
        "icon": Icons.wb_sunny,
        "color": Colors.orange,
      };
    } else if (hour >= 11 && hour < 15) {
      return {
        "text": "Selamat Siang",
        "message": "Selamat menjalankan aktivitas!",
        "icon": Icons.wb_sunny_outlined,
        "color": Colors.yellow[700],
      };
    } else if (hour >= 15 && hour < 18) {
      return {
        "text": "Selamat Sore",
        "message": "Jangan lupa beristirahat ya!",
        "icon": Icons.wb_twighlight,
        "color": Colors.deepOrange,
      };
    } else {
      return {
        "text": "Selamat Malam",
        "message": "Terima kasih untuk hari ini!",
        "icon": Icons.nightlight_round,
        "color": Colors.indigo,
      };
    }
  }

  Widget _buildVideoList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Terjadi kesalahan: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshVideos,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada video untuk ditampilkan.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshVideos,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          final thumbnailUrl = video.thumbnail.isEmpty
              ? video.youtubeThumbnailUrl
              : video.thumbnail;

          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: VideoCard(
              title: video.title,
              category: video.category,
              duration: video.duration,
              thumbnail: thumbnailUrl,
              description: video.description,
              rating: double.tryParse(video.rating) ?? 0.0,
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        VideoPlayerScreen(video: video),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final greeting = getGreeting();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === JUDUL ATAS ===
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Si - Cegah ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 2),
                Image.asset("assets/images/baby1.png", width: 50, height: 50),
                const SizedBox(width: 8),
                const Text(
                  "Hebat",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // === GREETING ===
            Text(
              'Hallo, $_userName!',
              style: const TextStyle(
                fontSize: 20.0,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),

            Row(
              children: [
                Text(
                  '${greeting["text"]},',
                  style: const TextStyle(
                    fontSize: 25.0,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    letterSpacing: 2.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(greeting["icon"], color: greeting["color"], size: 40),
              ],
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.center,
              child: Text(
                '"${greeting["message"]}"',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // === BANNER ===
            const BannerCarousel(),

            const SizedBox(height: 30),

            // === VIDEO LIST ===
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 600),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 21, 226, 106),
                      Color(0xFF42A5F5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Video Edukasi",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 12),

                      Flexible(child: _buildVideoList()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
