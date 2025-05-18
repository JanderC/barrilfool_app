import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para productos
    final products = [
      {
        'id': 1,
        'nombre': 'Hamburguesa Clásica',
        'descripcion': 'Deliciosa hamburguesa con carne, queso, lechuga y tomate',
        'precio': 8.99,
        'categoria_id': 1,
        'disponible': true,
        'destacado': true,
      },
      {
        'id': 2,
        'nombre': 'Pizza Margherita',
        'descripcion': 'Pizza tradicional con salsa de tomate, mozzarella y albahaca',
        'precio': 12.99,
        'categoria_id': 2,
        'disponible': true,
        'destacado': false,
      },
      {
        'id': 3,
        'nombre': 'Alitas BBQ',
        'descripcion': 'Alitas de pollo bañadas en salsa barbacoa',
        'precio': 9.99,
        'categoria_id': 1,
        'disponible': false,
        'destacado': false,
      },
    ];
    
    // Datos de ejemplo para categorías
    final categories = [
      {'id': 1, 'nombre': 'Hamburguesas'},
      {'id': 2, 'nombre': 'Pizzas'},
      {'id': 3, 'nombre': 'Bebidas'},
      {'id': 4, 'nombre': 'Postres'},
    ];
    
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Productos'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Productos'),
              Tab(text: 'Categorías'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña de Productos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de búsqueda y filtros
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar producto...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        hint: const Text('Filtrar'),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('Todos'),
                          ),
                          DropdownMenuItem(
                            value: 'available',
                            child: Text('Disponibles'),
                          ),
                          DropdownMenuItem(
                            value: 'unavailable',
                            child: Text('No disponibles'),
                          ),
                          DropdownMenuItem(
                            value: 'featured',
                            child: Text('Destacados'),
                          ),
                        ],
                        onChanged: (value) {
                          // Aplicar filtro
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Lista de productos
                  Expanded(
                    child: products.isEmpty
                        ? const Center(
                            child: Text('No hay productos registrados'),
                          )
                        : ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final category = categories.firstWhere(
                                (c) => c['id'] == product['categoria_id'],
                                orElse: () => {'nombre': 'Sin categoría'},
                              );
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Imagen del producto
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            _getProductIcon(category['nombre'] as String),
                                            size: 40,
                                            color: const Color(0xFFFF8C00),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Información del producto
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  product['nombre'] as String,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (product['destacado'] as bool)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: Colors.amber),
                                                    ),
                                                    child: const Text(
                                                      'Destacado',
                                                      style: TextStyle(
                                                        color: Colors.amber,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                              ],
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
                                              children: [
                                                Text(
                                                  '\$${(product['precio'] as double).toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFFFF8C00),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    category['nombre'] as String,
                                                    style: TextStyle(
                                                      color: Colors.grey.shade700,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Estado y acciones
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: product['disponible'] as bool
                                                  ? Colors.green.withOpacity(0.2)
                                                  : Colors.red.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: product['disponible'] as bool
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                            child: Text(
                                              product['disponible'] as bool ? 'Disponible' : 'No disponible',
                                              style: TextStyle(
                                                color: product['disponible'] as bool
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.blue),
                                                onPressed: () {
                                                  // Editar producto
                                                },
                                                tooltip: 'Editar',
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  product['disponible'] as bool
                                                      ? Icons.toggle_on
                                                      : Icons.toggle_off,
                                                  color: product['disponible'] as bool
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                                onPressed: () {
                                                  // Cambiar disponibilidad
                                                },
                                                tooltip: product['disponible'] as bool
                                                    ? 'Desactivar'
                                                    : 'Activar',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            
            // Pestaña de Categorías
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de búsqueda
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar categoría...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Lista de categorías
                  Expanded(
                    child: categories.isEmpty
                        ? const Center(
                            child: Text('No hay categorías registradas'),
                          )
                        : ListView.builder(
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFFF8C00),
                                    child: Icon(
                                      _getProductIcon(category['nombre'] as String),
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    category['nombre'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          // Editar categoría
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          // Eliminar categoría
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navegar a la pantalla de creación de producto o categoría según la pestaña activa
          },
          backgroundColor: const Color(0xFFFF8C00),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
  
  IconData _getProductIcon(String categoryName) {
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
