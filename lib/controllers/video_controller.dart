import '../Models/video_model.dart';
import '../services/video_service.dart';

class VideoController {
  final VideoService _service = VideoService();

  /// Registrar un nuevo video con validaciones básicas
  Future<void> registrarVideo(VideoModel video) async {
    if (video.urlVideo.isEmpty) {
      throw Exception('La URL del video no puede estar vacía.');
    }
    if (video.duracionSegundos <= 0) {
      throw Exception('La duración del video debe ser mayor que cero.');
    }
    await _service.crearVideo(video);
  }

  /// Obtener un video por ID
  Future<VideoModel?> obtenerVideoPorId(String id) {
    return _service.obtenerVideo(id);
  }

  /// Actualizar video existente
  Future<void> actualizarVideo(VideoModel video) async {
    await _service.actualizarVideo(video);
  }

  /// Eliminar video
  Future<void> eliminarVideo(String id) async {
    await _service.eliminarVideo(id);
  }

  /// Listar todos los videos activos
  Stream<List<VideoModel>> listarActivos() {
    return _service.obtenerActivos();
  }

  /// Listar videos por tipo
  Stream<List<VideoModel>> listarPorTipo(String tipoVideo) {
    return _service.obtenerPorTipo(tipoVideo);
  }

  /// Listar videos por proveedor (YouTube, Vimeo, etc.)
  Stream<List<VideoModel>> listarPorProveedor(String proveedor) {
    return _service.obtenerPorProveedor(proveedor);
  }

  /// Listar todos los videos (vista global/admin)
  Stream<List<VideoModel>> listarTodos() {
    return _service.obtenerTodos();
  }
}
