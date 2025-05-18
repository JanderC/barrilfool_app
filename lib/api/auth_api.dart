import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barrilfood_app/models/user.dart';
import 'package:barrilfood_app/api/constants.dart';

class AuthApi {
  final String _baseUrl = ApiConstants.baseUrl;
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Verificar estructura de respuesta correcta según tu backend
        if (responseData['data'] != null) {
          return responseData['data'];
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error en la autenticación');
      }
    } catch (e) {
      print('Error en login: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }
  
  Future<Map<String, dynamic>> registerCustomer(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/api/auth/register/customer');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        // Verificar estructura de respuesta correcta según tu backend
        if (responseData['data'] != null) {
          return responseData['data'];
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error en el registro');
      }
    } catch (e) {
      print('Error en registerCustomer: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }
  
  Future<User> checkToken(String token) async {
    final url = Uri.parse('$_baseUrl/api/auth/check-token');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Verificar estructura de respuesta correcta según tu backend
        if (responseData['data'] != null && responseData['data']['user'] != null) {
          return User.fromJson(responseData['data']['user']);
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        throw Exception('Token inválido');
      }
    } catch (e) {
      print('Error en checkToken: $e');
      throw Exception('Error al validar el token');
    }
  }
}