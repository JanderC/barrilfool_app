import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:barrilfood_app/config/api_config.dart';

class UserProvider with ChangeNotifier {
  // Estados de carga
  bool _isLoading = false;
  bool _isUpdatingOrder = false;
  String? _error;
  
  // Datos del usuario
  Map<String, dynamic>? _currentUser;
  List<Map<String, dynamic>> _userOrders = [];
  Map<String, dynamic>? _orderDetails;
  List<Map<String, dynamic>> _orderHistory = [];
  
  // Token de autenticación
  String? _token;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdatingOrder => _isUpdatingOrder;
  String? get error => _error;
  Map<String, dynamic>? get currentUser => _currentUser;
  List<Map<String, dynamic>> get userOrders => _userOrders;
  Map<String, dynamic>? get orderDetails => _orderDetails;
  List<Map<String, dynamic>> get orderHistory => _orderHistory;
  
  // Setters
  void setToken(String token) {
    _token = token;
  }
  
  // Headers para las peticiones
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };
  
  // Cargar perfil del usuario
  Future<void> loadUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/profile'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = data['data'];
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Error al cargar perfil';
        throw Exception(_error);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Cargar pedidos del usuario
  Future<void> loadUserOrders({
    int? estadoId,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      String url = '${ApiConfig.baseUrl}/api/user/orders';
      List<String> queryParams = [];
      
      if (estadoId != null) {
        queryParams.add('estado_id=$estadoId');
      }
      if (fechaInicio != null) {
        queryParams.add('fecha_inicio=$fechaInicio');
      }
      if (fechaFin != null) {
        queryParams.add('fecha_fin=$fechaFin');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userOrders = List<Map<String, dynamic>>.from(data['data']);
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Error al cargar pedidos';
        throw Exception(_error);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading user orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Obtener detalles de un pedido específico
  Future<void> loadOrderDetails(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/orders/$orderId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _orderDetails = data['data'];
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Error al cargar detalles del pedido';
        throw Exception(_error);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading order details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Tomar/confirmar pedido
  Future<void> takeOrder(String orderId) async {
    _isUpdatingOrder = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/orders/$orderId/take'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        // Recargar pedidos para actualizar la lista
        await loadUserOrders();
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Error al tomar el pedido';
        throw Exception(_error);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error taking order: $e');
      rethrow;
    } finally {
      _isUpdatingOrder = false;
      notifyListeners();
    }
  }
  
  // Actualizar estado del pedido
  Future<void> updateOrderStatus(String orderId, int estadoId, {String? notas}) async {
    _isUpdatingOrder = true;
    _error = null;
    notifyListeners();
    
    try {
      final body = {
        'estado_id': estadoId,
        if (notas != null) 'notas': notas,
      };
      
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/user/orders/$orderId/status'),
        headers: _headers,
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        // Recargar pedidos para actualizar la lista
        await loadUserOrders();
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Error al actualizar estado del pedido';
        throw Exception(_error);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating order status: $e');
      rethrow;
    } finally {
      _isUpdatingOrder = false;
      notifyListeners();
    }
  }
  
  // Obtener historial de un pedido
  Future<void> loadOrderHistory(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/orders/$orderId/history'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _orderHistory = List<Map<String, dynamic>>.from(data['data']);
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Error al cargar historial del pedido';
        throw Exception(_error);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading order history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Actualizar perfil del usuario
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/user/profile'),
        headers: _headers,
        body: json.encode(profileData),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = data['data'];
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Error al actualizar perfil';
        throw Exception(_error);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Cambiar contraseña
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final body = {
        'current_password': currentPassword,
        'new_password': newPassword,
      };
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/change-password'),
        headers: _headers,
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        _error = null;
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['error'] ?? 'Error al cambiar contraseña';
        throw Exception(_error);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error changing password: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Filtrar pedidos por estado
  List<Map<String, dynamic>> getOrdersByStatus(int? estadoId) {
    if (estadoId == null) return _userOrders;
    return _userOrders.where((order) => order['estado_id'] == estadoId).toList();
  }
  
  // Obtener estadísticas de pedidos
  Map<String, int> getOrderStatistics() {
    final stats = <String, int>{
      'total': _userOrders.length,
      'pendientes': 0,
      'confirmados': 0,
      'en_proceso': 0,
      'terminados': 0,
      'cancelados': 0,
    };
    
    for (final order in _userOrders) {
      switch (order['estado_id']) {
        case 1:
          stats['pendientes'] = stats['pendientes']! + 1;
          break;
        case 2:
          stats['confirmados'] = stats['confirmados']! + 1;
          break;
        case 3:
          stats['en_proceso'] = stats['en_proceso']! + 1;
          break;
        case 4:
          stats['terminados'] = stats['terminados']! + 1;
          break;
        case 7:
          stats['cancelados'] = stats['cancelados']! + 1;
          break;
      }
    }
    
    return stats;
  }
  
  // Limpiar datos
  void clearData() {
    _currentUser = null;
    _userOrders = [];
    _orderDetails = null;
    _orderHistory = [];
    _error = null;
    _isLoading = false;
    _isUpdatingOrder = false;
    notifyListeners();
  }
}