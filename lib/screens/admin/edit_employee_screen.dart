import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barrilfood_app/providers/employee_provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';
import 'package:barrilfood_app/models/user.dart';
import 'package:barrilfood_app/widgets/custom_text_field.dart';

class EditEmployeeScreen extends StatefulWidget {
  final User employee;

  const EditEmployeeScreen({super.key, required this.employee});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _changePassword = false;

  // Controladores para los campos del formulario
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _telefonoController;

  late int _selectedRol;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con los datos del empleado
    _nombreController = TextEditingController(text: widget.employee.nombre);
    _apellidoController = TextEditingController(text: widget.employee.apellido);
    _emailController = TextEditingController(text: widget.employee.email);
    _passwordController = TextEditingController();
    _telefonoController = TextEditingController(text: widget.employee.telefono);

    _selectedRol = widget.employee.rolId;
  }

  // Limpiar controladores al salir
  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // Validaciones para el formulario
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }

    // Validación simple de email
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Ingresa un email válido';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    // Si no se está cambiando la contraseña, no validamos
    if (!_changePassword) return null;

    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }

    // Validar que solo contenga números
    final phoneRegExp = RegExp(r'^\d+$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'El teléfono debe contener solo números';
    }

    return null;
  }

  // Actualizar el empleado
  Future<void> _updateEmployee() async {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Preparar los datos del empleado
    final employeeData = {
      'nombre': _nombreController.text.trim(),
      'apellido': _apellidoController.text.trim(),
      'email': _emailController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'rol_id': _selectedRol,
    };

    // Añadir contraseña solo si se está cambiando
    if (_changePassword && _passwordController.text.isNotEmpty) {
      employeeData['password'] = _passwordController.text;
    }

    // Obtener el token y proveedor de empleados
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employeeProvider = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    );

    try {
      // Actualizar el empleado
      final success = await employeeProvider.updateEmployee(
        widget.employee.id,
        employeeData,
        authProvider.token!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado actualizado exitosamente')),
        );

        // Regresar a la pantalla anterior con resultado exitoso
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar empleado: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Empleado')),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF8C00)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                widget.employee.activo
                                    ? const Color(0xFFFF8C00)
                                    : Colors.grey,
                            child: Text(
                              '${widget.employee.nombre.substring(0, 1)}${widget.employee.apellido.substring(0, 1)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Editar información',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'ID: ${widget.employee.id}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Nombre y apellido
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _nombreController,
                              labelText: 'Nombre',
                              prefixIcon: const Icon(Icons.person),
                              validator:
                                  (value) =>
                                      _validateRequiredField(value, 'Nombre'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _apellidoController,
                              labelText: 'Apellido',
                              prefixIcon: const Icon(Icons.person),
                              validator:
                                  (value) =>
                                      _validateRequiredField(value, 'Apellido'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),

                      // Cambiar contraseña (checkbox)
                      Row(
                        children: [
                          Checkbox(
                            value: _changePassword,
                            activeColor: const Color(0xFFFF8C00),
                            onChanged: (value) {
                              setState(() {
                                _changePassword = value ?? false;
                              });
                            },
                          ),
                          const Text('Cambiar contraseña'),
                        ],
                      ),

                      // Mostrar campo de contraseña solo si se va a cambiar
                      if (_changePassword) ...[
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Nueva contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Teléfono
                      CustomTextField(
                        controller: _telefonoController,
                        labelText: 'Teléfono',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 24),

                      // Selección de rol
                      const Text(
                        'Tipo de empleado',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('Empleado'),
                              value: 2,
                              groupValue: _selectedRol,
                              activeColor: const Color(0xFFFF8C00),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRol = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text('Repartidor'),
                              value: 3,
                              groupValue: _selectedRol,
                              activeColor: const Color(0xFFFF8C00),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRol = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón Cancelar
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              side: const BorderSide(color: Color(0xFFFF8C00)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Color(0xFFFF8C00)),
                            ),
                          ),

                          // Botón Guardar
                          ElevatedButton(
                            onPressed: _updateEmployee,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8C00),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Guardar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
