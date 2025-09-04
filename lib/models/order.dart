// models/order.dart

// Modelo básico de pedido para listas
class Order {
  final String id;
  final String fechaPedido;
  final String estado;
  final double total;
  final String cliente;
  final String? repartidor;

  Order({
    required this.id,
    required this.fechaPedido,
    required this.estado,
    required this.total,
    required this.cliente,
    this.repartidor,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['id'] ?? '').toString(),
      fechaPedido: json['fecha_pedido'] ?? 'Sin fecha',
      estado: json['estado'] ?? 'pendiente',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      cliente: json['cliente'] ?? 'Sin cliente',
      repartidor: json['repartidor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha_pedido': fechaPedido,
      'estado': estado,
      'total': total,
      'cliente': cliente,
      if (repartidor != null) 'repartidor': repartidor,
    };
  }

  // Getter para obtener el nombre del estado en español
  String get estadoNombre {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmado':
        return 'Confirmado';
      case 'en_preparacion':
        return 'En preparación';
      case 'listo_para_entrega':
        return 'Listo para entrega';
      case 'en_camino':
        return 'En camino';
      case 'entregado':
        return 'Entregado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  // Getter para determinar si el pedido puede ser cancelado
  bool get puedeSerCancelado {
    return estado.toLowerCase() == 'pendiente' || 
           estado.toLowerCase() == 'confirmado';
  }

  // Getter para determinar si el pedido puede ser valorado
  bool get puedeSerValorado {
    return estado.toLowerCase() == 'entregado';
  }
}

// Modelo detallado de pedido
class OrderDetail {
  final String id;
  final String fechaPedido;
  final String estado;
  final double total;
  final double subtotal;
  final double costoEnvio;
  final double descuento;
  final double impuestos;
  final String? notas;
  final List<OrderItem> detalles;
  final String? cliente;
  final String? repartidor;

  OrderDetail({
    required this.id,
    required this.fechaPedido,
    required this.estado,
    required this.total,
    required this.subtotal,
    required this.costoEnvio,
    required this.descuento,
    required this.impuestos,
    this.notas,
    required this.detalles,
    this.cliente,
    this.repartidor,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: (json['id'] ?? '').toString(),
      fechaPedido: json['fecha_pedido'] ?? 'Sin fecha',
      estado: json['estado'] ?? 'pendiente',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      costoEnvio: (json['costo_envio'] as num?)?.toDouble() ?? 0.0,
      descuento: (json['descuento'] as num?)?.toDouble() ?? 0.0,
      impuestos: (json['impuestos'] as num?)?.toDouble() ?? 0.0,
      notas: json['notas'],
      detalles: (json['detalles'] as List<dynamic>?)?.map((item) => OrderItem.fromJson(item)).toList() ?? [],
      cliente: json['cliente'],
      repartidor: json['repartidor'],
    );
  }

  String get estadoNombre {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmado':
        return 'Confirmado';
      case 'en_preparacion':
        return 'En preparación';
      case 'listo_para_entrega':
        return 'Listo para entrega';
      case 'en_camino':
        return 'En camino';
      case 'entregado':
        return 'Entregado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }
}

// Modelo de item de pedido
class OrderItem {
  final int? productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? notas;
  final List<OrderItemOption>? opciones;

  OrderItem({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.notas,
    this.opciones,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productoId: json['producto_id'],
      nombreProducto: json['nombre_producto'] ?? 'Producto sin nombre',
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 1,
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 
                ((json['precio_unitario'] as num?)?.toDouble() ?? 0.0) * ((json['cantidad'] as num?)?.toInt() ?? 1),
      notas: json['notas'],
      opciones: json['opciones'] != null
          ? (json['opciones'] as List<dynamic>)
              .map((option) => OrderItemOption.fromJson(option))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
      if (notas != null) 'notas': notas,
      if (opciones != null) 
        'opciones': opciones!.map((option) => option.toJson()).toList(),
    };
  }
}

// Modelo de opción de item
class OrderItemOption {
  final int opcionId;
  final double precio;
  final String? nombre;

  OrderItemOption({
    required this.opcionId,
    required this.precio,
    this.nombre,
  });

  factory OrderItemOption.fromJson(Map<String, dynamic> json) {
    return OrderItemOption(
      opcionId: (json['opcion_id'] as num?)?.toInt() ?? 0,
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opcion_id': opcionId,
      'precio': precio,
    };
  }
}

// Modelo para crear un pedido
class CreateOrderRequest {
  final int direccionId;
  final int metodoPagoId;
  final double subtotal;
  final double costoEnvio;
  final double descuento;
  final double envio;
  final double impuestos;
  final double total;
  final String metodoPago;
  final String? notas;
  final String direccionEntrega;
  final List<CreateOrderItem> items;

  CreateOrderRequest({
    required this.direccionId,
    required this.metodoPagoId,
    required this.subtotal,
    required this.envio,
    required this.costoEnvio,
    required this.descuento,
    required this.impuestos,
    required this.total,
    this.notas,
    required this.direccionEntrega,
    required this.metodoPago,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'direccion_id': direccionId,
      'metodo_pago_id': metodoPagoId,
      'subtotal': subtotal,
      'costo_envio': costoEnvio,
      'descuento': descuento,
      'impuestos': impuestos,
      'total': total,
      if (notas != null) 'notas': notas,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

// Modelo para crear item de pedido
class CreateOrderItem {
  final int? productoId;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? notas;
  final List<OrderItemOption>? opciones;

  CreateOrderItem({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.notas,
    this.opciones,
  });

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productoId,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
      if (notas != null) 'notas': notas,
      if (opciones != null) 
        'opciones': opciones!.map((option) => option.toJson()).toList(),
    };
  }
}

// Modelo de historial de pedido
class OrderHistory {
  final int id;
  final String fecha;
  final OrderState estado;
  final OrderUser usuario;
  final String? notas;

  OrderHistory({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.usuario,
    this.notas,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fecha: json['fecha'] ?? 'Sin fecha',
      estado: OrderState.fromJson(json['estado'] ?? {}),
      usuario: OrderUser.fromJson(json['usuario'] ?? {}),
      notas: json['notas'],
    );
  }
}

// Modelo de estado de pedido
class OrderState {
  final int id;
  final String nombre;
  final String color;

  OrderState({
    required this.id,
    required this.nombre,
    required this.color,
  });

  factory OrderState.fromJson(Map<String, dynamic> json) {
    return OrderState(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] ?? 'Sin estado',
      color: json['color'] ?? '#000000',
    );
  }
}

// Modelo de usuario en pedido
class OrderUser {
  final String id;
  final String nombre;

  OrderUser({
    required this.id,
    required this.nombre,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: (json['id'] ?? '').toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
    );
  }
}

// Modelo de valoración de pedido
class OrderReview {
  final int id;
  final String pedidoId;
  final int? productoId;
  final int calificacion;
  final String comentario;
  final String fecha;

  OrderReview({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.calificacion,
    required this.comentario,
    required this.fecha,
  });

  factory OrderReview.fromJson(Map<String, dynamic> json) {
    return OrderReview(
      id: (json['id'] as num?)?.toInt() ?? 0,
      pedidoId: (json['pedido_id'] ?? '').toString(),
      productoId: json['producto_id'],
      calificacion: (json['calificacion'] as num?)?.toInt() ?? 0,
      comentario: json['comentario'] ?? '',
      fecha: json['fecha'] ?? 'Sin fecha',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pedido_id': pedidoId,
      'producto_id': productoId,
      'calificacion': calificacion,
      'comentario': comentario,
      'fecha': fecha,
    };
  }
}