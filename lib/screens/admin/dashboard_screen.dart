import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para el dashboard
    final stats = {
      'pedidos_hoy': 12,
      'pedidos_pendientes': 5,
      'ingresos_hoy': 245.75,
      'ingresos_semana': 1850.50,
      'productos_activos': 48,
      'clientes_activos': 120,
      'empleados_activos': 8,
    };
    
    // Datos de ejemplo para el gráfico de pedidos recientes
    final recentOrders = [
      {'id': 'ORD-001', 'cliente': 'Juan Pérez', 'total': 27.97, 'estado': 'entregado'},
      {'id': 'ORD-002', 'cliente': 'María López', 'total': 12.99, 'estado': 'cancelado'},
      {'id': 'ORD-003', 'cliente': 'Carlos Ruiz', 'total': 18.98, 'estado': 'en_camino'},
      {'id': 'ORD-004', 'cliente': 'Ana Gómez', 'total': 32.50, 'estado': 'confirmado'},
      {'id': 'ORD-005', 'cliente': 'Pedro Sánchez', 'total': 15.75, 'estado': 'pendiente'},
    ];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'es').format(DateTime.now()),
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Tarjetas de estadísticas principales
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Pedidos Hoy',
                  value: '${stats['pedidos_hoy']}',
                  icon: Icons.shopping_bag,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Ingresos Hoy',
                  value: '\$${stats['ingresos_hoy']?.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Pendientes',
                  value: '${stats['pedidos_pendientes']}',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  title: 'Ingresos Semana',
                  value: '\$${stats['ingresos_semana']?.toStringAsFixed(2)}',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Sección de pedidos recientes
          const Text(
            'Pedidos Recientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Encabezado de la tabla
                  Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'ID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Cliente',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Estado',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  
                  // Filas de la tabla
                  ...recentOrders.map((order) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            order['id'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(order['cliente'] as String),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '\$${(order['total'] as double).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFFF8C00),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: _buildStatusBadge(order['estado'] as String),
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 8),
                  const Divider(),
                  
                  // Botón para ver todos los pedidos
                  TextButton(
                    onPressed: () {
                      // Navegar a la pantalla de todos los pedidos
                    },
                    child: const Text(
                      'Ver todos los pedidos',
                      style: TextStyle(
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Sección de estadísticas adicionales
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  title: 'Productos',
                  value: '${stats['productos_activos']}',
                  subtitle: 'productos activos',
                  icon: Icons.inventory_2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  context,
                  title: 'Clientes',
                  value: '${stats['clientes_activos']}',
                  subtitle: 'clientes registrados',
                  icon: Icons.people,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  context,
                  title: 'Empleados',
                  value: '${stats['empleados_activos']}',
                  subtitle: 'empleados activos',
                  icon: Icons.badge,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF8C00),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
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
}
