import 'package:flutter/material.dart';
import '../constants/despensa_constants.dart';

class DespensaItemCard extends StatelessWidget {
  final String nombre;
  final String cantidad;
  final String unidad;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DespensaItemCard({
    super.key,
    required this.nombre,
    required this.cantidad,
    required this.unidad,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: DespensaConstants.verdeSavory.withOpacity(0.1),
          child: const Icon(
            Icons.kitchen,
            color: DespensaConstants.verdeSavory,
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '$cantidad ${DespensaConstants.getUnitAbbreviation(unidad)}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20, color: DespensaConstants.verdeSavory),
                  SizedBox(width: 10),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: DespensaConstants.rojoError),
                  SizedBox(width: 10),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
      ),
    );
  }
}
