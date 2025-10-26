import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecetasPage extends StatefulWidget {
  const RecetasPage({super.key});

  @override
  State<RecetasPage> createState() => RecetasPageState();
}

class RecetasPageState extends State<RecetasPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Método público para ser llamado desde Homepage
  void showAddRecipeDialog() {
    _showAddRecipeDialog();
  }

  void _showAddRecipeDialog() {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    final TextEditingController tiempoController = TextEditingController();
    String dificultad = 'Fácil';
    String categoria = 'Desayuno';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar receta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la receta',
                    hintText: 'Ej: Pasta carbonara',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Breve descripción de la receta',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: tiempoController,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo de preparación (minutos)',
                    hintText: 'Ej: 30',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: dificultad,
                  decoration: const InputDecoration(
                    labelText: 'Dificultad',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Fácil', child: Text('Fácil')),
                    DropdownMenuItem(value: 'Media', child: Text('Media')),
                    DropdownMenuItem(value: 'Difícil', child: Text('Difícil')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      dificultad = value!;
                    });
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Desayuno', child: Text('Desayuno')),
                    DropdownMenuItem(value: 'Almuerzo', child: Text('Almuerzo')),
                    DropdownMenuItem(value: 'Cena', child: Text('Cena')),
                    DropdownMenuItem(value: 'Postre', child: Text('Postre')),
                    DropdownMenuItem(value: 'Snack', child: Text('Snack')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      categoria = value!;
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
                final descripcion = descripcionController.text.trim();
                final tiempo = tiempoController.text.trim();

                if (nombre.isEmpty || descripcion.isEmpty || tiempo.isEmpty) {
                  _showSnackBar('Por favor completa todos los campos', Colors.redAccent);
                  return;
                }

                Navigator.pop(context);
                await _addRecipe(nombre, descripcion, tiempo, dificultad, categoria);
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

  Future<void> _addRecipe(String nombre, String descripcion, String tiempo, String dificultad, String categoria) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .collection('recetas')
          .add({
        'nombre': nombre,
        'descripcion': descripcion,
        'tiempo_preparacion': tiempo,
        'dificultad': dificultad,
        'categoria': categoria,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'favorita': false,
      });

      _showSnackBar('Receta agregada exitosamente', const Color(0xFF47A72F));
    } catch (e) {
      _showSnackBar('Error al agregar: ${e.toString()}', Colors.redAccent);
    }
  }

  Future<void> _deleteRecipe(String docId, String nombre) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar receta'),
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
                    .collection('recetas')
                    .doc(docId)
                    .delete();

                _showSnackBar('Receta eliminada', const Color(0xFF47A72F));
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

  Future<void> _toggleFavorite(String docId, bool currentValue) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(_currentUser!.uid)
          .collection('recetas')
          .doc(docId)
          .update({
        'favorita': !currentValue,
      });
    } catch (e) {
      _showSnackBar('Error al actualizar: ${e.toString()}', Colors.redAccent);
    }
  }

  void _showRecipeDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['nombre'] ?? 'Sin nombre'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data['descripcion'] ?? 'Sin descripción',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF47A72F)),
                  const SizedBox(width: 8),
                  Text('${data['tiempo_preparacion']} minutos'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.bar_chart, size: 18, color: Color(0xFF47A72F)),
                  const SizedBox(width: 8),
                  Text('Dificultad: ${data['dificultad']}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 18, color: Color(0xFF47A72F)),
                  const SizedBox(width: 8),
                  Text('Categoría: ${data['categoria']}'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFF47A72F)),
            ),
          ),
        ],
      ),
    );
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

  Color _getDifficultyColor(String dificultad) {
    switch (dificultad) {
      case 'Fácil':
        return Colors.green;
      case 'Media':
        return Colors.orange;
      case 'Difícil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String categoria) {
    switch (categoria) {
      case 'Desayuno':
        return Icons.free_breakfast;
      case 'Almuerzo':
        return Icons.lunch_dining;
      case 'Cena':
        return Icons.dinner_dining;
      case 'Postre':
        return Icons.cake;
      case 'Snack':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
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
          .collection('recetas')
          .orderBy('fecha_creacion', descending: true)
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

        final recetas = snapshot.data?.docs ?? [];

        if (recetas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu_outlined,
                  size: 100,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 20),
                Text(
                  'No tienes recetas guardadas',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Agrega tu primera receta para comenzar',
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
                  onPressed: _showAddRecipeDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Agregar receta',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recetas.length,
          itemBuilder: (context, index) {
            final doc = recetas[index];
            final data = doc.data() as Map<String, dynamic>;
            final nombre = data['nombre'] ?? 'Sin nombre';
            final descripcion = data['descripcion'] ?? 'Sin descripción';
            final tiempo = data['tiempo_preparacion'] ?? '0';
            final dificultad = data['dificultad'] ?? 'Media';
            final categoria = data['categoria'] ?? 'Almuerzo';
            final favorita = data['favorita'] ?? false;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () => _showRecipeDetails(data),
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Icono de categoría
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF47A72F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(categoria),
                          color: const Color(0xFF47A72F),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Información
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              descripcion,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  '$tiempo min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(dificultad).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    dificultad,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _getDifficultyColor(dificultad),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Acciones
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              favorita ? Icons.favorite : Icons.favorite_border,
                              color: favorita ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleFavorite(doc.id, favorita),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
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
                              if (value == 'delete') {
                                _deleteRecipe(doc.id, nombre);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}