import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/usuario_model.dart';

class UsuarioService {
  final CollectionReference _usuarios =
      FirebaseFirestore.instance.collection('usuarios');

  Future<void> crearUsuario(UsuarioModel usuario) async {
    await _usuarios.doc(usuario.idUsuario).set(usuario.toJson());
  }

  Future<UsuarioModel?> obtenerUsuario(String id) async {
    final doc = await _usuarios.doc(id).get();
    if (!doc.exists) return null;
    return UsuarioModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<void> actualizarUsuario(UsuarioModel usuario) async {
    await _usuarios.doc(usuario.idUsuario).update(usuario.toJson());
  }

  Future<void> eliminarUsuario(String id) async {
    await _usuarios.doc(id).delete();
  }

  Stream<List<UsuarioModel>> obtenerTodos() {
    return _usuarios.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UsuarioModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
