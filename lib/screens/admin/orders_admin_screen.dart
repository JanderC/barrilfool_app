import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersAdminScreen extends StatelessWidget {
  const OrdersAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para pedidos
    final orders = [
      {
        'id': 'ORD-001',
        'cliente': 'Juan Pérez',
        'fecha': DateTime.now().subtract(const Duration(hours: 1)),
        'estado': 'pendiente',
        'total': 27.97,
        'direccion': 'Calle Principal #123, San Martín',
        'metodo_pago': 'efectivo',
      },
      {
        'id': 'ORD-002',
        'cliente': 'María López',
        'fecha': DateTime.now().subtract(const Duration(hours: 3)),
        'estado': 'confirmado',
        'total': 12.99,
        'direccion': 'Av. Central #45, Rubio',
        'metodo_pago': 'tarjeta',
      },
      {
        'id': 'ORD-003',
        'cliente': 'Carlos Ruiz',
        'fecha': DateTime.now().subtract(const Duration(hours: 5)),
        'estado': 'en_preparacion',
        'total': 18.98,
        'direccion': 'Calle 5 #67, Junín',
        'metodo_pago': 'efectivo',
      },
      {
        'id': 'ORD-004',
        'cliente': 'Ana Gómez',
        'fecha': DateTime.now().subtract(const Duration(days: 1)),
        'estado': 'entregado',
        'total': 32.50,
        'direccion': 'Av. Libertad #89, San Martín',
        'metodo_pago': 'transferencia',
      },
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros y búsqueda
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar pedido...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  hint: const Text('Estado'),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: 'pendiente',
                      child: Text('Pendientes'),
                    ),
                    DropdownMenuItem(
                      value: 'confirmado',
                      child: Text('Confirmados'),
                    ),
                    DropdownMenuItem(
                      value: 'en_preparacion',
                      child: Text('En preparación'),
                    ),
                    DropdownMenuItem(
                      value: 'listo_para_entrega',
                      child: Text('Listos para entrega'),
                    ),
                    DropdownMenuItem(
                      value: 'en_camino',
                      child: Text('En camino'),
                    ),
                    DropdownMenuItem(
                      value: 'entregado',
                      child: Text('Entregados'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelado',
                      child: Text('Cancelados'),
                    ),
                  ],
                  onChanged: (value) {
                    // Aplicar filtro
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Estadísticas rápidas
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Pendientes',
                  value: '2',
                  color: Colors.amber,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  title: 'En preparación',
                  value: '1',
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  title: 'En camino',
                  value: '0',
                  color: Colors.purple,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  title: 'Hoy',
                  value: '3',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Lista de pedidos
            Expanded(
              child: orders.isEmpty
                  ? const Center(
                      child: Text('No hay pedidos registrados'),
                    )
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
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
                                    Row(
                                      children: [
                                        Text(
                                          'Pedido ${order['id']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatusBadge(order['estado'] as String),
                                      ],
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(order['fecha'] as DateTime),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Información del cliente y dirección
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Color(0xFFFF8C00),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Cliente: ${order['cliente']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Color(0xFFFF8C00),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Dirección: ${order['direccion']}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.payment,
                                      size: 16,
                                      color: Color(0xFFFF8C00),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pago: ${_getPaymentMethodName(order['metodo_pago'] as String)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Total: \$${(order['total'] as double).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFF8C00),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
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
                                    const SizedBox(width: 8),
                                    if (order['estado'] == 'pendiente')
                                      ElevatedButton(
                                        onPressed: () {
                                          // Confirmar pedido
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Confirmar'),
                                      )
                                    else if (order['estado'] == 'confirmado')
                                      ElevatedButton(
                                        onPressed: () {
                                          // Iniciar preparación
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Preparar'),
                                      )
                                    else if (order['estado'] == 'en_preparacion')
                                      ElevatedButton(
                                        onPressed: () {
                                          // Marcar como listo para entrega
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Listo'),
                                      )
                                    else if (order['estado'] == 'listo_para_entrega')
                                      ElevatedButton(
                                        onPressed: () {
                                          // Asignar repartidor
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Enviar'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
  
  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'efectivo':
        return 'Efectivo';
      case 'tarjeta':
        return 'Tarjeta';
      case 'transferencia':
        return 'Transferencia';
      case 'billetera_digital':
        return 'Billetera Digital';
      default:
        return 'Desconocido';
    }
  }
}
