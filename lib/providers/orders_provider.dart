  // providers/orders_provider.dart
import 'package:flutter/material.dart';
import 'package:barrilfood_app/models/order.dart';
import 'package:barrilfood_app/api/orders_api.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersApi _ordersApi = OrdersApi();
  
  // Estado de la lista de pedidos
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  
  // Estado del pedido individual
  OrderDetail? _selectedOrder;
  bool _isLoadingOrder = false;
  String? _orderError;
  
  // Estado del historial
  List<OrderHistory> _orderHistory = [];
  bool _isLoadingHistory = false;
  
  // Filtros
  int? _selectedStatusFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  
  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  OrderDetail? get selectedOrder => _selectedOrder;
  bool get isLoadingOrder => _isLoadingOrder;
  String? get orderError => _orderError;
  
  List<OrderHistory> get orderHistory => _orderHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  
  int? get selectedStatusFilter => _selectedStatusFilter;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  
  // Cargar lista de pedidos
  Future<void> loadOrders(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _orders = await _ordersApi.getAllOrders(
        token: token,
        estadoId: _selectedStatusFilter,
        fechaInicio: _startDateFilter,
        fechaFin: _endDateFilter,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Cargar pedido por ID
  Future<void> loadOrderById(String orderId, String token) async {
    _isLoadingOrder = true;
    _orderError = null;
    _selectedOrder = null;
    notifyListeners();
    
    try {
      _selectedOrder = await _ordersApi.getOrderById(orderId, token);
      _orderError = null;
    } catch (e) {
      _orderError = e.toString();
      _selectedOrder = null;
    } finally {
      _isLoadingOrder = false;
      notifyListeners();
    }
  }
  
  // Crear nuevo pedido
  Future<Order?> createOrder(CreateOrderRequest orderData, String token) async {
    try {
      final newOrder = await _ordersApi.createOrder(orderData, token);
      
      // Agregar el nuevo pedido al inicio de la lista
      _orders.insert(0, newOrder);
      notifyListeners();
      
      return newOrder;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Actualizar estado del pedido
  Future<bool> updateOrderStatus(
    String orderId, 
    int estadoId, 
    String token, 
    {String? notas}
  ) async {
    try {
      final updatedOrder = await _ordersApi.updateOrderStatus(
        orderId, 
        estadoId, 
        token, 
        notas: notas
      );
      
      // Actualizar en la lista
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      
      // Actualizar el pedido seleccionado si coincide
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = await _ordersApi.getOrderById(orderId, token);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Cancelar pedido
  Future<bool> cancelOrder(String orderId, String motivo, String token) async {
    try {
      final updatedOrder = await _ordersApi.cancelOrder(orderId, motivo, token);
      
      // Actualizar en la lista
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      
      // Actualizar el pedido seleccionado si coincide
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = await _ordersApi.getOrderById(orderId, token);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Asignar repartidor
  Future<bool> assignDelivery(
    String orderId, 
    String repartidorId, 
    String token
  ) async {
    try {
      final updatedOrder = await _ordersApi.assignDelivery(
        orderId, 
        repartidorId, 
        token
      );
      
      // Actualizar en la lista
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
      }
      
      // Actualizar el pedido seleccionado si coincide
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = await _ordersApi.getOrderById(orderId, token);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Cargar historial del pedido
  Future<void> loadOrderHistory(String orderId, String token) async {
    _isLoadingHistory = true;
    notifyListeners();
    
    try {
      _orderHistory = await _ordersApi.getOrderHistory(orderId, token);
    } catch (e) {
      _error = e.toString();
      _orderHistory = [];
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }
  
  // Añadir valoración
  Future<bool> addOrderReview(
    String orderId,
    int productoId,
    int calificacion,
    String comentario,
    String token
  ) async {
    try {
      await _ordersApi.addOrderReview(
        orderId,
        productoId,
        calificacion,
        comentario,
        token
      );
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Aplicar filtro de estado
  void setStatusFilter(int? statusId) {
    _selectedStatusFilter = statusId;
    notifyListeners();
  }
  
  // Aplicar filtro de fecha
  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    _startDateFilter = startDate;
    _endDateFilter = endDate;
    notifyListeners();
  }
  
  // Limpiar filtros
  void clearFilters() {
    _selectedStatusFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    notifyListeners();
  }
  
  // Limpiar errores
  void clearError() {
    _error = null;
    _orderError = null;
    notifyListeners();
  }
  
  // Limpiar pedido seleccionado
  void clearSelectedOrder() {
    _selectedOrder = null;
    _orderHistory = [];
    _orderError = null;
    notifyListeners();
  }
  
  // Refrescar lista de pedidos
  Future<void> refreshOrders(String token) async {
    await loadOrders(token);
  }
  
  // Obtener pedidos por estado
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.estado.toLowerCase() == status.toLowerCase()).toList();
  }
  
  // Obtener conteo de pedidos por estado
  Map<String, int> getOrdersCountByStatus() {
    Map<String, int> counts = {
      'pendiente': 0,
      'confirmado': 0,
      'en_preparacion': 0,
      'listo_para_entrega': 0,
      'en_camino': 0,
      'entregado': 0,
      'cancelado': 0,
    };
    
    for (var order in _orders) {
      final status = order.estado.toLowerCase();
      if (counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
    }
    
    return counts;
  }
  
  // Obtener total de ventas
  double get totalSales {
    return _orders
        .where((order) => order.estado.toLowerCase() == 'entregado')
        .fold(0.0, (sum, order) => sum + order.total);
  }
  
  // Obtener pedidos del día actual
  List<Order> get todayOrders {
    final today = DateTime.now();
    return _orders.where((order) {
      final orderDate = DateTime.parse(order.fechaPedido);
      return orderDate.year == today.year &&
             orderDate.month == today.month &&
             orderDate.day == today.day;
    }).toList();
  }
  
  // Verificar si un pedido puede ser cancelado
  bool canCancelOrder(String orderId) {
    final order = _orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => Order(
        id: '',
        fechaPedido: '',
        estado: '',
        total: 0.0,
        cliente: '',
      ),
    );
    return order.puedeSerCancelado;
  }
  
  // Verificar si un pedido puede ser valorado
  bool canReviewOrder(String orderId) {
    final order = _orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => Order(
        id: '',
        fechaPedido: '',
        estado: '',
        total: 0.0,
        cliente: '',
      ),
    );
    return order.puedeSerValorado;
  }
}