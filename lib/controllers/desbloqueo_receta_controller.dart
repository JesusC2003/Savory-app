import '../Models/desbloqueo_receta_model.dart';
import '../services/desbloqueo_receta_service.dart';

class DesbloqueoRecetaController {
  final DesbloqueoRecetaService _service = DesbloqueoRecetaService();

  /// Registrar un nuevo desbloqueo
  Future<void> registrarDesbloqueo(DesbloqueoRecetaModel desbloqueo) async {
    if (desbloqueo.fechaExpiracion.isBefore(desbloqueo.fechaDesbloqueo)) {
      throw Exception('La fecha de expiración no puede ser anterior al desbloqueo.');
    }
    await _service.crearDesbloqueo(desbloqueo);
  }

  /// Obtener un desbloqueo por ID
  Future<DesbloqueoRecetaModel?> obtenerDesbloqueoPorId(String id) {
    return _service.obtenerDesbloqueo(id);
  }

  /// Actualizar un desbloqueo existente
  Future<void> actualizarDesbloqueo(DesbloqueoRecetaModel desbloqueo) async {
    await _service.actualizarDesbloqueo(desbloqueo);
  }

  /// Eliminar un desbloqueo
  Future<void> eliminarDesbloqueo(String id) async {
    await _service.eliminarDesbloqueo(id);
  }

  /// Listar todos los desbloqueos de un usuario
  Stream<List<DesbloqueoRecetaModel>> listarPorUsuario(String idUsuario) {
    return _service.obtenerPorUsuario(idUsuario);
  }

  /// Listar desbloqueos activos de un usuario
  Stream<List<DesbloqueoRecetaModel>> listarActivosPorUsuario(String idUsuario) {
    return _service.obtenerActivosPorUsuario(idUsuario);
  }

  /// Listar todos los desbloqueos (global/admin)
  Stream<List<DesbloqueoRecetaModel>> listarTodos() {
    return _service.obtenerTodos();
  }

  /// Verificar si una receta está desbloqueada por el usuario
  Future<bool> recetaDesbloqueada(String idUsuario, String idReceta) {
    return _service.tieneDesbloqueoActivo(idUsuario, idReceta);
  }
}
