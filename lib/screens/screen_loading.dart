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
              "assets/images/welcome.gif", 
              width: 330,
              height: 330,
            ),
            const SizedBox(height: 16),
            const Text(
              "Tunggu sebentar ya..",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
