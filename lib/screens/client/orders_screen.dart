import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:barrilfood_app/providers/orders_provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart'; // Asumiendo que tienes un AuthProvider
import 'package:barrilfood_app/models/order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    if (authProvider.token != null) {
      ordersProvider.loadPendingOrdersWithProducts(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con filtros
            _buildHeader(),
            const SizedBox(height: 16),

            // Lista de pedidos
            Expanded(
              child: Consumer<OrdersProvider>(
                builder: (context, ordersProvider, child) {
                  if (ordersProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8C00),
                      ),
                    );
                  }

                  if (ordersProvider.error != null) {
                    return _buildErrorState(ordersProvider.error!);
                  }

                  if (ordersProvider.orders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildOrdersList(ordersProvider.orders);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mis Pedidos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _showFilters,
                      icon: Icon(
                        Icons.filter_list,
                        color:
                            ordersProvider.selectedStatusFilter != null ||
                                    ordersProvider.startDateFilter != null
                                ? const Color(0xFFFF8C00)
                                : Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: _loadOrders,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ],
            ),
            if (ordersProvider.selectedStatusFilter != null ||
                ordersProvider.startDateFilter != null)
              _buildActiveFilters(ordersProvider),
          ],
        );
      },
    );
  }

  Widget _buildActiveFilters(OrdersProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (provider.selectedStatusFilter != null)
            Chip(
              label: Text(_getStatusName(provider.selectedStatusFilter!)),
              backgroundColor: const Color(0xFFFF8C00).withOpacity(0.2),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                provider.setStatusFilter(null);
                _loadOrders();
              },
            ),
          if (provider.startDateFilter != null)
            Chip(
              label: Text(
                '${DateFormat('dd/MM/yyyy').format(provider.startDateFilter!)} - ${provider.endDateFilter != null ? DateFormat('dd/MM/yyyy').format(provider.endDateFilter!) : 'Hoy'}',
              ),
              backgroundColor: const Color(0xFFFF8C00).withOpacity(0.2),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                provider.setDateFilter(null, null);
                _loadOrders();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    return RefreshIndicator(
      onRefresh: () async => _loadOrders(),
      color: const Color(0xFFFF8C00),
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildOrderCard(order),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Detalles Pedido',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(order.estado),
              ],
            ),
            const SizedBox(height: 8),

            // Fecha del pedido
            Text(
              'Fecha: ${_formatDate(order.fechaPedido)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),

            // Repartidor (si está asignado)
            if (order.repartidor != null && order.repartidor!.isNotEmpty)
              Text(
                'Repartidor: ${order.repartidor}',
                style: TextStyle(color: Colors.grey.shade700),
              ),

            const SizedBox(height: 12),

            if (order.productos != null && order.productos!.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Productos:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...order.productos!.map(
                (producto) => _buildProductItem(producto),
              ),
            ],

            // Total del pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8C00),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Botones de acción
            _buildOrderActions(order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderActions(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        
        if (order.estado.toLowerCase() == 'en_camino')
          TextButton(
            onPressed: () => _trackOrder(order.id),
            child: const Text(
              'Seguir',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        if (order.puedeSerCancelado)
          TextButton(
            onPressed: () => _cancelOrder(order),
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
        if (order.puedeSerValorado)
          TextButton(
            onPressed: () => _reviewOrder(order),
            child: const Text(
              'Valorar',
              style: TextStyle(color: Color(0xFF2196F3)),
            ),
          ),
      ],
    );
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

  // Agregar método para mostrar cada producto
  Widget _buildProductItem(OrderProduct producto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manejo mejorado de imágenes base64 o URLs
          _buildProductImage(producto.imagenUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${producto.cantidad}x ${producto.nombre}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (producto.descripcion?.isNotEmpty == true)
                  Text(
                    producto.descripcion!,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (producto.notas?.isNotEmpty == true)
                  Text(
                    'Notas: ${producto.notas!}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          Text(
            '\$${producto.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imagenUrl) {
    if (imagenUrl == null || imagenUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    if (imagenUrl.startsWith('data:image')) {
      // Es una imagen base64, mostrar placeholder
      return _buildPlaceholderImage();
    } else {
      // Es una URL normal
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imagenUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => _buildPlaceholderImage(),
        ),
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.restaurant, color: Colors.grey),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No tienes pedidos',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Tus pedidos aparecerán aquí',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error al cargar pedidos',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
            ),
            child: const Text(
              'Reintentar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => _FiltersBottomSheet(
            onApplyFilters: (statusFilter, startDate, endDate) {
              final provider = Provider.of<OrdersProvider>(
                context,
                listen: false,
              );
              provider.setStatusFilter(statusFilter);
              provider.setDateFilter(startDate, endDate);
              _loadOrders();
            },
          ),
    );
  }

  void _viewOrderDetails(String orderId) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    // Navegar a la pantalla de detalles del pedido
    Navigator.pushNamed(context, '/order-details', arguments: orderId);

    // Cargar detalles del pedido
    if (authProvider.token != null) {
      ordersProvider.loadOrderById(orderId, authProvider.token!);
    }
  }

  void _trackOrder(String orderId) {
    // Navegar a la pantalla de seguimiento
    Navigator.pushNamed(context, '/track-order', arguments: orderId);
  }

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder:
          (context) => _CancelOrderDialog(
            order: order,
            onCancel: (reason) async {
              try {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final ordersProvider = Provider.of<OrdersProvider>(
                  context,
                  listen: false,
                );

                if (authProvider.token != null &&
                    authProvider.token!.isNotEmpty) {
                  final success = await ordersProvider.cancelOrder(
                    order.id,
                    reason,
                    authProvider.token!,
                  );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pedido cancelado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ordersProvider.error ?? 'Error al cancelar pedido',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  _showAuthError();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error de autenticación'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  void _showAuthError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error de autenticación. Por favor, inicia sesión nuevamente.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _reviewOrder(Order order) {
    Navigator.pushNamed(context, '/order-review', arguments: order.id);
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusName(int statusId) {
    switch (statusId) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'Confirmado';
      case 3:
        return 'En preparación';
      case 4:
        return 'Listo para entrega';
      case 5:
        return 'En camino';
      case 6:
        return 'Entregado';
      case 7:
        return 'Cancelado';
      default:
        return 'Todos';
    }
  }
}

// Widget para el bottom sheet de filtros
class _FiltersBottomSheet extends StatefulWidget {
  final Function(int?, DateTime?, DateTime?) onApplyFilters;

  const _FiltersBottomSheet({required this.onApplyFilters});

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  int? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OrdersProvider>(context, listen: false);
    _selectedStatus = provider.selectedStatusFilter;
    _startDate = provider.startDateFilter;
    _endDate = provider.endDateFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filtrar Pedidos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Filtro por estado
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Estado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildStatusChip('Todos', null),
              _buildStatusChip('Pendiente', 1),
              _buildStatusChip('Confirmado', 2),
              _buildStatusChip('En preparación', 3),
              _buildStatusChip('En camino', 5),
              _buildStatusChip('Entregado', 6),
              _buildStatusChip('Cancelado', 7),
            ],
          ),
          const SizedBox(height: 20),

          // Filtro por fecha
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Rango de fechas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectStartDate,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _startDate != null
                        ? DateFormat('dd/MM/yyyy').format(_startDate!)
                        : 'Fecha inicial',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectEndDate,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _endDate != null
                        ? DateFormat('dd/MM/yyyy').format(_endDate!)
                        : 'Fecha final',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                  ),
                  child: const Text(
                    'Aplicar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, int? value) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? value : null;
        });
      },
      selectedColor: const Color(0xFFFF8C00).withOpacity(0.2),
      checkmarkColor: const Color(0xFFFF8C00),
    );
  }

  void _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_selectedStatus, _startDate, _endDate);
    Navigator.pop(context);
  }
}

// Dialog para cancelar pedido
class _CancelOrderDialog extends StatefulWidget {
  final Order order;
  final Function(String) onCancel;

  const _CancelOrderDialog({required this.order, required this.onCancel});

  @override
  State<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<_CancelOrderDialog> {
  final _reasonController = TextEditingController();
  String? _selectedReason;

  final List<String> _cancelReasons = [
    'Cambié de opinión',
    'Demora en la entrega',
    'Producto no disponible',
    'Error en el pedido',
    'Otro motivo',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancelar Pedido'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '¿Estás seguro de que deseas cancelar el pedido ${widget.order.id}?',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: const InputDecoration(
              labelText: 'Motivo de cancelación',
              border: OutlineInputBorder(),
            ),
            items:
                _cancelReasons.map((reason) {
                  return DropdownMenuItem(value: reason, child: Text(reason));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedReason = value;
              });
            },
          ),
          if (_selectedReason == 'Otro motivo') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Especifica el motivo',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedReason != null ? _confirmCancel : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _confirmCancel() {
    String reason = _selectedReason!;
    if (_selectedReason == 'Otro motivo' && _reasonController.text.isNotEmpty) {
      reason = _reasonController.text;
    }

    widget.onCancel(reason);
    Navigator.pop(context);
  }
}
