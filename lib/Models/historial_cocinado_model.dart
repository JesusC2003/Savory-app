class HistorialCocinadoModel {
  final String idHistorial;
  final String idUsuario;
  final String idReceta;
  final DateTime fecha;
  final int calificacion;

  HistorialCocinadoModel({
    required this.idHistorial,
    required this.idUsuario,
    required this.idReceta,
    required this.fecha,
    required this.calificacion,
  });

  factory HistorialCocinadoModel.fromJson(Map<String, dynamic> json) =>
      HistorialCocinadoModel(
        idHistorial: json['id_historial'],
        idUsuario: json['id_usuario'],
        idReceta: json['id_receta'],
        fecha: DateTime.parse(json['fecha']),
        calificacion: json['calificacion'],
      );

  Map<String, dynamic> toJson() => {
        'id_historial': idHistorial,
        'id_usuario': idUsuario,
        'id_receta': idReceta,
        'fecha': fecha.toIso8601String(),
        'calificacion': calificacion,
      };
}
