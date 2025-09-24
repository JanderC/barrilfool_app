import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:barrilfood_app/providers/orders_provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';

class OrdersAdminScreen extends StatefulWidget {
  const OrdersAdminScreen({super.key});

  @override
  State<OrdersAdminScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersAdminScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedStatusFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;

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
        _loadData();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      ordersProvider.loadOrders(authProvider.token!);
    }
  }

  void _refreshOrders() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      ordersProvider.loadOrders(authProvider.token!);
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

  List _getOrdersByStatus(List orders, String status) {
    return orders.where((order) => 
      (order.estadoNombre ?? '').toLowerCase() == status.toLowerCase()
    ).toList();
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
        (order.metodoPagoNombre ?? '').toLowerCase().contains(_searchQuery)
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
              // Header
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8C00), Color(0xFFFF6B35)],
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
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gestión de Pedidos',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Administra los pedidos',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: ordersProvider.isLoading ? null : _refreshOrders,
                              icon: ordersProvider.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  : const Icon(Icons.refresh, color: Colors.white),
                            ),
                          ],
                        ),
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
                            labelColor: const Color(0xFFFF8C00),
                            unselectedLabelColor: Colors.white70,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: 'Pendientes'),
                              Tab(text: 'Todos'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Contenido
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingOrdersTab(ordersProvider, authProvider),
                    _buildAllOrdersTab(ordersProvider, authProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPendingOrdersTab(OrdersProvider ordersProvider, AuthProvider authProvider) {
    if (ordersProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
    }

    if (ordersProvider.error != null) {
      return _buildErrorWidget(ordersProvider.error!);
    }

    final pendingOrders = _getOrdersByStatus(ordersProvider.orders, 'pendiente');
    final confirmOrders = _getOrdersByStatus(ordersProvider.orders, 'confirmado');
    final preparationOrders = _getOrdersByStatus(ordersProvider.orders, 'en_preparacion');
    final readyOrders = _getOrdersByStatus(ordersProvider.orders, 'listo_para_entrega');

    final allPendingOrders = [...pendingOrders, ...confirmOrders, ...preparationOrders, ...readyOrders];

    if (allPendingOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay pedidos pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Todos los pedidos están procesados'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allPendingOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(allPendingOrders[index], ordersProvider, authProvider);
      },
    );
  }

  Widget _buildAllOrdersTab(OrdersProvider ordersProvider, AuthProvider authProvider) {
    if (ordersProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
    }

    if (ordersProvider.error != null) {
      return _buildErrorWidget(ordersProvider.error!);
    }

    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Búsqueda
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
              const SizedBox(height: 16),
              // Filtros de estado
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todos', null),
                    _buildFilterChip('Pendientes', 'pendiente'),
                    _buildFilterChip('Confirmados', 'confirmado'),
                    _buildFilterChip('En Preparación', 'en_preparacion'),
                    _buildFilterChip('Listos', 'listo_para_entrega'),
                    _buildFilterChip('En Camino', 'en_camino'),
                    _buildFilterChip('Entregados', 'entregado'),
                    _buildFilterChip('Cancelados', 'cancelado'),
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
          child: _buildOrdersList(ordersProvider, authProvider),
        ),
      ],
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

  Widget _buildOrdersList(OrdersProvider ordersProvider, AuthProvider authProvider) {
    final filteredOrders = _getFilteredOrders(ordersProvider.orders);

    if (filteredOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No se encontraron pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Intenta cambiar los filtros de búsqueda'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(filteredOrders[index], ordersProvider, authProvider);
      },
    );
  }

  Widget _buildOrderCard(dynamic order, OrdersProvider ordersProvider, AuthProvider authProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                        color: const Color(0xFFFF8C00).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.id.substring(0, 8),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8C00),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(order.estadoNombre ?? 'desconocido'),
                  ],
                ),
                Text(
                  DateFormat('dd/MM HH:mm').format(DateTime.parse(order.fechaPedido)),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag, size: 16, color: Color(0xFFFF8C00)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getProductsDisplay(order),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pago: ${order.metodoPagoNombre ?? 'No especificado'}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: \$${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF2D3748),
                        ),
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
                      '${order.productos.length} productos',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showOrderDetails(order),
                    child: const Text('Ver Detalles'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildActionButton(order, ordersProvider, authProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(dynamic order, OrdersProvider ordersProvider, AuthProvider authProvider) {
    final status = (order.estadoNombre ?? '').toLowerCase();
    
    switch (status) {
      case 'pendiente':
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, 2, 'confirmado', ordersProvider, authProvider),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        );
      case 'confirmado':
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, 3, 'en_preparacion', ordersProvider, authProvider),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Preparar', style: TextStyle(color: Colors.white)),
        );
      case 'en_preparacion':
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, 4, 'listo_para_entrega', ordersProvider, authProvider),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Marcar Listo', style: TextStyle(color: Colors.white)),
        );
      case 'listo_para_entrega':
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, 5, 'en_camino', ordersProvider, authProvider),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Enviar', style: TextStyle(color: Colors.white)),
        );
      case 'en_camino':
        return ElevatedButton(
          onPressed: () => _updateOrderStatus(order.id, 6, 'entregado', ordersProvider, authProvider),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
          child: const Text('Entregado', style: TextStyle(color: Colors.white)),
        );
      default:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('Sin acciones', style: TextStyle(color: Colors.grey)),
          ),
        );
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
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
        text = 'En Preparación';
        break;
      case 'listo_para_entrega':
        color = Colors.green;
        text = 'Listo';
        break;
      case 'en_camino':
        color = Colors.purple;
        text = 'En Camino';
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  void _updateOrderStatus(String orderId, int statusId, String statusName, OrdersProvider ordersProvider, AuthProvider authProvider) async {
    if (authProvider.token != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Actualizando a $statusName...'),
          backgroundColor: const Color(0xFFFF8C00),
        ),
      );

      final success = await ordersProvider.updateOrderStatus(orderId, statusId, authProvider.token!);
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido actualizado a $statusName'),
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

  void _showOrderDetails(dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido ${order.id.substring(0, 8)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const Divider(),
            
            // Información del pedido
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('ID Completo'),
              subtitle: Text(order.id),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Método de Pago'),
              subtitle: Text(order.metodoPagoNombre ?? 'No especificado'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Total'),
              subtitle: Text('\$${order.total.toStringAsFixed(2)}'),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Fecha'),
              subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(order.fechaPedido))),
            ),
            
            const SizedBox(height: 16),
            
            // Productos
            if (order.productos != null && order.productos.isNotEmpty) ...[
              const Text('Productos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: order.productos.length,
                  itemBuilder: (context, index) {
                    final producto = order.productos[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${producto.cantidad}'),
                        ),
                        title: Text(producto.nombre),
                        subtitle: producto.descripcion != null && producto.descripcion.isNotEmpty
                            ? Text(producto.descripcion)
                            : null,
                        trailing: Text('\$${producto.subtotal.toStringAsFixed(2)}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Error al cargar los datos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshOrders,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}