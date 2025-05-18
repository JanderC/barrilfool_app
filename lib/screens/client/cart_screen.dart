import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para el carrito
    final cartItems = [
      {
        'id': 1,
        'nombre': 'Hamburguesa Clásica',
        'precio': 8.99,
        'cantidad': 2,
        'imagen': 'assets/hamburguesa_clasica.jpg',
      },
      {
        'id': 3,
        'nombre': 'Alitas BBQ',
        'precio': 9.99,
        'cantidad': 1,
        'imagen': 'assets/alitas_bbq.jpg',
      },
    ];
    
    // Calcular subtotal
    double subtotal = 0;
    for (var item in cartItems) {
      subtotal += (item['precio'] as double) * (item['cantidad'] as int);
    }
    
    // Costos adicionales
    const double envio = 2.50;
    const double impuestos = 0; // Asumimos que los impuestos están incluidos
    final double total = subtotal + envio;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu Carrito',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de productos en el carrito
          Expanded(
            child: cartItems.isEmpty
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
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
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
                                    child: Image.network(
                                      'https://via.placeholder.com/80x80/FF8C00/FFFFFF?text=${item['nombre']}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                        const Center(child: Icon(Icons.image_not_supported)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Información del producto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nombre'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${(item['precio'] as double).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Color(0xFFFF8C00),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Controles de cantidad
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () {
                                        // Disminuir cantidad
                                      },
                                    ),
                                    Text(
                                      '${item['cantidad']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        // Aumentar cantidad
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Resumen del pedido
          if (cartItems.isNotEmpty) ...[
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('\$${subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            
            // Costo de envío
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Envío'),
                Text('\$${envio.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            
            // Impuestos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Impuestos'),
                Text('\$${impuestos.toStringAsFixed(2)}'),
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
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFFF8C00),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botón de pago
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Procesar el pago
                },
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
        ],
      ),
    );
  }
}
