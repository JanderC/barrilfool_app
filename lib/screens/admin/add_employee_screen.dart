import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barrilfood_app/api/employee_api.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int? _role;

  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final String? token = authProvider.token;

    final employeeData = {
      'nombre': _nameController.text.trim(),
      'apellido': _lastNameController.text.trim(), // si lo implementas
      'email': _emailController.text.trim(),
      'telefono': _phoneController.text.trim(),
      'password': _passwordController.text.trim(),
      'rol_id': _role, // ✅ Aquí ya es un entero (2 o 3)
    };

    try {
      final api = EmployeeApi();
      await api.createEmployee(employeeData, token!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Empleado añadido correctamente')),
      );
      Navigator.of(context).pop(true); // Indicamos éxito al volver
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Error al crear empleado: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFFF8C00), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: const Text('Añadir Empleado'),
        backgroundColor: const Color(0xFFFF8C00),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Nombre completo', Icons.person),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Ingrese el nombre'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: _inputDecoration(
                    'Apellido',
                    Icons.person_outline,
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Ingrese el apellido'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration(
                    'Correo electrónico',
                    Icons.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el correo';
                    }
                    if (!value.contains('@')) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration('Teléfono', Icons.phone),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Ingrese el teléfono'
                              : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _role,
                  decoration: _inputDecoration('Rol', Icons.badge),
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('Empleado')),
                    DropdownMenuItem(value: 3, child: Text('Repartidor')),
                  ],
                  onChanged: (value) => setState(() => _role = value),
                  validator:
                      (value) => value == null ? 'Seleccione un rol' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: _inputDecoration('Contraseña', Icons.lock),
                  obscureText: true,
                  validator:
                      (value) =>
                          value == null || value.length < 6
                              ? 'La contraseña debe tener al menos 6 caracteres'
                              : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFFF8C00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    label:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Guardar Empleado',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
