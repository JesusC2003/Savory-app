import 'package:flutter/material.dart';

class RecetasPage extends StatelessWidget {
  const RecetasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Ejemplo visual (tarjetas de recetas)
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRecipeCard("Pasta con albahaca", "assets/onboarding/step1.svg"),
        _buildRecipeCard("Ensalada tropical", "assets/onboarding/step2.svg"),
        _buildRecipeCard("Smoothie verde", "assets/onboarding/step3.svg"),
      ],
    );
  }

  Widget _buildRecipeCard(String title, String imagePath) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF47A72F).withOpacity(0.1),
          child: const Icon(Icons.restaurant, color: Color(0xFF47A72F)),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: const Text("Ver detalles..."),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          // TODO: Abrir detalle receta
        },
      ),
    );
  }
}
