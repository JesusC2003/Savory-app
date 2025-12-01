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
    
    print('🔍 RecetaDelDiaController.obtenerRecetaDelDia()');
    print('   - Fecha hoy: $hoy');
    print('   - Fecha en caché: $_fechaCacheada');
    print('   - Tiene receta en caché: ${_recetaEnCache != null}');
    print('   - Está cargando: $_estaCargando');
    
    // Si ya está en caché del mismo día, retornar inmediatamente
    if (_recetaEnCache != null && _fechaCacheada == hoy) {
      print('📦 Retornando receta del día desde caché en memoria');
      print('   - Título: ${_recetaEnCache!.titulo}');
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
      print('⚠️ Aún sin receta después de esperar');
      return null;
    }

    try {
      _estaCargando = true;
      print('🔄 Llamando al servicio para obtener receta del día...');
      
      final receta = await _service.obtenerRecetaDelDia();
      
      if (receta != null) {
        _recetaEnCache = receta;
        _fechaCacheada = hoy;
        print('✅ Receta del día cargada y guardada en caché:');
        print('   - Título: ${receta.titulo}');
        print('   - Imagen URL: ${receta.imagenUrl.substring(0, 50)}...');
        print('   - Ingredientes: ${receta.ingredientes?.length ?? 0}');
        print('   - Pasos: ${receta.pasos?.length ?? 0}');
      } else {
        print('⚠️ El servicio retornó null');
      }
      
      return receta;
    } catch (e, stackTrace) {
      print('❌ Error obteniendo receta del día: $e');
      print('Stack trace: $stackTrace');
      return null;
    } finally {
      _estaCargando = false;
      print('✓ _estaCargando = false');
    }
  }

  String _obtenerFechaHoy() {
    final ahora = DateTime.now();
    return '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';
  }

  /// Fuerza regeneración (para uso manual)
  Future<RecetaModel?> forzarRegeneracion() async {
    print('🔄 Forzando regeneración de receta del día...');
    _recetaEnCache = null;
    _fechaCacheada = null;
    return obtenerRecetaDelDia();
  }

  /// Verifica si hay receta cargada
  bool get tieneRecetaCargada => _recetaEnCache != null;
  
  /// Obtiene la receta sin hacer llamada async (puede ser null)
  RecetaModel? get recetaActual => _recetaEnCache;
}