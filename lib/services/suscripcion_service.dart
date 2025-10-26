import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/suscripcion_model.dart';

class SuscripcionService {
  final CollectionReference _suscripciones =
      FirebaseFirestore.instance.collection('suscripciones');

  /// Crear una nueva suscripción
  Future<void> crearSuscripcion(SuscripcionModel suscripcion) async {
    await _suscripciones.doc(suscripcion.idSuscripcion).set(suscripcion.toJson());
  }

  /// Obtener una suscripción por su ID
  Future<SuscripcionModel?> obtenerSuscripcion(String id) async {
    final doc = await _suscripciones.doc(id).get();
    if (!doc.exists) return null;
    return SuscripcionModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar una suscripción existente
  Future<void> actualizarSuscripcion(SuscripcionModel suscripcion) async {
    await _suscripciones.doc(suscripcion.idSuscripcion).update(suscripcion.toJson());
  }

  /// Eliminar una suscripción
  Future<void> eliminarSuscripcion(String id) async {
    await _suscripciones.doc(id).delete();
  }

  /// Obtener las suscripciones de un usuario
  Stream<List<SuscripcionModel>> obtenerPorUsuario(String idUsuario) {
    return _suscripciones
        .where('id_usuario', isEqualTo: idUsuario)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                SuscripcionModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener suscripciones por estado (activa, expirada, cancelada)
  Stream<List<SuscripcionModel>> obtenerPorEstado(String estado) {
    return _suscripciones
        .where('estado', isEqualTo: estado)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                SuscripcionModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todas las suscripciones (vista global/admin)
  Stream<List<SuscripcionModel>> obtenerTodas() {
    return _suscripciones.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              SuscripcionModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Verificar si una suscripción está activa
  Future<bool> suscripcionActiva(String idUsuario) async {
    final ahora = DateTime.now();
    final query = await _suscripciones
        .where('id_usuario', isEqualTo: idUsuario)
        .where('estado', isEqualTo: 'activa')
        .get();

    if (query.docs.isEmpty) return false;

    final suscripcion = SuscripcionModel.fromJson(
        query.docs.first.data() as Map<String, dynamic>);

    return suscripcion.fechaExpiracion.isAfter(ahora);
  }
}
