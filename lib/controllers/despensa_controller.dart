import '../Models/despensa_model.dart';
import '../services/despensa_service.dart';

class DespensaController {
  final DespensaService _service = DespensaService();

  /// Crear una despensa validando los datos
  Future<void> registrarDespensa(DespensaModel despensa) async {
    if (despensa.nombre.isEmpty) {
      throw Exception('El nombre de la despensa no puede estar vacío.');
    }
    await _service.crearDespensa(despensa);
  }

  /// Obtener despensa por ID
  Future<DespensaModel?> obtenerDespensaPorId(String id) {
    return _service.obtenerDespensa(id);
  }

  /// Actualizar despensa
  Future<void> actualizarDespensa(DespensaModel despensa) async {
    await _service.actualizarDespensa(despensa);
  }

  /// Eliminar despensa
  Future<void> eliminarDespensa(String id) async {
    await _service.eliminarDespensa(id);
  }

  /// Listar despensas por usuario
  Stream<List<DespensaModel>> listarDespensasDeUsuario(String idUsuario) {
    return _service.obtenerDespensasPorUsuario(idUsuario);
  }

  /// Listar todas las despensas (solo para depuración o vista global)
  Stream<List<DespensaModel>> listarTodasDespensas() {
    return _service.obtenerTodas();
  }
}
