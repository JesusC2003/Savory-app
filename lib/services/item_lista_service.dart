import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/item_lista_model.dart';

class ItemListaService {
  final CollectionReference _itemsLista =
      FirebaseFirestore.instance.collection('items_lista');

  /// Crear un nuevo ítem dentro de una lista de compra
  Future<void> crearItemLista(ItemListaModel item) async {
    await _itemsLista.doc(item.idItemLista).set(item.toJson());
  }

  /// Obtener un ítem por su ID
  Future<ItemListaModel?> obtenerItem(String id) async {
    final doc = await _itemsLista.doc(id).get();
    if (!doc.exists) return null;
    return ItemListaModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar un ítem existente
  Future<void> actualizarItemLista(ItemListaModel item) async {
    await _itemsLista.doc(item.idItemLista).update(item.toJson());
  }

  /// Eliminar un ítem por su ID
  Future<void> eliminarItemLista(String id) async {
    await _itemsLista.doc(id).delete();
  }

  /// Obtener todos los ítems de una lista de compra
  Stream<List<ItemListaModel>> obtenerPorLista(String idLista) {
    return _itemsLista
        .where('id_lista', isEqualTo: idLista)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ItemListaModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todos los ítems de todas las listas (vista global/admin)
  Stream<List<ItemListaModel>> obtenerTodos() {
    return _itemsLista.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              ItemListaModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Filtrar ítems por estado (comprado o no comprado)
  Stream<List<ItemListaModel>> filtrarPorComprado(bool comprado) {
    return _itemsLista
        .where('comprado', isEqualTo: comprado)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ItemListaModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
