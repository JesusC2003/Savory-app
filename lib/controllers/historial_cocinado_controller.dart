import '../Models/historial_cocinado_model.dart';
import '../services/historial_cocinado_service.dart';

class HistorialCocinadoController {
  final HistorialCocinadoService _service = HistorialCocinadoService();

  /// Registrar un nuevo historial de cocinado
  Future<void> registrarHistorial(HistorialCocinadoModel historial) async {
    if (historial.calificacion < 1 || historial.calificacion > 5) {
      throw Exception('La calificación debe estar entre 1 y 5.');
    }
    await _service.crearHistorial(historial);
  }

  /// Obtener un historial por ID
  Future<HistorialCocinadoModel?> obtenerHistorialPorId(String id) {
    return _service.obtenerHistorial(id);
  }

  /// Actualizar historial existente
  Future<void> actualizarHistorial(HistorialCocinadoModel historial) async {
    await _service.actualizarHistorial(historial);
  }

  /// Eliminar historial
  Future<void> eliminarHistorial(String id) async {
    await _service.eliminarHistorial(id);
  }

  /// Listar historiales de un usuario
  Stream<List<HistorialCocinadoModel>> listarPorUsuario(String idUsuario) {
    return _service.obtenerPorUsuario(idUsuario);
  }

  /// Listar historiales de una receta
  Stream<List<HistorialCocinadoModel>> listarPorReceta(String idReceta) {
    return _service.obtenerPorReceta(idReceta);
  }

  /// Listar todos los historiales
  Stream<List<HistorialCocinadoModel>> listarTodos() {
    return _service.obtenerTodos();
  }

  /// Obtener promedio de calificación de una receta
  Future<double> promedioCalificacion(String idReceta) {
    return _service.obtenerPromedioCalificacion(idReceta);
  }
}
