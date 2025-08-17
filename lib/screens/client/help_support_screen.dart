import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
        backgroundColor: const Color(0xFFFF8C00),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con logo/información de la app
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF8C00),
                    const Color(0xFFFF8C00).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: const Color(0xFFFF8C00),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'BarrilFood',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu app de delivery favorita',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información de la aplicación
            _buildInfoCard(
              title: 'Acerca de BarrilFood',
              icon: Icons.info_outline,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Versión', '1.0.0'),
                  _buildInfoRow('Desarrollada por', 'Paola Ayala, Nelson Sierra, Jean Avila, Johnson Novoa'),
                  _buildInfoRow('Última actualización', 'Agosto 2025'),
                  const SizedBox(height: 12),
                  const Text(
                    'BarrilFood es tu plataforma de delivery de confianza, conectándote con los mejores restaurantes y productos de tu zona. Disfruta de comida deliciosa desde la comodidad de tu hogar.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contacto y soporte
            _buildInfoCard(
              title: 'Contacto y Soporte',
              icon: Icons.support_agent,
              content: Column(
                children: [
                  // WhatsApp de gerencia
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.chat,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'WhatsApp Gerencia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Para más información, dudas o soporte técnico, comunícate directamente con nuestra gerencia:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.green.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '04160467960',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _copyToClipboard(context, '04160467960'),
                              icon: Icon(
                                Icons.copy,
                                color: Colors.green.shade600,
                              ),
                              tooltip: 'Copiar número',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openWhatsApp('04160467960'),
                            icon: const Icon(Icons.chat),
                            label: const Text('ABRIR WHATSAPP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Preguntas frecuentes
            _buildInfoCard(
              title: 'Preguntas Frecuentes',
              icon: Icons.help_outline,
              content: Column(
                children: [
                  _buildFAQItem(
                    '¿Cómo realizo un pedido?',
                    'Navega por nuestro catálogo, selecciona los productos que deseas, agrégalos al carrito y procede al checkout.',
                  ),
                  _buildFAQItem(
                    '¿Cuáles son los métodos de pago?',
                    'Aceptamos pagos en efectivo, transferencias bancarias y métodos de pago digital.',
                  ),
                  _buildFAQItem(
                    '¿Cuánto tiempo tarda la entrega?',
                    'El tiempo de entrega varía según tu ubicación y el restaurante, generalmente entre 30-60 minutos.',
                  ),
                  _buildFAQItem(
                    '¿Puedo cancelar mi pedido?',
                    'Puedes cancelar tu pedido si aún no ha sido confirmado por el restaurante. Contacta a soporte para más información.',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            
            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'BarrilFood © 2025',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hecho con ❤️ para conectarte con la mejor comida',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
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
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFFF8C00),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
      iconColor: const Color(0xFFFF8C00),
      collapsedIconColor: Colors.grey.shade600,
    );
  }
  
  Widget _buildLegalItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFFFF8C00),
        size: 20,
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Aquí podrías navegar a las pantallas correspondientes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abriendo $title...'),
          ),
        );
      },
    );
  }
  
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Número copiado al portapapeles'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _openWhatsApp(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber?text=Hola,%20necesito%20ayuda%20con%20BarrilFood';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        // Fallback: copiar número al portapapeles
        Clipboard.setData(ClipboardData(text: phoneNumber));
      }
    } catch (e) {
      // Si no se puede abrir WhatsApp, copiar número
      Clipboard.setData(ClipboardData(text: phoneNumber));
    }
  }
}