import '../Models/ingrediente_despensa_model.dart';
import '../services/ingrediente_despensa_service.dart';

class IngredienteDespensaController {
  final IngredienteDespensaService _service = IngredienteDespensaService();

  /// Registrar un ingrediente en la despensa con validación
  Future<void> registrarIngredienteDespensa(IngredienteDespensaModel registro) async {
    if (registro.cantidad <= 0) {
      throw Exception('La cantidad debe ser mayor que cero.');
    }
    await _service.crearIngredienteDespensa(registro);
  }

  /// Obtener un registro por su ID
  Future<IngredienteDespensaModel?> obtenerPorId(String id) {
    return _service.obtenerPorId(id);
  }

  /// Actualizar un registro
  Future<void> actualizarIngredienteDespensa(IngredienteDespensaModel registro) async {
    await _service.actualizarIngredienteDespensa(registro);
  }

  /// Eliminar un registro
  Future<void> eliminarIngredienteDespensa(String id) async {
    await _service.eliminarIngredienteDespensa(id);
  }

  /// Listar ingredientes de una despensa específica
  Stream<List<IngredienteDespensaModel>> listarPorDespensa(String idDespensa) {
    return _service.obtenerPorDespensa(idDespensa);
  }

  /// Listar todos los registros
  Stream<List<IngredienteDespensaModel>> listarTodos() {
    return _service.obtenerTodos();
  }

  /// Filtrar ingredientes por estado
  Stream<List<IngredienteDespensaModel>> filtrarPorEstado(String estado) {
    return _service.filtrarPorEstado(estado);
  }

  /// Mostrar ingredientes que vencen en los próximos [dias]
  Stream<List<IngredienteDespensaModel>> listarProximosAVencer(int dias) {
    return _service.proximosAVencer(dias);
  }
}
