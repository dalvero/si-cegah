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
  bool isUserLoading = true;

  // Bottom navigation state
  int _selectedNavIndex = 1; // Default ke Home
  String? _userRole;
  String? _userId;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _getUserRole();
    await _loadVideos();
  }

  Future<void> _getUserRole() async {
    try {
      await _authService.refreshUserSession();
      final user = _authService.currentUser;
      print('DEBUG - Current user after refresh: $user');
      print('DEBUG - User ID: ${user?.id}');
      print('DEBUG - User role: ${user?.role}');

      setState(() {
        _userRole = user?.role ?? 'user';
        _userId = user?.id;
        isUserLoading = false;
      });

      if (user == null) {
        print('WARNING - User is null, might need to redirect to login');
        _showLoginPrompt();
      }
    } catch (e) {
      print('ERROR - Failed to get user role: $e');
      setState(() {
        _userRole = 'user';
        _userId = null;
        isUserLoading = false;
      });
      _showLoginPrompt();
    }
  }

  void _showLoginPrompt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session expired. Please login again.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'LOGIN',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to login page
                // Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        );
      }
    });
  }

  Future<void> _loadVideos() async {
    try {
      videos = await VideoService().getVideos();
      currentIndex = videos.indexWhere(
        (v) => v.videoUrl == widget.video.videoUrl,
      );

      if (currentIndex == -1) {
        currentIndex = 0;
      }

      final videoId = YoutubePlayer.convertUrlToId(
        videos[currentIndex].videoUrl,
      );
      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: false,
            forceHD: true,
          ),
        );
      } else {
        throw Exception('Invalid video URL');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('ERROR - Failed to load videos: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load videos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  void _handleQuizNavigation() {
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      // Pause video when showing login dialog
      _controller.pause();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            title: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Akses Terbatas',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            content: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Anda perlu login untuk mengakses fitur latihan soal.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Resume video when user cancels
                  _controller.play();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Keep video paused when navigating to login
                  // Navigate to login page
                  // Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    // Pause video before navigating to quiz
    _controller.pause();

    final currentVideo = videos[currentIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          videoId: currentVideo.id,
          userId: currentUser.id,
          videoTitle: currentVideo.title,
        ),
      ),
    ).then((_) {
      // OPSIONAL, MEMULAI VIDEO KETIKA KEMBALI DARI QUIZ (AUTO - RESUME VIDEO)
      _controller.play();
    });
  }

  @override
  void dispose() {
    if (!isLoading) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || isUserLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [      
                  Image.asset(
                    "assets/images/welcome.gif", 
                    width: 330,
                    height: 330,
                  ),              
                  const SizedBox(height: 20),
                  Text(
                    'Memuat video...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Video Player',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.videocam_off_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),
                Text(
                  'Tidak ada video tersedia',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan coba lagi nanti',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentVideo = videos[currentIndex];

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.redAccent,
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          extendBody: true,
          body: Column(
            children: [
              // Video Section - Tidak diubah posisi dan tampilan
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: player,
                  ),
                  Positioned(
                    top: 40,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              ),

              // Enhanced Content Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Video Info Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Video Title
                            Text(
                              currentVideo.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Color(0xFF2D3748),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade600,
                                    Colors.blue.shade700,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade200,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                currentVideo.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Scrollable Description
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deskripsi Video',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Text(
                                  currentVideo.description,
                                  textAlign: TextAlign.justify,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF4A5568),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Enhanced Bottom Actions
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quiz Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _userId != null
                            ? LinearGradient(
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade700,
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.orange.shade500,
                                  Colors.orange.shade600,
                                ],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_userId != null
                                    ? Colors.blue.shade300
                                    : Colors.orange.shade300)
                                .withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _handleQuizNavigation,
                        icon: Icon(
                          _userId != null ? Icons.quiz : Icons.lock_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: Text(
                          _userId != null ? "LATIHAN SOAL" : "LOGIN UNTUK QUIZ",
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Navigation Buttons
                    Row(
                      children: [
                        // Previous Button
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: currentIndex > 0
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: OutlinedButton.icon(
                              onPressed: currentIndex > 0
                                  ? _playPreviousVideo
                                  : null,
                              icon: Icon(
                                Icons.skip_previous,
                                color: currentIndex > 0
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400,
                                size: 20,
                              ),
                              label: Text(
                                "SEBELUMNYA",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: currentIndex > 0
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade400,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: BorderSide.none,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Next Button
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: currentIndex < videos.length - 1
                                  ? LinearGradient(
                                      colors: [
                                        Colors.green.shade600,
                                        Colors.green.shade700,
                                      ],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey.shade400,
                                        Colors.grey.shade500,
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: currentIndex < videos.length - 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.shade300
                                            .withOpacity(0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: currentIndex < videos.length - 1
                                  ? _playNextVideo
                                  : null,
                              label: const Text(
                                "BERIKUTNYA",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                              icon: const Icon(
                                Icons.skip_next,
                                color: Colors.white,
                                size: 20,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
        );
      },
    );
  }
}