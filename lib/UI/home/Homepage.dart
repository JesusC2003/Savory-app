import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest, // adapta a Material 3
      appBar: AppBar(
        title: const Text(
          '🍳 Savory',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary, // usa colorScheme (Material 3)
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Hola, chef!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '¿Qué cocinamos hoy?',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // 🟩 Cuadrícula de opciones principales
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildOptionCard(
                    context,
                    icon: Icons.kitchen,
                    title: 'Mi Despensa',
                    color: Colors.teal,
                    route: '/despensa',
                  ),
                  _buildOptionCard(
                    context,
                    icon: Icons.restaurant_menu,
                    title: 'Recetas',
                    color: Colors.deepOrange,
                    route: '/recetas',
                  ),
                  _buildOptionCard(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Lista de Compras',
                    color: Colors.indigo,
                    route: '/lista_compra',
                  ),
                  _buildOptionCard(
                    context,
                    icon: Icons.smart_toy,
                    title: 'Asistente IA',
                    color: Colors.purple,
                    route: '/asistente',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Widget auxiliar para construir cada tarjeta de acceso rápido
  Widget _buildOptionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        // ⚠️ Por ahora solo muestra un mensaje (luego se reemplazará por Navigator)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navegando a $title...')),
        );

        // Navigator.pushNamed(context, route);
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color.withValues(red: 100, green: 100, blue: 100),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _shadeColor(color, 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Devuelve una versión más oscura del color dado usando HSL (compatible con Color)
  Color _shadeColor(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
