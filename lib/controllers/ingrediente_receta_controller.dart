import '../Models/ingrediente_receta_model.dart';
import '../services/ingrediente_receta_service.dart';

class IngredienteRecetaController {
  final IngredienteRecetaService _service = IngredienteRecetaService();

  /// Registrar un ingrediente dentro de una receta
  Future<void> registrarIngredienteReceta(IngredienteRecetaModel registro) async {
    if (registro.cantidadNecesaria <= 0) {
      throw Exception('La cantidad necesaria debe ser mayor que cero.');
    }
    await _service.crearIngredienteReceta(registro);
  }

  /// Obtener un registro por ID
  Future<IngredienteRecetaModel?> obtenerPorId(String id) {
    return _service.obtenerPorId(id);
  }

  /// Actualizar registro
  Future<void> actualizarIngredienteReceta(IngredienteRecetaModel registro) async {
    await _service.actualizarIngredienteReceta(registro);
  }

  /// Eliminar registro
  Future<void> eliminarIngredienteReceta(String id) async {
    await _service.eliminarIngredienteReceta(id);
  }

  /// Listar todos los ingredientes de una receta específica
  Stream<List<IngredienteRecetaModel>> listarPorReceta(String idReceta) {
    return _service.obtenerPorReceta(idReceta);
  }

  /// Listar todos los registros
  Stream<List<IngredienteRecetaModel>> listarTodos() {
    return _service.obtenerTodos();
  }

  /// Listar solo los ingredientes opcionales o no opcionales
  Stream<List<IngredienteRecetaModel>> listarOpcionales(bool opcional) {
    return _service.obtenerOpcionales(opcional);
  }
}
