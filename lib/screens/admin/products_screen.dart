import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_product_screen.dart';
import 'package:barrilfood_app/providers/category_provider.dart';
import 'package:barrilfood_app/providers/product_provider.dart';
import 'package:barrilfood_app/models/category.dart' as my_models;
import 'package:barrilfood_app/models/product.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

// Función helper para convertir base64 a Uint8List
Uint8List _base64ToImage(String base64String) {
  String cleanBase64 = base64String;
  if (base64String.contains(',')) {
    cleanBase64 = base64String.split(',').last;
  }
  return base64Decode(cleanBase64);
}

bool _isUrl(String value) {
  return value.startsWith('http://') || value.startsWith('https://');
}

Widget _buildDefaultImage(String? categoryName) {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.grey.shade300,
    ),
    child: Center(
      child: Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey.shade600,
      ),
    ),
  );
}

bool _isBase64(String value) {
  try {
    String cleanBase64 = value;
    if (value.contains(',')) {
      cleanBase64 = value.split(',').last;
    }
    // Verificar que solo contenga caracteres válidos de base64
    final RegExp base64RegExp = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    if (!base64RegExp.hasMatch(cleanBase64)) {
      return false;
    }
    // Intentar decodificar
    base64Decode(cleanBase64);
    return true;
  } catch (e) {
    return false;
  }
}

class _ProductsScreenState extends State<ProductsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();

  String _selectedFilter = 'all';
  String _categorySearchTerm = '';
  String _productSearchTerm = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar los datos al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _categorySearchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // Cargar categorías y productos en paralelo
    await Future.wait([
      categoryProvider.fetchCategories(showInactive: true),
      productProvider.fetchProducts(),
    ]);
  }

  Future<void> _refreshData() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    await Future.wait([
      categoryProvider.fetchCategories(showInactive: true),
      productProvider.refreshData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Productos'), Tab(text: 'Categorías')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña de Productos
          _buildProductsTab(),

          // Pestaña de Categorías
          _buildCategoriesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFloatingActionButtonPressed,
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildImageWidget(dynamic product, dynamic category) {
    // Si imagenUrl es null o está vacío, mostrar icono de categoría
    if (product.imagenUrl == null || product.imagenUrl!.isEmpty) {
      return Center(
        child: Icon(
          _getProductIcon(category?.nombre ?? 'default'),
          size: 40,
          color: const Color(0xFFFF8C00),
        ),
      );
    }

    String imageUrl = product.imagenUrl!;

    // Si es una URL, usar Image.network
    if (_isUrl(imageUrl)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                _getProductIcon(category?.nombre ?? 'default'),
                size: 40,
                color: const Color(0xFFFF8C00),
              ),
            );
          },
        ),
      );
    }

    // Si es base64 válido, usar Image.memory
    if (_isBase64(imageUrl)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          _base64ToImage(imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                _getProductIcon(category?.nombre ?? 'default'),
                size: 40,
                color: const Color(0xFFFF8C00),
              ),
            );
          },
        ),
      );
    }

    // Si no es ni URL ni base64 válido, mostrar icono de categoría por defecto
    return Center(
      child: Icon(
        _getProductIcon(category?.nombre ?? 'default'),
        size: 40,
        color: const Color(0xFFFF8C00),
      ),
    );
  }

  Widget _buildProductsTab() {
    return Consumer2<ProductProvider, CategoryProvider>(
      builder: (context, productProvider, categoryProvider, child) {
        if (productProvider.isLoading && productProvider.products.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
          );
        }

        if (productProvider.error != null && productProvider.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar productos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  productProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    productProvider.clearError();
                    await productProvider.fetchProducts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final filteredProducts = _getFilteredProducts(productProvider.products);

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de búsqueda y filtros
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar producto...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _productSearchTerm = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedFilter,
                      hint: const Text('Filtrar'),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Todos')),
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
                        setState(() {
                          _selectedFilter = value ?? 'all';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Información de productos
                if (filteredProducts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF8C00).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFFF8C00),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${filteredProducts.length} producto${filteredProducts.length != 1 ? 's' : ''} encontrado${filteredProducts.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Color(0xFFFF8C00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Lista de productos
                Expanded(
                  child:
                      filteredProducts.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _productSearchTerm.isEmpty &&
                                          _selectedFilter == 'all'
                                      ? 'No hay productos registrados'
                                      : 'No se encontraron productos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (_productSearchTerm.isEmpty &&
                                    _selectedFilter == 'all') ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Presiona el botón + para crear un nuevo producto',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              final category = productProvider.getCategoryById(
                                product.categoriaId,
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: _buildImageWidget(
                                          product,
                                          category,
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Información del producto
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    product.nombre,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (product.destacado)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.amber,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Destacado',
                                                      style: TextStyle(
                                                        color: Colors.amber,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            if (product.descripcion != null &&
                                                product.descripcion!.isNotEmpty)
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
                                              children: [
                                                Text(
                                                  '\$${product.precio.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFFFF8C00),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    category?.nombre ??
                                                        'Sin categoría',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  product.disponible
                                                      ? Colors.green
                                                          .withOpacity(0.2)
                                                      : Colors.red.withOpacity(
                                                        0.2,
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    product.disponible
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            ),
                                            child: Text(
                                              product.disponible
                                                  ? 'Disponible'
                                                  : 'No disponible',
                                              style: TextStyle(
                                                color:
                                                    product.disponible
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
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () {
                                                  _navigateToEditProduct(
                                                    product,
                                                  );
                                                },
                                                tooltip: 'Editar',
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  product.disponible
                                                      ? Icons.toggle_on
                                                      : Icons.toggle_off,
                                                  color:
                                                      product.disponible
                                                          ? Colors.green
                                                          : Colors.red,
                                                ),
                                                onPressed: () {
                                                  _toggleProductAvailability(
                                                    product.id,
                                                  );
                                                },
                                                tooltip:
                                                    product.disponible
                                                        ? 'Desactivar'
                                                        : 'Activar',
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  product.destacado
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color:
                                                      product.destacado
                                                          ? Colors.amber
                                                          : Colors.grey,
                                                ),
                                                onPressed: () {
                                                  _toggleProductFeatured(
                                                    product.id,
                                                  );
                                                },
                                                tooltip:
                                                    product.destacado
                                                        ? 'Quitar destacado'
                                                        : 'Marcar como destacado',
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
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
          );
        }

        if (categoryProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar categorías',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categoryProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await categoryProvider.fetchCategories(showInactive: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        final categories = _getFilteredCategories(categoryProvider.categories);

        return RefreshIndicator(
          onRefresh: () async {
            await categoryProvider.fetchCategories(showInactive: true);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de búsqueda
                TextField(
                  controller: _categorySearchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar categoría...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _categorySearchTerm = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Información de categorías
                if (categories.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF8C00).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFFF8C00),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${categories.length} categoría${categories.length != 1 ? 's' : ''} encontrada${categories.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Color(0xFFFF8C00),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Lista de categorías
                Expanded(
                  child:
                      categories.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _categorySearchTerm.isEmpty
                                      ? 'No hay categorías registradas'
                                      : 'No se encontraron categorías',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (_categorySearchTerm.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Presiona el botón + para crear una nueva categoría',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
                                    backgroundColor:
                                        category.activo
                                            ? const Color(0xFFFF8C00)
                                            : Colors.grey,
                                    child: Icon(
                                      _getProductIcon(category.nombre),
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    category.nombre,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          category.activo
                                              ? Colors.black
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    category.activo ? 'Activa' : 'Inactiva',
                                    style: TextStyle(
                                      color:
                                          category.activo
                                              ? Colors.green
                                              : Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          _showEditCategoryDialog(category);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          category.activo
                                              ? Icons.toggle_on
                                              : Icons.toggle_off,
                                          color:
                                              category.activo
                                                  ? Colors.green
                                                  : Colors.red,
                                        ),
                                        onPressed: () {
                                          _toggleCategoryStatus(category);
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
        );
      },
    );
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    List<Product> filtered = products;

    // Aplicar filtro de búsqueda
    if (_productSearchTerm.isNotEmpty) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      filtered = productProvider.searchProducts(_productSearchTerm);
    }

    // Aplicar filtros de estado
    switch (_selectedFilter) {
      case 'available':
        filtered = filtered.where((product) => product.disponible).toList();
        break;
      case 'unavailable':
        filtered = filtered.where((product) => !product.disponible).toList();
        break;
      case 'featured':
        filtered = filtered.where((product) => product.destacado).toList();
        break;
      case 'all':
      default:
        // No filtrar
        break;
    }

    return filtered;
  }

  List<my_models.Category> _getFilteredCategories(
    List<my_models.Category> categories,
  ) {
    if (_categorySearchTerm.isEmpty) {
      return categories;
    }

    return categories.where((category) {
      return category.nombre.toLowerCase().contains(
        _categorySearchTerm.toLowerCase(),
      );
    }).toList();
  }

  void _onFloatingActionButtonPressed() {
    if (_tabController.index == 0) {
      _navigateToCreateProduct();
    } else {
      _showCreateCategoryDialog();
    }
  }

  void _navigateToCreateProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateProductScreen()),
    );

    if (result == true) {
      // Recargar productos después de crear uno nuevo
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      await productProvider.fetchProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lista de productos actualizada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _navigateToEditProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateProductScreen(),
        // TODO: Pasar el producto como argumento para editarlo
        // builder: (context) => CreateProductScreen(product: product),
      ),
    );

    if (result == true) {
      // Recargar productos después de editar
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      await productProvider.fetchProducts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Producto actualizado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _toggleProductAvailability(int productId) async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // TODO: Obtener el token del usuario autenticado
    const token = '';

    final success = await productProvider.toggleProductAvailability(
      productId,
      token,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado de disponibilidad actualizado'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cambiar disponibilidad: ${productProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleProductFeatured(int productId) async {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

    // TODO: Obtener el token del usuario autenticado
    const token = '';

    final success = await productProvider.toggleProductFeatured(
      productId,
      token,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado destacado actualizado'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cambiar estado destacado: ${productProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreateCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nueva Categoría'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              hintText: 'Nombre de la categoría',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _createCategory(categoryController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(my_models.Category category) {
    final TextEditingController categoryController = TextEditingController();
    categoryController.text = category.nombre;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Categoría'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              hintText: 'Nombre de la categoría',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateCategory(category.id, categoryController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createCategory(String categoryName) async {
    if (categoryName.isEmpty) return;

    Navigator.of(context).pop();

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Verificar si la categoría ya existe
    if (categoryProvider.categoryExists(categoryName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya existe una categoría con ese nombre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final categoryData = {'nombre': categoryName, 'activo': true};

    // Nota: Necesitarás obtener el token del usuario autenticado
    // const token = 'your_auth_token_here';
    const token = ''; // Por ahora vacío hasta que implementes autenticación

    final success = await categoryProvider.createCategory(categoryData, token);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Categoría "$categoryName" creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al crear la categoría: ${categoryProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateCategory(int categoryId, String categoryName) async {
    if (categoryName.isEmpty) return;

    Navigator.of(context).pop();

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Verificar si la categoría ya existe (excluyendo la actual)
    if (categoryProvider.categoryExists(categoryName, excludeId: categoryId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya existe una categoría con ese nombre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final categoryData = {'nombre': categoryName};

    // Nota: Necesitarás obtener el token del usuario autenticado
    const token = '';

    final success = await categoryProvider.updateCategory(
      categoryId,
      categoryData,
      token,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Categoría "$categoryName" actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al actualizar la categoría: ${categoryProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleCategoryStatus(my_models.Category category) async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Nota: Necesitarás obtener el token del usuario autenticado
    const token = '';

    final success = await categoryProvider.toggleCategoryStatus(
      category.id,
      token,
    );

    if (success) {
      final newStatus = !category.activo;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Categoría "${category.nombre}" ${newStatus ? 'activada' : 'desactivada'} exitosamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cambiar el estado: ${categoryProvider.error}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
