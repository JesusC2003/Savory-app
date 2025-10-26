import '../Models/solicitud_ia_model.dart';
import '../services/solicitud_ia_service.dart';

class SolicitudIaController {
  final SolicitudIaService _service = SolicitudIaService();

  /// Registrar una nueva solicitud IA con validaciones básicas
  Future<void> registrarSolicitud(SolicitudIaModel solicitud) async {
    if (solicitud.prompt.isEmpty) {
      throw Exception('El prompt no puede estar vacío.');
    }
    if (solicitud.apiUsada.isEmpty) {
      throw Exception('Debe especificarse la API usada.');
    }
    await _service.crearSolicitud(solicitud);
  }

  /// Obtener una solicitud por ID
  Future<SolicitudIaModel?> obtenerSolicitudPorId(String id) {
    return _service.obtenerSolicitud(id);
  }

  /// Actualizar solicitud existente
  Future<void> actualizarSolicitud(SolicitudIaModel solicitud) async {
    await _service.actualizarSolicitud(solicitud);
  }

  /// Eliminar solicitud
  Future<void> eliminarSolicitud(String id) async {
    await _service.eliminarSolicitud(id);
  }

  /// Listar todas las solicitudes de un usuario
  Stream<List<SolicitudIaModel>> listarPorUsuario(String idUsuario) {
    return _service.obtenerPorUsuario(idUsuario);
  }

  /// Listar solicitudes por estado
  Stream<List<SolicitudIaModel>> listarPorEstado(String estado) {
    return _service.obtenerPorEstado(estado);
  }

  /// Listar todas las solicitudes (vista global/admin)
  Stream<List<SolicitudIaModel>> listarTodas() {
    return _service.obtenerTodas();
  }
}
