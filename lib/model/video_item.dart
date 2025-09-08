class VideoItem {
  final String id;
  final String title;
  final String description;
  final String youtubeId;
  final String categoryId;
  final String categoryName;
  final String categoryColor;
  final int minAge;
  final int maxAge;
  final List<String> targetRole; // Changed from String to List<String>
  final String thumbnailUrl;
  final int viewCount;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasTest;

  VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.minAge,
    required this.maxAge,
    required this.targetRole,
    required this.thumbnailUrl,
    required this.viewCount,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.hasTest,
  });

  // Getter untuk kompatibilitas dengan kode lama
  String get category => categoryName;
  String get rating => '5.0'; // default rating
  String get videoUrl => 'https://youtube.com/watch?v=$youtubeId';
  String get thumbnail => thumbnailUrl;
  String get duration => 'N/A'; // durasi tidak tersedia dari API

  // Helper getter untuk menampilkan targetRole sebagai string
  String get targetRoleText => targetRole.join(', ');

  String? get youtubeVideoId => youtubeId;

  String get youtubeThumbnailUrl {
    return 'https://i.ytimg.com/vi/$youtubeId/maxresdefault.jpg';
  }

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Judul Tidak Ditemukan',
      description: json['description']?.toString() ?? '',
      youtubeId: json['youtubeId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName:
          json['category']?['name']?.toString() ?? 'Kategori Tidak Ditemukan',
      categoryColor: json['category']?['color']?.toString() ?? '#000000',
      minAge: json['minAge'] ?? 0,
      maxAge: json['maxAge'] ?? 100,
      targetRole: List<String>.from(
        json['targetRole'] ?? [],
      ), // Fixed: Handle array properly
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      viewCount: json['viewCount'] ?? 0,
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      hasTest: json['test'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'youtubeId': youtubeId,
      'categoryId': categoryId,
      'minAge': minAge,
      'maxAge': maxAge,
      'targetRole': targetRole, // Now properly handles List<String>
      'thumbnailUrl': thumbnailUrl,
      'viewCount': viewCount,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Factory untuk backward compatibility dengan Firestore
  factory VideoItem.fromFirestore(dynamic doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VideoItem(
      id: doc.id,
      title: data['title']?.toString() ?? 'Judul Tidak Ditemukan',
      description: data['description']?.toString() ?? '',
      youtubeId: data['youtubeId']?.toString() ?? '',
      categoryId: data['categoryId']?.toString() ?? '',
      categoryName: data['category']?.toString() ?? 'Kategori Tidak Ditemukan',
      categoryColor: data['categoryColor']?.toString() ?? '#000000',
      minAge: data['minAge'] ?? 0,
      maxAge: data['maxAge'] ?? 100,
      targetRole: data['targetRole'] is List
          ? List<String>.from(data['targetRole'])
          : [data['targetRole']?.toString() ?? ''], // Handle both cases
      thumbnailUrl: data['thumbnail']?.toString() ?? '',
      viewCount: data['viewCount'] ?? 0,
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      hasTest: false,
    );
  }
}
