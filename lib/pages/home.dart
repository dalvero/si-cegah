import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        });
      }
    }
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

  // === BACKGROUND GRADIENT BERDASARKAN WAKTU ===
  LinearGradient getBackgroundGradient() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 11) {
      // PAGI – BERNUANSA CERAH 
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFE29F), // KUNING LEMBUT
          Color(0xFFFFB07C), // ORANYE PASTEL
        ],
      );
    } else if (hour >= 11 && hour < 15) {
      // SIANG – BIRU TERANG
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6A11CB), // UNGU
          Color(0xFF2575FC), // BIRU
        ],
      );
    } else if (hour >= 15 && hour < 18) {
      // SORE – JINGGA KEUNGU
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF9A9E), // PINK TERANG
          Color(0xFFFAD0C4), // PEACH
        ],
      );
    } else {
      // MALAM – AGAK TERANG TAPI TETAP DARK
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
        Color(0xFF6A11CB), // UNGU 
        Color(0xFF2575FC), // BIRU
        ],
      );
    }


}
  @override
  Widget build(BuildContext context) {
    final greeting = getGreeting();
    return Scaffold(    
      body: Container (  
        decoration: BoxDecoration(
          gradient: getBackgroundGradient()
        ),
      
        child : SingleChildScrollView(                
        
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
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 2),
                Image.asset(
                  "assets/images/baby1.png",
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Hebat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30), // JARAK

            // === GREETING ===   
            // USERNAME
            Text(
              'Hallo, $_userName!',              
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,                
                color: Colors.white,    
                letterSpacing: 2.0,            
              ),
            ),


            Row(
              children: [
                Text(
                  '${greeting["text"]},',
                  style: TextStyle(
                    fontSize: 25.0,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    letterSpacing: 2.0,    
                    color: Colors.white,                                
                  ),
                ),
                Icon(
                  greeting["icon"], 
                  color: greeting["color"],
                  size: 40,
                ),
              ],
            ),            

            SizedBox(height: 30),

            // MESSAGE
            // AGAR TEXT BERADA DIKANAN
            Align(
              alignment: Alignment.center,
              child: Text(                          
              '"${greeting["message"]}"',
              style: TextStyle(              
                fontSize: 20.0,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                constraints: const BoxConstraints(
                  maxHeight: 600, // BATAS TINGGI MAKSIMAL, BISA DISESUAIKAN
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 221, 219, 247),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),                  
                  child: Column(                    
                    mainAxisSize: MainAxisSize.min, // AGAR FLEKSIBEL
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
                      // ====== VIDEO CARDS ======
                      Flexible(
                        child: StreamBuilder<List<VideoItem>>(
                          stream: _videoService.getVideosStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(child: Text('Tidak ada video untuk ditampilkan.'));
                            }

                            final videos = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: videos.length,
                              itemBuilder: (context, index) {
                                final video = videos[index];
                                final thumbnailUrl = video.thumbnail.isEmpty
                                    ? video.youtubeThumbnailUrl
                                    : video.thumbnail;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: VideoCard(
                                        title: video.title,
                                        category: video.category,
                                        duration: video.duration,
                                        thumbnail: thumbnailUrl,
                                        rating: double.tryParse(video.rating) ?? 0.0,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              transitionDuration: const Duration(milliseconds: 500),
                                              pageBuilder: (context, animation, secondaryAnimation) => VideoPlayerScreen(video: video),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.easeInOut;

                                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                                return SlideTransition(
                                                  position: animation.drive(tween),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),          
          ],
        ),
      ),
    ),
    );        
  }
}
