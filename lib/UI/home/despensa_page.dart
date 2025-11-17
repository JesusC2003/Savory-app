// lib/UI/home/despensa_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proyecto_savory/services/ocr.service.dart';

class DespensaPage extends StatefulWidget {
  const DespensaPage({super.key});

  @override
  State<DespensaPage> createState() => DespensaPageState();
}

class DespensaPageState extends State<DespensaPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final OcrService _ocrService = OcrService();

  // Método público para ser llamado desde Homepage
  void showAddIngredientDialog() {
    _mostrarOpcionesAgregarIngrediente();
  }

  // ✨ NUEVO MÉTODO: Mostrar opciones de entrada
  void _mostrarOpcionesAgregarIngrediente() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Cómo deseas agregar ingredientes?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF47A72F),
              ),
            ),
            const SizedBox(height: 20),

            // Opción 1: Tomar foto
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF47A72F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF47A72F),
                ),
              ),
              title: const Text('Tomar foto'),
              subtitle: const Text('Escanear ingredientes con la cámara'),
              onTap: () {
                Navigator.pop(context);
                _escanearConCamara();
              },
            ),

            const Divider(),

            // Opción 2: Subir imagen
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.blue,
                ),
              ),
              title: const Text('Subir imagen'),
              subtitle: const Text('Seleccionar desde la galería'),
              onTap: () {
                Navigator.pop(context);
                _escanearDesdeGaleria();
              },
            ),

            const Divider(),

            // Opción 3: Manual
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.orange,
                ),
              ),
              title: const Text('Agregar manualmente'),
              subtitle: const Text('Escribir los ingredientes'),
              onTap: () {
                Navigator.pop(context);
                _showAddIngredientDialog();
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ✨ NUEVO: Escanear con cámara
  Future<void> _escanearConCamara() async {
    final status = await Permission.camera.request();
    
    if (!status.isGranted) {
      _showSnackBar(
        '⚠️ Necesitas conceder permisos de cámara',
        Colors.orange,
      );
      return;
    }

    try {
      _showLoadingDialog('📸 Procesando imagen...');

      final ingredientes = await _ocrService.escanearDesdeCamara();
      
      if (!mounted) return;
      Navigator.pop(context);

      if (ingredientes.isEmpty) {
        _showSnackBar(
          'No se detectaron ingredientes. Intenta de nuevo',
          Colors.orange,
        );
        return;
      }

      _mostrarIngredientesDetectados(ingredientes);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('Error al escanear: ${e.toString()}', Colors.redAccent);
    }
  }

  // ✨ NUEVO: Escanear desde galería
  Future<void> _escanearDesdeGaleria() async {
    try {
      _showLoadingDialog('📷 Procesando imagen...');

      final ingredientes = await _ocrService.escanearDesdeGaleria();
      
      if (!mounted) return;
      Navigator.pop(context);

      if (ingredientes.isEmpty) {
        _showSnackBar(
          'No se detectaron ingredientes. Intenta de nuevo',
          Colors.orange,
        );
        return;
      }

      _mostrarIngredientesDetectados(ingredientes);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar('Error al procesar: ${e.toString()}', Colors.redAccent);
    }
  }

  // ✨ NUEVO: Diálogo de carga
  void _showLoadingDialog(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF47A72F),
                ),
                const SizedBox(height: 20),
                Text(
                  mensaje,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✨ NUEVO: Mostrar ingredientes detectados
  void _mostrarIngredientesDetectados(List<String> ingredientes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF47A72F),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Ingredientes detectados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF47A72F),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 30),
              
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ingredientes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: 
                              const Color(0xFF47A72F).withOpacity(0.1),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF47A72F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          ingredientes[index],
                          style: const TextStyle(fontSize: 15),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Color(0xFF47A72F),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _mostrarDialogoConfirmarIngrediente(
                              ingredientes[index],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF47A72F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _agregarTodosLosIngredientes(ingredientes);
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  'Agregar todos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ NUEVO: Diálogo para confirmar ingrediente individual
  void _mostrarDialogoConfirmarIngrediente(String nombreDetectado) {
    final TextEditingController nombreController = 
        TextEditingController(text: nombreDetectado);
    final TextEditingController cantidadController = 
        TextEditingController(text: '1');
    String unidad = 'unidades';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Confirmar ingrediente'),
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
                    DropdownMenuItem(
                        value: 'kilogramos', child: Text('Kilogramos (kg)')),
                    DropdownMenuItem(value: 'litros', child: Text('Litros (L)')),
                    DropdownMenuItem(
                        value: 'mililitros', child: Text('Mililitros (ml)')),
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
                  _showSnackBar(
                    'Por favor completa todos los campos',
                    Colors.redAccent,
                  );
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

  // ✨ NUEVO: Agregar todos los ingredientes detectados
  Future<void> _agregarTodosLosIngredientes(List<String> ingredientes) async {
    int agregados = 0;
    
    _showLoadingDialog('Agregando ingredientes...');

    for (String ingrediente in ingredientes) {
      try {
        await _addIngredient(ingrediente, '1', 'unidades');
        agregados++;
      } catch (e) {
        // Continuar con el siguiente aunque falle uno
      }
    }

    if (!mounted) return;
    Navigator.pop(context);

    _showSnackBar(
      '✓ Se agregaron $agregados de ${ingredientes.length} ingredientes',
      const Color(0xFF47A72F),
    );
  }

  // MÉTODO ORIGINAL: Agregar ingrediente manualmente
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
                    DropdownMenuItem(
                        value: 'kilogramos', child: Text('Kilogramos (kg)')),
                    DropdownMenuItem(value: 'litros', child: Text('Litros (L)')),
                    DropdownMenuItem(
                        value: 'mililitros', child: Text('Mililitros (ml)')),
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
                  _showSnackBar(
                    'Por favor completa todos los campos',
                    Colors.redAccent,
                  );
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
                    DropdownMenuItem(
                        value: 'kilogramos', child: Text('Kilogramos (kg)')),
                    DropdownMenuItem(value: 'litros', child: Text('Litros (L)')),
                    DropdownMenuItem(
                        value: 'mililitros', child: Text('Mililitros (ml)')),
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
                  _showSnackBar(
                    'Por favor completa todos los campos',
                    Colors.redAccent,
                  );
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
                  onPressed: showAddIngredientDialog,
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

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}