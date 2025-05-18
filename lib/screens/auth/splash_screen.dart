import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 200,
              height: 200,
              // Si no tienes el logo aún, puedes usar un placeholder
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.restaurant, size: 100, color: Color(0xFFFF8C00)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Barrilfood',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8C00),
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
            ),
          ],
        ),
      ),
    );
  }
}
