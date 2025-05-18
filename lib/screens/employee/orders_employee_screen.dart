import 'package:flutter/material.dart';

class OrdersEmployeeScreen extends StatelessWidget {
  const OrdersEmployeeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos - Empleado'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán los pedidos asignados al empleado.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}