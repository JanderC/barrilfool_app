import 'package:flutter/material.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Home'),
      ),
      body: const Center(
        child: Text('Welcome to the Employee Home Screen!'),
      ),
    );
  }
}