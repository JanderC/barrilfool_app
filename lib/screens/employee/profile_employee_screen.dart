import 'package:flutter/material.dart';

class ProfileEmployeeScreen extends StatelessWidget {
  const ProfileEmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFFFF8C00),
      ),
      body: const Center(
        child: Text('Pantalla de Perfil del Empleado'),
      ),
    );
  }
}