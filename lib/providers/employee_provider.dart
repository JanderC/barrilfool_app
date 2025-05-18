import 'package:flutter/foundation.dart';
import 'package:barrilfood_app/api/employee_api.dart';
import 'package:barrilfood_app/models/user.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeApi _employeeApi = EmployeeApi();
  List<User> _employees = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<User> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Obtener todos los empleados
  Future<void> fetchEmployees(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _employees = await _employeeApi.getAllEmployees(token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Crear un nuevo empleado
  Future<bool> createEmployee(Map<String, dynamic> employeeData, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newEmployee = await _employeeApi.createEmployee(employeeData, token);
      _employees.add(newEmployee);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Actualizar un empleado existente
  Future<bool> updateEmployee(String employeeId, Map<String, dynamic> employeeData, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedEmployee = await _employeeApi.updateEmployee(employeeId, employeeData, token);
      final index = _employees.indexWhere((emp) => emp.id == employeeId);
      if (index != -1) {
        _employees[index] = updatedEmployee;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Cambiar el estado de un empleado (activar/desactivar)
  Future<bool> toggleEmployeeStatus(String employeeId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedEmployee = await _employeeApi.toggleEmployeeStatus(employeeId, token);
      final index = _employees.indexWhere((emp) => emp.id == employeeId);
      if (index != -1) {
        _employees[index] = updatedEmployee;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Eliminar un empleado
  Future<bool> deleteEmployee(String employeeId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final success = await _employeeApi.deleteEmployee(employeeId, token);
      if (success) {
        _employees.removeWhere((emp) => emp.id == employeeId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Filtrar empleados
  List<User> filterEmployees({String? searchQuery, String? filter}) {
    List<User> filteredList = List.from(_employees);
    
    // Aplicar filtro de búsqueda
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredList = filteredList.where((emp) {
        final fullName = '${emp.nombre} ${emp.apellido}'.toLowerCase();
        final email = emp.email.toLowerCase();
        final query = searchQuery.toLowerCase();
        return fullName.contains(query) || email.contains(query);
      }).toList();
    }
    
    // Aplicar filtro de categoría
    if (filter != null) {
      switch (filter) {
        case 'active':
          filteredList = filteredList.where((emp) => emp.activo).toList();
          break;
        case 'inactive':
          filteredList = filteredList.where((emp) => !emp.activo).toList();
          break;
        case 'employee':
          filteredList = filteredList.where((emp) => emp.rolId == 2).toList();
          break;
        case 'delivery':
          filteredList = filteredList.where((emp) => emp.rolId == 3).toList();
          break;
      }
    }
    
    return filteredList;
  }
}