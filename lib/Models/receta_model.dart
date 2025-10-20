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
  });

  factory RecetaModel.fromJson(Map<String, dynamic> json) => RecetaModel(
        idReceta: json['id_receta'],
        titulo: json['titulo'],
        descripcion: json['descripcion'],
        tiempoPreparacion: json['tiempo_preparacion'],
        porciones: json['porciones'],
        dificultad: json['dificultad'],
        imagenUrl: json['imagen_url'],
        fechaRegistro: DateTime.parse(json['fecha_registro']),
        nivelAcceso: json['nivel_acceso'],
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
      };
}
