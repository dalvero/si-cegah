import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/baby_loading.gif", 
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              "Memuat...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
