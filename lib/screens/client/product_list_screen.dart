import 'package:flutter/material.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para categorías
    final categories = [
      {'id': 1, 'nombre': 'Hamburguesas', 'imagen': 'assets/hamburguesas.jpg'},
      {'id': 2, 'nombre': 'Pizzas', 'imagen': 'assets/pizzas.jpg'},
      {'id': 3, 'nombre': 'Bebidas', 'imagen': 'assets/bebidas.jpg'},
      {'id': 4, 'nombre': 'Postres', 'imagen': 'assets/postres.jpg'},
    ];
    
    // Datos de ejemplo para productos destacados
    final featuredProducts = [
      {
        'id': 1,
        'nombre': 'Hamburguesa Clásica',
        'descripcion': 'Deliciosa hamburguesa con carne, queso, lechuga y tomate',
        'precio': 8.99,
        'imagen': 'assets/hamburguesa_clasica.jpg',
      },
      {
        'id': 2,
        'nombre': 'Pizza Margherita',
        'descripcion': 'Pizza tradicional con salsa de tomate, mozzarella y albahaca',
        'precio': 12.99,
        'imagen': 'assets/pizza_margherita.jpg',
      },
      {
        'id': 3,
        'nombre': 'Alitas BBQ',
        'descripcion': 'Alitas de pollo bañadas en salsa barbacoa',
        'precio': 9.99,
        'imagen': 'assets/alitas_bbq.jpg',
      },
    ];
    
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
                color: const Color(0xFFFF8C00).withOpacity(0.2),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://via.placeholder.com/600x300/FF8C00/FFFFFF?text=Promocion+Especial',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          const Center(child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: const Text(
                        '¡30% de descuento en tu primer pedido!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        // Navegar a la lista de productos de esta categoría
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
                                _getCategoryIcon(category['nombre'] as String),
                                size: 40,
                                color: const Color(0xFFFF8C00),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['nombre'] as String,
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
            const Text(
              'Destacados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: featuredProducts.length,
              itemBuilder: (context, index) {
                final product = featuredProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      // Navegar al detalle del producto
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
                              child: Image.network(
                                'https://via.placeholder.com/120x120/FF8C00/FFFFFF?text=${product['nombre']}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Center(child: Icon(Icons.image_not_supported)),
                              ),
                            ),
                          ),
                          // Información del producto
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['nombre'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['descripcion'] as String,
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
                                        '\$${(product['precio'] as double).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFFFF8C00),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: Color(0xFFFF8C00),
                                        ),
                                        onPressed: () {
                                          // Añadir al carrito
                                        },
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
  }
  
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
}
