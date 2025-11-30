// lib/controllers/receta_del_dia_controller.dart

import '../Models/receta_model.dart';
import '../services/receta_del_dia_service.dart';

class RecetaDelDiaController {
  static final RecetaDelDiaController _instance = RecetaDelDiaController._internal();
  factory RecetaDelDiaController() => _instance;
  RecetaDelDiaController._internal();

  final RecetaDelDiaService _service = RecetaDelDiaService();
  
  RecetaModel? _recetaEnCache;
  bool _estaCargando = false;
  String? _fechaCacheada;

  /// Obtiene la receta del día (singleton con caché)
  Future<RecetaModel?> obtenerRecetaDelDia() async {
    final hoy = _obtenerFechaHoy();
    
    // Si ya está en caché del mismo día, retornar inmediatamente
    if (_recetaEnCache != null && _fechaCacheada == hoy) {
      print('📦 Retornando receta del día desde caché en memoria');
      return _recetaEnCache;
    }

    // Evitar múltiples llamadas simultáneas
    if (_estaCargando) {
      print('⏳ Ya se está cargando la receta del día...');
      // Esperar un poco y reintentar
      await Future.delayed(const Duration(milliseconds: 500));
      if (_recetaEnCache != null && _fechaCacheada == hoy) {
        return _recetaEnCache;
      }
      return null;
    }

    try {
      _estaCargando = true;
      print('🔄 Obteniendo receta del día...');
      
      final receta = await _service.obtenerRecetaDelDia();
      
      if (receta != null) {
        _recetaEnCache = receta;
        _fechaCacheada = hoy;
        print('✅ Receta del día cargada: ${receta.titulo}');
      }
      
      return receta;
    } catch (e) {
      print('❌ Error obteniendo receta del día: $e');
      return null;
    } finally {
      _estaCargando = false;
    }
  }

  String _obtenerFechaHoy() {
    final ahora = DateTime.now();
    return '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';
  }

  /// Fuerza regeneración (para uso manual)
  Future<RecetaModel?> forzarRegeneracion() async {
    _recetaEnCache = null;
    _fechaCacheada = null;
    return obtenerRecetaDelDia();
  }

  /// Verifica si hay receta cargada
  bool get tieneRecetaCargada => _recetaEnCache != null;
  
  /// Obtiene la receta sin hacer llamada async (puede ser null)
  RecetaModel? get recetaActual => _recetaEnCache;
}
