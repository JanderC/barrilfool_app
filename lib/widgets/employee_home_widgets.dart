import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:barrilfood_app/providers/user_provider.dart';

class EmployeeHomeWidgets {
  static Widget buildWelcomeCard(Map<String, dynamic>? user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFFF8C00),
              child: Icon(Icons.person, size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${user?['nombre'] ?? 'Empleado'}!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'es',
                    ).format(DateTime.now()),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildStatsGrid(
    int pending,
    int inProcess,
    int completed,
    int total,
  ) {
    final statsData = [
      {
        'title': 'Pendientes por Tomar',
        'value': '$pending',
        'icon': Icons.pending_actions,
        'color': Colors.orange,
      },
      {
        'title': 'En Proceso',
        'value': '$inProcess',
        'icon': Icons.schedule,
        'color': Colors.blue,
      },
      {
        'title': 'Completados Hoy',
        'value': '$completed',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'Total Asignados',
        'value': '$total',
        'icon': Icons.assignment,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: statsData.length,
      itemBuilder: (context, index) {
        final stat = statsData[index];
        return _buildStatCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          icon: stat['icon'] as IconData,
          color: stat['color'] as Color,
        );
      },
    );
  }

  static Widget buildUpcomingOrders(List<Map<String, dynamic>> upcomingOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximos Pedidos (Por Tomar)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (upcomingOrders.isEmpty)
          buildEmptyState(
            Icons.assignment_turned_in,
            'No tienes pedidos pendientes por tomar',
          )
        else
          ...upcomingOrders.map((order) => _buildPreviewOrderCard(order)),
      ],
    );
  }

  static Widget buildOrderCard(
    Map<String, dynamic> order,
    BuildContext context,
    Function(String) onTakeOrder,
    Function(String, int, String) onUpdateOrderStatus,
    Function(String) onShowCancelDialog,
    int employeePendingStateId,
    int employeeInProcessStateId,
    int employeeCompletedStateId,
    int employeeCancelledStateId, {
    bool isPreview = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order['id']?.toString() ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusBadge(
                  order['estado_id'] as int?,
                  employeePendingStateId,
                  employeeInProcessStateId,
                  employeeCompletedStateId,
                  employeeCancelledStateId,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order['cliente_nombre'] ??
                  order['cliente'] ??
                  'Cliente desconocido',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Total: \$${double.tryParse(order['total']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                color: Color(0xFFFF8C00),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isPreview) ...[
              const SizedBox(height: 16),
              if (order['items'] != null && (order['items'] as List).isNotEmpty)
                _buildProductsList(order['items'] as List<dynamic>),
              if (order['productos'] != null &&
                  (order['productos'] as List).isNotEmpty)
                _buildProductsList(order['productos'] as List<dynamic>),

              if (order['estado_id'] == employeePendingStateId ||
                  order['estado_id'] == employeeInProcessStateId) ...[
                const SizedBox(height: 16),
                _buildOrderActions(
                  order,
                  context,
                  onTakeOrder,
                  onUpdateOrderStatus,
                  onShowCancelDialog,
                  employeePendingStateId,
                  employeeInProcessStateId,
                  employeeCompletedStateId,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildProfileHeader(Map<String, dynamic>? user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFFF8C00),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user?['nombre'] ?? 'Nombre no disponible',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildProfileInfo(Map<String, dynamic>? user) {
    final List<Map<String, dynamic>> infoItems = [];
    if (user != null) {
      infoItems.add({
        'icon': Icons.badge,
        'label': 'ID Usuario',
        'value': user['id']?.toString() ?? 'N/A',
      });
      if (user['telefono'] != null) {
        infoItems.add({
          'icon': Icons.phone,
          'label': 'Teléfono',
          'value': user['telefono'],
        });
      }
      if (user['email'] != null) {
        infoItems.add({
          'icon': Icons.email,
          'label': 'Email',
          'value': user['email'],
        });
      }
      if (user['fecha_ingreso'] != null) {
        try {
          infoItems.add({
            'icon': Icons.calendar_today,
            'label': 'Fecha de Registro',
            'value': DateFormat(
              'd MMMM yyyy',
              'es',
            ).format(DateTime.parse(user['fecha_ingreso'])),
          });
        } catch (e) {
          infoItems.add({
            'icon': Icons.calendar_today,
            'label': 'Fecha de Registro',
            'value': user['fecha_ingreso'],
          });
        }
      } else if (user['created_at'] != null) {
        try {
          infoItems.add({
            'icon': Icons.calendar_today,
            'label': 'Fecha de Creación',
            'value': DateFormat(
              'd MMMM yyyy',
              'es',
            ).format(DateTime.parse(user['created_at'])),
          });
        } catch (e) {
          infoItems.add({
            'icon': Icons.calendar_today,
            'label': 'Fecha de Creación',
            'value': user['created_at'],
          });
        }
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Personal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (infoItems.isEmpty)
              const Text("No hay información de perfil disponible."),
            ...infoItems.map(
              (item) => _buildInfoRow(
                item['icon'] as IconData,
                item['label'] as String,
                item['value'] as String,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState(IconData icon, String message) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widgets privados
  static Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
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

  static Widget _buildPreviewOrderCard(Map<String, dynamic> order) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.restaurant_menu, color: Colors.orange.shade600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${order['id']?.toString() ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    order['cliente_nombre'] ?? 'Cliente desconocido',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Text(
              '\$${double.tryParse(order['total']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                color: Color(0xFFFF8C00),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildProductsList(List<dynamic> products) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...products.map((item) {
          final nombre =
              item['nombre'] ?? item['producto_nombre'] ?? 'Producto';
          final cantidad = item['cantidad'] ?? 1;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text('- $nombre x$cantidad'),
          );
        }).toList(),
      ],
    );
  }
}

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.orange, size: 20),
        const SizedBox(width: 12),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}

Widget _buildStatusBadge(
  int? estadoId,
  int pendingId,
  int inProcessId,
  int completedId,
  int cancelledId,
) {
  Color color;
  String text;

  if (estadoId == pendingId) {
    color = Colors.orange;
    text = 'Pendiente';
  } else if (estadoId == inProcessId) {
    color = Colors.blue;
    text = 'En Proceso';
  } else if (estadoId == completedId) {
    color = Colors.green;
    text = 'Completado';
  } else if (estadoId == cancelledId) {
    color = Colors.red;
    text = 'Cancelado';
  } else {
    color = Colors.grey;
    text = 'Desconocido';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}

Widget _buildOrderActions(
  Map<String, dynamic> order,
  BuildContext context,
  Function(String) onTakeOrder,
  Function(String, int, String) onUpdateOrderStatus,
  Function(String) onShowCancelDialog,
  int employeePendingStateId,
  int employeeInProcessStateId,
  int employeeCompletedStateId,
) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ElevatedButton.icon(
        onPressed: () => onTakeOrder(order['id'].toString()),
        icon: const Icon(Icons.check),
        label: const Text('Tomar Pedido'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      ),
      if (order['estado_id'] == employeePendingStateId)
        ElevatedButton.icon(
          onPressed:
              () => onUpdateOrderStatus(
                order['id'].toString(),
                employeeInProcessStateId,
                userProvider.currentUser?['id']?.toString() ?? '',
              ),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Iniciar Proceso'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
      if (order['estado_id'] == employeeInProcessStateId)
        ElevatedButton.icon(
          onPressed:
              () => onUpdateOrderStatus(
                order['id'].toString(),
                employeeCompletedStateId,
                userProvider.currentUser?['id']?.toString() ?? '',
              ),
          icon: const Icon(Icons.check_circle),
          label: const Text('Completar'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
      ElevatedButton.icon(
        onPressed: () => onShowCancelDialog(order['id'].toString()),
        icon: const Icon(Icons.cancel),
        label: const Text('Cancelar'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      ),
    ],
  );
}
