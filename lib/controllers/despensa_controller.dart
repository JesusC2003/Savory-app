import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DespensaController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  /// Obtener stream de ingredientes de la despensa
  Stream<QuerySnapshot> obtenerIngredientes() {
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .collection('despensa')
        .orderBy('fecha_agregado', descending: true)
        .snapshots();
  }

  /// Agregar un solo ingrediente
  Future<void> agregarIngrediente({
    required String nombre,
    required String cantidad,
    required String unidad,
  }) async {
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    await _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .collection('despensa')
        .add({
      'nombre': nombre,
      'cantidad': cantidad,
      'unidad': unidad,
      'fecha_agregado': DateTime.now().toIso8601String(),
    });
  }

  /// Agregar múltiples ingredientes en lote (batch)
  Future<void> agregarIngredientesLote(List<String> ingredientes) async {
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    if (ingredientes.isEmpty) {
      throw Exception('No hay ingredientes para agregar');
    }

    final batch = _firestore.batch();
    final despensaRef = _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .collection('despensa');

    for (String ingrediente in ingredientes) {
      final docRef = despensaRef.doc();
      batch.set(docRef, {
        'nombre': ingrediente,
        'cantidad': '1',
        'unidad': 'unidades',
        'fecha_agregado': DateTime.now().toIso8601String(),
      });
    }

    await batch.commit();
  }

  /// Actualizar un ingrediente
  Future<void> actualizarIngrediente({
    required String docId,
    required String nombre,
    required String cantidad,
    required String unidad,
  }) async {
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    await _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .collection('despensa')
        .doc(docId)
        .update({
      'nombre': nombre,
      'cantidad': cantidad,
      'unidad': unidad,
    });
  }

  /// Eliminar un ingrediente
  Future<void> eliminarIngrediente(String docId) async {
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    await _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .collection('despensa')
        .doc(docId)
        .delete();
  }

  /// Verificar si un ingrediente ya existe
  Future<bool> ingredienteExiste(String nombre) async {
    if (currentUser == null) return false;final query = await _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .collection('despensa')
        .where('nombre', isEqualTo: nombre.toLowerCase())
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  /// Obtener cantidad total de ingredientes
  Future<int> obtenerCantidadTotal() async {
    if (currentUser == null) return 0;

    final snapshot = await _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .collection('despensa')
        .get();

    return snapshot.docs.length;
  }

  /// Limpiar toda la despensa
  Future<void> limpiarDespensa() async {
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .collection('despensa')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}