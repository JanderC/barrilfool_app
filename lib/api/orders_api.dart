// api/orders_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barrilfood_app/models/order.dart';
import 'package:barrilfood_app/api/constants.dart';

class OrdersApi {
  static const String baseUrl = ApiConstants.baseUrl;

  // Headers por defecto
  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // Headers con autenticación
  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // Obtener lista de pedidos
  Future<List<Order>> getAllOrders({
    String? token,
    int? estadoId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? repartidorId,
  }) async {
    try {
      String url = '$baseUrl/api/orders';

      // Construir query parameters
      List<String> queryParams = [];
      if (estadoId != null) queryParams.add('estado_id=$estadoId');
      if (fechaInicio != null) {
        queryParams.add(
          'fecha_inicio=${fechaInicio.toIso8601String().split('T')[0]}',
        );
      }
      if (fechaFin != null) {
        queryParams.add(
          'fecha_fin=${fechaFin.toIso8601String().split('T')[0]}',
        );
      }
      if (repartidorId != null) queryParams.add('repartidor_id=$repartidorId');

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: token != null ? _authHeaders(token) : _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => Order.fromJsonWithProducts(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autenticado');
      } else {
        throw Exception('Error al obtener pedidos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Order>> getPendingOrdersWithProducts({
    required String token,
  }) async {
    try {
      final url = '$baseUrl/api/orders/pending-with-products';
      print('🔍 DEBUG: URL completa: $url');
      print('🔍 DEBUG: Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔍 DEBUG: Status Code: ${response.statusCode}');
      print('🔍 DEBUG: Response Headers: ${response.headers}');
      print('🔍 DEBUG: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('🔍 DEBUG: Datos parseados: ${data.length} pedidos');
        if (data.isNotEmpty) {
          print('🔍 DEBUG: Primer pedido: ${data.first}');
        }
        return data
            .map((orderJson) => Order.fromJsonWithProducts(orderJson))
            .toList();
      } else {
        print('❌ ERROR: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Error al obtener pedidos pendientes: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ EXCEPTION: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener pedido por ID
  Future<OrderDetail> getOrderById(String orderId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: _authHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return OrderDetail.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Pedido no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('Sin permisos para ver este pedido');
      } else {
        throw Exception('Error al obtener pedido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear nuevo pedido
  Future<Order> createOrder(CreateOrderRequest orderData, String token) async {
    try {
      print(json.encode(orderData.toJson()));
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: _authHeaders(token),
        body: json.encode(orderData.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Order.fromJsonWithProducts(jsonData);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error de validación');
      } else if (response.statusCode == 401) {
        throw Exception('No autenticado');
      } else {
        throw Exception('Error al crear pedido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar estado del pedido
  Future<Order> updateOrderStatus(
    String orderId,
    int estadoId,
    String token, {
    String? notas,
  }) async {
    try {
      final body = {'estado_id': estadoId, if (notas != null) 'notas': notas};

      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/$orderId/status'),
        headers: _authHeaders(token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Order.fromJsonWithProducts(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Pedido no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('Sin permisos para actualizar este pedido');
      } else {
        throw Exception('Error al actualizar estado: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Asignar repartidor
  Future<Order> assignDelivery(
    String orderId,
    String repartidorId,
    String token,
  ) async {
    try {
      final body = {'repartidor_id': repartidorId};

      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/$orderId/delivery'),
        headers: _authHeaders(token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Order.fromJsonWithProducts(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Pedido no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('Sin permisos para asignar repartidor');
      } else {
        throw Exception('Error al asignar repartidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Cancelar pedido
  Future<Order> cancelOrder(String orderId, String motivo, String token) async {
    try {
      final body = {'motivo': motivo};

      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/$orderId/cancel'),
        headers: _authHeaders(token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Order.fromJsonWithProducts(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Pedido no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('Sin permisos para cancelar este pedido');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ?? 'No se puede cancelar este pedido',
        );
      } else {
        throw Exception('Error al cancelar pedido: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener historial del pedido
  Future<List<OrderHistory>> getOrderHistory(
    String orderId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId/history'),
        headers: _authHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => OrderHistory.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Pedido no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('Sin permisos para ver el historial');
      } else {
        throw Exception('Error al obtener historial: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Añadir valoración al pedido
  Future<OrderReview> addOrderReview(
    String orderId,
    int productoId,
    int calificacion,
    String comentario,
    String token,
  ) async {
    try {
      final body = {
        'producto_id': productoId,
        'calificacion': calificacion,
        'comentario': comentario,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/$orderId/review'),
        headers: _authHeaders(token),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return OrderReview.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Pedido no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('Sin permisos para valorar este pedido');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error de validación');
      } else {
        throw Exception('Error al añadir valoración: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
