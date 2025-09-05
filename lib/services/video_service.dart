import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:si_cegah/model/video_item.dart';

class VideoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan stream data video secara real-time dari Firestore
  Stream<List<VideoItem>> getVideosStream() {
    return _firestore.collection('videos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => VideoItem.fromFirestore(doc)).toList();
    });
  }

  // Mendapatkan daftar semua video dari Firestore (sekali ambil)
  Future<List<VideoItem>> getVideos() async {
    final querySnapshot = await _firestore.collection('videos').get();
    return querySnapshot.docs.map((doc) => VideoItem.fromFirestore(doc)).toList();
  }
}
