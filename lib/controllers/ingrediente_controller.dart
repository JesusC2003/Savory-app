import '../Models/ingrediente_model.dart';
import '../services/ingrediente_service.dart';

class IngredienteController {
  final IngredienteService _service = IngredienteService();

  /// Registrar un nuevo ingrediente con validación básica
  Future<void> registrarIngrediente(IngredienteModel ingrediente) async {
    if (ingrediente.nombre.isEmpty || ingrediente.categoria.isEmpty) {
      throw Exception('El nombre y la categoría del ingrediente son obligatorios.');
    }
    await _service.crearIngrediente(ingrediente);
  }

  /// Obtener ingrediente por ID
  Future<IngredienteModel?> obtenerIngredientePorId(String id) {
    return _service.obtenerIngrediente(id);
  }

  /// Actualizar ingrediente
  Future<void> actualizarIngrediente(IngredienteModel ingrediente) async {
    await _service.actualizarIngrediente(ingrediente);
  }

  /// Eliminar ingrediente
  Future<void> eliminarIngrediente(String id) async {
    await _service.eliminarIngrediente(id);
  }

  /// Listar todos los ingredientes
  Stream<List<IngredienteModel>> listarIngredientes() {
    return _service.obtenerTodos();
  }

  /// Buscar ingredientes por nombre
  Stream<List<IngredienteModel>> buscarIngrediente(String texto) {
    return _service.buscarPorNombre(texto);
  }

  /// Filtrar ingredientes por categoría
  Stream<List<IngredienteModel>> filtrarPorCategoria(String categoria) {
    return _service.filtrarPorCategoria(categoria);
  }
}
