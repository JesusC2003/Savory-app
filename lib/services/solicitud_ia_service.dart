import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/solicitud_ia_model.dart';

class SolicitudIaService {
  final CollectionReference _solicitudes =
      FirebaseFirestore.instance.collection('solicitudes_ia');

  /// Crear una nueva solicitud IA
  Future<void> crearSolicitud(SolicitudIaModel solicitud) async {
    await _solicitudes.doc(solicitud.idSolicitud).set(solicitud.toJson());
  }

  /// Obtener una solicitud por su ID
  Future<SolicitudIaModel?> obtenerSolicitud(String id) async {
    final doc = await _solicitudes.doc(id).get();
    if (!doc.exists) return null;
    return SolicitudIaModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar una solicitud existente
  Future<void> actualizarSolicitud(SolicitudIaModel solicitud) async {
    await _solicitudes.doc(solicitud.idSolicitud).update(solicitud.toJson());
  }

  /// Eliminar una solicitud por su ID
  Future<void> eliminarSolicitud(String id) async {
    await _solicitudes.doc(id).delete();
  }

  /// Obtener todas las solicitudes de un usuario
  Stream<List<SolicitudIaModel>> obtenerPorUsuario(String idUsuario) {
    return _solicitudes
        .where('id_usuario', isEqualTo: idUsuario)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                SolicitudIaModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todas las solicitudes por estado (pendiente, completada, error)
  Stream<List<SolicitudIaModel>> obtenerPorEstado(String estado) {
    return _solicitudes
        .where('estado', isEqualTo: estado)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                SolicitudIaModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todas las solicitudes registradas (vista global/admin)
  Stream<List<SolicitudIaModel>> obtenerTodas() {
    return _solicitudes.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              SolicitudIaModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
