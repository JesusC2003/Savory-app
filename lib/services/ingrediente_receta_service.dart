import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/ingrediente_receta_model.dart';

class IngredienteRecetaService {
  final CollectionReference _ingredientesReceta =
      FirebaseFirestore.instance.collection('ingredientes_receta');

  /// Crear un registro de ingrediente en receta
  Future<void> crearIngredienteReceta(IngredienteRecetaModel registro) async {
    await _ingredientesReceta.doc(registro.idIngReceta).set(registro.toJson());
  }

  /// Obtener un registro por su ID
  Future<IngredienteRecetaModel?> obtenerPorId(String id) async {
    final doc = await _ingredientesReceta.doc(id).get();
    if (!doc.exists) return null;
    return IngredienteRecetaModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar un registro existente
  Future<void> actualizarIngredienteReceta(IngredienteRecetaModel registro) async {
    await _ingredientesReceta.doc(registro.idIngReceta).update(registro.toJson());
  }

  /// Eliminar un registro por ID
  Future<void> eliminarIngredienteReceta(String id) async {
    await _ingredientesReceta.doc(id).delete();
  }

  /// Obtener todos los ingredientes asociados a una receta específica
  Stream<List<IngredienteRecetaModel>> obtenerPorReceta(String idReceta) {
    return _ingredientesReceta
        .where('id_receta', isEqualTo: idReceta)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                IngredienteRecetaModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todos los registros (vista global)
  Stream<List<IngredienteRecetaModel>> obtenerTodos() {
    return _ingredientesReceta.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              IngredienteRecetaModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Filtrar por ingredientes opcionales
  Stream<List<IngredienteRecetaModel>> obtenerOpcionales(bool esOpcional) {
    return _ingredientesReceta
        .where('opcional', isEqualTo: esOpcional)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                IngredienteRecetaModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
