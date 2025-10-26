import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/desbloqueo_receta_model.dart';

class DesbloqueoRecetaService {
  final CollectionReference _desbloqueos =
      FirebaseFirestore.instance.collection('desbloqueos_recetas');

  /// Crear un nuevo desbloqueo de receta
  Future<void> crearDesbloqueo(DesbloqueoRecetaModel desbloqueo) async {
    await _desbloqueos.doc(desbloqueo.idDesbloqueo).set(desbloqueo.toJson());
  }

  /// Obtener un desbloqueo por su ID
  Future<DesbloqueoRecetaModel?> obtenerDesbloqueo(String id) async {
    final doc = await _desbloqueos.doc(id).get();
    if (!doc.exists) return null;
    return DesbloqueoRecetaModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar un desbloqueo existente
  Future<void> actualizarDesbloqueo(DesbloqueoRecetaModel desbloqueo) async {
    await _desbloqueos.doc(desbloqueo.idDesbloqueo).update(desbloqueo.toJson());
  }

  /// Eliminar un desbloqueo por su ID
  Future<void> eliminarDesbloqueo(String id) async {
    await _desbloqueos.doc(id).delete();
  }

  /// Obtener todos los desbloqueos de un usuario
  Stream<List<DesbloqueoRecetaModel>> obtenerPorUsuario(String idUsuario) {
    return _desbloqueos
        .where('id_usuario', isEqualTo: idUsuario)
        .orderBy('fecha_desbloqueo', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DesbloqueoRecetaModel.fromJson(
                doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todos los desbloqueos activos de un usuario
  Stream<List<DesbloqueoRecetaModel>> obtenerActivosPorUsuario(
      String idUsuario) {
    final ahora = DateTime.now();
    return _desbloqueos
        .where('id_usuario', isEqualTo: idUsuario)
        .where('estado', isEqualTo: 'activo')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DesbloqueoRecetaModel.fromJson(
                doc.data() as Map<String, dynamic>))
            .where((d) => d.fechaExpiracion.isAfter(ahora))
            .toList());
  }

  /// Obtener todos los desbloqueos (vista global/admin)
  Stream<List<DesbloqueoRecetaModel>> obtenerTodos() {
    return _desbloqueos.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              DesbloqueoRecetaModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Verificar si un usuario tiene desbloqueo activo de una receta específica
  Future<bool> tieneDesbloqueoActivo(String idUsuario, String idReceta) async {
    final ahora = DateTime.now();
    final query = await _desbloqueos
        .where('id_usuario', isEqualTo: idUsuario)
        .where('id_receta', isEqualTo: idReceta)
        .where('estado', isEqualTo: 'activo')
        .get();

    if (query.docs.isEmpty) return false;

    final desbloqueo = DesbloqueoRecetaModel.fromJson(
        query.docs.first.data() as Map<String, dynamic>);

    return desbloqueo.fechaExpiracion.isAfter(ahora);
  }
}
