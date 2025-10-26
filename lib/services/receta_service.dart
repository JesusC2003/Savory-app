import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/receta_model.dart';

class RecetaService {
  final CollectionReference _recetas =
      FirebaseFirestore.instance.collection('recetas');

  /// Crear una nueva receta
  Future<void> crearReceta(RecetaModel receta) async {
    await _recetas.doc(receta.idReceta).set(receta.toJson());
  }

  /// Obtener una receta por su ID
  Future<RecetaModel?> obtenerReceta(String id) async {
    final doc = await _recetas.doc(id).get();
    if (!doc.exists) return null;
    return RecetaModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar una receta existente
  Future<void> actualizarReceta(RecetaModel receta) async {
    await _recetas.doc(receta.idReceta).update(receta.toJson());
  }

  /// Eliminar una receta
  Future<void> eliminarReceta(String id) async {
    await _recetas.doc(id).delete();
  }

  /// Obtener todas las recetas (stream en tiempo real)
  Stream<List<RecetaModel>> obtenerTodas() {
    return _recetas.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RecetaModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Buscar recetas por título (coincidencia parcial)
  Stream<List<RecetaModel>> buscarPorTitulo(String texto) {
    return _recetas
        .where('titulo', isGreaterThanOrEqualTo: texto)
        .where('titulo', isLessThanOrEqualTo: '$texto\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecetaModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Filtrar recetas por nivel de acceso (gratuita, premium, video)
  Stream<List<RecetaModel>> filtrarPorNivel(String nivel) {
    return _recetas
        .where('nivel_acceso', isEqualTo: nivel)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecetaModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Filtrar recetas por dificultad
  Stream<List<RecetaModel>> filtrarPorDificultad(String dificultad) {
    return _recetas
        .where('dificultad', isEqualTo: dificultad)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecetaModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
