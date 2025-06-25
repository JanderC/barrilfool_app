// models/category.dart

class Category {
  final int id;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final String? imagen;
  final int? orden;
  final String? color;
  final String? icono;

  const Category({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.activo,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.imagen,
    this.orden,
    this.color,
    this.icono,
  });

  /// Factory constructor para crear desde JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      activo: json['activo'] ?? true,
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(),
      fechaActualizacion: json['fecha_actualizacion'] != null 
          ? DateTime.parse(json['fecha_actualizacion'])
          : null,
      imagen: json['imagen'],
      orden: json['orden'],
      color: json['color'],
      icono: json['icono'],
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion?.toIso8601String(),
      'imagen': imagen,
      'orden': orden,
      'color': color,
      'icono': icono,
    };
  }

  /// Crear copia con modificaciones
  Category copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? imagen,
    int? orden,
    String? color,
    String? icono,
  }) {
    return Category(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      imagen: imagen ?? this.imagen,
      orden: orden ?? this.orden,
      color: color ?? this.color,
      icono: icono ?? this.icono,
    );
  }

  /// Crear categoría vacía para formularios
  factory Category.empty() {
    return Category(
      id: 0,
      nombre: '',
      descripcion: '',
      activo: true,
      fechaCreacion: DateTime.now(),
    );
  }

  /// Crear datos para crear categoría (sin ID)
  Map<String, dynamic> toCreateJson() {
    final data = <String, dynamic>{
      'nombre': nombre,
      'activo': activo,
    };

    // Solo agregar campos no nulos
    if (descripcion != null && descripcion!.isNotEmpty) {
      data['descripcion'] = descripcion;
    }
    if (imagen != null && imagen!.isNotEmpty) {
      data['imagen'] = imagen;
    }
    if (orden != null) {
      data['orden'] = orden;
    }
    if (color != null && color!.isNotEmpty) {
      data['color'] = color;
    }
    if (icono != null && icono!.isNotEmpty) {
      data['icono'] = icono;
    }

    return data;
  }

  /// Crear datos para actualizar categoría
  Map<String, dynamic> toUpdateJson() {
    return toCreateJson(); // Misma estructura para update
  }

  /// Validar si la categoría tiene datos válidos
  bool isValid() {
    return nombre.isNotEmpty && nombre.trim().length >= 2;
  }

  /// Obtener errores de validación
  List<String> getValidationErrors() {
    final errors = <String>[];
    
    if (nombre.isEmpty) {
      errors.add('El nombre es requerido');
    } else if (nombre.trim().length < 2) {
      errors.add('El nombre debe tener al menos 2 caracteres');
    } else if (nombre.length > 100) {
      errors.add('El nombre no puede exceder 100 caracteres');
    }
    
    if (descripcion != null && descripcion!.length > 500) {
      errors.add('La descripción no puede exceder 500 caracteres');
    }
    
    if (color != null && color!.isNotEmpty) {
      // Validar formato de color hexadecimal
      final colorRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
      if (!colorRegex.hasMatch(color!)) {
        errors.add('El color debe tener un formato hexadecimal válido (#RRGGBB)');
      }
    }
    
    return errors;
  }

  /// Obtener el estado como texto
  String get estadoTexto => activo ? 'Activa' : 'Inactiva';

  /// Obtener fecha de creación formateada
  String get fechaCreacionFormateada {
    return '${fechaCreacion.day.toString().padLeft(2, '0')}/'
           '${fechaCreacion.month.toString().padLeft(2, '0')}/'
           '${fechaCreacion.year}';
  }

  /// Obtener fecha de actualización formateada
  String? get fechaActualizacionFormateada {
    if (fechaActualizacion == null) return null;
    return '${fechaActualizacion!.day.toString().padLeft(2, '0')}/'
           '${fechaActualizacion!.month.toString().padLeft(2, '0')}/'
           '${fechaActualizacion!.year}';
  }

  /// Obtener días desde la creación
  int get diasDesdeCreacion {
    return DateTime.now().difference(fechaCreacion).inDays;
  }

  /// Verificar si es una categoría nueva (menos de 7 días)
  bool get esNueva => diasDesdeCreacion <= 7;

  /// Verificar si fue actualizada recientemente (menos de 24 horas)
  bool get fueActualizadaRecientemente {
    if (fechaActualizacion == null) return false;
    return DateTime.now().difference(fechaActualizacion!).inHours <= 24;
  }

  /// Obtener color como Color de Flutter (si tienes flutter/material)
  /// Descomenta si necesitas esta funcionalidad
  /*
  Color? get colorFlutter {
    if (color == null || color!.isEmpty) return null;
    try {
      return Color(int.parse(color!.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return null;
    }
  }
  */

  /// Crear una representación string de la categoría
  @override
  String toString() {
    return 'Category(id: $id, nombre: $nombre, activo: $activo, fechaCreacion: $fechaCreacion)';
  }

  /// Para comparaciones con Equatable
  List<Object?> get props => [
    id,
    nombre,
    descripcion,
    activo,
    fechaCreacion,
    fechaActualizacion,
    imagen,
    orden,
    color,
    icono,
  ];
}

/// Extensión para listas de categorías
extension CategoryListExtension on List<Category> {
  /// Filtrar categorías activas
  List<Category> get activas => where((c) => c.activo).toList();
  
  /// Filtrar categorías inactivas
  List<Category> get inactivas => where((c) => !c.activo).toList();
  
  /// Ordenar por nombre
  List<Category> get ordenadosPorNombre {
    final lista = List<Category>.from(this);
    lista.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    return lista;
  }
  
  /// Ordenar por fecha de creación (más recientes primero)
  List<Category> get ordenadosPorFecha {
    final lista = List<Category>.from(this);
    lista.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    return lista;
  }
  
  /// Ordenar por orden personalizado
  List<Category> get ordenadosPorOrden {
    final lista = List<Category>.from(this);
    lista.sort((a, b) {
      final ordenA = a.orden ?? 999999;
      final ordenB = b.orden ?? 999999;
      return ordenA.compareTo(ordenB);
    });
    return lista;
  }
  
  /// Buscar por término
  List<Category> buscar(String termino) {
    if (termino.isEmpty) return this;
    final terminoLower = termino.toLowerCase();
    return where((categoria) =>
      categoria.nombre.toLowerCase().contains(terminoLower) ||
      (categoria.descripcion?.toLowerCase().contains(terminoLower) ?? false)
    ).toList();
  }
  
  /// Obtener categorías nuevas (últimos 7 días)
  List<Category> get nuevas => where((c) => c.esNueva).toList();
}