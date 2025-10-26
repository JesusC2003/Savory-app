import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/ingrediente_model.dart';

class IngredienteService {
  final CollectionReference _ingredientes =
      FirebaseFirestore.instance.collection('ingredientes');

  /// Crear un nuevo ingrediente
  Future<void> crearIngrediente(IngredienteModel ingrediente) async {
    await _ingredientes.doc(ingrediente.idIngrediente).set(ingrediente.toJson());
  }

  /// Obtener un ingrediente por su ID
  Future<IngredienteModel?> obtenerIngrediente(String id) async {
    final doc = await _ingredientes.doc(id).get();
    if (!doc.exists) return null;
    return IngredienteModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar un ingrediente existente
  Future<void> actualizarIngrediente(IngredienteModel ingrediente) async {
    await _ingredientes.doc(ingrediente.idIngrediente).update(ingrediente.toJson());
  }

  /// Eliminar un ingrediente
  Future<void> eliminarIngrediente(String id) async {
    await _ingredientes.doc(id).delete();
  }

  /// Obtener todos los ingredientes (stream en tiempo real)
  Stream<List<IngredienteModel>> obtenerTodos() {
    return _ingredientes.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => IngredienteModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Buscar ingredientes por nombre (búsqueda parcial)
  Stream<List<IngredienteModel>> buscarPorNombre(String nombre) {
    return _ingredientes
        .where('nombre', isGreaterThanOrEqualTo: nombre)
        .where('nombre', isLessThanOrEqualTo: '$nombre\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IngredienteModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Filtrar ingredientes por categoría
  Stream<List<IngredienteModel>> filtrarPorCategoria(String categoria) {
    return _ingredientes
        .where('categoria', isEqualTo: categoria)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IngredienteModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
