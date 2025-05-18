import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para pedidos
    final orders = [
      {
        'id': 'ORD-001',
        'fecha': DateTime.now().subtract(const Duration(days: 1)),
        'estado': 'entregado',
        'total': 27.97,
        'items': [
          'Hamburguesa Clásica x2',
          'Alitas BBQ x1',
        ],
      },
      {
        'id': 'ORD-002',
        'fecha': DateTime.now().subtract(const Duration(days: 5)),
        'estado': 'cancelado',
        'total': 12.99,
        'items': [
          'Pizza Margherita x1',
        ],
      },
      {
        'id': 'ORD-003',
        'fecha': DateTime.now().subtract(const Duration(hours: 2)),
        'estado': 'en_camino',
        'total': 18.98,
        'items': [
          'Hamburguesa Especial x1',
          'Refresco x2',
        ],
      },
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Pedidos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de pedidos
          Expanded(
            child: orders.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No tienes pedidos',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tus pedidos aparecerán aquí',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Encabezado del pedido
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pedido ${order['id']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    _buildStatusBadge(order['estado'] as String),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Fecha del pedido
                                Text(
                                  'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(order['fecha'] as DateTime)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // Elementos del pedido
                                const Text(
                                  'Productos:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...List.generate(
                                  (order['items'] as List).length,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '• ${(order['items'] as List)[i]}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // Total del pedido
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '\$${(order['total'] as double).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF8C00),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Botones de acción
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        // Ver detalles del pedido
                                      },
                                      child: const Text(
                                        'Ver Detalles',
                                        style: TextStyle(
                                          color: Color(0xFFFF8C00),
                                        ),
                                      ),
                                    ),
                                    if (order['estado'] == 'en_camino')
                                      TextButton(
                                        onPressed: () {
                                          // Seguir pedido
                                        },
                                        child: const Text(
                                          'Seguir Pedido',
                                          style: TextStyle(
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'pendiente':
        color = Colors.amber;
        text = 'Pendiente';
        break;
      case 'confirmado':
        color = Colors.blue;
        text = 'Confirmado';
        break;
      case 'en_preparacion':
        color = Colors.orange;
        text = 'En preparación';
        break;
      case 'listo_para_entrega':
        color = Colors.green;
        text = 'Listo para entrega';
        break;
      case 'en_camino':
        color = Colors.purple;
        text = 'En camino';
        break;
      case 'entregado':
        color = Colors.green.shade700;
        text = 'Entregado';
        break;
      case 'cancelado':
        color = Colors.red;
        text = 'Cancelado';
        break;
      default:
        color = Colors.grey;
        text = 'Desconocido';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
