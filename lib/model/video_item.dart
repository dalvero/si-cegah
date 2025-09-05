import 'package:cloud_firestore/cloud_firestore.dart';

class VideoItem {
  final String title;
  final String category;
  final String duration;
  final String thumbnail;
  final String rating;
  final String videoUrl;

  VideoItem({
    required this.title,
    required this.category,
    required this.duration,
    required this.thumbnail,
    required this.rating,
    required this.videoUrl,
  });

  // Getter untuk mendapatkan ID video dari URL YouTube
  String? get youtubeVideoId {
    if (videoUrl.contains('youtube.com')) {
      return videoUrl.split('v=')[1].split('&')[0];
    }
    if (videoUrl.contains('youtu.be')) {
      return videoUrl.split('/').last.split('?').first;
    }
    return null;
  }

  // Getter untuk mendapatkan URL thumbnail secara otomatis dari YouTube
  String get youtubeThumbnailUrl {
    if (youtubeVideoId != null) {
      return 'https://i.ytimg.com/vi/$youtubeVideoId/maxresdefault.jpg';
    }
    return 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg'; // Gambar placeholder
  }

  factory VideoItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VideoItem(
      title: data['title'] ?? 'Judul Tidak Ditemukan',
      category: data['category'] ?? 'Kategori Tidak Ditemukan',
      duration: data['duration'] ?? 'Durasi Tidak Ditemukan',
      thumbnail: data['thumbnail'] ?? '',
      rating: data['rating'] ?? '5.0',
      videoUrl: data['video_url'] ?? 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    );
  }
}
