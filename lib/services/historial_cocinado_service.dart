import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/historial_cocinado_model.dart';

class HistorialCocinadoService {
  final CollectionReference _historial =
      FirebaseFirestore.instance.collection('historial_cocinado');

  /// Registrar un nuevo historial de receta cocinada
  Future<void> crearHistorial(HistorialCocinadoModel historial) async {
    await _historial.doc(historial.idHistorial).set(historial.toJson());
  }

  /// Obtener un registro de historial por su ID
  Future<HistorialCocinadoModel?> obtenerHistorial(String id) async {
    final doc = await _historial.doc(id).get();
    if (!doc.exists) return null;
    return HistorialCocinadoModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar un registro existente
  Future<void> actualizarHistorial(HistorialCocinadoModel historial) async {
    await _historial.doc(historial.idHistorial).update(historial.toJson());
  }

  /// Eliminar un registro del historial
  Future<void> eliminarHistorial(String id) async {
    await _historial.doc(id).delete();
  }

  /// Obtener todos los historiales de un usuario
  Stream<List<HistorialCocinadoModel>> obtenerPorUsuario(String idUsuario) {
    return _historial
        .where('id_usuario', isEqualTo: idUsuario)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                HistorialCocinadoModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todos los historiales (vista global/admin)
  Stream<List<HistorialCocinadoModel>> obtenerTodos() {
    return _historial.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              HistorialCocinadoModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Obtener todos los historiales asociados a una receta específica
  Stream<List<HistorialCocinadoModel>> obtenerPorReceta(String idReceta) {
    return _historial
        .where('id_receta', isEqualTo: idReceta)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                HistorialCocinadoModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Calcular el promedio de calificación de una receta
  Future<double> obtenerPromedioCalificacion(String idReceta) async {
    final query =
        await _historial.where('id_receta', isEqualTo: idReceta).get();

    if (query.docs.isEmpty) return 0.0;

    final total = query.docs
        .map((doc) => (doc['calificacion'] as num).toDouble())
        .reduce((a, b) => a + b);

    return total / query.docs.length;
  }
}
