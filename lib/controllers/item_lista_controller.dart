import '../Models/item_lista_model.dart';
import '../services/item_lista_service.dart';

class ItemListaController {
  final ItemListaService _service = ItemListaService();

  /// Registrar un ítem en la lista con validación básica
  Future<void> registrarItemLista(ItemListaModel item) async {
    if (item.cantidad <= 0) {
      throw Exception('La cantidad debe ser mayor que cero.');
    }
    await _service.crearItemLista(item);
  }

  /// Obtener un ítem por ID
  Future<ItemListaModel?> obtenerItemPorId(String id) {
    return _service.obtenerItem(id);
  }

  /// Actualizar ítem
  Future<void> actualizarItemLista(ItemListaModel item) async {
    await _service.actualizarItemLista(item);
  }

  /// Eliminar ítem
  Future<void> eliminarItemLista(String id) async {
    await _service.eliminarItemLista(id);
  }

  /// Listar ítems de una lista específica
  Stream<List<ItemListaModel>> listarItemsPorLista(String idLista) {
    return _service.obtenerPorLista(idLista);
  }

  /// Listar todos los ítems (solo para vista global)
  Stream<List<ItemListaModel>> listarTodos() {
    return _service.obtenerTodos();
  }

  /// Filtrar ítems por estado de compra (comprado o no)
  Stream<List<ItemListaModel>> listarPorEstadoCompra(bool comprado) {
    return _service.filtrarPorComprado(comprado);
  }
}
