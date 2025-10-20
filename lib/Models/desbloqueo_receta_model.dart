class DesbloqueoRecetaModel {
  final String idDesbloqueo;
  final String idUsuario;
  final String idReceta;
  final String idVideo;
  final DateTime fechaDesbloqueo;
  final DateTime fechaExpiracion;
  final String tipoDesbloqueo;
  final String estado;

  DesbloqueoRecetaModel({
    required this.idDesbloqueo,
    required this.idUsuario,
    required this.idReceta,
    required this.idVideo,
    required this.fechaDesbloqueo,
    required this.fechaExpiracion,
    required this.tipoDesbloqueo,
    required this.estado,
  });

  factory DesbloqueoRecetaModel.fromJson(Map<String, dynamic> json) =>
      DesbloqueoRecetaModel(
        idDesbloqueo: json['id_desbloqueo'],
        idUsuario: json['id_usuario'],
        idReceta: json['id_receta'],
        idVideo: json['id_video'],
        fechaDesbloqueo: DateTime.parse(json['fecha_desbloqueo']),
        fechaExpiracion: DateTime.parse(json['fecha_expiracion']),
        tipoDesbloqueo: json['tipo_desbloqueo'],
        estado: json['estado'],
      );

  Map<String, dynamic> toJson() => {
        'id_desbloqueo': idDesbloqueo,
        'id_usuario': idUsuario,
        'id_receta': idReceta,
        'id_video': idVideo,
        'fecha_desbloqueo': fechaDesbloqueo.toIso8601String(),
        'fecha_expiracion': fechaExpiracion.toIso8601String(),
        'tipo_desbloqueo': tipoDesbloqueo,
        'estado': estado,
      };
}
