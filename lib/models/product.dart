// models/product.dart
class Product {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String? imagenUrl;
  final int? tiempoPreparacion;
  final int categoriaId;
  final bool disponible;
  final bool destacado;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? calificacion;
  final List<ProductOption>? opciones;

  Product({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.imagenUrl,
    this.tiempoPreparacion,
    required this.categoriaId,
    required this.disponible,
    required this.destacado,
    this.createdAt,
    this.updatedAt,
    this.calificacion,
    this.opciones,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: double.parse(json['precio'].toString()),
      imagenUrl: json['imagen_url'],
      tiempoPreparacion: json['tiempo_preparacion'],
      categoriaId: json['categoria_id'],
      disponible: json['disponible'] ?? true,
      destacado: json['destacado'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      calificacion: json['calificacion']?.toDouble(),
      opciones: json['opciones'] != null 
          ? (json['opciones'] as List).map((e) => ProductOption.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen_url': imagenUrl,
      'tiempo_preparacion': tiempoPreparacion,
      'categoria_id': categoriaId,
      'disponible': disponible,
      'destacado': destacado,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'calificacion': calificacion,
      'opciones': opciones?.map((e) => e.toJson()).toList(),
    };
  }

  Product copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    double? precio,
    String? imagenUrl,
    int? tiempoPreparacion,
    int? categoriaId,
    bool? disponible,
    bool? destacado,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? calificacion,
    List<ProductOption>? opciones,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      tiempoPreparacion: tiempoPreparacion ?? this.tiempoPreparacion,
      categoriaId: categoriaId ?? this.categoriaId,
      disponible: disponible ?? this.disponible,
      destacado: destacado ?? this.destacado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      calificacion: calificacion ?? this.calificacion,
      opciones: opciones ?? this.opciones,
    );
  }
}

class ProductOption {
  final int id;
  final int? productoId;
  final String nombre;
  final double precioAdicional;
  final bool disponible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductOption({
    required this.id,
    required this.productoId,
    required this.nombre,
    required this.precioAdicional,
    required this.disponible,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      id: json['id'],
      productoId: json['producto_id'],
      nombre: json['nombre'],
      precioAdicional: double.parse(json['precio_adicional'].toString()),
      disponible: json['disponible'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'nombre': nombre,
      'precio_adicional': precioAdicional,
      'disponible': disponible,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
