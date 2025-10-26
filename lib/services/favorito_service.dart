import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/favorito_model.dart';

class FavoritoService {
  final CollectionReference _favoritos =
      FirebaseFirestore.instance.collection('favoritos');

  /// Crear un nuevo favorito
  Future<void> crearFavorito(FavoritoModel favorito) async {
    await _favoritos.doc(favorito.idFavorito).set(favorito.toJson());
  }

  /// Obtener un favorito por su ID
  Future<FavoritoModel?> obtenerFavorito(String id) async {
    final doc = await _favoritos.doc(id).get();
    if (!doc.exists) return null;
    return FavoritoModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Eliminar un favorito
  Future<void> eliminarFavorito(String id) async {
    await _favoritos.doc(id).delete();
  }

  /// Obtener todos los favoritos de un usuario
  Stream<List<FavoritoModel>> obtenerPorUsuario(String idUsuario) {
    return _favoritos
        .where('id_usuario', isEqualTo: idUsuario)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                FavoritoModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Verificar si una receta ya está marcada como favorita por un usuario
  Future<bool> esFavorito(String idUsuario, String idReceta) async {
    final query = await _favoritos
        .where('id_usuario', isEqualTo: idUsuario)
        .where('id_receta', isEqualTo: idReceta)
        .get();

    return query.docs.isNotEmpty;
  }

  /// Obtener todos los favoritos (vista global/admin)
  Stream<List<FavoritoModel>> obtenerTodos() {
    return _favoritos.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FavoritoModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
