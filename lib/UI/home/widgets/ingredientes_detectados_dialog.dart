import 'package:flutter/material.dart';
import '../constants/despensa_constants.dart';

class IngredientesDetectadosDialog extends StatefulWidget {
  final List<String> ingredientes;
  final Function(List<String>) onAgregarSeleccionados;

  const IngredientesDetectadosDialog({
    super.key,
    required this.ingredientes,
    required this.onAgregarSeleccionados,
  });

  @override
  State<IngredientesDetectadosDialog> createState() =>
      _IngredientesDetectadosDialogState();
}

class _IngredientesDetectadosDialogState
    extends State<IngredientesDetectadosDialog> {
  late Map<String, bool> _seleccionados;

  @override
  void initState() {
    super.initState();
    // Inicializar todos como seleccionados
    _seleccionados = {
      for (var ing in widget.ingredientes) ing: true,
    };
  }

  int get _contarSeleccionados =>
      _seleccionados.values.where((v) => v).length;

  List<String> get _obtenerSeleccionados => widget.ingredientes
      .where((ing) => _seleccionados[ing] == true)
      .toList();

  void _toggleSeleccion(String ingrediente) {
    setState(() {
      _seleccionados[ingrediente] = !(_seleccionados[ingrediente] ?? true);
    });
  }

  void _toggleTodos() {
    setState(() {
      final todosSeleccionados =
          _contarSeleccionados == widget.ingredientes.length;
      for (var ing in widget.ingredientes) {
        _seleccionados[ing] = !todosSeleccionados;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650, maxWidth: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildContador(),
            const Divider(height: 30),
            _buildListaIngredientes(),
            const SizedBox(height: 15),
            _buildBotonesAccion(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: DespensaConstants.verdeSavory,
          size: 28,
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            DespensaConstants.tituloIngredientesDetectados,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DespensaConstants.verdeSavory,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }

  Widget _buildContador() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: DespensaConstants.verdeSavory.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$_contarSeleccionados de ${widget.ingredientes.length} seleccionados',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: DespensaConstants.verdeSavory,
        ),
      ),
    );
  }

  Widget _buildListaIngredientes() {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.ingredientes.length,
        itemBuilder: (context, index) {
          final ingrediente = widget.ingredientes[index];
          final isSeleccionado = _seleccionados[ingrediente] ?? true;

          return _buildIngredienteCard(
            ingrediente: ingrediente,
            index: index,
            isSeleccionado: isSeleccionado,
          );
        },
      ),
    );
  }

  Widget _buildIngredienteCard({
    required String ingrediente,
    required int index,
    required bool isSeleccionado,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isSeleccionado ? 2 : 1,
      color: isSeleccionado ? Colors.white : Colors.grey.shade50,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSeleccionado
              ? DespensaConstants.verdeSavory.withOpacity(0.1)
              : Colors.grey.shade200,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isSeleccionado
                  ? DespensaConstants.verdeSavory
                  : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          ingrediente,
          style: TextStyle(
            fontSize: 15,
            decoration: isSeleccionado
                ? TextDecoration.none
                : TextDecoration.lineThrough,
            color: isSeleccionado ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
        trailing: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isSeleccionado ? Icons.add_circle : Icons.remove_circle,
              key: ValueKey(isSeleccionado),
              color: isSeleccionado
                  ? DespensaConstants.verdeSavory
                  : Colors.grey.shade400,
              size: 28,
            ),
          ),
          onPressed: () => _toggleSeleccion(ingrediente),
        ),
        onTap: () => _toggleSeleccion(ingrediente),
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context) {
    final todosSeleccionados =
        _contarSeleccionados == widget.ingredientes.length;

    return Row(
      children: [
        // Botón seleccionar/deseleccionar todos
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: DespensaConstants.verdeSavory,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _toggleTodos,
            icon: Icon(
              todosSeleccionados
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color: DespensaConstants.verdeSavory,
              size: 20,
            ),
            label: Text(
              todosSeleccionados ? 'Deseleccionar' : 'Seleccionar',
              style: const TextStyle(
                color: DespensaConstants.verdeSavory,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Botón agregar seleccionados
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: DespensaConstants.verdeSavory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 2,
            ),
            onPressed: _contarSeleccionados == 0
                ? null
                : () {
                    Navigator.pop(context);
                    widget.onAgregarSeleccionados(_obtenerSeleccionados);
                  },
            icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
            label: Text(
              'Agregar ($_contarSeleccionados)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}