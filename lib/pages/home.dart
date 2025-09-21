// home.dart - Updated dengan user context untuk star rating
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:si_cegah/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:si_cegah/services/auth_service.dart';
import 'package:si_cegah/widget/banner.dart';
import 'package:si_cegah/widget/video_card.dart';
import 'package:si_cegah/model/video_item.dart';
import 'package:si_cegah/services/video_service.dart';
import 'package:si_cegah/screens/screen_video_player.dart';
import 'package:si_cegah/widget/celebration_snackbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final VideoService _videoService = VideoService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String _userName = "Memuat...";
  List<VideoItem> _videos = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _fetchUserProfile();
    _loadVideos();
  }

  Future<void> _fetchUserProfile() async {
    if (_user != null) {
      setState(() {
        _userName = _user!.name;
      });
    } else {
      await _authService.refreshCurrentUser();
      _user = _authService.currentUser;
      setState(() {
        _userName = "Pengguna";
      });
    }
  }

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

  Future<void> _refreshVideos() async {
    await _loadVideos();
  }

  // Show celebration snackbar when returned from quiz completion
  void _showCelebrationFromQuiz(Map<String, dynamic> celebrationData) {
    final message = celebrationData['message'] ?? 'Test selesai!';
    final starRating = celebrationData['starRating'] ?? 0;
    final achievementsUnlocked = List<String>.from(
      celebrationData['achievementsUnlocked'] ?? [],
    );
    final isPassed = celebrationData['isPassed'] ?? false;
    final score = celebrationData['score'] ?? 0;
    final videoTitle = celebrationData['videoTitle'] ?? '';

    String finalMessage = message;
    if (isPassed) {
      finalMessage = 'Selamat! Kamu lulus test "$videoTitle" dengan $score%!';
    }

    CelebrationSnackbar.show(
      context,
      message: finalMessage,
      starRating: starRating,
      achievementsUnlocked: achievementsUnlocked,
    );
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
              key: ValueKey('${video.id}-${_videos.hashCode}'),
              title: video.title,
              category: video.category,
              duration: video.duration,
              thumbnail: thumbnailUrl,
              description: video.description,
              videoId: video.id, // TAMBAHAN: Pass video ID
              userId: _user?.id, // TAMBAHAN: Pass user ID for star rating
              rating: double.tryParse(video.rating) ?? 0.0,
              onTap: () async {
                // Navigate to VideoPlayerScreen and wait for result
                final result = await Navigator.of(context)
                    .push<Map<String, dynamic>>(
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

                // If celebration data returned from quiz completion
                if (result != null && result.containsKey('message')) {
                  _showCelebrationFromQuiz(result);
                  // Refresh video list to update star ratings
                  _refreshVideos();
                }
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 60, left: 10, right: 10),
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

            // === BANNER ===
            const BannerCarousel(),

            const SizedBox(height: 10),

            // === VIDEO LIST ===
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: const BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Video Edukasi",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 0),
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
