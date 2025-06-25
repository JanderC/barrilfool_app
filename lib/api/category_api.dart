// api/category_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barrilfood_app/models/category.dart';
import 'package:barrilfood_app/models/product.dart';
import 'package:barrilfood_app/providers/category_provider.dart'; // Para CategoryStatistics
import 'package:barrilfood_app/api/constants.dart';


class CategoryApi {
  static const String baseUrl = ApiConstants.baseUrl;
  
  // Headers por defecto
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };
  
  // Headers con autenticación
  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  
  // Obtener todas las categorías
  Future<List<Category>> getAllCategories({bool showInactive = true}) async {
    try {
      final url = '$baseUrl/api/categories';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Obtener categoría por ID
  Future<Category> getCategoryById(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$categoryId'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Category.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else {
        throw Exception('Error al obtener categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Crear nueva categoría
  Future<Category> createCategory(Map<String, dynamic> categoryData, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl'),
        headers: _authHeaders(token),
        body: json.encode(categoryData),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Category.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error de validación');
      } else {
        throw Exception('Error al crear categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Actualizar categoría
  Future<Category> updateCategory(int categoryId, Map<String, dynamic> categoryData, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$categoryId'),
        headers: _authHeaders(token),
        body: json.encode(categoryData),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Category.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error de validación');
      } else {
        throw Exception('Error al actualizar categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Eliminar categoría
  Future<bool> deleteCategory(int categoryId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$categoryId'),
        headers: _authHeaders(token),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'No se puede eliminar la categoría');
      } else {
        throw Exception('Error al eliminar categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Desactivar categoría
  Future<Category> deactivateCategory(int categoryId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$categoryId/deactivate'),
        headers: _authHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Category.fromJson(jsonData['categoria']);
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else {
        throw Exception('Error al desactivar categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Activar categoría
  Future<Category> activateCategory(int categoryId, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$categoryId/activate'),
        headers: _authHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Category.fromJson(jsonData['categoria']);
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else {
        throw Exception('Error al activar categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Obtener productos de una categoría
  Future<List<Product>> getCategoryProducts(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$categoryId/products'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else {
        throw Exception('Error al obtener productos de la categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Obtener estadísticas de una categoría
  Future<CategoryStatistics> getCategoryStatistics(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$categoryId/stats'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CategoryStatistics.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Categoría no encontrada');
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Buscar categorías
  Future<List<Category>> searchCategories(String searchTerm) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=${Uri.encodeComponent(searchTerm)}'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Category.fromJson(json)).toList();
      } else if (response.statusCode == 400) {
        throw Exception('Se requiere un término de búsqueda');
      } else {
        throw Exception('Error al buscar categorías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Obtener categorías con productos disponibles
  Future<List<Category>> getCategoriesWithProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/with-products'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener categorías con productos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}