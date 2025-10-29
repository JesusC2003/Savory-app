// lib/Models/receta_model.dart

class RecetaModel {
  final String idReceta;
  final String titulo;
  final String descripcion;
  final int tiempoPreparacion;
  final int porciones;
  final String dificultad;
  final String imagenUrl;
  final DateTime fechaRegistro;
  final String nivelAcceso;
  final String? categoria; // NUEVO
  final List<IngredienteRecetaDetalle>? ingredientes; // NUEVO
  final List<String>? pasos; // NUEVO
  final bool? favorita; // NUEVO

  RecetaModel({
    required this.idReceta,
    required this.titulo,
    required this.descripcion,
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

  factory RecetaModel.fromJson(Map<String, dynamic> json) => RecetaModel(
        idReceta: json['id_receta'] ?? '',
        titulo: json['titulo'] ?? '',
        descripcion: json['descripcion'] ?? '',
        tiempoPreparacion: json['tiempo_preparacion'] ?? 0,
        porciones: json['porciones'] ?? 1,
        dificultad: json['dificultad'] ?? 'Media',
        imagenUrl: json['imagen_url'] ?? '',
        fechaRegistro: json['fecha_registro'] != null
            ? DateTime.parse(json['fecha_registro'])
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

  Map<String, dynamic> toJson() => {
        'id_receta': idReceta,
        'titulo': titulo,
        'descripcion': descripcion,
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

// Clase auxiliar para ingredientes dentro de la receta (simplificado)
class IngredienteRecetaDetalle {
  final String nombre;
  final String cantidad;
  final String unidad;

  IngredienteRecetaDetalle({
    required this.nombre,
    required this.cantidad,
    required this.unidad,
  });

  factory IngredienteRecetaDetalle.fromJson(Map<String, dynamic> json) =>
      IngredienteRecetaDetalle(
        nombre: json['nombre'] ?? '',
        cantidad: json['cantidad']?.toString() ?? '0',
        unidad: json['unidad'] ?? 'unidades',
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'cantidad': cantidad,
        'unidad': unidad,
      };
}

// Modelo para ingredientes de la despensa (simplificado)
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
      Map<String, dynamic> data, String id) {
    return IngredienteDespensaSimple(
      id: id,
      nombre: data['nombre'] ?? '',
      cantidad: double.tryParse(data['cantidad']?.toString() ?? '0') ?? 0.0,
      unidad: data['unidad'] ?? 'unidades',
    );
  }
}

// Enum para el estado de los ingredientes
enum EstadoIngrediente {
  disponible,
  insuficiente,
  noDisponible,
}

// Clase para ingrediente con su estado
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