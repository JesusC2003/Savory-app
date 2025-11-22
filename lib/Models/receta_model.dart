// lib/Models/receta_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RecetaModel {
  final String idReceta;
  final String titulo;
  final String descripcion;
  final String? promptImagen; // ⭐ NUEVO: Prompt para generar imagen
  final int tiempoPreparacion;
  final int porciones;
  final String dificultad;
  final String imagenUrl;
  final DateTime fechaRegistro;
  final String nivelAcceso;
  final String? categoria;
  final List<IngredienteRecetaDetalle>? ingredientes;
  final List<String>? pasos;
  final bool? favorita;

  RecetaModel({
    required this.idReceta,
    required this.titulo,
    required this.descripcion,
    this.promptImagen,
    required this.tiempoPreparacion,
    required this.porciones,
    required this.dificultad,
    required this.imagenUrl,
    required this.fechaRegistro,
    required this.nivelAcceso,
    this.categoria,
    this.ingredientes,
    this.pasos,
    this.favorita,
  });

  // fromJson - Para deserializar desde Firestore o JSON
  factory RecetaModel.fromJson(Map<String, dynamic> json) {
    return RecetaModel(
      idReceta: json['id_receta'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      promptImagen: json['prompt_imagen'],
      tiempoPreparacion: json['tiempo_preparacion'] ?? 0,
      porciones: json['porciones'] ?? 1,
      dificultad: json['dificultad'] ?? 'Media',
      imagenUrl: json['imagen_url'] ?? '',
      fechaRegistro: json['fecha_registro'] != null
          ? (json['fecha_registro'] is Timestamp
              ? (json['fecha_registro'] as Timestamp).toDate()
              : DateTime.parse(json['fecha_registro']))
          : DateTime.now(),
      nivelAcceso: json['nivel_acceso'] ?? 'gratuita',
      categoria: json['categoria'],
      ingredientes: json['ingredientes'] != null
          ? (json['ingredientes'] as List)
              .map((i) => IngredienteRecetaDetalle.fromJson(i))
              .toList()
          : null,
      pasos: json['pasos'] != null ? List<String>.from(json['pasos']) : null,
      favorita: json['favorita'],
    );
  }

  // toJson - Para serializar hacia Firestore o JSON
  Map<String, dynamic> toJson() {
    return {
      'id_receta': idReceta,
      'titulo': titulo,
      'descripcion': descripcion,
      'prompt_imagen': promptImagen,
      'tiempo_preparacion': tiempoPreparacion,
      'porciones': porciones,
      'dificultad': dificultad,
      'imagen_url': imagenUrl,
      'fecha_registro': Timestamp.fromDate(fechaRegistro),
      'nivel_acceso': nivelAcceso,
      if (categoria != null) 'categoria': categoria,
      if (ingredientes != null)
        'ingredientes': ingredientes!.map((i) => i.toJson()).toList(),
      if (pasos != null) 'pasos': pasos,
      if (favorita != null) 'favorita': favorita,
    };
  }

  // toMap - Versión simplificada para operaciones sin Timestamp
  Map<String, dynamic> toMap() {
    return {
      'id_receta': idReceta,
      'titulo': titulo,
      'descripcion': descripcion,
      'prompt_imagen': promptImagen,
      'tiempo_preparacion': tiempoPreparacion,
      'porciones': porciones,
      'dificultad': dificultad,
      'imagen_url': imagenUrl,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'nivel_acceso': nivelAcceso,
      if (categoria != null) 'categoria': categoria,
      if (ingredientes != null)
        'ingredientes': ingredientes!.map((i) => i.toJson()).toList(),
      if (pasos != null) 'pasos': pasos,
      if (favorita != null) 'favorita': favorita,
    };
  }

  // copyWith - Para crear copias con modificaciones
  RecetaModel copyWith({
    String? idReceta,
    String? titulo,
    String? descripcion,
    String? promptImagen,
    int? tiempoPreparacion,
    int? porciones,
    String? dificultad,
    String? imagenUrl,
    DateTime? fechaRegistro,
    String? nivelAcceso,
    String? categoria,
    List<IngredienteRecetaDetalle>? ingredientes,
    List<String>? pasos,
    bool? favorita,
  }) {
    return RecetaModel(
      idReceta: idReceta ?? this.idReceta,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      promptImagen: promptImagen ?? this.promptImagen,
      tiempoPreparacion: tiempoPreparacion ?? this.tiempoPreparacion,
      porciones: porciones ?? this.porciones,
      dificultad: dificultad ?? this.dificultad,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      nivelAcceso: nivelAcceso ?? this.nivelAcceso,
      categoria: categoria ?? this.categoria,
      ingredientes: ingredientes ?? this.ingredientes,
      pasos: pasos ?? this.pasos,
      favorita: favorita ?? this.favorita,
    );
  }

  // Generar hash único basado en ingredientes y título para detectar duplicados
  String getRecipeHash() {
    final ingredientesStr = ingredientes
            ?.map((i) => i.nombre.toLowerCase().trim())
            .toList()
            .join(',') ??
        '';
    final tituloNormalizado = titulo.toLowerCase().trim();
    return '${tituloNormalizado}_$ingredientesStr'.hashCode.toString();
  }
}

// ==================== CLASES AUXILIARES ====================

/// Detalle de ingrediente dentro de una receta
class IngredienteRecetaDetalle {
  final String nombre;
  final String cantidad;
  final String unidad;

  IngredienteRecetaDetalle({
    required this.nombre,
    required this.cantidad,
    required this.unidad,
  });

  factory IngredienteRecetaDetalle.fromJson(Map<String, dynamic> json) {
    return IngredienteRecetaDetalle(
      nombre: json['nombre'] ?? '',
      cantidad: json['cantidad']?.toString() ?? '0',
      unidad: json['unidad'] ?? 'unidades',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'cantidad': cantidad,
      'unidad': unidad,
    };
  }

  factory IngredienteRecetaDetalle.fromMap(Map<String, dynamic> map) {
    return IngredienteRecetaDetalle.fromJson(map);
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }
}

/// Ingrediente simplificado de la despensa
class IngredienteDespensaSimple {
  final String id;
  final String nombre;
  final double cantidad;
  final String unidad;

  IngredienteDespensaSimple({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.unidad,
  });

  factory IngredienteDespensaSimple.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return IngredienteDespensaSimple(
      id: id,
      nombre: data['nombre'] ?? '',
      cantidad: double.tryParse(data['cantidad']?.toString() ?? '0') ?? 0.0,
      unidad: data['unidad'] ?? 'unidades',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'unidad': unidad,
    };
  }
}

/// Estado de disponibilidad de ingredientes
enum EstadoIngrediente {
  disponible,
  insuficiente,
  noDisponible,
}

/// Ingrediente con su estado de disponibilidad
class IngredienteConEstado {
  final IngredienteRecetaDetalle ingrediente;
  final EstadoIngrediente estado;
  final double? cantidadDisponible;

  IngredienteConEstado({
    required this.ingrediente,
    required this.estado,
    this.cantidadDisponible,
  });
}