import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barrilfood_app/providers/employee_provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';
import 'package:barrilfood_app/models/user.dart';
import 'package:barrilfood_app/screens/admin/add_employee_screen.dart';
import 'package:barrilfood_app/screens/admin/edit_employee_screen.dart';
import 'package:barrilfood_app/widgets/loading_indicator.dart';
import 'package:barrilfood_app/widgets/error_message.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _searchQuery = '';
  String? _selectedFilter;
  bool _isLoading = false;
  bool _isInit = true; // <--- Agregado

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadEmployees(); // <--- Llamado correctamente aquí
      });
    }
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final employeeProvider = Provider.of<EmployeeProvider>(
        context,
        listen: false,
      );

      await employeeProvider.fetchEmployees(authProvider.token!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar empleados: ${e.toString()}')),
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

  Future<void> _toggleEmployeeStatus(String employeeId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employeeProvider = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    );

    try {
      final success = await employeeProvider.toggleEmployeeStatus(
        employeeId,
        authProvider.token!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado del empleado actualizado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar estado: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteEmployee(String employeeId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employeeProvider = Provider.of<EmployeeProvider>(
      context,
      listen: false,
    );

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: const Text(
                '¿Estás seguro de que deseas eliminar este empleado? Esta acción no se puede deshacer.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );

      if (confirmed == true) {
        final success = await employeeProvider.deleteEmployee(
          employeeId,
          authProvider.token!,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empleado eliminado correctamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar empleado: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final filteredEmployees = employeeProvider.filterEmployees(
      searchQuery: _searchQuery,
      filter: _selectedFilter,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Empleados'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body:
          _isLoading
              ? const LoadingIndicator(message: 'Cargando empleados...')
              : employeeProvider.error != null
              ? ErrorMessage(
                message: 'Error: ${employeeProvider.error}',
                onRetry: _loadEmployees,
              )
              : Padding(
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
                              hintText: 'Buscar empleado...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          hint: const Text('Filtrar'),
                          value: _selectedFilter,
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Todos')),
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('Activos'),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Text('Inactivos'),
                            ),
                            DropdownMenuItem(
                              value: 'employee',
                              child: Text('Empleados'),
                            ),
                            DropdownMenuItem(
                              value: 'delivery',
                              child: Text('Repartidores'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Lista de empleados
                    Expanded(
                      child:
                          filteredEmployees.isEmpty
                              ? const Center(
                                child: Text(
                                  'No hay empleados que coincidan con tu búsqueda',
                                ),
                              )
                              : RefreshIndicator(
                                onRefresh: _loadEmployees,
                                child: ListView.builder(
                                  itemCount: filteredEmployees.length,
                                  itemBuilder: (context, index) {
                                    final employee = filteredEmployees[index];
                                    return _buildEmployeeCard(employee);
                                  },
                                ),
                              ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          );

          if (result == true) {
            _loadEmployees();
          }
        },
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmployeeCard(User employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar del empleado
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  employee.activo ? const Color(0xFFFF8C00) : Colors.grey,
              child: Text(
                '${employee.nombre.substring(0, 1)}${employee.apellido.substring(0, 1)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Información del empleado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${employee.nombre} ${employee.apellido}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.email,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        employee.telefono,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.badge, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        employee.rolId == 2 ? 'Empleado' : 'Repartidor',
                        style: TextStyle(color: Colors.grey.shade600),
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
                    color:
                        employee.activo
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: employee.activo ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    employee.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: employee.activo ? Colors.green : Colors.red,
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
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EditEmployeeScreen(employee: employee),
                          ),
                        );

                        if (result == true) {
                          _loadEmployees();
                        }
                      },
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      icon: Icon(
                        employee.activo ? Icons.toggle_on : Icons.toggle_off,
                        color: employee.activo ? Colors.green : Colors.red,
                      ),
                      onPressed: () => _toggleEmployeeStatus(employee.id),
                      tooltip: employee.activo ? 'Desactivar' : 'Activar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEmployee(employee.id),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
