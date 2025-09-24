import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:barrilfood_app/providers/orders_provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';
import 'package:barrilfood_app/providers/user_provider.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> 
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;
  String _searchQuery = '';
  String? _selectedStatusFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadInitialData();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      // Cargar perfil del empleado
      userProvider.loadUserProfile();
      // Cargar todos los pedidos
      ordersProvider.loadPendingOrdersWithProducts(authProvider.token!);
    }
  }

  void _refreshData() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      userProvider.loadUserProfile();
      ordersProvider.loadPendingOrdersWithProducts(authProvider.token!);
    }
  }

  String _getProductsDisplay(dynamic order) {
    if (order.productos != null && order.productos.isNotEmpty) {
      final product = order.productos[0];
      final productName = product.nombre ?? 'Producto';
      if (order.productos.length > 1) {
        return '$productName (+${order.productos.length - 1})';
      }
      return productName;
    }
    return 'Sin productos';
  }

  List _getFilteredOrders(List orders) {
    var filteredOrders = orders;
    
    if (_selectedStatusFilter != null) {
      filteredOrders = filteredOrders.where((order) => 
        (order.estadoNombre ?? order.estado ?? '').toLowerCase() == _selectedStatusFilter!.toLowerCase()
      ).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) =>
        order.id.toLowerCase().contains(_searchQuery) ||
        _getProductsDisplay(order).toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    return filteredOrders;
  }

  // Obtener pedidos asignados al empleado actual
  List _getMyOrders(OrdersProvider ordersProvider, AuthProvider authProvider) {
    final userId = authProvider.currentUser?.fullName;
    if (userId == null) return [];
    
    return ordersProvider.orders.where((order) {
      // Verificar si el pedido está asignado a este empleado
      // Puedes ajustar esta lógica según cómo se asignen los pedidos
      return order.repartidor == userId || 
             (order.cliente == userId && authProvider.userRole == 2);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer3<OrdersProvider, AuthProvider, UserProvider>(
        builder: (context, ordersProvider, authProvider, userProvider, child) {
          final userName = userProvider.currentUser?['nombre'] ?? 
                          authProvider.currentUser?.fullName ?? 
                          'Empleado';
          final userEmail = userProvider.currentUser?['email'] ?? 
                          authProvider.currentUser?.email ?? 
                          'empleado@barrilfood.com';
          
          return Column(
            children: [
              // Header con información del empleado
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hola, $userName',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy', 'es').format(DateTime.now()),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: ordersProvider.isLoading ? null : _refreshData,
                                  icon: ordersProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.refresh, color: Colors.white),
                                ),
                                IconButton(
                                  onPressed: () {
                                    authProvider.logout();

                                    
                                  },
                                  icon: const Icon(Icons.logout, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Estadísticas rápidas
                        _buildQuickStats(ordersProvider, authProvider),
                        
                        const SizedBox(height: 20),
                        
                        // Tabs
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            labelColor: const Color(0xFF4CAF50),
                            unselectedLabelColor: Colors.white70,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: 'Disponibles'),
                              Tab(text: 'Mis Pedidos'),
                              Tab(text: 'Perfil'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Contenido de las tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAvailableOrdersTab(ordersProvider, authProvider),
                    _buildMyOrdersTab(ordersProvider, authProvider),
                    _buildProfileTab(userProvider, authProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(OrdersProvider ordersProvider, AuthProvider authProvider) {
    final myOrders = _getMyOrders(ordersProvider, authProvider);
    final pendingCount = myOrders.where((o) => 
      (o.estadoNombre ?? o.estado ?? '').toLowerCase() == 'confirmado').length;
    final inProgressCount = myOrders.where((o) => 
      (o.estadoNombre ?? o.estado ?? '').toLowerCase() == 'en_preparacion').length;
    final completedToday = myOrders.where((o) {
      final status = (o.estadoNombre ?? o.estado ?? '').toLowerCase();
      if (status != 'listo_para_entrega' && status != 'entregado') return false;
      try {
        final orderDate = DateTime.parse(o.fechaPedido);
        final now = DateTime.now();
        return orderDate.day == now.day && 
               orderDate.month == now.month && 
               orderDate.year == now.year;
      } catch (_) {
        return false;
      }
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Pendientes', pendingCount.toString(), Icons.pending_actions),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('En Proceso', inProgressCount.toString(), Icons.restaurant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Hoy', completedToday.toString(), Icons.today),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableOrdersTab(OrdersProvider ordersProvider, AuthProvider authProvider) {
    // Filtrar pedidos confirmados que pueden ser tomados por empleados
    final availableOrders = ordersProvider.orders.where((order) {
      final status = (order.estadoNombre ?? order.estado ?? '').toLowerCase();
      // Mostrar pedidos confirmados que aún no están en preparación
      return status == 'confirmado' || status == 'pendiente';
    }).toList();

    if (ordersProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
    }

    if (availableOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No hay pedidos disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Los nuevos pedidos aparecerán aquí'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableOrders.length,
      itemBuilder: (context, index) {
        final order = availableOrders[index];
        return _buildOrderCard(
          order,
          isAvailable: true,
          onAction: () => _processOrder(order.id, ordersProvider, authProvider),
        );
      },
    );
  }

  Widget _buildMyOrdersTab(OrdersProvider ordersProvider, AuthProvider authProvider) {
    final myOrders = _getFilteredOrders(_getMyOrders(ordersProvider, authProvider));

    if (ordersProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
    }

    return Column(
      children: [
        // Barra de búsqueda y filtros
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar pedidos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todos', null),
                    _buildFilterChip('Confirmados', 'confirmado'),
                    _buildFilterChip('En Preparación', 'en_preparacion'),
                    _buildFilterChip('Listos', 'listo_para_entrega'),
                  ].map((chip) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: chip,
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
        
        // Lista de pedidos
        Expanded(
          child: myOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _selectedStatusFilter != null
                            ? 'No se encontraron pedidos'
                            : 'No tienes pedidos asignados',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _searchQuery.isNotEmpty || _selectedStatusFilter != null
                            ? 'Intenta cambiar los filtros'
                            : 'Procesa pedidos de la pestaña "Disponibles"',
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: myOrders.length,
                  itemBuilder: (context, index) {
                    final order = myOrders[index];
                    return _buildOrderCard(
                      order,
                      isAvailable: false,
                      onAction: () => _updateOrderStatus(order, ordersProvider, authProvider),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(UserProvider userProvider, AuthProvider authProvider) {
    final user = userProvider.currentUser;
    final userName = user?['nombre'] ?? authProvider.currentUser?.nombre ?? 'Empleado';
    final userEmail = user?['email'] ?? authProvider.currentUser?.email ?? 'empleado@barrilfood.com';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar y nombre
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF4CAF50),
                  child: Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  userEmail,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Información del empleado
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Información',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (user != null) ...[
                  /**construimos la informacion del usuario */
                  _buildInfoRow('Nombre', user['nombre'] ?? 'N/A'),
                  _buildInfoRow('Apellido', user['apellido'] ?? 'N/A'),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botones de acción
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showChangePasswordDialog(context),
                  icon: const Icon(Icons.lock),
                  label: const Text('Cambiar Contraseña'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, authProvider),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, {
    required bool isAvailable,
    required VoidCallback onAction,
  }) {
    final status = (order.estadoNombre ?? order.estado ?? '').toLowerCase();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(order.estadoNombre ?? order.estado ?? 'desconocido'),
                  ],
                ),
                Text(
                  DateFormat('HH:mm').format(DateTime.parse(order.fechaPedido)),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Productos
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 16, color: Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getProductsDisplay(order),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Total y cantidad
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                if (order.productos != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${order.productos.length} items',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(
                  isAvailable ? Icons.assignment_turned_in : 
                  status == 'confirmado' ? Icons.restaurant :
                  status == 'en_preparacion' ? Icons.check_circle :
                  Icons.info,
                  size: 18,
                ),
                label: Text(
                  isAvailable ? 'Procesar Pedido' :
                  status == 'confirmado' ? 'Iniciar Preparación' :
                  status == 'en_preparacion' ? 'Marcar como Listo' :
                  'Ver Detalles',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: 
                    isAvailable ? const Color(0xFF4CAF50) :
                    status == 'confirmado' ? Colors.orange :
                    status == 'en_preparacion' ? Colors.green :
                    Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _selectedStatusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? status : null;
        });
      },
      selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
      checkmarkColor: const Color(0xFF4CAF50),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pendiente':
        color = Colors.amber;
        text = 'Pendiente';
        icon = Icons.schedule;
        break;
      case 'confirmado':
        color = Colors.blue;
        text = 'Confirmado';
        icon = Icons.check_circle;
        break;
      case 'en_preparacion':
        color = Colors.orange;
        text = 'Preparando';
        icon = Icons.restaurant;
        break;
      case 'listo_para_entrega':
        color = Colors.green;
        text = 'Listo';
        icon = Icons.done_all;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _processOrder(String orderId, OrdersProvider ordersProvider, AuthProvider authProvider) async {
    if (!mounted) return;
    
    // Cambiar el estado a "en_preparacion"
    if (authProvider.token != null) {
      final success = await ordersProvider.updateOrderStatus(
        orderId, 
        3, // en_preparacion
        authProvider.token!,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Pedido en preparación' : 'Error al procesar pedido'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      
      if (success) {
        _tabController.animateTo(1); // Cambiar a "Mis Pedidos"
      }
    }
  }

  void _updateOrderStatus(dynamic order, OrdersProvider ordersProvider, AuthProvider authProvider) async {
    if (!mounted) return;
    
    final status = (order.estadoNombre ?? order.estado ?? '').toLowerCase();
    int newStatusId;
    String message;
    
    switch (status) {
      case 'confirmado':
        newStatusId = 3; // en_preparacion
        message = 'Pedido en preparación';
        break;
      case 'en_preparacion':
        newStatusId = 4; // listo_para_entrega
        message = 'Pedido marcado como listo';
        break;
      default:
        return; // No hacer nada para otros estados
    }
    
    if (authProvider.token != null) {
      final success = await ordersProvider.updateOrderStatus(
        order.id,
        newStatusId,
        authProvider.token!,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? message : 'Error al actualizar'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: const Text('Esta función estará disponible próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}