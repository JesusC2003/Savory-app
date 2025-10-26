import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DespensaPage extends StatefulWidget {
  const DespensaPage({super.key});

  @override
  State<DespensaPage> createState() => DespensaPageState();
}

class DespensaPageState extends State<DespensaPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Método público para ser llamado desde Homepage
  void showAddIngredientDialog() {
    _showAddIngredientDialog();
  }

  void _showAddIngredientDialog() {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController cantidadController = TextEditingController();
    String unidad = 'unidades';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar ingrediente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del ingrediente',
                    hintText: 'Ej: Tomates, Pasta, etc.',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: cantidadController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    hintText: 'Ej: 3, 500, 1',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: unidad,
                  decoration: const InputDecoration(
                    labelText: 'Unidad',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'unidades', child: Text('Unidades')),
                    DropdownMenuItem(value: 'gramos', child: Text('Gramos (g)')),
                    DropdownMenuItem(value: 'kilogramos', child: Text('Kilogramos (kg)')),
                    DropdownMenuItem(value: 'litros', child: Text('Litros (L)')),
                    DropdownMenuItem(value: 'mililitros', child: Text('Mililitros (ml)')),
                    DropdownMenuItem(value: 'paquetes', child: Text('Paquetes')),
                    DropdownMenuItem(value: 'latas', child: Text('Latas')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      unidad = value!;
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
                backgroundColor: const Color(0xFF47A72F),
              ),
              onPressed: () async {
                final nombre = nombreController.text.trim();
                final cantidad = cantidadController.text.trim();

                if (nombre.isEmpty || cantidad.isEmpty) {
                  _showSnackBar('Por favor completa todos los campos', Colors.redAccent);
                  return;
                }

                Navigator.pop(context);
                await _addIngredient(nombre, cantidad, unidad);
              },
              child: const Text(
                'Agregar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addIngredient(String nombre, String cantidad, String unidad) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .collection('despensa')
          .add({
        'nombre': nombre,
        'cantidad': cantidad,
        'unidad': unidad,
        'fecha_agregado': DateTime.now().toIso8601String(),
      });

      _showSnackBar('Ingrediente agregado exitosamente', const Color(0xFF47A72F));
    } catch (e) {
      _showSnackBar('Error al agregar: ${e.toString()}', Colors.redAccent);
    }
  }

  Future<void> _deleteIngredient(String docId, String nombre) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ingrediente'),
        content: Text('¿Estás seguro de eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(_currentUser!.uid)
                    .collection('despensa')
                    .doc(docId)
                    .delete();

                _showSnackBar('Ingrediente eliminado', const Color(0xFF47A72F));
              } catch (e) {
                _showSnackBar('Error al eliminar: ${e.toString()}', Colors.redAccent);
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String docId, Map<String, dynamic> data) {
    final TextEditingController nombreController = TextEditingController(text: data['nombre']);
    final TextEditingController cantidadController = TextEditingController(text: data['cantidad']);
    String unidad = data['unidad'] ?? 'unidades';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar ingrediente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del ingrediente',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: cantidadController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: unidad,
                  decoration: const InputDecoration(
                    labelText: 'Unidad',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'unidades', child: Text('Unidades')),
                    DropdownMenuItem(value: 'gramos', child: Text('Gramos (g)')),
                    DropdownMenuItem(value: 'kilogramos', child: Text('Kilogramos (kg)')),
                    DropdownMenuItem(value: 'litros', child: Text('Litros (L)')),
                    DropdownMenuItem(value: 'mililitros', child: Text('Mililitros (ml)')),
                    DropdownMenuItem(value: 'paquetes', child: Text('Paquetes')),
                    DropdownMenuItem(value: 'latas', child: Text('Latas')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      unidad = value!;
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
                backgroundColor: const Color(0xFF47A72F),
              ),
              onPressed: () async {
                final nombre = nombreController.text.trim();
                final cantidad = cantidadController.text.trim();

                if (nombre.isEmpty || cantidad.isEmpty) {
                  _showSnackBar('Por favor completa todos los campos', Colors.redAccent);
                  return;
                }

                Navigator.pop(context);
                await _updateIngredient(docId, nombre, cantidad, unidad);
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateIngredient(String docId, String nombre, String cantidad, String unidad) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .collection('despensa')
          .doc(docId)
          .update({
        'nombre': nombre,
        'cantidad': cantidad,
        'unidad': unidad,
      });

      _showSnackBar('Ingrediente actualizado', const Color(0xFF47A72F));
    } catch (e) {
      _showSnackBar('Error al actualizar: ${e.toString()}', Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _getUnitAbbreviation(String unidad) {
    switch (unidad) {
      case 'gramos':
        return 'g';
      case 'kilogramos':
        return 'kg';
      case 'litros':
        return 'L';
      case 'mililitros':
        return 'ml';
      default:
        return unidad;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(
        child: Text('Por favor inicia sesión'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .collection('despensa')
          .orderBy('fecha_agregado', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF47A72F),
            ),
          );
        }

        final items = snapshot.data?.docs ?? [];

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.kitchen_outlined,
                  size: 100,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 20),
                Text(
                  'Tu despensa está vacía',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Agrega ingredientes para comenzar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF47A72F),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _showAddIngredientDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Agregar ingrediente',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final doc = items[index];
            final data = doc.data() as Map<String, dynamic>;
            final nombre = data['nombre'] ?? 'Sin nombre';
            final cantidad = data['cantidad'] ?? '0';
            final unidad = data['unidad'] ?? 'unidades';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF47A72F).withOpacity(0.1),
                  child: const Icon(
                    Icons.kitchen,
                    color: Color(0xFF47A72F),
                  ),
                ),
                title: Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text('$cantidad ${_getUnitAbbreviation(unidad)}'),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20, color: Color(0xFF47A72F)),
                          SizedBox(width: 10),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(doc.id, data);
                    } else if (value == 'delete') {
                      _deleteIngredient(doc.id, nombre);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}