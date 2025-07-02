// api/product_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barrilfood_app/models/product.dart';
import 'package:barrilfood_app/models/category.dart';
import 'package:barrilfood_app/api/constants.dart';

class ProductApi {
  static const String baseUrl = ApiConstants.baseUrl;

  // Obtener todos los productos con filtros opcionales
  Future<List<Product>> getAllProducts({
    int? categoryId,
    bool? disponible,
    bool? destacado,
  }) async {
    String url = '$baseUrl/api/products';
    List<String> queryParams = [];

    if (categoryId != null) {
      queryParams.add('category_id=$categoryId');
    }
    if (disponible != null) {
      queryParams.add('disponible=$disponible');
    }
    if (destacado != null) {
      queryParams.add('destacado=$destacado');
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener productos: ${response.body}');
    }
  }

  Future<Product> modifyProduct({
    required int productId,
    required Map<String, dynamic> productData,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(productData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Si el backend devuelve un objeto con la clave 'producto'
      if (data is Map<String, dynamic> && data.containsKey('producto')) {
        return Product.fromJson(data['producto']);
      }
      // Si el backend devuelve directamente el producto
      else if (data is Map<String, dynamic>) {
        return Product.fromJson(data);
      }
      // Si el backend devuelve una lista (fallback)
      else if (data is List && data.isNotEmpty) {
        return Product.fromJson(data.first);
      } else {
        throw Exception('Formato de respuesta inesperado del servidor');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Producto no encontrado');
    } else {
      throw Exception('Error al modificar producto: ${response.body}');
    }
  }

  // Obtener un producto por ID
  Future<Product> getProductById(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$productId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Product.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Producto no encontrado');
    } else {
      throw Exception('Error al obtener producto: ${response.body}');
    }
  }

  // Crear un nuevo producto
  Future<Product> createProduct(
    Map<String, dynamic> productData,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(productData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Product.fromJson(data);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al crear producto');
    }
  }

  // Actualizar un producto existente
  Future<Product> updateProduct(
    int productId,
    Map<String, dynamic> productData,
    String token,
  ) async {
    late http.Response response; // Declarar response fuera del if/else

    // Verificar si se está desactivando el producto
    if (productData['disponible'] == false) {
      response = await http.put(
        Uri.parse('$baseUrl/api/products/$productId/deactivate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } else if (productData['disponible'] == true) {
      response = await http.put(
        Uri.parse('$baseUrl/api/products/$productId/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } else {
      // Si no es activar/desactivar, usar endpoint general de actualización
      response = await http.put(
        Uri.parse('$baseUrl/api/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(productData),
      );
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Product.fromJson(data['producto']);
    } else if (response.statusCode == 404) {
      throw Exception('Producto no encontrado');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al actualizar producto');
    }
  }

  // Eliminar un producto
  Future<bool> deleteProduct(int productId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      throw Exception('Producto no encontrado');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al eliminar producto');
    }
  }

  // Actualizar solo la imagen de un producto
  Future<Product> updateProductImage(
    int productId,
    String imageBase64,
    String token,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$productId/image'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'imagen_base64': imageBase64}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Product.fromJson(data['producto']);
    } else if (response.statusCode == 404) {
      throw Exception('Producto no encontrado');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al actualizar imagen');
    }
  }

  // Obtener solo la imagen de un producto
  Future<String?> getProductImage(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$productId/image'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['imagen_url'];
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Error al obtener imagen del producto');
    }
  }

  // Remover la imagen de un producto
  Future<Product> removeProductImage(int productId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$productId/image'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Product.fromJson(data['producto']);
    } else if (response.statusCode == 404) {
      throw Exception('Producto no encontrado');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al remover imagen');
    }
  }

  // Obtener opciones de un producto
  Future<List<ProductOption>> getProductOptions(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$productId/options'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProductOption.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('Producto no encontrado');
    } else {
      throw Exception('Error al obtener opciones del producto');
    }
  }

  // Añadir una opción a un producto
  Future<ProductOption> addProductOption(
    int productId,
    Map<String, dynamic> optionData,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products/$productId/options'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({...optionData, 'producto_id': productId}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return ProductOption.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Producto no encontrado');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ?? 'Error al crear opción del producto',
      );
    }
  }
}
