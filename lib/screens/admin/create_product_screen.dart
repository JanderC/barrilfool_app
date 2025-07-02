// screens/admin/create_product_screen.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barrilfood_app/providers/product_provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';
import 'package:barrilfood_app/models/product.dart';
import 'package:barrilfood_app/models/category.dart';

class CreateProductScreen extends StatefulWidget {
  final Product? product; // Para editar producto existente
  
  const CreateProductScreen({super.key, this.product});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _tiempoPreparacionController = TextEditingController();
  
  int? _selectedCategoryId;
  bool _disponible = true;
  bool _destacado = false;
  File? _selectedImage;
  String? _imageBase64;
  bool _isLoading = false;
  
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    // Cargar categorías al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchCategories();
    });
    
    if (widget.product != null) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    final product = widget.product!;
    _nombreController.text = product.nombre;
    _descripcionController.text = product.descripcion ?? '';
    _precioController.text = product.precio.toString();
    _tiempoPreparacionController.text = product.tiempoPreparacion?.toString() ?? '';
    _selectedCategoryId = product.categoriaId;
    _disponible = product.disponible;
    _destacado = product.destacado;
    _imageBase64 = product.imagenUrl;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _tiempoPreparacionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final String base64String = base64Encode(imageBytes);
        
        // Obtener el tipo de imagen
        String mimeType = 'image/jpeg';
        if (image.path.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (image.path.toLowerCase().endsWith('.gif')) {
          mimeType = 'image/gif';
        } else if (image.path.toLowerCase().endsWith('.webp')) {
          mimeType = 'image/webp';
        }
        
        setState(() {
          _selectedImage = imageFile;
          _imageBase64 = 'data:$mimeType;base64,$base64String';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar imagen: ${e.toString()}');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final String base64String = base64Encode(imageBytes);
        
        setState(() {
          _selectedImage = imageFile;
          _imageBase64 = 'data:image/jpeg;base64,$base64String';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al tomar foto: ${e.toString()}');
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              if (_imageBase64 != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Eliminar imagen'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _imageBase64 = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
      try {
        // Si es una URL base64 completa, extraer solo los datos
        String base64Data = _imageBase64!;
        if (base64Data.contains(',')) {
          base64Data = base64Data.split(',').last;
        }
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.grey,
            ),
          ),
        );
      }
    } else {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.add_photo_alternate,
            size: 50,
            color: Colors.grey,
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      _showErrorSnackBar('Selecciona una categoría');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final productProvider = context.read<ProductProvider>();
      
      if (authProvider.token == null) {
        _showErrorSnackBar('No estás autenticado');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Preparar datos del producto
      final productData = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precio': double.parse(_precioController.text),
        'tiempo_preparacion': _tiempoPreparacionController.text.isNotEmpty 
            ? int.parse(_tiempoPreparacionController.text) 
            : null,
        'categoria_id': _selectedCategoryId,
        'disponible': _disponible,
        'destacado': _destacado,
      };

      // Agregar imagen si existe
      if (_imageBase64 != null && _imageBase64!.isNotEmpty) {
        productData['imagen_base64'] = _imageBase64;
      }

      bool success;
      if (widget.product == null) {
        // Crear nuevo producto
        success = await productProvider.createProduct(productData, authProvider.token!);
      } else {
        // Actualizar producto existente
        success = await productProvider.modifyProduct(
          widget.product!.id,
          productData,
          authProvider.token!,
        );
      }

      if (success) {
        _showSuccessSnackBar(widget.product == null 
            ? 'Producto creado exitosamente' 
            : 'Producto actualizado exitosamente');
        
        // Recargar la lista de productos
        await productProvider.fetchProducts();
        
        // Regresar a la pantalla anterior
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar(productProvider.error ?? 'Error al procesar el producto');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Crear Producto' : 'Editar Producto'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagen del producto
                  Card(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Imagen del Producto',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showImageOptions,
                          child: _buildImageWidget(),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showImageOptions,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Seleccionar Imagen'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Información básica
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información Básica',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Nombre del producto
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre del Producto',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.fastfood),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La descripción es requerida';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Categoría
                          DropdownButtonFormField<int>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: productProvider.categories.map((category) {
                              return DropdownMenuItem<int>(
                                value: category.id,
                                child: Text(category.nombre),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecciona una categoría';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Precio y tiempo
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Precio y Tiempo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Precio
                          TextFormField(
                            controller: _precioController,
                            decoration: const InputDecoration(
                              labelText: 'Precio',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                              suffixText: '\$',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El precio es requerido';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Ingresa un precio válido';
                              }
                              if (double.parse(value) <= 0) {
                                return 'El precio debe ser mayor a 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Tiempo de preparación
                          TextFormField(
                            controller: _tiempoPreparacionController,
                            decoration: const InputDecoration(
                              labelText: 'Tiempo de Preparación (minutos)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer),
                              suffixText: 'min',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                if (int.tryParse(value) == null) {
                                  return 'Ingresa un tiempo válido';
                                }
                                if (int.parse(value) <= 0) {
                                  return 'El tiempo debe ser mayor a 0';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Configuraciones adicionales
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Configuraciones',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Disponible
                          SwitchListTile(
                            title: const Text('Producto Disponible'),
                            subtitle: const Text('Los clientes pueden ver y ordenar este producto'),
                            value: _disponible,
                            onChanged: (value) {
                              setState(() {
                                _disponible = value;
                              });
                            },
                          ),

                          // Destacado
                          SwitchListTile(
                            title: const Text('Producto Destacado'),
                            subtitle: const Text('Se mostrará en la sección de productos destacados'),
                            value: _destacado,
                            onChanged: (value) {
                              setState(() {
                                _destacado = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de guardar
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.product == null ? 'Crear Producto' : 'Actualizar Producto',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}