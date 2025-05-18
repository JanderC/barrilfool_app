import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barrilfood_app/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del perfil
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFFFF8C00),
                child: Text(
                  user?.nombre.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'email@ejemplo.com',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.roleName ?? 'Cliente',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Secciones del perfil
          _buildSection(
            context,
            title: 'Información Personal',
            icon: Icons.person,
            onTap: () {
              // Navegar a la pantalla de edición de perfil
            },
          ),
          
          _buildSection(
            context,
            title: 'Mis Direcciones',
            icon: Icons.location_on,
            onTap: () {
              // Navegar a la pantalla de direcciones
            },
          ),
          
          _buildSection(
            context,
            title: 'Métodos de Pago',
            icon: Icons.payment,
            onTap: () {
              // Navegar a la pantalla de métodos de pago
            },
          ),
          
          _buildSection(
            context,
            title: 'Notificaciones',
            icon: Icons.notifications,
            onTap: () {
              // Navegar a la pantalla de notificaciones
            },
          ),
          
          _buildSection(
            context,
            title: 'Ayuda y Soporte',
            icon: Icons.help,
            onTap: () {
              // Navegar a la pantalla de ayuda
            },
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Botón de cerrar sesión
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                authProvider.logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('CERRAR SESIÓN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: const Color(0xFFFF8C00),
          ),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
