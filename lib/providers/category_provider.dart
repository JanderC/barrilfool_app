// providers/category_provider.dart
import 'package:flutter/foundation.dart';
import 'package:barrilfood_app/api/category_api.dart';
import 'package:barrilfood_app/models/category.dart' as my_models;
import 'package:barrilfood_app/models/product.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryApi _categoryApi = CategoryApi();
  
  List<my_models.Category> _categories = [];
  List<Product> _categoryProducts = [];
  Map<int, CategoryStatistics> _categoryStats = {};
  bool _isLoading = false;
  bool _isProductsLoading = false;
  String? _error;
  
  // Getters
  List<my_models.Category> get categories => _categories;
  List<Product> get categoryProducts => _categoryProducts;
  Map<int, CategoryStatistics> get categoryStats => _categoryStats;
  bool get isLoading => _isLoading;
  bool get isProductsLoading => _isProductsLoading;
  String? get error => _error;
  
  // ✅ Método auxiliar para extraer el mensaje de error limpio
  String _extractErrorMessage(dynamic error) {
    String errorMessage = error.toString();
    // Remover "Exception: " del inicio si existe
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }
    // Remover "Error de conexión: Exception: " si existe
    if (errorMessage.startsWith('Error de conexión: Exception: ')) {
      errorMessage = errorMessage.substring(30);
    }
    return errorMessage;
  }
  
  // Obtener todas las categorías
  Future<void> fetchCategories({bool showInactive = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _categories = await _categoryApi.getAllCategories(showInactive: showInactive);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching categories: $e');
    }
  }
  
  // Obtener categoría por ID
  Future<my_models.Category?> getCategoryById(int categoryId) async {
    try {
      return await _categoryApi.getCategoryById(categoryId);
    } catch (e) {
      _error = _extractErrorMessage(e);
      notifyListeners();
      debugPrint('Error getting category by ID: $e');
      return null;
    }
  }
  
  // Crear una nueva categoría
  Future<bool> createCategory(Map<String, dynamic> categoryData, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newCategory = await _categoryApi.createCategory(categoryData, token);
      _categories.add(newCategory);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      debugPrint('Error creating category: $e');
      return false;
    }
  }
  
  // Actualizar una categoría existente
  Future<bool> updateCategory(int categoryId, Map<String, dynamic> categoryData, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedCategory = await _categoryApi.updateCategory(categoryId, categoryData, token);
      final index = _categories.indexWhere((category) => category.id == categoryId);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating category: $e');
      return false;
    }
  }
  
  // Eliminar una categoría
  Future<bool> deleteCategory(int categoryId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _categoryApi.deleteCategory(categoryId, token);
      if (success) {
        _categories.removeWhere((category) => category.id == categoryId);
        _categoryStats.remove(categoryId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      debugPrint('Error deleting category: $e');
      return false;
    }
  }
  
  // Desactivar una categoría
  Future<bool> deactivateCategory(int categoryId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedCategory = await _categoryApi.deactivateCategory(categoryId, token);
      final index = _categories.indexWhere((category) => category.id == categoryId);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      debugPrint('Error deactivating category: $e');
      return false;
    }
  }
  
  // Activar una categoría
  Future<bool> activateCategory(int categoryId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedCategory = await _categoryApi.activateCategory(categoryId, token);
      final index = _categories.indexWhere((category) => category.id == categoryId);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      debugPrint('Error activating category: $e');
      return false;
    }
  }
  
  // Alternar el estado activo de una categoría
  Future<bool> toggleCategoryStatus(int categoryId, String token) async {
    try {
      final category = _categories.firstWhere((c) => c.id == categoryId);
      if (category.activo) {
        return await deactivateCategory(categoryId, token);
      } else {
        return await activateCategory(categoryId, token);
      }
    } catch (e) {
      _error = _extractErrorMessage(e);
      notifyListeners();
      debugPrint('Error toggling category status: $e');
      return false;
    }
  }
  
  // Obtener productos de una categoría
  Future<void> fetchCategoryProducts(int categoryId) async {
    _isProductsLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _categoryProducts = await _categoryApi.getCategoryProducts(categoryId);
      _isProductsLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isProductsLoading = false;
      notifyListeners();
      debugPrint('Error fetching category products: $e');
    }
  }
  
  // Obtener estadísticas de una categoría
  Future<void> fetchCategoryStatistics(int categoryId) async {
    try {
      final stats = await _categoryApi.getCategoryStatistics(categoryId);
      _categoryStats[categoryId] = stats;
      notifyListeners();
    } catch (e) {
      _error = _extractErrorMessage(e);
      notifyListeners();
      debugPrint('Error fetching category statistics: $e');
    }
  }
  
  // Buscar categorías
  Future<List<my_models.Category>> searchCategories(String searchTerm) async {
    try {
      return await _categoryApi.searchCategories(searchTerm);
    } catch (e) {
      _error = _extractErrorMessage(e);
      notifyListeners();
      debugPrint('Error searching categories: $e');
      return [];
    }
  }
  
  // Obtener categorías con productos disponibles
  Future<void> fetchCategoriesWithProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _categories = await _categoryApi.getCategoriesWithProducts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _extractErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching categories with products: $e');
    }
  }
  
  // Métodos auxiliares para filtrar categorías
  List<my_models.Category> get activeCategories {
    return _categories.where((category) => category.activo).toList();
  }
  
  List<my_models.Category> get inactiveCategories {
    return _categories.where((category) => !category.activo).toList();
  }
  
  // Obtener categoría por ID desde la lista local
  my_models.Category? getLocalCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }
  
  // Verificar si una categoría existe localmente
  bool categoryExists(String nombre, {int? excludeId}) {
    return _categories.any((category) => 
      category.nombre.toLowerCase() == nombre.toLowerCase() && 
      (excludeId == null || category.id != excludeId)
    );
  }
  
  // Obtener conteo de productos por categoría
  int getProductCountForCategory(int categoryId) {
    final stats = _categoryStats[categoryId];
    return stats?.totalProductos ?? 0;
  }
  
  // Obtener estadísticas desde el cache local
  CategoryStatistics? getLocalCategoryStatistics(int categoryId) {
    return _categoryStats[categoryId];
  }
  
  // Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Limpiar productos de categoría
  void clearCategoryProducts() {
    _categoryProducts.clear();
    notifyListeners();
  }
  
  // Refrescar datos
  Future<void> refreshData({bool showInactive = false}) async {
    await fetchCategories(showInactive: showInactive);
  }
  
  // Limpiar todos los datos
  void clearAllData() {
    _categories.clear();
    _categoryProducts.clear();
    _categoryStats.clear();
    _error = null;
    _isLoading = false;
    _isProductsLoading = false;
    notifyListeners();
  }
}

// Clase auxiliar para las estadísticas de categoría
class CategoryStatistics {
  final my_models.Category categoria;
  final int totalProductos;
  final int productosDisponibles;
  final int productosDestacados;
  
  CategoryStatistics({
    required this.categoria,
    required this.totalProductos,
    required this.productosDisponibles,
    required this.productosDestacados,
  });
  
  factory CategoryStatistics.fromJson(Map<String, dynamic> json) {
    return CategoryStatistics(
      categoria: my_models.Category.fromJson(json['categoria']),
      totalProductos: json['estadisticas']['total_productos'] ?? 0,
      productosDisponibles: json['estadisticas']['productos_disponibles'] ?? 0,
      productosDestacados: json['estadisticas']['productos_destacados'] ?? 0,
    );
  }
}