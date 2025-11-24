// lib/controllers/receta_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/receta_model.dart';
import '../services/receta_service.dart';
import '../services/gemini_service.dart';

class RecetaController {
  final RecetaService _service = RecetaService();
  final GeminiService _geminiService = GeminiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  /// Registrar una receta validando los datos esenciales
  Future<void> registrarReceta(RecetaModel receta) async {
    if (receta.titulo.isEmpty || receta.descripcion.isEmpty) {
      throw Exception('El título y la descripción son obligatorios.');
    }
    await _service.crearReceta(receta);
  }

  /// Guardar receta en la colección del usuario (simplificado para UI)
  Future<void> guardarRecetaUsuario(RecetaModel receta) async {
    if (currentUser == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      print('💾 Guardando receta: ${receta.titulo}');
      print('   - ID: ${receta.idReceta}');
      print('   - Imagen URL: ${receta.imagenUrl}');
      print('   - Tiene ingredientes: ${receta.ingredientes?.isNotEmpty ?? false}');
      
      await _firestore
          .collection('usuarios')
          .doc(currentUser!.uid)
          .collection('recetas')
          .add(receta.toJson());
      
      print('✓ Receta guardada exitosamente');
    } catch (e) {
      print('❌ Error al guardar: $e');
      throw Exception('Error al guardar receta: $e');
    }
  }

  /// Obtener ingredientes de la despensa del usuario
  Future<List<IngredienteDespensaSimple>> obtenerIngredientesDespensa() async {
    if (currentUser == null) return [];

    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(currentUser!.uid)
          .collection('despensa')
          .get();

      return snapshot.docs
          .map((doc) =>
              IngredienteDespensaSimple.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener ingredientes: $e');
    }
  }

  /// Generar recetas con IA basadas en ingredientes disponibles
  Future<List<RecetaModel>> generarRecetasConIA() async {
    final ingredientes = await obtenerIngredientesDespensa();

    if (ingredientes.isEmpty) {
      throw Exception('No hay ingredientes en la despensa');
    }

    return await _geminiService.generarRecetasConIngredientes(ingredientes);
  }

  /// Verificar estado de ingredientes de una receta
  List<IngredienteConEstado> verificarEstadoIngredientes(
    RecetaModel receta,
    List<IngredienteDespensaSimple> despensa,
  ) {
    if (receta.ingredientes == null) return [];

    return receta.ingredientes!.map((ingredienteReceta) {
      // Buscar el ingrediente en la despensa
      final ingredienteDespensa = despensa.firstWhere(
        (d) =>
            d.nombre.toLowerCase().trim() ==
            ingredienteReceta.nombre.toLowerCase().trim(),
        orElse: () => IngredienteDespensaSimple(
          id: '',
          nombre: '',
          cantidad: 0,
          unidad: '',
        ),
      );

      // Si no existe en la despensa
      if (ingredienteDespensa.nombre.isEmpty) {
        return IngredienteConEstado(
          ingrediente: ingredienteReceta,
          estado: EstadoIngrediente.noDisponible,
        );
      }

      // Comparar cantidades
      final cantidadNecesaria =
          double.tryParse(ingredienteReceta.cantidad) ?? 0.0;
      final cantidadDisponible = ingredienteDespensa.cantidad;

      if (cantidadDisponible >= cantidadNecesaria) {
        return IngredienteConEstado(
          ingrediente: ingredienteReceta,
          estado: EstadoIngrediente.disponible,
          cantidadDisponible: cantidadDisponible,
        );
      } else if (cantidadDisponible > 0) {
        return IngredienteConEstado(
          ingrediente: ingredienteReceta,
          estado: EstadoIngrediente.insuficiente,
          cantidadDisponible: cantidadDisponible,
        );
      } else {
        return IngredienteConEstado(
          ingrediente: ingredienteReceta,
          estado: EstadoIngrediente.noDisponible,
        );
      }
    }).toList();
  }

  /// Obtener recetas del usuario (stream)
  Stream<List<RecetaModel>> obtenerRecetasUsuario() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('usuarios')
        .doc(currentUser!.uid)
        .collection('recetas')
        .orderBy('fecha_registro', descending: true)
        .snapshots()
        .map((snapshot) {
      final recetas = snapshot.docs
          .map((doc) {
            final data = {...doc.data(), 'id_receta': doc.id};
            final receta = RecetaModel.fromJson(data);
            print('📖 Receta recuperada: ${receta.titulo}');
            print('   - ID: ${receta.idReceta}');
            print('   - Imagen URL: ${receta.imagenUrl}');
            print('   - Preparada: ${receta.preparada}');
            return receta;
          })
          .toList();
      
      print('📊 Total recetas: ${recetas.length}');
      return recetas;
    });
  }

  /// Eliminar receta del usuario
  Future<void> eliminarRecetaUsuario(String recetaId) async {
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('usuarios')
          .doc(currentUser!.uid)
          .collection('recetas')
          .doc(recetaId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar receta: $e');
    }
  }

  /// Marcar receta como favorita
  Future<void> toggleFavorita(String recetaId, bool estadoActual) async {
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('usuarios')
          .doc(currentUser!.uid)
          .collection('recetas')
          .doc(recetaId)
          .update({'favorita': !estadoActual});
    } catch (e) {
      throw Exception('Error al actualizar favorita: $e');
    }
  }

  /// Marcar receta como preparada
  Future<void> togglePreparada(String recetaId, bool estadoActual) async {
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('usuarios')
          .doc(currentUser!.uid)
          .collection('recetas')
          .doc(recetaId)
          .update({'preparada': !estadoActual});
    } catch (e) {
      throw Exception('Error al actualizar preparada: $e');
    }
  }

  // ===== Métodos originales del controller =====

  /// Obtener una receta por su ID
  Future<RecetaModel?> obtenerRecetaPorId(String id) {
    return _service.obtenerReceta(id);
  }

  /// Actualizar una receta existente
  Future<void> actualizarReceta(RecetaModel receta) async {
    await _service.actualizarReceta(receta);
  }

  /// Eliminar una receta por su ID
  Future<void> eliminarReceta(String id) async {
    await _service.eliminarReceta(id);
  }

  /// Listar todas las recetas (stream)
  Stream<List<RecetaModel>> listarRecetas() {
    return _service.obtenerTodas();
  }

  /// Buscar recetas por texto (título parcial)
  Stream<List<RecetaModel>> buscarRecetas(String texto) {
    return _service.buscarPorTitulo(texto);
  }

  /// Filtrar recetas por nivel de acceso (gratuita, premium, video)
  Stream<List<RecetaModel>> filtrarPorNivel(String nivel) {
    return _service.filtrarPorNivel(nivel);
  }

  /// Filtrar recetas por dificultad
  Stream<List<RecetaModel>> filtrarPorDificultad(String dificultad) {
    return _service.filtrarPorDificultad(dificultad);
  }
}