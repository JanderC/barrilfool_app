class ApiConstants {
  // Cambia esta URL por la URL de tu servidor backend
    static const String baseUrl = 'http://127.0.0.1:5000';  // Para el emulador Android
    static const String ordersEndpoint = '/api/orders';
 //  static const String baseUrl = 'https://barrilfoodbackend-production.up.railway.app';  // Para el servidor
  // static const String baseUrl = 'http://localhost:5000';  // Para iOS simulator
  // static const String baseUrl = 'https://tu-dominio-en-produccion.com'; // Para producción

   // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
  
  // Headers comunes
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Estados de pedidos
  static const Map<int, String> orderStatuses = {
    1: 'pendiente',
    2: 'confirmado', 
    3: 'en_preparacion',
    4: 'listo_para_entrega',
    5: 'en_camino',
    6: 'entregado',
    7: 'cancelado',
  };
  
  // Colores de estados
  static const Map<String, String> statusColors = {
    'pendiente': '#FFA500',
    'confirmado': '#0000FF',
    'en_preparacion': '#FF8C00',
    'listo_para_entrega': '#00FF00',
    'en_camino': '#800080',
    'entregado': '#006400',
    'cancelado': '#FF0000',
  };
}