import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:barrilfood_app/providers/cart_provider.dart';
import 'dart:convert';
import 'dart:typed_data';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y cantidad de items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tu Carrito',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (cartProvider.totalQuantity > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C00),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${cartProvider.totalQuantity} items',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Lista de productos en el carrito
              Expanded(
                child: cartProvider.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tu carrito está vacío',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Agrega productos para comenzar',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: cartProvider.items.length,
                        itemBuilder: (context, index) {
                          final cartItem = cartProvider.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Imagen del producto
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: _buildProductImage(cartItem.product),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // Información del producto
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cartItem.product.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${cartItem.product.precio.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Color(0xFFFF8C00),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Subtotal: \$${cartItem.subtotal.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Controles de cantidad
                                    _buildCartItemCounter(cartItem, cartProvider),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              
              // Resumen del pedido
              if (!cartProvider.isEmpty) ...[
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                
                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('\$${cartProvider.subtotal.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Costo de envío
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Envío'),
                    Text('\$${cartProvider.envio.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Impuestos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Impuestos'),
                    Text('\$${cartProvider.impuestos.toStringAsFixed(2)}'),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '\$${cartProvider.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Botones de acción
                Row(
                  children: [
                    // Botón limpiar carrito
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => _showClearCartDialog(context, cartProvider),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFF8C00)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(color: Color(0xFFFF8C00)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón de pago
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () => _openWhatsApp(context, cartProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('PROCEDER AL PAGO'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Widget para construir la imagen del producto
  Widget _buildProductImage(product) {
    // Si no hay imagen_url, mostrar imagen por defecto
    if (product.imagenUrl == null || product.imagenUrl!.isEmpty) {
      return _buildDefaultImage();
    }

    try {
      // Limpiar el string base64 si tiene prefijos
      String base64String = product.imagenUrl!.trim();
      
      // Remover el prefijo "data:image/..." si existe
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      
      // Validar que el string base64 no esté vacío después de la limpieza
      if (base64String.isEmpty) {
        return _buildDefaultImage();
      }
      
      // Validar formato base64 básico
      if (!_isValidBase64(base64String)) {
        return _buildDefaultImage();
      }
      
      // Intentar decodificar el base64
      final Uint8List imageBytes = base64Decode(base64String);
      
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultImage();
        },
      );
    } catch (e) {
      // Si falla la decodificación del base64, mostrar imagen por defecto
      return _buildDefaultImage();
    }
  }

  // Función para validar formato base64
  bool _isValidBase64(String str) {
    try {
      // Un string base64 válido debe tener longitud múltiplo de 4
      if (str.length % 4 != 0) return false;
      
      // Verificar que solo contenga caracteres válidos de base64
      final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      return base64Regex.hasMatch(str);
    } catch (e) {
      return false;
    }
  }

  // Widget para imagen por defecto
  Widget _buildDefaultImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 40,
          color: Color(0xFFFF8C00),
        ),
      ),
    );
  }

  // Widget del contador para items del carrito
  Widget _buildCartItemCounter(CartItem cartItem, CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF8C00), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.remove,
              color: Color(0xFFFF8C00),
              size: 18,
            ),
            onPressed: () => _updateCartItemQuantity(cartItem, cartItem.cantidad - 1, cartProvider),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 25),
            child: Text(
              '${cartItem.cantidad}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFFFF8C00),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color(0xFFFF8C00),
              size: 18,
            ),
            onPressed: () => _updateCartItemQuantity(cartItem, cartItem.cantidad + 1, cartProvider),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // Método para actualizar la cantidad de un item del carrito
  void _updateCartItemQuantity(CartItem cartItem, int newQuantity, CartProvider cartProvider) {
    if (newQuantity <= 0) {
      // Mostrar mensaje cuando se elimina un producto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cartItem.product.nombre} eliminado del carrito'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFFFF8C00),
        ),
      );
    }
    
    // Actualizar la cantidad en el provider
    cartProvider.updateQuantity(cartItem.product.id, newQuantity);
  }

  // Función para mostrar diálogo de confirmación para limpiar carrito
  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar Carrito'),
          content: const Text('¿Estás seguro de que quieres eliminar todos los productos del carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Carrito limpiado'),
                    backgroundColor: Color(0xFFFF8C00),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Limpiar'),
            ),
          ],
        );
      },
    );
  }

  // Función para abrir WhatsApp con el mensaje del pedido
  Future<void> _openWhatsApp(BuildContext context, CartProvider cartProvider) async {
    const String phoneNumber = '584160467960'; // Número con código de país (58 para Venezuela)
    
    // Construir el mensaje con los detalles del pedido
    String message = '¡Hola! Me gustaría realizar el siguiente pedido:\n\n';
    message += '📋 *DETALLES DEL PEDIDO:*\n';
    
    for (var cartItem in cartProvider.items) {
      message += '• ${cartItem.product.nombre}\n';
      message += '  Cantidad: ${cartItem.cantidad}\n';
      message += '  Precio unitario: \$${cartItem.product.precio.toStringAsFixed(2)}\n';
      message += '  Subtotal: \$${cartItem.subtotal.toStringAsFixed(2)}\n\n';
    }
    
    message += '💰 *RESUMEN DE COSTOS:*\n';
    message += 'Subtotal: \$${cartProvider.subtotal.toStringAsFixed(2)}\n';
    message += 'Envío: \$${cartProvider.envio.toStringAsFixed(2)}\n';
    message += 'Impuestos: \$${cartProvider.impuestos.toStringAsFixed(2)}\n';
    message += '*TOTAL A PAGAR: \$${cartProvider.total.toStringAsFixed(2)}*\n\n';
    message += '¿Pueden confirmar la disponibilidad y procesar mi pedido? ¡Gracias!';
    
    // Codificar el mensaje para URL
    final String encodedMessage = Uri.encodeComponent(message);
    
    // Crear la URL de WhatsApp
    final String whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
    
    try {
      // Intentar abrir WhatsApp
      final Uri uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Si no se puede abrir WhatsApp, mostrar un error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir WhatsApp. Por favor, instala la aplicación.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Manejar errores
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}