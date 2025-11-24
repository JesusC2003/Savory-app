import 'package:flutter/material.dart';
import '../constants/despensa_constants.dart';

class AddIngredientOptionsSheet extends StatelessWidget {
  final VoidCallback onTomarFoto;
  final VoidCallback onSubirImagen;
  final VoidCallback onAgregarManual;

  const AddIngredientOptionsSheet({
    super.key,
    required this.onTomarFoto,
    required this.onSubirImagen,
    required this.onAgregarManual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador visual
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Text(
            '¿Cómo deseas agregar ingredientes?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DespensaConstants.verdeSavory,
            ),
          ),
          const SizedBox(height: 20),

          // Opción: Tomar foto
          _buildOptionTile(
            icon: DespensaConstants.iconoCamara,
            title: 'Tomar foto',
            subtitle: 'Escanear ingredientes con la cámara',
            color: DespensaConstants.verdeSavory,
            onTap: () {
              Navigator.pop(context);
              onTomarFoto();
            },
          ),

          const Divider(height: 20),

          // Opción: Subir imagen
          _buildOptionTile(
            icon: DespensaConstants.iconoGaleria,
            title: 'Subir imagen',
            subtitle: 'Seleccionar desde la galería',
            color: DespensaConstants.azulInfo,
            onTap: () {
              Navigator.pop(context);
              onSubirImagen();
            },
          ),

          const Divider(height: 20),

          // Opción: Manual
          _buildOptionTile(
            icon: DespensaConstants.iconoEditar,
            title: 'Agregar manualmente',
            subtitle: 'Escribir los ingredientes',
            color: DespensaConstants.naranjaWarning,
            onTap: () {
              Navigator.pop(context);
              onAgregarManual();
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}