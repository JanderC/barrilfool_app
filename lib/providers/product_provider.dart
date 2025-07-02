// providers/product_provider.dart
import 'package:flutter/foundation.dart';
import 'package:barrilfood_app/api/product_api.dart';
import 'package:barrilfood_app/api/category_api.dart';
import 'package:barrilfood_app/models/product.dart';
import 'package:barrilfood_app/models/category.dart' as model;

class ProductProvider with ChangeNotifier {
  final ProductApi _productApi = ProductApi();
  final CategoryApi _categoryApi = CategoryApi();

  List<Product> _products = [];
  List<model.Category> _categories = [];
  bool _isLoading = false;
  bool _isCategoriesLoading = false;
  String? _error;

  // Getters
  List<Product> get products => _products;
  List<model.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isCategoriesLoading => _isCategoriesLoading;
  String? get error => _error;

  // Obtener todas las categorías
  Future<void> fetchCategories() async {
    _isCategoriesLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryApi.getAllCategories();
      _isCategoriesLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isCategoriesLoading = false;
      notifyListeners();
      debugPrint('Error fetching categories: $e');
    }
  }

  // Obtener todos los productos
  Future<void> fetchProducts({
    int? categoryId,
    bool? disponible,
    bool? destacado,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productApi.getAllProducts(
        categoryId: categoryId,
        disponible: disponible,
        destacado: destacado,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching products: $e');
    }
  }

  // Obtener un producto por ID
  Future<Product?> getProductById(int productId) async {
    try {
      return await _productApi.getProductById(productId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error getting product by ID: $e');
      return null;
    }
  }

  // Crear un nuevo producto
  Future<bool> createProduct(
    Map<String, dynamic> productData,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProduct = await _productApi.createProduct(productData, token);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error creating product: $e');
      return false;
    }
  }

  // Modificar un producto existente
  Future<bool> modifyProduct(
    int productId,
    Map<String, dynamic> productData,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final modifiedProduct = await _productApi.modifyProduct(
        productId: productId,
        productData: productData,
        token: token,
      );

      // Actualizar el producto en la lista local
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        _products[index] = modifiedProduct;
      } else {
        // Si no existe en la lista local, agregarlo
        _products.add(modifiedProduct);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error modifying product: $e');
      return false;
    }
  }

  // Actualizar un producto existente
  Future<bool> updateProduct(
    int productId,
    Map<String, dynamic> productData,
    String token,
  ) async {
    print('datos del producto ');
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updatedProduct = await _productApi.updateProduct(
        productId,
        productData,
        token,
      );
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating product: $e');
      return false;
    }
  }

  // Cambiar la disponibilidad de un producto
  Future<bool> toggleProductAvailability(int productId, String token) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final updatedData = {'disponible': !product.disponible};

      final success = await updateProduct(productId, updatedData, token);
      if (success) {
        // Actualizar inmediatamente en la lista local
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = _products[index].copyWith(
            disponible: !product.disponible,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error toggling product availability: $e');
      return false;
    }
  }

  // Cambiar el estado destacado de un producto
  Future<bool> toggleProductFeatured(int productId, String token) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final updatedData = {'destacado': !product.destacado};

      final success = await updateProduct(productId, updatedData, token);
      if (success) {
        // Actualizar inmediatamente en la lista local
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = _products[index].copyWith(
            destacado: !product.destacado,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error toggling product featured: $e');
      return false;
    }
  }

  // Eliminar un producto
  Future<bool> deleteProduct(int productId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _productApi.deleteProduct(productId, token);
      if (success) {
        _products.removeWhere((product) => product.id == productId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error deleting product: $e');
      return false;
    }
  }

  // Actualizar solo la imagen de un producto
  Future<bool> updateProductImage(
    int productId,
    String imageBase64,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProduct = await _productApi.updateProductImage(
        productId,
        imageBase64,
        token,
      );
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating product image: $e');
      return false;
    }
  }

  // Remover la imagen de un producto
  Future<bool> removeProductImage(int productId, String token) async {
    try {
      final updatedProduct = await _productApi.removeProductImage(
        productId,
        token,
      );
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error removing product image: $e');
      return false;
    }
  }

  // Obtener imagen de un producto específico
  Future<String?> getProductImage(int productId) async {
    try {
      return await _productApi.getProductImage(productId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error getting product image: $e');
      return null;
    }
  }

  // Obtener opciones de un producto
  Future<List<dynamic>?> getProductOptions(int productId) async {
    try {
      return await _productApi.getProductOptions(productId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error getting product options: $e');
      return null;
    }
  }

  // Agregar una opción a un producto
  Future<bool> addProductOption(
    int productId,
    Map<String, dynamic> optionData,
    String token,
  ) async {
    try {
      await _productApi.addProductOption(productId, optionData, token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error adding product option: $e');
      return false;
    }
  }

  // Métodos auxiliares para filtrar productos
  List<Product> getProductsByCategory(int categoryId) {
    return _products
        .where((product) => product.categoriaId == categoryId)
        .toList();
  }

  List<Product> get availableProducts {
    return _products.where((product) => product.disponible).toList();
  }

  List<Product> get featuredProducts {
    return _products.where((product) => product.destacado).toList();
  }

  // Obtener categoría por ID
  model.Category? getCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refrescar datos
  Future<void> refreshData() async {
    await Future.wait([fetchProducts(), fetchCategories()]);
  }

  // Buscar productos por nombre
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    return _products
        .where(
          (product) =>
              product.nombre.toLowerCase().contains(query.toLowerCase()) ||
              (product.descripcion?.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }
}
