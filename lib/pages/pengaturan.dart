// pengaturan.dart (modifikasi)
import 'package:flutter/material.dart';

class Pengaturan extends StatefulWidget {
  const Pengaturan({super.key});

  @override
  State<Pengaturan> createState() => _PengaturanState();
}

class _PengaturanState extends State<Pengaturan> {
  @override
  Widget build(BuildContext context) {
    return const Center( // Ubah Placeholder menjadi Center dengan Text
      child: Text(
        "Halaman Pengaturan",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}