import 'package:flutter/material.dart';
import '../constants/despensa_constants.dart';

class DespensaEmptyState extends StatelessWidget {
  final VoidCallback onAgregarPressed;

  const DespensaEmptyState({
    super.key,
    required this.onAgregarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            DespensaConstants.iconoDespensa,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            DespensaConstants.mensajeDespensaVacia,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            DespensaConstants.mensajeAgregarParaComenzar,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: DespensaConstants.verdeSavory,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onAgregarPressed,
            icon: const Icon(DespensaConstants.iconoAgregar, color: Colors.white),
            label: const Text(
              'Agregar ingrediente',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}