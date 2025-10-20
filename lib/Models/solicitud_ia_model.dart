class SolicitudIaModel {
  final String idSolicitud;
  final String idUsuario;
  final String idReceta;
  final String prompt;
  final DateTime fecha;
  final String apiUsada;
  final String estado;

  SolicitudIaModel({
    required this.idSolicitud,
    required this.idUsuario,
    required this.idReceta,
    required this.prompt,
    required this.fecha,
    required this.apiUsada,
    required this.estado,
  });

  factory SolicitudIaModel.fromJson(Map<String, dynamic> json) =>
      SolicitudIaModel(
        idSolicitud: json['id_solicitud'],
        idUsuario: json['id_usuario'],
        idReceta: json['id_receta'],
        prompt: json['prompt'],
        fecha: DateTime.parse(json['fecha']),
        apiUsada: json['api_usada'],
        estado: json['estado'],
      );

  Map<String, dynamic> toJson() => {
        'id_solicitud': idSolicitud,
        'id_usuario': idUsuario,
        'id_receta': idReceta,
        'prompt': prompt,
        'fecha': fecha.toIso8601String(),
        'api_usada': apiUsada,
        'estado': estado,
      };
}
