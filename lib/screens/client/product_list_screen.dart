import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:barrilfood_app/providers/product_provider.dart';
import 'package:barrilfood_app/providers/cart_provider.dart'; // Importar CartProvider
import 'package:barrilfood_app/models/product.dart';
import 'package:barrilfood_app/models/category.dart' as model;

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchCategories();
      // Cargar TODOS los productos inicialmente, no solo destacados
      productProvider.fetchProducts(); // Removido el parámetro destacado: true
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductProvider, CartProvider>(
      builder: (context, productProvider, cartProvider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner promocional
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF8C00),
                        const Color(0xFFFF8C00).withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Patrón de fondo decorativo
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomPaint(
                              painter: _PromoBannerPainter(),
                            ),
                          ),
                        ),
                      ),
                      // Contenido del banner
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '¡Oferta Especial!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '30% de descuento en tu primer pedido',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Ícono decorativo
                      const Positioned(
                        top: 16,
                        right: 16,
                        child: Icon(
                          Icons.local_offer,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Categorías
                const Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Mostrar loading de categorías o las categorías
                if (productProvider.isCategoriesLoading)
                  const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (productProvider.categories.isEmpty)
                  const SizedBox(
                    height: 120,
                    child: Center(
                      child: Text(
                        'No hay categorías disponibles',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: productProvider.categories.length + 1, // +1 para "Todos"
                      itemBuilder: (context, index) {
                        // Primer elemento será "Todos"
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                // Mostrar todos los productos
                                productProvider.fetchProducts();
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(40),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.apps,
                                        size: 40,
                                        color: Color(0xFFFF8C00),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Todos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        final category = productProvider.categories[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              // Filtrar productos por categoría
                              productProvider.fetchProducts(categoryId: category.id);
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getCategoryIcon(category.nombre),
                                      size: 40,
                                      color: const Color(0xFFFF8C00),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Productos destacados
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (productProvider.products.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          // Mostrar solo productos destacados
                          productProvider.fetchProducts(destacado: true);
                        },
                        child: const Text(
                          'Solo destacados',
                          style: TextStyle(color: Color(0xFFFF8C00)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Mostrar loading de productos o los productos
                if (productProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (productProvider.error != null)
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error al cargar productos',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            productProvider.clearError();
                            productProvider.fetchProducts(); // Cargar todos los productos
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                else if (productProvider.products.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No hay productos disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      final isInCart = cartProvider.isInCart(product.id);
                      final quantityInCart = cartProvider.getProductQuantity(product.id);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            // Navegar al detalle del producto
                            _showProductDetails(context, product, cartProvider);
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Imagen del producto
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: _buildProductImage(product),
                                  ),
                                ),
                                // Información del producto
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product.nombre,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            if (product.destacado)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFF8C00),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Destacado',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        if (product.descripcion != null && product.descripcion!.isNotEmpty)
                                          Text(
                                            product.descripcion!,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${product.precio.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFFFF8C00),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                if (!product.disponible)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade100,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'No disponible',
                                                      style: TextStyle(
                                                        color: Colors.red.shade700,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  )
                                                else if (isInCart)
                                                  // Mostrar contador si el producto está en el carrito
                                                  _buildCartItemCounter(product, quantityInCart, cartProvider)
                                                else
                                                  // Mostrar botón de agregar si no está en el carrito
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.add_circle,
                                                      color: Color(0xFFFF8C00),
                                                    ),
                                                    onPressed: () {
                                                      // Añadir al carrito
                                                      _addToCart(context, product, cartProvider);
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget del contador para items en la lista de productos
  Widget _buildCartItemCounter(Product product, int quantity, CartProvider cartProvider) {
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
            onPressed: () {
              cartProvider.updateQuantity(product.id, quantity - 1);
              if (quantity - 1 <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.nombre} eliminado del carrito'),
                    backgroundColor: const Color(0xFFFF8C00),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 25),
            child: Text(
              '$quantity',
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
            onPressed: () {
              cartProvider.updateQuantity(product.id, quantity + 1);
            },
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // Widget para construir la imagen del producto con validación de base64 mejorada
  Widget _buildProductImage(Product product) {
    // Si no hay imagen_url, mostrar imagen por defecto
    if (product.imagenUrl == null || product.imagenUrl!.isEmpty) {
      debugPrint('Producto ${product.nombre}: No tiene imagen_url');
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
        debugPrint('Producto ${product.nombre}: Base64 vacío después de limpieza');
        return _buildDefaultImage();
      }
      
      // Validar formato base64 básico
      if (!_isValidBase64(base64String)) {
        debugPrint('Producto ${product.nombre}: Formato base64 inválido');
        return _buildDefaultImage();
      }
      
      // Intentar decodificar el base64
      final Uint8List imageBytes = base64Decode(base64String);
      
      debugPrint('Producto ${product.nombre}: Imagen base64 decodificada correctamente');
      
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Producto ${product.nombre}: Error al mostrar imagen: $error');
          return _buildDefaultImage();
        },
      );
    } catch (e) {
      // Si falla la decodificación del base64, mostrar imagen por defecto
      debugPrint('Producto ${product.nombre}: Error al decodificar base64: $e');
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

  // Función para obtener el ícono de categoría
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'hamburguesas':
        return Icons.lunch_dining;
      case 'pizzas':
        return Icons.local_pizza;
      case 'bebidas':
        return Icons.local_drink;
      case 'postres':
        return Icons.cake;
      default:
        return Icons.restaurant;
    }
  }

  // Función para mostrar detalles del producto
  void _showProductDetails(BuildContext context, Product product, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isInCart = cartProvider.isInCart(product.id);
            final quantityInCart = cartProvider.getProductQuantity(product.id);
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen del producto
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: _buildProductImage(product),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nombre del producto
                    Text(
                      product.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Descripción
                    if (product.descripcion != null && product.descripcion!.isNotEmpty)
                      Text(
                        product.descripcion!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    // Precio
                    Text(
                      '\$${product.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Botones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cerrar'),
                        ),
                        if (product.disponible)
                          isInCart
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'En carrito: $quantityInCart',
                                      style: const TextStyle(
                                        color: Color(0xFFFF8C00),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        cartProvider.addToCart(product);
                                        setState(() {}); // Actualizar el diálogo
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${product.nombre} agregado al carrito'),
                                            backgroundColor: const Color(0xFFFF8C00),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF8C00),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Agregar más'),
                                    ),
                                  ],
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    cartProvider.addToCart(product);
                                    setState(() {}); // Actualizar el diálogo
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${product.nombre} agregado al carrito'),
                                        backgroundColor: const Color(0xFFFF8C00),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF8C00),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Agregar al carrito'),
                                ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Función para agregar al carrito
  void _addToCart(BuildContext context, Product product, CartProvider cartProvider) {
    cartProvider.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.nombre} agregado al carrito'),
        backgroundColor: const Color(0xFFFF8C00),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// CustomPainter para el patrón decorativo del banner
class _PromoBannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Crear círculos decorativos
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      30,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      25,
      paint,
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.2),
      15,
      paint,
    );

    // Líneas decorativas
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.4),
      linePaint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.8),
      Offset(size.width, size.height * 0.5),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}