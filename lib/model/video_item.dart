import 'package:cloud_firestore/cloud_firestore.dart';

class VideoItem {
  final String id;        // tambahkan id
  final String title;
  final String category;
  final String duration;
  final String thumbnail;
  final String rating;
  final String videoUrl;
  final String description; // ✅ baru

  VideoItem({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.thumbnail,
    required this.rating,
    required this.videoUrl,
    required this.description,
  });

  String? get youtubeVideoId {
    if (videoUrl.contains('youtube.com')) {
      return videoUrl.split('v=')[1].split('&')[0];
    }
    if (videoUrl.contains('youtu.be')) {
      return videoUrl.split('/').last.split('?').first;
    }
    return null;
  }

  String get youtubeThumbnailUrl {
    if (youtubeVideoId != null) {
      return 'https://i.ytimg.com/vi/$youtubeVideoId/maxresdefault.jpg';
    }
    return 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg';
  }

  factory VideoItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VideoItem(
      id: doc.id,
      title: data['title'] ?? 'Judul Tidak Ditemukan',
      category: data['category'] ?? 'Kategori Tidak Ditemukan',
      duration: data['duration'] ?? 'Durasi Tidak Ditemukan',
      thumbnail: data['thumbnail'] ?? '',
      rating: data['rating'] ?? '5.0',
      videoUrl: data['video_url'] ?? '',
      description: data['description'] ?? '', // ✅ baru
    );
  }
}
