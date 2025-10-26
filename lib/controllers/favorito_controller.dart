import '../Models/favorito_model.dart';
import '../services/favorito_service.dart';

class FavoritoController {
  final FavoritoService _service = FavoritoService();

  /// Registrar un nuevo favorito
  Future<void> registrarFavorito(FavoritoModel favorito) async {
    final existe = await _service.esFavorito(favorito.idUsuario, favorito.idReceta);
    if (existe) {
      throw Exception('La receta ya está en favoritos.');
    }
    await _service.crearFavorito(favorito);
  }

  /// Obtener un favorito por ID
  Future<FavoritoModel?> obtenerFavoritoPorId(String id) {
    return _service.obtenerFavorito(id);
  }

  /// Eliminar un favorito
  Future<void> eliminarFavorito(String id) async {
    await _service.eliminarFavorito(id);
  }

  /// Listar todos los favoritos de un usuario
  Stream<List<FavoritoModel>> listarFavoritosDeUsuario(String idUsuario) {
    return _service.obtenerPorUsuario(idUsuario);
  }

  /// Verificar si una receta es favorita del usuario
  Future<bool> esFavorito(String idUsuario, String idReceta) {
    return _service.esFavorito(idUsuario, idReceta);
  }

  /// Listar todos los favoritos (global/admin)
  Stream<List<FavoritoModel>> listarTodos() {
    return _service.obtenerTodos();
  }
}
