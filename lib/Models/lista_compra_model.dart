class ListaCompraModel {
  final String idLista;
  final String idUsuario;
  final String nombre;
  final DateTime fechaCreacion;
  final String estado;

  ListaCompraModel({
    required this.idLista,
    required this.idUsuario,
    required this.nombre,
    required this.fechaCreacion,
    required this.estado,
  });

  factory ListaCompraModel.fromJson(Map<String, dynamic> json) =>
      ListaCompraModel(
        idLista: json['id_lista'],
        idUsuario: json['id_usuario'],
        nombre: json['nombre'],
        fechaCreacion: DateTime.parse(json['fecha_creacion']),
        estado: json['estado'],
      );

  Map<String, dynamic> toJson() => {
        'id_lista': idLista,
        'id_usuario': idUsuario,
        'nombre': nombre,
        'fecha_creacion': fechaCreacion.toIso8601String(),
        'estado': estado,
      };
}
