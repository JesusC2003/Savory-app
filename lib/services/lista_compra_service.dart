import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/lista_compra_model.dart';

class ListaCompraService {
  final CollectionReference _listas =
      FirebaseFirestore.instance.collection('listas_compra');

  /// Crear una nueva lista de compra
  Future<void> crearListaCompra(ListaCompraModel lista) async {
    await _listas.doc(lista.idLista).set(lista.toJson());
  }

  /// Obtener una lista de compra por su ID
  Future<ListaCompraModel?> obtenerLista(String id) async {
    final doc = await _listas.doc(id).get();
    if (!doc.exists) return null;
    return ListaCompraModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Actualizar una lista existente
  Future<void> actualizarListaCompra(ListaCompraModel lista) async {
    await _listas.doc(lista.idLista).update(lista.toJson());
  }

  /// Eliminar una lista por ID
  Future<void> eliminarListaCompra(String id) async {
    await _listas.doc(id).delete();
  }

  /// Obtener todas las listas de un usuario
  Stream<List<ListaCompraModel>> obtenerPorUsuario(String idUsuario) {
    return _listas
        .where('id_usuario', isEqualTo: idUsuario)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ListaCompraModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Obtener todas las listas (vista general o admin)
  Stream<List<ListaCompraModel>> obtenerTodas() {
    return _listas.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              ListaCompraModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Filtrar listas por estado (activa, completada, cancelada)
  Stream<List<ListaCompraModel>> filtrarPorEstado(String estado) {
    return _listas
        .where('estado', isEqualTo: estado)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ListaCompraModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Buscar listas por nombre (coincidencia parcial)
  Stream<List<ListaCompraModel>> buscarPorNombre(String texto) {
    return _listas
        .where('nombre', isGreaterThanOrEqualTo: texto)
        .where('nombre', isLessThanOrEqualTo: '$texto\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ListaCompraModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
