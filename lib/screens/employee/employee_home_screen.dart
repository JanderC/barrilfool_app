import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:barrilfood_app/providers/user_provider.dart'; // Changed to UserProvider
import 'package:barrilfood_app/providers/auth_provider.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      provider.loadUserProfile(); // Load user (employee) profile
      provider.loadUserOrders(); // Load orders assigned to this user (employee)
    });
  }

  static const List<String> _titles = [
    'Inicio - Empleado',
    'Mis Pedidos',
    'Mi Perfil'
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
    BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Pedidos'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
  ];

  // Helper to map UserProvider estado_id to logical states for Employee
  // Esto define qué estado de UserProvider es "Pendiente" para que el empleado lo tome.
  static const int employeePendingStateId = 2; // UserProvider's 'Confirmado'
  static const int employeeInProcessStateId = 3; // UserProvider's 'En Proceso'
  static const int employeeCompletedStateId = 4; // UserProvider's 'Terminado'
  static const int employeeCancelledStateId = 7; // UserProvider's 'Cancelado'


  void _reloadData() {
    final provider = Provider.of<UserProvider>(context, listen: false);
    provider.loadUserProfile();
    provider.loadUserOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFFFF8C00),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeScreen(),
          _buildOrdersScreen(),
          _buildProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF8C00),
        unselectedItemColor: Colors.grey,
        items: _navItems,
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.userOrders.isEmpty && provider.currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null && provider.userOrders.isEmpty && provider.currentUser == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error al cargar datos: ${provider.error}', textAlign: TextAlign.center),
            )
          );
        }

        final orders = provider.userOrders;
        final user = provider.currentUser;
        final stats = provider.getOrderStatistics();

        // Orders pending for the employee to take action (e.g., "Tomar Pedido")
        final pendingForEmployee = stats['confirmados'] ?? 0; // estado_id = 2
        // Orders currently being processed by the employee
        final inProcessOrders = stats['en_proceso'] ?? 0; // estado_id = 3
        
        final completedToday = orders.where((o) {
          if (o['estado_id'] != employeeCompletedStateId) return false;
          // Try to parse 'updated_at' or 'fecha' for completion date
          String? dateString = o['updated_at'] as String? ?? o['fecha'] as String?;
          if (dateString == null) return false;
          try {
            final orderDate = DateTime.parse(dateString);
            final now = DateTime.now();
            return orderDate.year == now.year &&
                   orderDate.month == now.month &&
                   orderDate.day == now.day;
          } catch (e) {
            return false; 
          }
        }).length;

        // Upcoming orders are those confirmed and waiting for the employee to start processing
        final upcomingOrders = orders.where((o) => o['estado_id'] == employeePendingStateId).take(3).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(user),
              const SizedBox(height: 24),
              _buildStatsGrid(pendingForEmployee, inProcessOrders, completedToday, stats['total'] ?? 0),
              const SizedBox(height: 24),
              _buildUpcomingOrders(upcomingOrders),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(Map<String, dynamic>? user) {
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
                    '¡Hola, ${user?['nombre'] ?? 'Empleado'}!', // Assuming 'nombre' field in currentUser
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy', 'es').format(DateTime.now()),
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

  Widget _buildStatsGrid(int pending, int inProcess, int completed, int total) {
    final statsData = [
      {'title': 'Pendientes por Tomar', 'value': '$pending', 'icon': Icons.pending_actions, 'color': Colors.orange},
      {'title': 'En Proceso', 'value': '$inProcess', 'icon': Icons.schedule, 'color': Colors.blue},
      {'title': 'Completados Hoy', 'value': '$completed', 'icon': Icons.check_circle, 'color': Colors.green},
      {'title': 'Total Asignados', 'value': '$total', 'icon': Icons.assignment, 'color': Colors.purple},
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

  Widget _buildUpcomingOrders(List<Map<String, dynamic>> upcomingOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Próximos Pedidos (Por Tomar)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (upcomingOrders.isEmpty)
          _buildEmptyState(Icons.assignment_turned_in, 'No tienes pedidos pendientes por tomar')
        else
          ...upcomingOrders.map((order) => _buildOrderCard(order, isPreview: true)),
      ],
    );
  }

  Widget _buildOrdersScreen() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.userOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
         if (provider.error != null && provider.userOrders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error al cargar pedidos: ${provider.error}', textAlign: TextAlign.center),
            )
          );
        }

        final orders = provider.userOrders;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Todos Mis Pedidos Asignados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => provider.loadUserOrders(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (orders.isEmpty)
                _buildEmptyState(Icons.inbox, 'No tienes pedidos asignados actualmente')
              else
                ...orders.map((order) => _buildOrderCard(order)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileScreen() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
        }
        if (provider.error != null && provider.currentUser == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error al cargar perfil: ${provider.error}', textAlign: TextAlign.center),
            )
          );
        }

        final user = provider.currentUser;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildProfileInfo(user),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showChangePasswordDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cambiar Contraseña'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? user) {
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
              user?['nombre'] ?? 'Nombre no disponible', // Assuming 'nombre'
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Removed 'puesto' as it's not standard in UserProvider.currentUser
            // If you have a role field, you can add it here:
            // const SizedBox(height: 8),
            // Text(
            //   user?['role'] ?? 'Usuario', // Example if 'role' field exists
            //   style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(Map<String, dynamic>? user) {
    final List<Map<String, dynamic>> infoItems = [];
    if (user != null) {
      infoItems.add({'icon': Icons.badge, 'label': 'ID Usuario', 'value': user['id']?.toString() ?? 'N/A'});
      if (user['telefono'] != null) {
        infoItems.add({'icon': Icons.phone, 'label': 'Teléfono', 'value': user['telefono']});
      }
      if (user['email'] != null) {
        infoItems.add({'icon': Icons.email, 'label': 'Email', 'value': user['email']});
      }
      if (user['fecha_ingreso'] != null) { // Assuming 'fecha_ingreso' might exist
        try {
           infoItems.add({
            'icon': Icons.calendar_today,
            'label': 'Fecha de Registro', // Changed from Ingreso for generality
            'value': DateFormat('d MMMM yyyy', 'es').format(DateTime.parse(user['fecha_ingreso']))
          });
        } catch(e) {
          infoItems.add({'icon': Icons.calendar_today, 'label': 'Fecha de Registro', 'value': user['fecha_ingreso']});
        }
      } else if (user['created_at'] != null) { // Fallback to created_at
         try {
           infoItems.add({
            'icon': Icons.calendar_today,
            'label': 'Fecha de Creación',
            'value': DateFormat('d MMMM yyyy', 'es').format(DateTime.parse(user['created_at']))
          });
        } catch(e) {
          infoItems.add({'icon': Icons.calendar_today, 'label': 'Fecha de Creación', 'value': user['created_at']});
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
            const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (infoItems.isEmpty) const Text("No hay información de perfil disponible."),
            ...infoItems.map((item) => _buildInfoRow(
              item['icon'] as IconData,
              item['label'] as String,
              item['value'] as String,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
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
                Expanded(child: Text(title, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2,)),
              ],
            ),
            //const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, {bool isPreview = false}) {
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
                Text('Pedido #${order['id']?.toString() ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildStatusBadge(order['estado_id'] as int?),
              ],
            ),
            const SizedBox(height: 8),
            Text(order['cliente_nombre'] ?? order['cliente'] ?? 'Cliente desconocido', style: const TextStyle(fontSize: 16)), // Assuming 'cliente_nombre' or 'cliente'
            const SizedBox(height: 4),
            Text(
              'Total: \$${double.tryParse(order['total']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(color: Color(0xFFFF8C00), fontWeight: FontWeight.bold),
            ),
            if (!isPreview) ...[
              const SizedBox(height: 16),
              if (order['items'] != null && (order['items'] as List).isNotEmpty)
                _buildProductsList(order['items'] as List<dynamic>),
              if (order['productos'] != null && (order['productos'] as List).isNotEmpty)
                _buildProductsList(order['productos'] as List<dynamic>),

              if (order['estado_id'] == employeePendingStateId || order['estado_id'] == employeeInProcessStateId) ...[
                const SizedBox(height: 16),
                _buildOrderActions(order),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList(List<dynamic> productos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...productos.map((producto) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('${producto['cantidad'] ?? 1}x ${producto['nombre'] ?? producto['product_name'] ?? 'Producto desconocido'}')), // Assuming 'product_name' or 'nombre'
              Text('\$${double.tryParse(producto['precio']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildOrderActions(Map<String, dynamic> order) {
    final orderId = order['id']?.toString();
    if (orderId == null) return const SizedBox.shrink();

    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            if (order['estado_id'] == employeePendingStateId) ...[ // Status: "Confirmado", employee action: "Tomar Pedido"
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.isUpdatingOrder 
                    ? null 
                    : () => _takeOrder(orderId),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: provider.isUpdatingOrder 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,))
                    : const Text('Tomar Pedido'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (order['estado_id'] == employeeInProcessStateId) ...[ // Status: "En Proceso", employee action: "Marcar Terminado"
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.isUpdatingOrder 
                    ? null 
                    : () => _updateOrderStatus(orderId, employeeCompletedStateId, 'Pedido marcado como terminado'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: provider.isUpdatingOrder 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,))
                    : const Text('Marcar Terminado'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: OutlinedButton(
                onPressed: provider.isUpdatingOrder ? null : () => _showCancelOrderDialog(orderId),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(int? estadoId) {
    final Map<int, Map<String, dynamic>> statusMap = {
      1: {'color': Colors.grey, 'text': 'Pendiente Cliente'}, // UserProvider: Pendiente
      employeePendingStateId: {'color': Colors.orange, 'text': 'Por Tomar'},    // UserProvider: Confirmado (Employee: "Asignado/Pendiente de tomar")
      employeeInProcessStateId: {'color': Colors.blue, 'text': 'En Proceso'}, // UserProvider: En Proceso
      employeeCompletedStateId: {'color': Colors.green, 'text': 'Terminado'},  // UserProvider: Terminado
      5: {'color': Colors.teal, 'text': 'Entregado'}, // Example, if exists
      6: {'color': Colors.brown, 'text': 'Pagado'}, // Example, if exists
      employeeCancelledStateId: {'color': Colors.red, 'text': 'Cancelado'},   // UserProvider: Cancelado
    };
    
    final statusInfo = statusMap[estadoId] ?? {'color': Colors.black, 'text': 'Desconocido (${estadoId ?? ''})'};
    final color = statusInfo['color'] as Color;
    final text = statusInfo['text'] as String;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Card(
      elevation: 0, // Less pronounced for empty states usually
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  void _takeOrder(String orderId) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    try {
      await provider.takeOrder(orderId); // UserProvider.takeOrder reloads orders
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido tomado exitosamente'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al tomar el pedido: ${provider.error ?? e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _updateOrderStatus(String orderId, int newEstadoId, String successMessage) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    try {
      await provider.updateOrderStatus(orderId, newEstadoId); // UserProvider.updateOrderStatus reloads orders
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el pedido: ${provider.error ?? e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCancelOrderDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Pedido'),
        content: const Text('¿Estás seguro de que quieres cancelar este pedido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(orderId, employeeCancelledStateId, 'Pedido cancelado exitosamente');
            },
            child: const Text('Sí, Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final controllers = {
      'current': TextEditingController(),
      'new': TextEditingController(),
      'confirm': TextEditingController(),
    };
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controllers['current'],
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña actual', border: OutlineInputBorder()),
                validator: (value) => (value?.isEmpty ?? true) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controllers['new'],
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nueva contraseña', border: OutlineInputBorder()),
                 validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  if (value!.length < 6) return 'Mínimo 6 caracteres'; // Example validation
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controllers['confirm'],
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirmar nueva contraseña', border: OutlineInputBorder()),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Campo requerido';
                  if (value != controllers['new']!.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          Consumer<UserProvider>( // Use UserProvider here
            builder: (context, provider, child) => ElevatedButton(
              onPressed: provider.isLoading ? null : () async { // Check UserProvider's isLoading
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    await provider.changePassword(controllers['current']!.text, controllers['new']!.text);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contraseña actualizada exitosamente'), backgroundColor: Colors.green),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cambiar contraseña: ${provider.error ?? e.toString()}'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00), foregroundColor: Colors.white),
              child: provider.isLoading  // Check UserProvider's isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,))
                : const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // It's good practice for AuthProvider.logout to also clear UserProvider data
              Provider.of<UserProvider>(context, listen: false).clearData(); 
              Provider.of<AuthProvider>(context, listen: false).logout();
              // Navigation to login screen should be handled by the AuthProvider listener in main.dart or a wrapper widget
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}