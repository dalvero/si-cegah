import 'package:flutter/material.dart';
import 'package:si_cegah/services/video_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:si_cegah/model/video_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;  
  const VideoPlayerScreen({super.key, required this.video});
  
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;  
  late int currentIndex;
  List<VideoItem> videos = []; // daftar semua video

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }  

  void _loadVideos() async {
    videos = await VideoService().getVideos();
    currentIndex = videos.indexWhere((v) => v.videoUrl == widget.video.videoUrl);

    final videoId = YoutubePlayer.convertUrlToId(videos[currentIndex].videoUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true, // otomatis play saat pertama kali
        mute: false,
        enableCaption: false,
        forceHD: true,
      ),
    );

    setState(() {
      isLoading = false; // data sudah siap
    });
  }

  void _playPreviousVideo() {
    if (currentIndex > 0) {
      currentIndex--;
      final prevVideoId = YoutubePlayer.convertUrlToId(videos[currentIndex].videoUrl) ?? '';
      _controller.load(prevVideoId);
      setState(() {});
    }
  }

  void _playNextVideo() {
    if (videos.isEmpty) return;
    if (currentIndex < videos.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0; // loop ke video pertama
    }

    final nextVideoId = YoutubePlayer.convertUrlToId(videos[currentIndex].videoUrl) ?? '';
    _controller.load(nextVideoId);
    setState(() {}); // update UI judul & kategori
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
          body: Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    height: 280,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF15E26A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: player,
                    ),
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentVideo.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentVideo.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                        letterSpacing: 2.0,
                      ),
                    ),             
                    const Divider(color: Colors.black),
                    const SizedBox(height: 12),
                    Text(
                      videos[currentIndex].description,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),                      

                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Aksi button baru
                                debugPrint('Loop video diaktifkan');
                              },                              
                              label: const Text(
                                "Latihan Soal",
                                style: TextStyle(
                                  color: Colors.black, 
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 64, 255, 144),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),                                      

                    Row(
                      children: [
                        // Tombol Video Sebelumnya
                        Expanded(
                          child: OutlinedButton(
                            onPressed: currentIndex > 0 ? _playPreviousVideo : null, // nonaktif jika video pertama
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "VIDEO SEBELUMNYA",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal,
                                color: currentIndex > 0 ? Colors.black : Colors.grey, // warna abu jika disabled
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Tombol Video Berikutnya
                        Expanded(
                          child: ElevatedButton(
                            onPressed: currentIndex < videos.length - 1 ? _playNextVideo : null, // nonaktif jika video terakhir
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentIndex < videos.length - 1 ? Colors.blueAccent : Colors.grey, // warna abu jika disabled
                              padding: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "VIDEO BERIKUTNYA",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )

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
