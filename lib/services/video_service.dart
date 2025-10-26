import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/video_model.dart';

class VideoService {
  final CollectionReference _videos =
      FirebaseFirestore.instance.collection('videos');

  /// Crear un nuevo video
  Future<void> crearVideo(VideoModel video) async {
    await _videos.doc(video.idVideo).set(video.toJson());
  }

  /// Obtener un video por su ID
  Future<VideoModel?> obtenerVideo(String id) async {
    final doc = await _videos.doc(id).get();
    if (!doc.exists) return null;
    return VideoModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar un video existente
  Future<void> actualizarVideo(VideoModel video) async {
    await _videos.doc(video.idVideo).update(video.toJson());
  }

  /// Eliminar un video por su ID
  Future<void> eliminarVideo(String id) async {
    await _videos.doc(id).delete();
  }

  /// Obtener todos los videos activos
  Stream<List<VideoModel>> obtenerActivos() {
    return _videos
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VideoModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener videos por tipo (tutorial, promocional, etc.)
  Stream<List<VideoModel>> obtenerPorTipo(String tipoVideo) {
    return _videos
        .where('tipo_video', isEqualTo: tipoVideo)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VideoModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener videos por proveedor (YouTube, Vimeo, etc.)
  Stream<List<VideoModel>> obtenerPorProveedor(String proveedor) {
    return _videos
        .where('proveedor', isEqualTo: proveedor)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VideoModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todos los videos (vista global/admin)
  Stream<List<VideoModel>> obtenerTodos() {
    return _videos.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => VideoModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
