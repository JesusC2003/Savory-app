import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/ingrediente_despensa_model.dart';

class IngredienteDespensaService {
  final CollectionReference _ingredientesDespensa =
      FirebaseFirestore.instance.collection('ingredientes_despensa');

  /// Crear un registro de ingrediente en despensa
  Future<void> crearIngredienteDespensa(IngredienteDespensaModel registro) async {
    await _ingredientesDespensa.doc(registro.idIngDespensa).set(registro.toJson());
  }

  /// Obtener un registro de ingrediente por su ID
  Future<IngredienteDespensaModel?> obtenerPorId(String id) async {
    final doc = await _ingredientesDespensa.doc(id).get();
    if (!doc.exists) return null;
    return IngredienteDespensaModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar un registro existente
  Future<void> actualizarIngredienteDespensa(IngredienteDespensaModel registro) async {
    await _ingredientesDespensa.doc(registro.idIngDespensa).update(registro.toJson());
  }

  /// Eliminar un registro
  Future<void> eliminarIngredienteDespensa(String id) async {
    await _ingredientesDespensa.doc(id).delete();
  }

  /// Obtener todos los ingredientes de una despensa específica
  Stream<List<IngredienteDespensaModel>> obtenerPorDespensa(String idDespensa) {
    return _ingredientesDespensa
        .where('id_despensa', isEqualTo: idDespensa)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IngredienteDespensaModel.fromJson(
                doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todos los ingredientes de todas las despensas (vista global/admin)
  Stream<List<IngredienteDespensaModel>> obtenerTodos() {
    return _ingredientesDespensa.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              IngredienteDespensaModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Filtrar ingredientes por estado (disponible, agotado, vencido)
  Stream<List<IngredienteDespensaModel>> filtrarPorEstado(String estado) {
    return _ingredientesDespensa
        .where('estado', isEqualTo: estado)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IngredienteDespensaModel.fromJson(
                doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Filtrar ingredientes próximos a vencer (en los próximos X días)
  Stream<List<IngredienteDespensaModel>> proximosAVencer(int dias) {
    final limite = DateTime.now().add(Duration(days: dias));
    return _ingredientesDespensa
        .where('fecha_vencimiento', isLessThanOrEqualTo: limite.toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IngredienteDespensaModel.fromJson(
                doc.data() as Map<String, dynamic>))
            .toList());
  }
}
