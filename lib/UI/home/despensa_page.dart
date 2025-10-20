import 'package:flutter/material.dart';

class DespensaPage extends StatelessWidget {
  const DespensaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _ItemDespensa(nombre: "Tomates", cantidad: "3 unidades"),
        _ItemDespensa(nombre: "Pasta", cantidad: "1 paquete"),
        _ItemDespensa(nombre: "Queso rallado", cantidad: "200 g"),
      ],
    );
  }
}

class _ItemDespensa extends StatelessWidget {
  final String nombre;
  final String cantidad;

  const _ItemDespensa({required this.nombre, required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.kitchen, color: Color(0xFF47A72F)),
        title: Text(nombre,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(cantidad),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }
}
