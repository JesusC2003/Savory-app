import 'package:proyecto_savory/services/usuario_servicio.dart';

import '../Models/usuario_model.dart';


class UsuarioController {
  final UsuarioService _service = UsuarioService();

  Future<void> registrarUsuario(UsuarioModel usuario) async {
    if (usuario.nombre.isEmpty || usuario.correo.isEmpty) {
      throw Exception('El nombre y el correo son obligatorios.');
    }
    await _service.crearUsuario(usuario);
  }

  Future<UsuarioModel?> obtenerUsuarioPorId(String id) {
    return _service.obtenerUsuario(id);
  }

  Future<void> actualizarPerfil(UsuarioModel usuario) async {
    await _service.actualizarUsuario(usuario);
  }

  Future<void> eliminarCuenta(String id) async {
    await _service.eliminarUsuario(id);
  }

  Stream<List<UsuarioModel>> listarUsuarios() {
    return _service.obtenerTodos();
  }
}
