import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:si_cegah/model/video_item.dart';
import 'package:si_cegah/services/video_service.dart';
import 'package:si_cegah/widget/video_card.dart';

class ManageVideoPage extends StatefulWidget {
  const ManageVideoPage({super.key});

  @override
  State<ManageVideoPage> createState() => _ManageVideoPageState();
}

class _ManageVideoPageState extends State<ManageVideoPage> {
  final VideoService _videoService = VideoService();

  void _addVideoDialog() {
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final durationController = TextEditingController();
  final urlController = TextEditingController();
  final descController = TextEditingController(); // ✅ baru

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Tambah Video"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Judul")),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Kategori")),
            TextField(controller: durationController, decoration: const InputDecoration(labelText: "Durasi")),
            TextField(controller: urlController, decoration: const InputDecoration(labelText: "URL YouTube")),
            TextField(
              controller: descController, 
              decoration: const InputDecoration(labelText: "Deskripsi"),
              keyboardType: TextInputType.multiline, 
              maxLines: null, // ✅ bikin bisa nulis banyak baris
              minLines: 3,    // opsional, kasih tinggi awal 3 baris
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance.collection("videos").add({
              "title": titleController.text,
              "category": categoryController.text,
              "duration": durationController.text,
              "video_url": urlController.text,
              "thumbnail": "",
              "rating": "5.0",
              "description": descController.text, // ✅ baru
            });
            if (mounted) Navigator.pop(context);
          },
          child: const Text("Simpan"),
        )
      ],
    ),
  );
}


 void _editVideoDialog(VideoItem video) {
  final titleController = TextEditingController(text: video.title);
  final categoryController = TextEditingController(text: video.category);
  final durationController = TextEditingController(text: video.duration);
  final urlController = TextEditingController(text: video.videoUrl);
  final descController = TextEditingController(text: video.description); // ✅ baru

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Video"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Judul")),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: "Kategori")),
            TextField(controller: durationController, decoration: const InputDecoration(labelText: "Durasi")),
            TextField(controller: urlController, decoration: const InputDecoration(labelText: "URL YouTube")),
            TextField(
              controller: descController, 
              decoration: const InputDecoration(labelText: "Deskripsi"),
              keyboardType: TextInputType.multiline, 
              maxLines: null, // ✅ bikin bisa nulis banyak baris
              minLines: 3,    // opsional, kasih tinggi awal 3 baris
            ), // ✅ baru
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance.collection("videos").doc(video.id).update({
              "title": titleController.text,
              "category": categoryController.text,
              "duration": durationController.text,
              "video_url": urlController.text,
              "description": descController.text, // ✅ baru
            });
            if (mounted) Navigator.pop(context);
          },
          child: const Text("Update"),
        )
      ],
    ),
  );
}


  // Hapus video
  Future<void> _deleteVideo(String id) async {
    await FirebaseFirestore.instance.collection("videos").doc(id).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video berhasil dihapus")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Video"),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<VideoItem>>(
        stream: _videoService.getVideosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada video"));
          }

          final videos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final thumb = video.thumbnail.isEmpty ? video.youtubeThumbnailUrl : video.thumbnail;

              return Stack(
                children: [
                  VideoCard(
                    title: video.title,
                    category: video.category,
                    duration: video.duration,
                    thumbnail: thumb,
                    description: video.description,
                    rating: double.tryParse(video.rating) ?? 0.0,
                    onTap: () {}, // admin tidak play video
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editVideoDialog(video),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteVideo(video.id),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVideoDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
