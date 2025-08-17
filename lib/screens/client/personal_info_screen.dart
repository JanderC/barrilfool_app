import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Personal'),
        backgroundColor: const Color(0xFFFF8C00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y nombre
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFFF8C00),
                    child: Text(
                      user?.nombre.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Información personal
            _buildInfoCard(
              title: 'Información de Contacto',
              children: [
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'Nombre completo',
                  value: user?.fullName ?? 'No especificado',
                ),
                _buildInfoRow(
                  icon: Icons.email,
                  label: 'Correo electrónico',
                  value: user?.email ?? 'No especificado',
                ),
                _buildInfoRow(
                  icon: Icons.phone,
                  label: 'Teléfono',
                  value: user?.telefono ?? 'No especificado',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoCard(
              title: 'Información de la Cuenta',
              children: [
                _buildInfoRow(
                  icon: Icons.badge,
                  label: 'Rol',
                  value: user?.roleName ?? 'Cliente',
                ),
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Miembro desde',
                  value: user?.fechaRegistro != null 
                    ? _formatDateString(user!.fechaRegistro!)
                    : 'No especificado',
                ),
                _buildInfoRow(
                  icon: Icons.verified_user,
                  label: 'Estado de la cuenta',
                  value: user?.activo == true ? 'Activa' : 'Inactiva',
                  valueColor: user?.activo == true ? Colors.green : Colors.red,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Botón de editar perfil
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showEditDialog(context, user);
                },
                icon: const Icon(Icons.edit),
                label: const Text('EDITAR INFORMACIÓN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8C00),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDateString(String dateString) {
    try {
      // Intenta parsear la fecha desde string
      DateTime date = DateTime.parse(dateString);
      return _formatDate(date);
    } catch (e) {
      // Si no se puede parsear, devuelve el string original o un formato simple
      return dateString;
    }
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${date.day} de ${months[date.month - 1]} ${date.year}';
  }
  
  void _showEditDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Información'),
        content: const Text(
          'Para modificar tu información personal, contacta con nuestro soporte a través de WhatsApp.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí podrías abrir WhatsApp o mostrar el número
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contacta al 04160467960 para modificar tus datos'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8C00),
            ),
            child: const Text('Contactar Soporte', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}