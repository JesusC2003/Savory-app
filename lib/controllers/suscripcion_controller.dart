import '../Models/suscripcion_model.dart';
import '../services/suscripcion_service.dart';

class SuscripcionController {
  final SuscripcionService _service = SuscripcionService();

  /// Registrar una nueva suscripción con validaciones básicas
  Future<void> registrarSuscripcion(SuscripcionModel suscripcion) async {
    if (suscripcion.fechaExpiracion.isBefore(suscripcion.fechaInicio)) {
      throw Exception('La fecha de expiración no puede ser anterior a la de inicio.');
    }
    await _service.crearSuscripcion(suscripcion);
  }

  /// Obtener una suscripción por ID
  Future<SuscripcionModel?> obtenerSuscripcionPorId(String id) {
    return _service.obtenerSuscripcion(id);
  }

  /// Actualizar una suscripción
  Future<void> actualizarSuscripcion(SuscripcionModel suscripcion) async {
    await _service.actualizarSuscripcion(suscripcion);
  }

  /// Eliminar una suscripción
  Future<void> eliminarSuscripcion(String id) async {
    await _service.eliminarSuscripcion(id);
  }

  /// Listar suscripciones de un usuario
  Stream<List<SuscripcionModel>> listarPorUsuario(String idUsuario) {
    return _service.obtenerPorUsuario(idUsuario);
  }

  /// Listar suscripciones por estado
  Stream<List<SuscripcionModel>> listarPorEstado(String estado) {
    return _service.obtenerPorEstado(estado);
  }

  /// Listar todas las suscripciones
  Stream<List<SuscripcionModel>> listarTodas() {
    return _service.obtenerTodas();
  }

  /// Verificar si el usuario tiene una suscripción activa
  Future<bool> tieneSuscripcionActiva(String idUsuario) {
    return _service.suscripcionActiva(idUsuario);
  }
}
