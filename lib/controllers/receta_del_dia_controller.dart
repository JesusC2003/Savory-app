// lib/controllers/receta_del_dia_controller.dart

import '../Models/receta_model.dart';
import '../services/receta_del_dia_service.dart';

class RecetaDelDiaController {
  final RecetaDelDiaService _service = RecetaDelDiaService();

  RecetaModel? _recetaEnCache;
  DateTime? _fechaUltimaConsulta;

  /// Obtiene la receta del día
  /// Si está en caché y es del mismo día, la retorna
  /// Si no, genera una nueva
  Future<RecetaModel?> obtenerRecetaDelDia() async {
    try {
      final ahora = DateTime.now();
      final hoy = DateTime(ahora.year, ahora.month, ahora.day);

      // Verificar si está en caché y es del mismo día
      if (_recetaEnCache != null &&
          _fechaUltimaConsulta != null &&
          DateTime(_fechaUltimaConsulta!.year, _fechaUltimaConsulta!.month, _fechaUltimaConsulta!.day)
              .isAtSameMomentAs(hoy)) {
        return _recetaEnCache;
      }

      // Generar nueva receta
      final receta = await _service.obtenerRecetaDelDia();

      // Guardar en caché
      _recetaEnCache = receta;
      _fechaUltimaConsulta = ahora;

      return receta;
    } catch (e) {
      print('Error obteniendo receta del día: $e');
      return null;
    }
  }

  /// Limpia el caché (útil para pruebas o refresh manual)
  void limpiarCache() {
    _recetaEnCache = null;
    _fechaUltimaConsulta = null;
  }
}
