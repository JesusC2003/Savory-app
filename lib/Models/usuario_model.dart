class UsuarioModel {
  final String idUsuario;
  final String nombre;
  final String correo;
  final String tipoCuenta;
  final List<String>? preferenciasDieta;
  final DateTime fechaRegistro;
  final DateTime ultimoAcceso;

  UsuarioModel({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.tipoCuenta,
    this.preferenciasDieta,
    required this.fechaRegistro,
    required this.ultimoAcceso,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
        idUsuario: json['id_usuario'],
        nombre: json['nombre'],
        correo: json['correo'],
        tipoCuenta: json['tipo_cuenta'],
        preferenciasDieta: json['preferencias_dieta'] != null
            ? List<String>.from(json['preferencias_dieta'])
            : [],
        fechaRegistro: DateTime.parse(json['fecha_registro']),
        ultimoAcceso: DateTime.parse(json['ultimo_acceso']),
      );

  Map<String, dynamic> toJson() => {
        'id_usuario': idUsuario,
        'nombre': nombre,
        'correo': correo,
        'tipo_cuenta': tipoCuenta,
        'preferencias_dieta': preferenciasDieta,
        'fecha_registro': fechaRegistro.toIso8601String(),
        'ultimo_acceso': ultimoAcceso.toIso8601String(),
      };
}
