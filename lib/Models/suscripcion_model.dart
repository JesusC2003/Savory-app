class SuscripcionModel {
  final String idSuscripcion;
  final String idUsuario;
  final String plan;
  final DateTime fechaInicio;
  final DateTime fechaExpiracion;
  final String estado;

  SuscripcionModel({
    required this.idSuscripcion,
    required this.idUsuario,
    required this.plan,
    required this.fechaInicio,
    required this.fechaExpiracion,
    required this.estado,
  });

  factory SuscripcionModel.fromJson(Map<String, dynamic> json) =>
      SuscripcionModel(
        idSuscripcion: json['id_suscripcion'],
        idUsuario: json['id_usuario'],
        plan: json['plan'],
        fechaInicio: DateTime.parse(json['fecha_inicio']),
        fechaExpiracion: DateTime.parse(json['fecha_expiracion']),
        estado: json['estado'],
      );

  Map<String, dynamic> toJson() => {
        'id_suscripcion': idSuscripcion,
        'id_usuario': idUsuario,
        'plan': plan,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'fecha_expiracion': fechaExpiracion.toIso8601String(),
        'estado': estado,
      };
}
