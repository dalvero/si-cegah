// screen_video_player.dart - Updated version
import 'package:flutter/material.dart';
import 'package:si_cegah/services/video_service.dart';
import 'package:si_cegah/services/auth_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:si_cegah/model/video_item.dart';
import 'package:si_cegah/pages/home.dart';
import 'package:si_cegah/pages/profil.dart';
import 'package:si_cegah/pages/pengaturan.dart';
import 'package:si_cegah/pages/admin/dashboard.dart';
import 'quiz.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late int currentIndex;
  List<VideoItem> videos = [];
  bool isLoading = true;

  // Bottom navigation state
  int _selectedNavIndex = 1; // Default ke Home
  String? _userRole;
  String? _userId; // Added userId
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _getUserRole();
  }

  void _getUserRole() async {
    final user = _authService.currentUser;
    setState(() {
      _userRole = user?.role ?? 'user';
      _userId = user?.id; // Store user ID
    });
  }

  void _loadVideos() async {
    videos = await VideoService().getVideos();
    currentIndex = videos.indexWhere(
      (v) => v.videoUrl == widget.video.videoUrl,
    );

    final videoId = YoutubePlayer.convertUrlToId(videos[currentIndex].videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        forceHD: true,
      ),
    );

    setState(() {
      isLoading = false;
    });
  }

  void _playPreviousVideo() {
    if (currentIndex > 0) {
      currentIndex--;
      final prevVideoId =
          YoutubePlayer.convertUrlToId(videos[currentIndex].videoUrl) ?? '';
      _controller.load(prevVideoId);
      setState(() {});
    }
  }

  void _playNextVideo() {
    if (videos.isEmpty) return;
    if (currentIndex < videos.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }

    final nextVideoId =
        YoutubePlayer.convertUrlToId(videos[currentIndex].videoUrl) ?? '';
    _controller.load(nextVideoId);
    setState(() {});
  }

  void _onNavItemTapped(int index) {
    if (index == _selectedNavIndex) return;

    Widget targetPage;
    switch (index) {
      case 0: // Pengaturan
        targetPage = const Pengaturan();
        break;
      case 1: // Home
        targetPage = const Home();
        break;
      case 2: // Profil
        targetPage = const Profile();
        break;
      case 3: // Dashboard (only for admin)
        if (_userRole == 'admin') {
          targetPage = const Dashboard();
        } else {
          return;
        }
        break;
      default:
        return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => targetPage),
      (route) => false,
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: Container(
        height: 70,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => _onNavItemTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentVideo = videos[currentIndex];

    // Define navigation items
    final navItems = [
      {'icon': Icons.settings_outlined, 'label': 'Pengaturan'},
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
      if (_userRole == 'admin')
        {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
    ];

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.redAccent,
      ),
      builder: (context, player) {
        return Scaffold(
          extendBody: true,
          body: Column(
            children: [
              // Video Section
              Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    child: player,
                  ),
                  Positioned(
                    top: 30,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              // Content Section
              Expanded(
                child: Column(
                  children: [
                    // Title and Category
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentVideo.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentVideo.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Divider(color: Colors.black, height: 24),
                        ],
                      ),
                    ),

                    // Scrollable Description
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          videos[currentIndex].description,
                          textAlign: TextAlign.justify,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed Bottom Buttons (above navigation)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 94.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Latihan Soal Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          debugPrint(
                            'Latihan soal diaktifkan untuk video: ${currentVideo.id}',
                          );
                          // Navigate ke halaman quiz dengan videoId dan userId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizPage(
                                videoId: currentVideo.id, // Pass video ID
                                userId: _userId ?? '', // Pass user ID
                                videoTitle:
                                    currentVideo.title, // Pass video title
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.quiz, color: Colors.white),
                        label: const Text(
                          "LATIHAN SOAL",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Navigation Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: currentIndex > 0
                                ? _playPreviousVideo
                                : null,
                            icon: Icon(
                              Icons.skip_previous,
                              color: currentIndex > 0
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            label: Text(
                              "SEBELUMNYA",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: currentIndex > 0
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: currentIndex < videos.length - 1
                                ? _playNextVideo
                                : null,
                            label: const Text(
                              "BERIKUTNYA",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            icon: const Icon(
                              Icons.skip_next,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentIndex < videos.length - 1
                                  ? Colors.blueAccent
                                  : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Bottom Navigation Bar
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
                    isSelected: _selectedNavIndex == index,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
