class User {
  final String id;
  final String email;
  final String nombre;
  final String apellido;
  final String telefono;
  final int rolId;
  final bool activo;
  final String? fechaRegistro;
  final String? ultimoAcceso;
  
  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.rolId,
    required this.activo,
    this.fechaRegistro,
    this.ultimoAcceso,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      telefono: json['telefono'],
      rolId: json['rol_id'],
      activo: json['activo'],
      fechaRegistro: json['fecha_registro'],
      ultimoAcceso: json['ultimo_acceso'],
    );
  }
  
  String get fullName => '$nombre $apellido';
  
  String get roleName {
    switch (rolId) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Empleado';
      case 3:
        return 'Repartidor';
      case 4:
        return 'Cliente';
      default:
        return 'Usuario';
    }
  }
}
