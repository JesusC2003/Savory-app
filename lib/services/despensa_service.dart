import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/despensa_model.dart';

class DespensaService {
  final CollectionReference _despensas =
      FirebaseFirestore.instance.collection('despensas');

  /// Crear una nueva despensa
  Future<void> crearDespensa(DespensaModel despensa) async {
    await _despensas.doc(despensa.idDespensa).set(despensa.toJson());
  }

  /// Obtener una despensa por su ID
  Future<DespensaModel?> obtenerDespensa(String id) async {
    final doc = await _despensas.doc(id).get();
    if (!doc.exists) return null;
    return DespensaModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar una despensa existente
  Future<void> actualizarDespensa(DespensaModel despensa) async {
    await _despensas.doc(despensa.idDespensa).update(despensa.toJson());
  }

  /// Eliminar una despensa
  Future<void> eliminarDespensa(String id) async {
    await _despensas.doc(id).delete();
  }

  /// Obtener todas las despensas de un usuario
  Stream<List<DespensaModel>> obtenerDespensasPorUsuario(String idUsuario) {
    return _despensas
        .where('id_usuario', isEqualTo: idUsuario)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DespensaModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Obtener todas las despensas (admin o debug)
  Stream<List<DespensaModel>> obtenerTodas() {
    return _despensas.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DespensaModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
