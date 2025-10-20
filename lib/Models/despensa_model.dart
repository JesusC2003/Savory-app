class DespensaModel {
  final String idDespensa;
  final String idUsuario;
  final String nombre;

  DespensaModel({
    required this.idDespensa,
    required this.idUsuario,
    required this.nombre,
  });

  factory DespensaModel.fromJson(Map<String, dynamic> json) => DespensaModel(
        idDespensa: json['id_despensa'],
        idUsuario: json['id_usuario'],
        nombre: json['nombre'],
      );

  Map<String, dynamic> toJson() => {
        'id_despensa': idDespensa,
        'id_usuario': idUsuario,
        'nombre': nombre,
      };
}
