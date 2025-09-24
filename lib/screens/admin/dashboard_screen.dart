import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:barrilfood_app/providers/orders_provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;
  String? _selectedStatusFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      // Usar addPostFrameCallback para evitar setState durante build
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
    
    if (authProvider.token != null) {
      ordersProvider.loadPendingOrdersWithProducts(authProvider.token!);
    }
  }

  void _refreshData() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      ordersProvider.refreshOrders(authProvider.token!);
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
        (order.estadoNombre ?? '').toLowerCase() == _selectedStatusFilter!.toLowerCase()
      ).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) =>
        order.id.toLowerCase().contains(_searchQuery) ||
        (order.estadoNombre ?? '').toLowerCase().contains(_searchQuery) ||
        _getProductsDisplay(order).toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    return filteredOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer2<OrdersProvider, AuthProvider>(
        builder: (context, ordersProvider, authProvider, child) {
          return Column(
            children: [
              // Header personalizado con gradiente
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF8C00),
                      Color(0xFFFF6B35),
                    ],
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
                        // Título y fecha
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Panel de Administración',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('EEEE, d MMMM yyyy', 'es')
                                      .format(DateTime.now()),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            // Botón de refresh
                            Material(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: ordersProvider.isLoading
                                    ? null
                                    : () => _refreshData(),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: ordersProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Estadísticas en tiempo real
                        _buildRealTimeStats(ordersProvider),
                        
                        const SizedBox(height: 24),
                        
                        // Pestañas
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
                            indicatorPadding: const EdgeInsets.all(4),
                            labelColor: const Color(0xFFFF8C00),
                            unselectedLabelColor: Colors.white70,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.dashboard),
                                text: 'Dashboard',
                              ),
                              Tab(
                                icon: Icon(Icons.shopping_bag),
                                text: 'Gestión Pedidos',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Contenido de las pestañas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDashboardTab(ordersProvider),
                    _buildOrdersManagementTab(ordersProvider, authProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRealTimeStats(OrdersProvider ordersProvider) {
    final counts = ordersProvider.getOrdersCountByStatus();
    final todayOrders = ordersProvider.todayOrders;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Hoy',
            '${todayOrders.length}',
            Icons.today,
            Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Pendientes',
            '${counts['pendiente'] ?? 0}',
            Icons.pending_actions,
            Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'En Preparación',
            '${counts['en_preparacion'] ?? 0}',
            Icons.restaurant,
            Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'En Camino',
            '${counts['en_camino'] ?? 0}',
            Icons.delivery_dining,
            Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(OrdersProvider ordersProvider) {
    if (ordersProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF8C00),
        ),
      );
    }

    if (ordersProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${ordersProvider.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de pedidos recientes
          const Text(
            'Pedidos Recientes',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildRecentOrdersList(ordersProvider),
          
          const SizedBox(height: 32),
          
          // Gráfico de estados
          const Text(
            'Estado de Pedidos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildOrderStatusChart(ordersProvider),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersList(OrdersProvider ordersProvider) {
    final recentOrders = ordersProvider.orders.take(5).toList();
    
    if (recentOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No hay pedidos registrados',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header de la tabla
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Productos', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          
          // Filas de pedidos
          ...recentOrders.asMap().entries.map((entry) {
            final index = entry.key;
            final order = entry.value;
            final isLast = index == recentOrders.length - 1;
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: isLast ? null : Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      order.id.substring(0, 8),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      _getProductsDisplay(order),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildStatusBadge(order.estadoNombre ?? 'desconocido'),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderStatusChart(OrdersProvider ordersProvider) {
    final counts = ordersProvider.getOrdersCountByStatus();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              _buildStatusChartItem('Pendientes', counts['pendiente'] ?? 0, Colors.amber),
              const SizedBox(width: 16),
              _buildStatusChartItem('Confirmados', counts['confirmado'] ?? 0, Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusChartItem('En Preparación', counts['en_preparacion'] ?? 0, Colors.orange),
              const SizedBox(width: 16),
              _buildStatusChartItem('En Camino', counts['en_camino'] ?? 0, Colors.purple),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusChartItem('Entregados', counts['entregado'] ?? 0, Colors.green),
              const SizedBox(width: 16),
              _buildStatusChartItem('Cancelados', counts['cancelado'] ?? 0, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChartItem(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersManagementTab(OrdersProvider ordersProvider, AuthProvider authProvider) {
    if (ordersProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF8C00),
        ),
      );
    }

    if (ordersProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${ordersProvider.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Filtros
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por ID o producto...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFFF8C00)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text('Estado'),
                    value: _selectedStatusFilter,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos')),
                      DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
                      DropdownMenuItem(value: 'confirmado', child: Text('Confirmados')),
                      DropdownMenuItem(value: 'en_preparacion', child: Text('En Preparación')),
                      DropdownMenuItem(value: 'en_camino', child: Text('En Camino')),
                      DropdownMenuItem(value: 'entregado', child: Text('Entregados')),
                      DropdownMenuItem(value: 'cancelado', child: Text('Cancelados')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatusFilter = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Lista de pedidos
          Expanded(
            child: _buildOrdersList(ordersProvider, authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrdersProvider ordersProvider, AuthProvider authProvider) {
    final filteredOrders = _getFilteredOrders(ordersProvider.orders);

    if (filteredOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron pedidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Intenta cambiar los filtros de búsqueda'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order, ordersProvider, authProvider);
      },
    );
  }

  Widget _buildOrderCard(order, OrdersProvider ordersProvider, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C00).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.id.substring(0, 8),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8C00),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(order.estadoNombre ?? 'desconocido'),
                  ],
                ),
                Text(
                  DateFormat('dd/MM HH:mm').format(DateTime.parse(order.fechaPedido)),
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información de productos y pago
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag, size: 18, color: Color(0xFFFF8C00)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getProductsDisplay(order),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pago: ${order.metodoPagoNombre ?? 'No especificado'}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (order.productos != null && order.productos.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${order.productos.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Total del pedido y botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 18, color: Color(0xFFFF8C00)),
                    const SizedBox(width: 8),
                    Text(
                      'Total: \$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                  ],
                ),
                
                // Botones de acción
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showOrderDetails(order, ordersProvider, authProvider);
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Ver'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF8C00),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    _buildActionButton(order, ordersProvider, authProvider),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(order, OrdersProvider ordersProvider, AuthProvider authProvider) {
    final status = (order.estadoNombre ?? '').toLowerCase();
    
    switch (status) {
      case 'pendiente':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order.id, 2, ordersProvider, authProvider),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Confirmar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      case 'confirmado':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order.id, 3, ordersProvider, authProvider),
          icon: const Icon(Icons.restaurant, size: 18),
          label: const Text('Preparar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      case 'en_preparacion':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order.id, 4, ordersProvider, authProvider),
          icon: const Icon(Icons.done, size: 18),
          label: const Text('Listo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      case 'listo_para_entrega':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order.id, 5, ordersProvider, authProvider),
          icon: const Icon(Icons.delivery_dining, size: 18),
          label: const Text('Enviar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      case 'en_camino':
        return ElevatedButton.icon(
          onPressed: () => _updateOrderStatus(order.id, 6, ordersProvider, authProvider),
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Entregado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _updateOrderStatus(String orderId, int statusId, OrdersProvider ordersProvider, AuthProvider authProvider) async {
    if (!mounted) return;
    
    if (authProvider.token != null) {
      final success = await ordersProvider.updateOrderStatus(orderId, statusId, authProvider.token!);
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estado del pedido actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${ordersProvider.error ?? 'Error desconocido'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOrderDetails(order, OrdersProvider ordersProvider, AuthProvider authProvider) {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con información básica
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pedido #${order.id.substring(0, 8)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildStatusBadge(order.estadoNombre ?? 'desconocido'),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          iconSize: 28,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Información del pedido
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('ID Completo', order.id),
                          const Divider(),
                          _buildDetailRow('Fecha', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order.fechaPedido))),
                          const Divider(),
                          _buildDetailRow('Método de Pago', order.metodoPagoNombre ?? 'No especificado'),
                          const Divider(),
                          _buildDetailRow('Total', '\$${order.total.toStringAsFixed(2)}', isHighlight: true),
                        ],
                      ),
                    ),
                    
                    // Lista de productos si está disponible
                    if (order.productos != null && order.productos.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Productos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8C00).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${order.productos.length} items',
                              style: const TextStyle(
                                color: Color(0xFFFF8C00),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...order.productos.map<Widget>((producto) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8C00).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${producto.cantidad}x',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF8C00),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (producto.descripcion != null && producto.descripcion.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          producto.descripcion,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '\$${(producto.subtotal* producto.cantidad).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFFFF8C00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ] else ...[
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No hay productos en este pedido',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: isHighlight ? 18 : 14,
              color: isHighlight ? const Color(0xFFFF8C00) : Colors.black87,
            ),
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
      selectedColor: const Color(0xFFFF8C00).withOpacity(0.2),
      checkmarkColor: const Color(0xFFFF8C00),
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
        text = 'En Preparación';
        icon = Icons.restaurant;
        break;
      case 'listo_para_entrega':
        color = Colors.green;
        text = 'Listo';
        icon = Icons.done_all;
        break;
      case 'en_camino':
        color = Colors.purple;
        text = 'En Camino';
        icon = Icons.delivery_dining;
        break;
      case 'entregado':
        color = Colors.green.shade700;
        text = 'Entregado';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelado':
        color = Colors.red;
        text = 'Cancelado';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = 'Desconocido';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}