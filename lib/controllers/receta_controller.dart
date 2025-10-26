import '../Models/receta_model.dart';
import '../services/receta_service.dart';

class RecetaController {
  final RecetaService _service = RecetaService();

  /// Registrar una receta validando los datos esenciales
  Future<void> registrarReceta(RecetaModel receta) async {
    if (receta.titulo.isEmpty || receta.descripcion.isEmpty) {
      throw Exception('El título y la descripción son obligatorios.');
    }
    await _service.crearReceta(receta);
  }

  /// Obtener una receta por su ID
  Future<RecetaModel?> obtenerRecetaPorId(String id) {
    return _service.obtenerReceta(id);
  }

  /// Actualizar una receta existente
  Future<void> actualizarReceta(RecetaModel receta) async {
    await _service.actualizarReceta(receta);
  }

  /// Eliminar una receta por su ID
  Future<void> eliminarReceta(String id) async {
    await _service.eliminarReceta(id);
  }

  /// Listar todas las recetas (stream)
  Stream<List<RecetaModel>> listarRecetas() {
    return _service.obtenerTodas();
  }

  /// Buscar recetas por texto (título parcial)
  Stream<List<RecetaModel>> buscarRecetas(String texto) {
    return _service.buscarPorTitulo(texto);
  }

  /// Filtrar recetas por nivel de acceso (gratuita, premium, video)
  Stream<List<RecetaModel>> filtrarPorNivel(String nivel) {
    return _service.filtrarPorNivel(nivel);
  }

  /// Filtrar recetas por dificultad
  Stream<List<RecetaModel>> filtrarPorDificultad(String dificultad) {
    return _service.filtrarPorDificultad(dificultad);
  }
}
