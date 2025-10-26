import '../Models/lista_compra_model.dart';
import '../services/lista_compra_service.dart';

class ListaCompraController {
  final ListaCompraService _service = ListaCompraService();

  /// Registrar una nueva lista de compra con validación básica
  Future<void> registrarListaCompra(ListaCompraModel lista) async {
    if (lista.nombre.isEmpty) {
      throw Exception('El nombre de la lista no puede estar vacío.');
    }
    await _service.crearListaCompra(lista);
  }

  /// Obtener una lista por su ID
  Future<ListaCompraModel?> obtenerListaPorId(String id) {
    return _service.obtenerLista(id);
  }

  /// Actualizar lista
  Future<void> actualizarListaCompra(ListaCompraModel lista) async {
    await _service.actualizarListaCompra(lista);
  }

  /// Eliminar lista
  Future<void> eliminarListaCompra(String id) async {
    await _service.eliminarListaCompra(id);
  }

  /// Listar todas las listas de un usuario
  Stream<List<ListaCompraModel>> listarListasDeUsuario(String idUsuario) {
    return _service.obtenerPorUsuario(idUsuario);
  }

  /// Listar todas las listas (global)
  Stream<List<ListaCompraModel>> listarTodas() {
    return _service.obtenerTodas();
  }

  /// Filtrar listas por estado
  Stream<List<ListaCompraModel>> filtrarPorEstado(String estado) {
    return _service.filtrarPorEstado(estado);
  }

  /// Buscar listas por nombre
  Stream<List<ListaCompraModel>> buscarListas(String texto) {
    return _service.buscarPorNombre(texto);
  }
}
