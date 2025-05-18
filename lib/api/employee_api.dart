// employee_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barrilfood_app/models/user.dart';
import 'package:barrilfood_app/api/constants.dart';

class EmployeeApi {
  final String _baseUrl = ApiConstants.baseUrl;
  
  // Obtener todos los empleados
  Future<List<User>> getAllEmployees(String token) async {
    final url = Uri.parse('$_baseUrl/api/admin/employees');
    
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
        
        if (responseData['data'] != null) {
          final employeesData = responseData['data'] as List;
          return employeesData.map((employeeJson) => User.fromJson(employeeJson)).toList();
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al obtener empleados');
      }
    } catch (e) {
      print('Error en getAllEmployees: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }
  
  // Crear un nuevo empleado
  Future<User> createEmployee(Map<String, dynamic> employeeData, String token) async {
    final url = Uri.parse('$_baseUrl/api/admin/employees');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(employeeData),
      );
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        if (responseData['data'] != null) {
          return User.fromJson(responseData['data']);
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al crear empleado');
      }
    } catch (e) {
      print('Error en createEmployee: $e');
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
  
  // Actualizar un empleado existente
  Future<User> updateEmployee(String employeeId, Map<String, dynamic> employeeData, String token) async {
    final url = Uri.parse('$_baseUrl/api/admin/employees/$employeeId');
    
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(employeeData),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['data'] != null) {
          return User.fromJson(responseData['data']);
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al actualizar empleado');
      }
    } catch (e) {
      print('Error en updateEmployee: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }
  
  // Cambiar el estado de un empleado (activar/desactivar)
  Future<User> toggleEmployeeStatus(String employeeId, String token) async {
    final url = Uri.parse('$_baseUrl/api/admin/employees/$employeeId/toggle-status');
    
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['data'] != null) {
          return User.fromJson(responseData['data']);
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al cambiar estado del empleado');
      }
    } catch (e) {
      print('Error en toggleEmployeeStatus: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }
  
  // Eliminar un empleado
  Future<bool> deleteEmployee(String employeeId, String token) async {
    final url = Uri.parse('$_baseUrl/api/admin/employees/$employeeId');
    
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al eliminar empleado');
      }
    } catch (e) {
      print('Error en deleteEmployee: $e');
      throw Exception('Error al conectar con el servidor');
    }
  }
}