import 'package:flutter/material.dart';
import 'package:barrilfood_app/models/product.dart';

class CartItem {
  final Product product;
  int cantidad;

  CartItem({
    required this.product,
    this.cantidad = 1,
  });

  double get subtotal => product.precio * cantidad;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.fold(0, (total, item) => total + item.cantidad);
  }

  double get subtotal {
    return _items.fold(0.0, (total, item) => total + item.subtotal);
  }

  double get envio => _items.isEmpty ? 0.0 : 2.50;

  double get impuestos => 0.0; // Asumimos que los impuestos están incluidos

  double get total => subtotal + envio + impuestos;

  bool get isEmpty => _items.isEmpty;

  // Agregar producto al carrito
  void addToCart(Product product, {int cantidad = 1}) {
    // Buscar si ya existe el producto en el carrito
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Si ya existe, incrementar la cantidad
      _items[existingIndex].cantidad += cantidad;
    } else {
      // Si no existe, agregar nuevo item
      _items.add(CartItem(product: product, cantidad: cantidad));
    }
    
    notifyListeners();
  }

  // Actualizar cantidad de un producto
  void updateQuantity(int productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].cantidad = newQuantity;
      }
      notifyListeners();
    }
  }

  // Eliminar producto del carrito
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Limpiar carrito
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Obtener cantidad de un producto específico
  int getProductQuantity(int productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(
        id: -1,
        nombre: '',
        descripcion: '',
        precio: 0.0,
        disponible: false,
        destacado: false,
        categoriaId: 0,
        imagenUrl: '',
      )),
    );
    return item.product.id == -1 ? 0 : item.cantidad;
  }

  // Verificar si un producto está en el carrito
  bool isInCart(int productId) {
    return _items.any((item) => item.product.id == productId);
  }
}