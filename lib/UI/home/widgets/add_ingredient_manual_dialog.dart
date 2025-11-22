import 'package:flutter/material.dart';
import '../constants/despensa_constants.dart';

class AddIngredientManualDialog extends StatefulWidget {
  final Function(String nombre, String cantidad, String unidad) onGuardar;
  final String? nombreInicial;
  final String? cantidadInicial;
  final String? unidadInicial;
  final bool isEditing;

  const AddIngredientManualDialog({
    super.key,
    required this.onGuardar,
    this.nombreInicial,
    this.cantidadInicial,
    this.unidadInicial,
    this.isEditing = false,
  });

  @override
  State<AddIngredientManualDialog> createState() =>
      _AddIngredientManualDialogState();
}

class _AddIngredientManualDialogState extends State<AddIngredientManualDialog> {
  late TextEditingController _nombreController;
  late TextEditingController _cantidadController;
  late String _unidadSeleccionada;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreInicial);
    _cantidadController = TextEditingController(text: widget.cantidadInicial ?? '1');
    _unidadSeleccionada = widget.unidadInicial ?? 'unidades';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  void _guardar() {
    final nombre = _nombreController.text.trim();
    final cantidad = _cantidadController.text.trim();

    if (nombre.isEmpty || cantidad.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    if (double.tryParse(cantidad) == null || double.parse(cantidad) <= 0) {
      _showError('La cantidad debe ser un número válido mayor a cero');
      return;
    }

    Navigator.pop(context);
    widget.onGuardar(nombre, cantidad, _unidadSeleccionada);
  }

  void _showError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: DespensaConstants.rojoError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.isEditing ? 'Editar ingrediente' : DespensaConstants.tituloAgregarManual,
        style: const TextStyle(
          color: DespensaConstants.verdeSavory,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo nombre
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre del ingrediente',
                hintText: 'Ej: Tomates, Pasta, etc.',
                prefixIcon: const Icon(Icons.fastfood),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: DespensaConstants.verdeSavory,
                    width: 2,
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 15),

            // Campo cantidad
            TextField(
              controller: _cantidadController,
              decoration: InputDecoration(
                labelText: 'Cantidad',
                hintText: 'Ej: 3, 500, 1',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: DespensaConstants.verdeSavory,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 15),

            // Selector de unidad
            DropdownButtonFormField<String>(
              value: _unidadSeleccionada,
              decoration: InputDecoration(
                labelText: 'Unidad',
                prefixIcon: const Icon(Icons.straighten),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: DespensaConstants.verdeSavory,
                    width: 2,
                  ),
                ),
              ),
              items: DespensaConstants.unidades
                  .map((unidad) => DropdownMenuItem(
                        value: unidad['value'],
                        child: Text(unidad['label']!),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _unidadSeleccionada = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DespensaConstants.verdeSavory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: _guardar,
          child: Text(
            widget.isEditing ? 'Guardar' : 'Agregar',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}