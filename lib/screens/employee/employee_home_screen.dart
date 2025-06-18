import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:barrilfood_app/providers/user_provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';
import 'package:barrilfood_app/widgets/employee_home_widgets.dart';
import 'package:barrilfood_app/widgets/employee_dialogs.dart';

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
      provider.loadUserProfile();
      provider.loadUserOrders();
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
            onPressed: () => EmployeeDialogs.showLogoutDialog(
              context,
              onLogout: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
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
        // Datos de prueba si no hay datos del servicio
        final mockUser = {
          'id': 1,
          'nombre': 'Juan Pérez',
          'telefono': '555-0123',
          'email': 'juan.perez@barrilfood.com',
          'created_at': '2024-01-15T10:30:00Z'
        };

        final mockOrders = [
          {
            'id': 1,
            'cliente_nombre': 'María García',
            'total': '45.50',
            'estado_id': employeePendingStateId,
            'items': [
              {'nombre': 'Hamburguesa Clásica', 'cantidad': 2, 'precio': '15.00'},
              {'nombre': 'Papas Fritas', 'cantidad': 1, 'precio': '8.50'},
              {'nombre': 'Coca Cola', 'cantidad': 2, 'precio': '3.50'}
            ]
          },
          {
            'id': 2,
            'cliente_nombre': 'Carlos Rodríguez',
            'total': '32.75',
            'estado_id': employeeInProcessStateId,
            'items': [
              {'nombre': 'Pizza Margherita', 'cantidad': 1, 'precio': '22.00'},
              {'nombre': 'Cerveza', 'cantidad': 2, 'precio': '5.25'}
            ]
          },
          {
            'id': 3,
            'cliente_nombre': 'Ana Martínez',
            'total': '28.00',
            'estado_id': employeeCompletedStateId,
            'updated_at': DateTime.now().toIso8601String(),
            'items': [
              {'nombre': 'Ensalada César', 'cantidad': 1, 'precio': '18.00'},
              {'nombre': 'Agua', 'cantidad': 1, 'precio': '2.00'}
            ]
          }
        ];

        // Usar datos del provider si están disponibles, sino usar datos de prueba
        final user = provider.currentUser ?? mockUser;
        final orders = provider.userOrders.isNotEmpty ? provider.userOrders : mockOrders;
        
        // Mostrar mensaje de modo demo si no hay datos reales
        final isDemoMode = provider.currentUser == null && provider.userOrders.isEmpty;

        if (provider.isLoading && provider.userOrders.isEmpty && provider.currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Calcular estadísticas
        final pendingForEmployee = orders.where((o) => o['estado_id'] == employeePendingStateId).length;
        final inProcessOrders = orders.where((o) => o['estado_id'] == employeeInProcessStateId).length;
        
        final completedToday = orders.where((o) {
          if (o['estado_id'] != employeeCompletedStateId) return false;
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

        final upcomingOrders = orders.where((o) => o['estado_id'] == employeePendingStateId).take(3).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDemoMode)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Modo Demo: Los servicios no están disponibles. Mostrando datos de prueba.',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isDemoMode) const SizedBox(height: 16),
              EmployeeHomeWidgets.buildWelcomeCard(user),
              const SizedBox(height: 24),
              EmployeeHomeWidgets.buildStatsGrid(
                pendingForEmployee, 
                inProcessOrders, 
                completedToday, 
                orders.length
              ),
              const SizedBox(height: 24),
              EmployeeHomeWidgets.buildUpcomingOrders(upcomingOrders),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersScreen() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        // Datos de prueba para pedidos
        final mockOrders = [
          {
            'id': 1,
            'cliente_nombre': 'María García',
            'total': '45.50',
            'estado_id': employeePendingStateId,
            'items': [
              {'nombre': 'Hamburguesa Clásica', 'cantidad': 2, 'precio': '15.00'},
              {'nombre': 'Papas Fritas', 'cantidad': 1, 'precio': '8.50'},
              {'nombre': 'Coca Cola', 'cantidad': 2, 'precio': '3.50'}
            ]
          },
          {
            'id': 2,
            'cliente_nombre': 'Carlos Rodríguez',
            'total': '32.75',
            'estado_id': employeeInProcessStateId,
            'items': [
              {'nombre': 'Pizza Margherita', 'cantidad': 1, 'precio': '22.00'},
              {'nombre': 'Cerveza', 'cantidad': 2, 'precio': '5.25'}
            ]
          },
          {
            'id': 3,
            'cliente_nombre': 'Ana Martínez',
            'total': '28.00',
            'estado_id': employeeCompletedStateId,
            'updated_at': DateTime.now().toIso8601String(),
            'items': [
              {'nombre': 'Ensalada César', 'cantidad': 1, 'precio': '18.00'},
              {'nombre': 'Agua', 'cantidad': 1, 'precio': '2.00'}
            ]
          },
          {
            'id': 4,
            'cliente_nombre': 'Luis Fernández',
            'total': '52.25',
            'estado_id': employeePendingStateId,
            'items': [
              {'nombre': 'Parrillada Mixta', 'cantidad': 1, 'precio': '35.00'},
              {'nombre': 'Arroz', 'cantidad': 2, 'precio': '4.50'},
              {'nombre': 'Jugo Natural', 'cantidad': 2, 'precio': '6.25'}
            ]
          }
        ];

        final orders = provider.userOrders.isNotEmpty ? provider.userOrders : mockOrders;
        final isDemoMode = provider.userOrders.isEmpty;

        if (provider.isLoading && provider.userOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

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
              if (isDemoMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Datos de prueba - Servicios no disponibles',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (orders.isEmpty)
                EmployeeHomeWidgets.buildEmptyState(Icons.inbox, 'No tienes pedidos asignados actualmente')
              else
                ...orders.map((order) => EmployeeHomeWidgets.buildOrderCard(
                  order, 
                  context, 
                  _takeOrder, 
                  _updateOrderStatus, 
                  _showCancelOrderDialog,
                  employeePendingStateId,
                  employeeInProcessStateId,
                  employeeCompletedStateId,
                  employeeCancelledStateId
                )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileScreen() {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        // Datos de prueba para el perfil
        final mockUser = {
          'id': 1,
          'nombre': 'Juan Pérez',
          'telefono': '555-0123',
          'email': 'juan.perez@barrilfood.com',
          'created_at': '2024-01-15T10:30:00Z'
        };

        final user = provider.currentUser ?? mockUser;
        final isDemoMode = provider.currentUser == null;

        if (provider.isLoading && provider.currentUser == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (isDemoMode)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Perfil de prueba - Servicios no disponibles',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isDemoMode) const SizedBox(height: 16),
              EmployeeHomeWidgets.buildProfileHeader(user),
              const SizedBox(height: 24),
              EmployeeHomeWidgets.buildProfileInfo(user),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => EmployeeDialogs.showChangePasswordDialog(context),
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

  void _takeOrder(String orderId) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    try {
      await provider.takeOrder(orderId);
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
      await provider.updateOrderStatus(orderId, newEstadoId);
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
    EmployeeDialogs.showCancelOrderDialog(
      context, 
      orderId, 
      () => _updateOrderStatus(orderId, employeeCancelledStateId, 'Pedido cancelado exitosamente')
    );
  }
}